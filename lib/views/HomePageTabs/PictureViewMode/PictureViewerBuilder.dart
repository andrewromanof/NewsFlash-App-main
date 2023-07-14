/*
 OnlineHomeScreen creates a gridview using snapshot instances found within the firebase
 database.
 The data in the firebase database is turned into an OnlinePost and is sent and is used
 to populate the gridview.
 @author Andre Alix
 @version Group Project Check-In
 @since 2022-11-11
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/Account.dart';
import '../../../models/PostOnline.dart';
import '../../DatabaseEditors.dart';
import '../OfflineDatabase/OfflineHomeScreenBuilder.dart';

class PictureViewerBuilder extends StatefulWidget {
  const PictureViewerBuilder({Key? key, this.loggedInAccount}) : super(key: key);

  final Account? loggedInAccount;

  @override
  State<PictureViewerBuilder> createState() => _PictureViewerBuilderState();
}

/*
  PictureViewerBuilder will create a gridview containing pictures from all the posts
  found within the online database.
  Double tapping the image will bring the up the comment page for the specific post
  similar to OnlineHomeScreenBuilder
 */
class _PictureViewerBuilderState extends State<PictureViewerBuilder> {

  final fireBaseInstance = FirebaseFirestore.instance.collection('posts');

  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
        stream: fireBaseInstance.snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            print("Data is missing from buildGradeList");
            return CircularProgressIndicator();
          }
          else {
            print("Data Loaded!");
            return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2)
                    ,
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      PostOnline post = PostOnline.fromMap(snapshot.data.docs[index].data(), reference: snapshot.data.docs[index].reference);
                      return GestureDetector(
                        onTap: (){
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        onDoubleTap: ()async{
                          setState(() {
                            selectedIndex = index;
                          });
                          var updatedPost = await Navigator.pushNamed(
                              context, '/commentPage', arguments: {
                            'fireBaseInstance': fireBaseInstance,
                            'user': widget.loggedInAccount,
                          });
                          if(updatedPost != null) {
                            updateOnlineDatabase(index, updatedPost, fireBaseInstance);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(color: selectedIndex != index ? Colors.white : Colors.black12 ),
                          padding: EdgeInsets.all(10),
                          child: Image.network(
                            "${post.imageURL}",
                            fit: BoxFit.fill,
                          ),
                        ),
                      );
                    }
                );
          }
    }
    );
    // return
  }
}

Future<void> goToCommentPage(context) async{
  var newPost = await Navigator.pushNamed(context, r'/commentPage');
}

