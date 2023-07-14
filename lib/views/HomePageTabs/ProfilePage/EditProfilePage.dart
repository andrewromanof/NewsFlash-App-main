//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:groupproject/models/Polls.dart';
import 'package:groupproject/views/HomePageTabs/ProfilePage/ProfilePageBuilder.dart';

import '../../../models/Account.dart';


class EditProfilePage extends StatefulWidget {


  EditProfilePage({Key? key}) : super(key: key);



  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  var formKey = GlobalKey<FormState>();
  

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ProfileArguments;

    String? username1 = args.loggedInUser?.userName;
    String? password1 = args.loggedInUser?.password;

    //final un = args.username;
    //final pw = args.password;
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile"),),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Current Username: ${args.loggedInUser?.userName}"),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Username",
                    hintText: "Change your username",
                  ),
                  onChanged: (value) {
                    username1 = value;
                  },
                ),
                Text("Current Password: ${args.loggedInUser?.password}"),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Password",
                    hintText: "Change your password",
                  ),
                  onChanged: (value) {
                    password1 = value;
                  },
                ),


                ElevatedButton(
                    onPressed: () async{
                        setState(() {
                          args.loggedInUser?.userName = username1;
                          args.loggedInUser?.password = password1;

                        });
                        Navigator.of(context).pop();


                    },
                    child: const Text("Edit Profile")),
              ]
          ),
        ),
      ),
    );
  }



}
