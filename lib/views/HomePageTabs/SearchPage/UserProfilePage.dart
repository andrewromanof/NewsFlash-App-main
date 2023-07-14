import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/Account.dart';
import '../../../models/PostOnline.dart';
import '../../DatabaseEditors.dart';
import '../OfflineDatabase/OfflineHomeScreenBuilder.dart';

class UserProfilePage extends StatefulWidget {
  UserProfilePage({Key? key, this.user, this.loggedInUser}) : super(key: key);

  Account? user;
  Account? loggedInUser;

  @override
  State<UserProfilePage> createState() => _UserProfilePage();
}

class _UserProfilePage extends State<UserProfilePage> {
  final fireBaseInstance = FirebaseFirestore.instance.collection('posts');
  bool follow = true;

  @override
  Widget build(BuildContext context) {
      return Scaffold(
      appBar: AppBar(leading: IconButton(icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },),),
      body: StreamBuilder(
        stream: fireBaseInstance.snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            print("Data is missing from buildGradeList");
            return CircularProgressIndicator();
          } else {

            // Loads the posts that belong to the user profile that was clicked
            List<dynamic> profilePosts = [];
            for (int i = 0; i < snapshot.data.docs.length; i++){
              PostOnline post = PostOnline.fromMap(snapshot.data.docs[i].data(), reference: snapshot.data.docs[i].reference);
              widget.user!.numposts = 0;
              if(post.userName?.toLowerCase() == widget.user!.userName!.toLowerCase()){
                profilePosts.add({"post": post, "id": i});
                widget.user!.numposts = widget.user!.numposts! + 1;
              }
            }
            // Returns the header of the profile
            return Material(
              child: ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // The bolded username at the top
                          Text(
                            "${widget.user!.userName}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // The icon for a profile picture
                              Flexible(
                                  flex: 1,
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.teal,
                                    child: Text(widget.user!.userName![0] +
                                        widget.user!.userName![widget.user!.userName!.length - 1]),
                                  )),
                              // Number of posts, followers, and following the user has
                              Flexible(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      Column(
                                        children: [
                                          Text("${widget.user!.numposts}" ,style: TextStyle(fontSize: 14),),
                                          Text("Posts",style: TextStyle(fontSize: 14)),

                                        ],
                                      ),
                                      Spacer(),
                                      Column(
                                        children: [
                                          Text("${widget.user!.followers}" ,style: TextStyle(fontSize: 14)),
                                          Text("Followers",style: TextStyle(fontSize: 14)),
                                        ],
                                      ),
                                      Spacer(),
                                      Column(
                                        children: [
                                          Text("${widget.user!.following}",style: TextStyle(fontSize: 14) ),
                                          Text("Following",style: TextStyle(fontSize: 14)),
                                        ],
                                      ),
                                      Spacer(),
                                    ],
                                  )),

                            ],
                          ),
                          const SizedBox(height: 10),

                          // The follow button that allows the currently logged in user to follow / unfollow.
                          // Updates the values of the text of the button, amount of followers the profile page
                          // has and the number of following the currently logged in user has
                          ElevatedButton.icon(
                            onPressed: () async {
                              if (follow) {
                                setState(() {
                                  widget.user!.followers = widget.user!.followers! + 1;
                                  widget.loggedInUser!.following = widget.loggedInUser!.following! + 1;
                                  follow = !follow;
                                });
                              }
                              else {
                                setState(() {
                                  widget.user!.followers = widget.user!.followers! - 1;
                                  widget.loggedInUser!.following = widget.loggedInUser!.following! - 1;
                                  follow = !follow;
                                });
                              }
                            },
                            label: follow ? Text('Follow') : Text('Unfollow'),
                            icon: Icon(Icons.follow_the_signs, size: 24.0,),
                          ),
                          const SizedBox(height: 20),

                          // Builds the posts that the user has made
                          GridView.builder(
                              shrinkWrap: true,
                              physics: const ScrollPhysics(),
                              gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                              itemCount: profilePosts.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = profilePosts[index]['id'];
                                      print(selectedIndex);
                                    });
                                  },
                                  onDoubleTap: () async {
                                    setState(() {
                                      selectedIndex = profilePosts[index]['id'];
                                      print(selectedIndex);
                                    });
                                    var updatedPost = await Navigator.pushNamed(
                                        context, '/commentPage',
                                        arguments: {'fireBaseInstance': fireBaseInstance
                                        });
                                    if(updatedPost != null) {
                                      updateOnlineDatabase(
                                          profilePosts[index]['id'], updatedPost,
                                          fireBaseInstance);
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: selectedIndex != profilePosts[index]['id']
                                            ? Colors.white
                                            : Colors.black12),
                                    padding: EdgeInsets.all(10),
                                    child: Image.network(
                                      "${profilePosts[index]['post'].imageURL}",
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                );
                              })
                        ]),
                  ),
                ],
              ),
            );

          }
        }));
  }
}