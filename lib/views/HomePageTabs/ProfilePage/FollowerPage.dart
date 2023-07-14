//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:groupproject/models/Polls.dart';
import 'package:groupproject/views/HomePageTabs/ProfilePage/ProfilePageBuilder.dart';

import '../../../models/Account.dart';

class FollowerPage extends StatefulWidget {
  FollowerPage({Key? key}) : super(key: key);

  @override
  State<FollowerPage> createState() => _FollowerPageState();
}

var followerlist = [
  "followeruser1",
  "followeruser2",
  "followeruser3",
  "followeruser4",
  "followeruser5",
];

class _FollowerPageState extends State<FollowerPage> {
  var formKey = GlobalKey<FormState>();

  //Function that displays accounts that follow user
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ProfileArguments;
    final fireBaseInstance = FirebaseFirestore.instance.collection('accounts');

    return StreamBuilder(
        stream: fireBaseInstance.snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          print("Data is missing from buildGradeList");
          return CircularProgressIndicator();
        } else {
          var li = [];
          for (int i = 0; i < snapshot.data.docs.length; i++) {
            if (snapshot.data.docs[0].data()["username"].toLowerCase() ==
                args.loggedInUser!.userName!.toLowerCase()) {
              li = snapshot.data.docs[0].data()["listoffollowers"];
            }
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text("Follower List"),
            ),
            body: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                for (int i = 0; i < li.length; i++) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(li[i], style: TextStyle(fontSize: 20)),
                      IconButton(
                          icon: Icon(
                            Icons.delete,
                            size: 20,
                          ),
                          onPressed: () => {
                                deleteuser(li, i),
                                args.loggedInUser?.followers = li.length,
                                Navigator.of(context).pop(),
                              })
                    ],
                  ),
                ],
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  label: Text('exit'),
                  icon: Icon(
                    Icons.exit_to_app,
                    size: 24.0,
                  ),
                ),
              ],
            ),
          );}
        });
  }

//Function that removes a user from their follower list
}

deleteuser(li, index) async {
  li.removeAt(index);
  //print(index);
  //print(followerlist);
}
