import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/Account.dart';
import '../models/PostOnline.dart';
import 'DatabaseEditors.dart';
import 'HomePageTabs/OfflineDatabase/OfflineHomeScreenBuilder.dart';


class SignupPage extends StatefulWidget {
  SignupPage ({Key? key}) : super(key: key);

  Account? user;
  Account? loggedInUser;

  @override
  State<SignupPage > createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage > {

  var formKey = GlobalKey<FormState>();

  final fireBaseInstance = FirebaseFirestore.instance.collection('accounts');
  bool follow = true;



  @override
  Widget build(BuildContext context) {
    String enteruser ="Anonymous";
    String enterpass = "emptypassword";
    String enteremail ="emptyemail";
    return StreamBuilder(
        stream: fireBaseInstance.snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            print("Data is missing from buildGradeList");
            return CircularProgressIndicator();
          } else {


            return Scaffold(
              body: Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Username",
                          hintText: "Add a username",
                        ),
                        onChanged: (value) {
                          enteruser = value;
                        },
                      ),
                      TextFormField(
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Password",
                          hintText: "Add a password",
                        ),
                        onChanged: (value) {
                          enterpass = value;
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Email",
                          hintText: "Add a email",
                        ),
                        onChanged: (value) {
                          enteremail = value;
                        },
                      ),


                      ElevatedButton(
                          onPressed: ()=> _addAccountDp(enteruser,enterpass,enteremail) ,
                          child: const Text("Sign Up")),
                    ]
                ),
              ),
            ),
          );

          }
        });
  }

  Future _addAccountDp(u, p ,e ) async{
    print("Adding new Account...");
    final data = <String,Object?>{
      "username": u,
      "password": p,
      "email": e,
      "numposts": 0,
      "followers": 0,
      "following": 0,
      "listoffollowers": [],
      "listoffollowing": [],
    };
    await
    FirebaseFirestore.instance.collection('accounts').doc().set(data);
    setState(() {
      print("Added account: $data");
      var snackBar = const SnackBar(
          duration: Duration(seconds: 1), content: Text("Logging In..."));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Future.delayed(Duration(seconds: 1));
      var loginStatus = Navigator.pushNamed(context, r'/homePage',
          arguments: {'userName': u, 'password': p});
    });

  }
}