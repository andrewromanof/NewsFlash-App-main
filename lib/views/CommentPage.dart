/*
  CommentPage creates a page that is used to display the post (on top) and
  all the comments associated to the given post (the bottom). Also
  contains ways to edit, delete and create comments for the post
  "post" Contains the OnlinePost that is being displayed and generates
  the comment page based of variables contained within the given post
  @author Andre Alix
  @version Group Project Check-In
  @since 2022-11-11
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:groupproject/views/DatabaseEditors.dart';
import 'package:groupproject/views/HomePageTabs/OfflineDatabase/OfflineHomeScreenBuilder.dart';
import '../models/Account.dart';
import '../models/PostOnline.dart';
import 'HomePageTabs/OnlineViewMode/OnlineHomeScreenBuilder.dart';
import 'HomePageTabs/ProfilePage/ProfilePageBuilder.dart';

/*
  CommentPage creates the comment page given a OnlinePost
  "post" specific post used to generate the contents of the comment page
 */
class CommentPage extends StatefulWidget {

  CommentPage({Key? key, this.post}) : super(key: key);

  PostOnline? post;

  @override
  State<CommentPage> createState() => _CommentPageState();
}

/*
  _CommentPageState Creates the page that contains both he post itself
  and the comment section. Each of which are populated using the variables
  within the given post.
  When the page is exited the instance of the post is sent back to the HomeScreen
  and updated over the selected post to update any of the changed variables.
 */
class _CommentPageState extends State<CommentPage> {
  @override
  Widget build(BuildContext context) {

    final routeData = ModalRoute.of(context)?.settings.arguments as Map<String, Object?>;
    final CollectionReference<Map<String, dynamic>> fireBaseInstance = routeData['fireBaseInstance'] as CollectionReference<Map<String, dynamic>>;
    final loggedInAccount = routeData['user'] as Account;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: (){
            Navigator.of(context).pop();
          },
        ),
        title: const Text("Post Viewer"),
      ),

      body:StreamBuilder(
          stream: fireBaseInstance.snapshots(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              print("Data is missing from buildGradeList");
              return CircularProgressIndicator();
            }
            else {
              print("Data Loaded!");
              PostOnline post = PostOnline.fromMap(snapshot.data.docs[selectedIndex].data(), reference: snapshot.data.docs[selectedIndex].reference);
              return ListView(

                children: [

                  Container(
                    padding: EdgeInsets.all(15),
                    child: buildOnlineLongPost(post, context, selectedIndex, fireBaseInstance, loggedInAccount),
                  ),

                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12)
                    ),
                    child: Row(
                      children: [
                        const Text("Comments", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                        IconButton(
                          icon: Icon(Icons.add),
                          tooltip: "Add a comment",
                          onPressed: (){
                            goToCreateCommentPage(context, post, fireBaseInstance);
                          },
                        ),
                      ],
                    ),
                  ),

                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: post.comments?.length,
                      itemBuilder: (context, index){
                        index-1;
                        return Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)
                          ),
                          child: buildCommentSection(context, post, index, fireBaseInstance),
                        );
                      }
                  ),
                ],
              );
            }
          }
      ),

    );
  }
}

/*
  goToCreateCommentPage goes to a new page that is used to create a new comment
  once done the comment is added to the post's comment list
 */
Future<void> goToCreateCommentPage(context, post, fireBaseInstance) async{

  var newComment = await Navigator.pushNamed(context, r'/createCommentPage');
  if (newComment == null){
    print("Nothing was inputted");
  }
  else{
    post.addComment(newComment);
    updateOnlineDatabase(selectedIndex, post, fireBaseInstance);
  }
}

/*
  goToEditCommentPage goes to a new page that is used to create a new comment
  once done the comment is done it replaces the previous comment in
  the post's comment list
 */
Future<void> goToEditCommentPage(context, post, fireBaseInstance, commentIndex) async{

  var newComment = await Navigator.pushNamed(context, r'/createCommentPage');
  if (newComment == null){
    print("Nothing was inputted");
  }
  else{
    post.editComment(newComment, commentIndex);
    updateOnlineDatabase(selectedIndex, post, fireBaseInstance);
  }
}

/*
  buildCommentSection creates a widget contain a comment and
  a button used to edit or delete a comment
 */
Widget buildCommentSection(context, post, index, fireBaseInstance){

  return Container(
      padding: EdgeInsets.all(15),
      child: Row(
        children: [
          IconButton(
              onPressed: (){
                _showCommentOptions(context, post, index, fireBaseInstance);
              },
              icon: const Icon(Icons.more_vert)
          ),
          Expanded(
            child: Text(post.comments[index]),
          ),
        ],
      )
  );
}

/*
  Creates a dialog asking weather the user would like to edit
  or delete the given comment
 */
_showCommentOptions(context, post, index, fireBaseInstance){
  showDialog(
      context: context,
      builder: (context){
        return SimpleDialog(
          title: const Text("What would you like to do"),
          children: [
            SimpleDialogOption(
                onPressed: (){
                  Navigator.of(context).pop();
                  goToEditCommentPage(context, post, fireBaseInstance, index);
                },
                child: const Text("Edit Comment")
            ),
            SimpleDialogOption(
                onPressed: (){
                  Navigator.of(context).pop();
                  _showDeleteCommentDialog(context, post, index, fireBaseInstance);
                },
                child: const Text("Delete Comment")
            ),
          ],
        );
      }
  );
}

/*
  If the deleted was chosen for the previous comment than asks
  a second time if the user would like to delete the comment
 */
_showDeleteCommentDialog(context, post, index, fireBaseInstance){
  showDialog(context: context,
      barrierDismissible: false,                              //doesnt allow user to click of alert pop up
      builder: (context){
        return AlertDialog(
          title: const Text("Delete Comment"),
          content: const Text("Are you sure you would like to delete this Comment"),
          actions: [
            TextButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: Text("Cancel")
            ),
            TextButton(
                onPressed: (){
                  post.deleteComment(index);
                  updateOnlineDatabase(selectedIndex, post, fireBaseInstance);
                  Navigator.of(context).pop();
                },
                child: Text("Delete")
            )
          ],
        );
      }
  );
}