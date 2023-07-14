/*
 OnlineHomeScreen creates a list of post based from the data found within the firebase
 database.
 OnlineHomeScreen will be used to view the post and interact with the post through
 the things likes likes, dislikes, reposts, etc.
 @author Andre Alix
 @version Group Project Check-In
 @since 2022-11-11
*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:groupproject/constants.dart';
import 'package:groupproject/views/HomePageTabs/OnlineViewMode/MapViewer.dart';
import 'package:groupproject/views/HomePageTabs/ProfilePage/ProfilePageBuilder.dart';
import '../../../app_localizations.dart';
import '../../../models/Account.dart';
import '../../../models/PostOffline.dart';
import '../../../models/PostOnline.dart';
import '../../DatabaseEditors.dart';
import '../../HomePage.dart';
import '../OfflineDatabase/OfflineHomeScreenBuilder.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class OnlineHomeScreen extends StatefulWidget {
  OnlineHomeScreen({Key? key, this.loggedInAccount}) : super(key: key);

  final Account? loggedInAccount;

  @override
  State<OnlineHomeScreen> createState() => _OnlineHomeScreenState();
}

/*
 OnlineHomeScreen creates a listview using snapshot instances found within the firebase
 database.
 The data in the firebase database is turned into an OnlinePost which is sent to
 separate widget creates buildlongpost and buildshort post.
 The widget has two viewing modes which will change depending on which index is currently
 being selected.
 Clicking a post will select the post, expanding it
 Double clicking an object will bring up the comment page for the post
 Holding down will unselect the post turning it back to its default view
*/
class _OnlineHomeScreenState extends State<OnlineHomeScreen> {
  final fireBaseInstance = FirebaseFirestore.instance.collection('posts');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: fireBaseInstance.snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            print("Data is missing from buildGradeList");
            return CircularProgressIndicator();
          } else {
            print("Data Loaded!");
            return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  PostOnline post = PostOnline.fromMap(
                      snapshot.data.docs[index].data(),
                      reference: snapshot.data.docs[index].reference);
                  return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                              // print("selected index $selectedIndex");
                            });
                          },
                          onLongPress: () {
                            setState(() {
                              selectedIndex = 1 ^ 1000;
                            });
                          },
                          onDoubleTap: () async {
                            setState(() {
                              selectedIndex = index;
                            });
                            var updatedPost = await Navigator.pushNamed(
                                context, '/commentPage',
                                arguments: {
                                  'fireBaseInstance': fireBaseInstance,
                                  'user': widget.loggedInAccount,
                                });
                          },
                          child: SingleChildScrollView(
                            child: Container(
                              width: 400,
                              decoration: BoxDecoration(
                                  color: selectedIndex != index
                                      ? Colors.white
                                      : Colors.black12),
                              padding: const EdgeInsets.all(15),
                              child: selectedIndex != index
                                  ? buildOnlineShortPost(post, context, index,
                                      fireBaseInstance, widget.loggedInAccount)
                                  : buildOnlineLongPost(post, context, index,
                                      fireBaseInstance, widget.loggedInAccount),
                            ),
                          )));
                });
          }
        });
  }
}

/*
* Navigates into a new page which returns a new OnlinePost which is than used
* to replace data stored within the firebase database
*/
Future<void> goToUpdatePostPage(
    context, index, fireBaseInstance, loggedInAccount) async {
  var newPost = await Navigator.pushNamed(context, r'/createPostPage',
      arguments: ProfileArguments(loggedInAccount));
  updateOnlineDatabase(index, newPost, fireBaseInstance);
}

/*
 buildOnlineLongPost is given a post which is used to display the information
 stored within the post. This will only be created when the selectedIndex
 is equal to the index of the post.
 Displays information with a larger font and displays the longDiscription
*/
Widget buildOnlineLongPost(
    post, context, index, fireBaseInstance, loggedInAccount) {
  return Column(
    children: [
      //Username and settings button
      Row(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircleAvatar(
                radius: 20,
                // changed circle avatar text to show first letter of username.(removed const from circleavatar)
                child: Text("${post.userName[0]}", textScaleFactor: 1),
              ),
              const SizedBox(width: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 250,
                    child: Text("${post.userName}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                  ),
                  IconButton(
                    onPressed: () {
                      selectedIndex = index;
                      _showPostOptions(context, index, fireBaseInstance, post,
                          loggedInAccount);
                    },
                    icon: const Icon(Icons.more_horiz),
                  ),
                ],
              )
            ],
          ),
        ],
      ),

      //time
      // Row(
      //   children: [
      //     Text("${post.timeString}",
      //         style:
      //             const TextStyle(fontStyle: FontStyle.italic, fontSize: 15)),
      //   ],
      // ),
      const SizedBox(height: 10),

      //Title
      Text(
        "${post.title}",
        style: const TextStyle(
          fontFamily: 'PlayfairDisplay',
          //fontWeight: FontWeight.bold,
          fontSize: 30,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 10),

      //Description, if it's longer than a certain amount of characters, it will make 2 columns.
      IntrinsicHeight(
          child: post.longDescription.length > 150
              ? _buildDividedPost(post)
              : _buildSinglePost(post)),
      const SizedBox(height: 20),
      Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${post.timeString}",
                style:
                    const TextStyle(fontStyle: FontStyle.italic, fontSize: 10)),
          ],
        ),
      ),

      //Image
      Container(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            "${post.imageURL}",
            fit: BoxFit.fill,
          ),
        ),
      ),
      //image section
      const SizedBox(
        height: 20,
      ),

      //likes, dislikes, etc
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.chat_bubble_outline,
              size: 20,
            ),
          ),
          Text("  ${post.comments.length}"),
          const SizedBox(width: 20),
          IconButton(
            onPressed: () {
              post.numReposts += 1;
              updateOnlineDatabase(selectedIndex, post, fireBaseInstance);
              _repost(post, loggedInAccount);
              //print("Number of Reposts: ${post.numReposts}");
            },
            icon: const Icon(Icons.repeat, size: 20),
          ),
          Text(" ${post.numReposts}"),
          const SizedBox(width: 20),
          IconButton(
            onPressed: () {
              post.numLikes += 1;
              updateOnlineDatabase(selectedIndex, post, fireBaseInstance);
              print("Number of Likes: ${post.numLikes}");
            },
            icon: const Icon(Icons.thumb_up_outlined, size: 20),
          ),
          Text("  ${post.numLikes}"),
          const SizedBox(width: 20),
          IconButton(
            onPressed: () {
              post.numDislikes += 1;
              updateOnlineDatabase(selectedIndex, post, fireBaseInstance);
              print("Number of Dislikes: ${post.numDislikes}");
            },
            icon: const Icon(Icons.thumb_down_outlined, size: 20),
          ),
          Text("  ${post.numDislikes}"),
        ],
      ),
      // user's post location
      RichText(
          text: TextSpan(
              text: "Posted from: ",
              style: TextStyle(fontSize: 15, color: Colors.black),
              children: <TextSpan>[
            TextSpan(
                text: "${post.location}",
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.blue,
                    decoration: TextDecoration.underline),
                // When tapping the blue underlined text that contains the location of where
                // the post was from, it takes you to the mapviewer page
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MapViewer(
                                  address: post.location,
                                )));
                  }),
          ])),
    ],
  );
}

/*
 buildOnlineShortPost is given a post which is used to display the information
 stored within the post. This will only be the default widget used to display
 the post and will happened if the selected index is not equal to the post's index
 Displays information with a smaller font and displays the shortDescription
*/
Widget buildOnlineShortPost(
    post, context, index, fireBaseInstance, loggedInAccount) {
  return Column(
    children: [
      //Username and settings button
      Row(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircleAvatar(
                radius: 15,
                // changed circle avatar text to show first letter of username.(removed const from circleavatar)
                child: Text("${post.userName[0]}", textScaleFactor: 1),
              ),
              const SizedBox(width: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 250,
                    child: Text("${post.userName}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                  IconButton(
                    onPressed: () {
                      selectedIndex = index;
                      _showPostOptions(context, index, fireBaseInstance, post,
                          loggedInAccount);
                    },
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              )
            ],
          ),
        ],
      ),

      //time
      // Row(
      //   children: [
      //     Text("${post.timeString}",
      //         style:
      //             const TextStyle(fontStyle: FontStyle.italic, fontSize: 10)),
      //   ],
      // ),
      const SizedBox(height: 10),

      //Title
      Text(
        "${post.title}",
        style: const TextStyle(
          fontFamily: 'PlayfairDisplay',
          //fontWeight: FontWeight.bold,
          fontSize: 25,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 10),

      //Description
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          "${post.shortDescription}",
          style: const TextStyle(
              fontSize: 15, fontStyle: FontStyle.italic, color: Colors.black54),
        ),
      ),
      // time
      Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${post.timeString}",
                style:
                    const TextStyle(fontStyle: FontStyle.italic, fontSize: 10)),
          ],
        ),
      ),
      //Image
      Container(
          child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network("${post.imageURL}"))),
      //image section
      const SizedBox(
        height: 20,
      ),
    ],
  );
}

_repost(post, loggedInAccount) {
  PostOnline newPost = PostOnline(
    userName: "${loggedInAccount?.userName} Reposting:  ${post.userName}",
    timeString: post.timeString,
    longDescription: post.longDescription,
    imageURL: post.imageURL,
    title: "Repost of: ${post.title}",
    shortDescription: post.shortDescription,
    numReposts: 0,
    numLikes: 0,
    numDislikes: 0,
    comments: [],
    location: post.location,
  );
  print("Adding repost to the database!");
  insertOnlineDatabase(newPost);
}

String _findCutOff(String text, int half) {
  int cutOffPoint = (text.length / 2).floor();
  while (text[cutOffPoint] != ' ') {
    cutOffPoint++;
  }
  if (half == 1) {
    return text.substring(0, cutOffPoint);
  }
  return text.substring(cutOffPoint);
}

/*
 _showPostOptions shows a dialog asking what the user would like to
 do with the post. They may delete, edit or save the post.
 Deleting a post will remove it from the firebase database
 Editing will prompt you to a new page where you can make anew post
 this post will replace the previous post
 Save post will add the post into the sqlite database
*/
_showPostOptions(context, index, fireBaseInstance, post, loggedInAccount) {
  showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(AppLocalizations.of(context).translate('post_dialog')),
          children: [
            SimpleDialogOption(
                onPressed: () {
                  Navigator.of(context).pop();
                  goToUpdatePostPage(
                      context, index, fireBaseInstance, loggedInAccount);
                },
                child:
                    Text(AppLocalizations.of(context).translate('edit_post'))),
            SimpleDialogOption(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showDeleteDialog(context, fireBaseInstance);
                },
                child: Text(
                    AppLocalizations.of(context).translate('delete_post'))),
            SimpleDialogOption(
                onPressed: () {
                  Navigator.of(context).pop();
                  PostOffline downloadedPost = PostOffline(
                      userName: post.userName,
                      timeString: post.timeString,
                      longDescription: post.longDescription,
                      shortDescription: post.shortDescription,
                      imageURL: post.imageURL,
                      title: post.title,
                      id: lastInsertedId + 1);
                  addOfflineDatabase(downloadedPost, context);
                },
                child:
                    Text(AppLocalizations.of(context).translate('save_post'))),
          ],
        );
      });
}

//Asks the user if they would like to delete a the post from the online database
_showDeleteDialog(context, fireBaseInstance) {
  showDialog(
      context: context,
      barrierDismissible: false, //doesn't allow user to click of alert pop up
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('delete_post')),
          content: Text(
              AppLocalizations.of(context).translate('delete_post_confirm')),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel")),
            TextButton(
                onPressed: () {
                  deleteOnlineDatabase(selectedIndex, fireBaseInstance);
                  Navigator.of(context).pop();
                },
                child: Text("Delete"))
          ],
        );
      });
}

Widget _buildDividedPost(PostOnline post) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Expanded(
        child: Container(
          //width: 150,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            _findCutOff("${post.longDescription}", 1),
            textAlign: TextAlign.justify,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
        ),
      ),
      const VerticalDivider(
        width: 3,
        thickness: 1,
        indent: 3,
        endIndent: 0,
        color: Colors.black54,
      ),
      Expanded(
        child: Container(
          //width: 150,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            _findCutOff("${post.longDescription}", 2),
            textAlign: TextAlign.justify,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _buildSinglePost(PostOnline post) {
  return Column(
    children: [
      Expanded(
        child: Container(
          //width: 150,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "${post.longDescription}",
            textAlign: TextAlign.justify,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
        ),
      ),
    ],
  );
}
