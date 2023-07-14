import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:groupproject/views/CommentPage.dart';
import 'package:groupproject/views/HomePage.dart';
import 'package:groupproject/views/HomePageTabs/OnlineViewMode/CreateCommentPage.dart';
import 'package:groupproject/views/HomePageTabs/Polls/CreatePollPage.dart';
import 'package:groupproject/views/HomePageTabs/Polls/ViewPollStatistics.dart';
import 'package:groupproject/views/HomePageTabs/OnlineViewMode/MakePostPage.dart';
import 'package:groupproject/views/HomePageTabs/ProfilePage/FollowerPage.dart';
import 'package:groupproject/views/HomePageTabs/ProfilePage/FollowingPage.dart';
import 'package:groupproject/views/signup.dart';
import "package:provider/provider.dart";
import 'package:groupproject/notifications.dart';
import 'package:groupproject/views/HomePageTabs/ProfilePage/EditProfilePage.dart';

import 'models/PostOffline.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_localizations.dart';

void main() {
  runApp(MultiProvider(
    child: const MyApp(),
    providers: [
      ChangeNotifierProvider(create: (value) => PostsListBLoC()),
    ],
  ));
  // runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("Error initializing Firebase");
          }
          if (snapshot.connectionState == ConnectionState.done) {
            print("Succesfully connected to Firebase");
            return MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(
                primarySwatch: Colors.teal,
              ),
              supportedLocales: [
                Locale('en', ''),
                Locale('fr', 'FR'),
                Locale('es', 'US')
              ],
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              localeResolutionCallback: (locale, supportedLocales) {
                for (var supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == locale!.languageCode &&
                      supportedLocale.countryCode == locale.countryCode) {
                    return supportedLocale;
                  }
                }

                return supportedLocales.first;
              },
              home: const LoginPage(title: 'Flutter Demo Home Page'),
              routes: {
                '/homePage': (context) => HomePageWidget(title: 'Home Page'),
                '/createPostPage': (context) => const CreatePostWidget(
                      title: "Create a Post",
                    ),
                '/commentPage': (context) => CommentPage(),
                '/createCommentPage': (context) => const CreateCommentPage(),
                '/createNewPoll': (context) => const CreatePollPage(),
                '/editprofile': (context) => EditProfilePage(),
                '/followinglist': (context) => FollowingPage(),
                '/followerlist': (context) => FollowerPage(),
              },
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final fireBaseInstance = FirebaseFirestore.instance.collection('accounts');
  final formKey = GlobalKey<FormState>();
  final notifications = Notifications();

  @override
  Widget build(BuildContext context) {
    PostsListBLoC postsListBLoC = context.watch<PostsListBLoC>();

    notifications.init();

    return Scaffold(
      body:
          buildLogin(), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> goToHomePage(userName, password) async {
    var snackBar = const SnackBar(
        duration: Duration(seconds: 1), content: Text("Logging In..."));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    await Future.delayed(Duration(seconds: 1));
    var loginStatus = await Navigator.pushNamed(context, r'/homePage',
        arguments: {'userName': userName, 'password': password});
  }

  Future<void> goToSignUpPage() async {
    await Future.delayed(Duration(seconds: 1));
    var SignUpStatus = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => SignupPage()));
  }

  void notificationNow() async {
    notifications.sendNotification("t", "body", "payload");
  }

  void notificationPeriodic() async {
    notifications.sendNotificationPeriodic("NEWSFLASH!",
        "Post an article to see what is going on in YOUR world.", "payload");
  }

  Widget buildLogin() {
    String? userName = "";
    String? password = "";

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: const Text(
            "NEWSFLASH",
            style: TextStyle(
                color: Colors.teal,
                fontSize: 30,
                fontWeight: FontWeight.w500,
                fontFamily: 'Raleway'),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text(
            AppLocalizations.of(context).translate('sign_in'),
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
        Form(
            key: formKey,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Column(children: [
                TextFormField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.teal, width: 5.0),
                          borderRadius: BorderRadius.circular(50.0)),
                      label: Text("Username"),
                      hintText: "Username"),
                  onChanged: (value) {
                    userName = value;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal),
                          borderRadius: BorderRadius.circular(50)),
                      label: Text("Password"),
                      hintText: "Password "),
                  onChanged: (value) {
                    password = value;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25))),
                    onPressed: () {
                      // notificationNow();
                      notificationPeriodic();
                      goToHomePage(userName, password);
                    },
                    child: Text(
                      AppLocalizations.of(context).translate('log_in'),
                      style: TextStyle(fontSize: 20),
                    )),
                TextButton(
                    onPressed: () {},
                    child: Text(AppLocalizations.of(context)
                        .translate('forgot_password'))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context).translate('no_account?')),
                    TextButton(
                        onPressed: goToSignUpPage, child: Text('Sign Up'))
                  ],
                )
              ]),
            )),
      ],
    );
  }
}
