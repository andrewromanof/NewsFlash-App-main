/*
  HomePage creates the page that contains the different features within the app
  TabController that populates the homepage with different features depending
  on the selected tab

  "model" contains an instance of post_model used to edit the sqlite database
  "lastInsertedId" contains a integer used to determine the last used id for the sqlite database

  @author Andre Alix
  @version Group Project Check-In
  @since 2022-11-11
 */

import 'package:flutter/material.dart';
import 'package:groupproject/models/Account.dart';
import 'package:groupproject/views/HomePageTabs/PictureViewMode/PictureViewerBuilder.dart';
import 'package:groupproject/views/HomePageTabs/SearchPage/SearchPage.dart';
import 'package:groupproject/views/HomePageTabs/ProfilePage/ProfilePageBuilder.dart';
import '../app_localizations.dart';
import 'DatabaseEditors.dart';
import 'HomePageTabs/OfflineDatabase/OfflineHomeScreenBuilder.dart';
import 'HomePageTabs/OfflineDatabase/post_model.dart';
import 'HomePageTabs/OnlineViewMode/OnlineHomeScreenBuilder.dart';
import 'HomePageTabs/Polls/PollsPageBuilder.dart';

var model = PostModel();
int lastInsertedId = 0;

/*
  Creates the HomePage scaffold which contains the main UI elements
  for the app
 */
class HomePageWidget extends StatefulWidget {
  const HomePageWidget({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

/*
  Creates the DefaultTabController that allows changes the widget
  displayed in the body depending on the tab that is currently being
  selected
  "HomeScreen" tab creates a listview that contains all the posts
  found within the firebase database
  "PictureViewer" creates a gridview containing all the pictures
  found within the firebase database
  "Polls and Surveys" Work in Progress
  "Offline Viewer" tab creates a listview that contains all the posts
  found within the sqlite database
  "Profile" contains a gridview containing all of the posts that are linked
   to the current account
 */
class _HomePageWidgetState extends State<HomePageWidget> {
  @override
  void initState() {
    super.initState();
    initializeOfflineDataBase(context);
  }

  @override
  Widget build(BuildContext context) {
    final routeData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final Account loggedInAccount = Account(
        userName: routeData['userName'],
        password: routeData['password'],
        email: "",
        numposts: 0,
        followers: 0,
        following: 0);
    if (loggedInAccount.userName == "") {
      loggedInAccount.userName = "Anonymous";
    }

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title!),
          actions: [
            IconButton(
              onPressed: () {
                showAddPostDialog(context, loggedInAccount);
              },
              tooltip: "Submit your article!",
              icon: const Icon(Icons.add),
            ),
            IconButton(
                onPressed: () {
                  showSearch(
                      context: context,
                      delegate: SearchPage(loggedInUser: loggedInAccount));
                },
                icon: const Icon(Icons.search)),
            IconButton(
                onPressed: () {
                  readOfflineDatabase();
                },
                icon: Icon(Icons.data_object)),
          ],
        ),
        body:
            //SingleChildScrollView (
            //   scrollDirection: Axis.horizontal,
            //  child:
            TabBarView(
          children: [
            OnlineHomeScreen(loggedInAccount: loggedInAccount),
            PictureViewerBuilder(loggedInAccount: loggedInAccount),
            PollsPageBuilder(),
            OfflineHomeScreen(),
            ProfilePageBuilder(loggedInUser: loggedInAccount),
          ],
        ),
        //),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(color: Colors.teal),
          child: TabBar(
            tabs: [
              Tab(
                text: AppLocalizations.of(context).translate('home_tab'),
                icon: Icon(Icons.home),
              ),
              Tab(
                  text: 'picture_tab',
                  icon: Icon(Icons.photo)),
              Tab(
                  text: AppLocalizations.of(context).translate('polls_tab'),
                  icon: Icon(Icons.poll)),
              Tab(
                  text: AppLocalizations.of(context).translate('offline_tab'),
                  icon: Icon(Icons.download)),
              Tab(
                  text: AppLocalizations.of(context).translate('profile_tab'),
                  icon: Icon(Icons.account_box)),
            ],
          ),
        ),
      ),
    );
  }

  showAddPostDialog(context, loggedInAccount) {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title:
                Text(AppLocalizations.of(context).translate('add_post_dialog')),
            children: [
              SimpleDialogOption(
                  onPressed: () {
                    goToCreatePostPage(context, loggedInAccount);
                  },
                  child: Text(
                      AppLocalizations.of(context).translate('written_post'))),
              SimpleDialogOption(
                  onPressed: () {
                    goToCreatePollsPage(context);
                  },
                  child: Text(
                      AppLocalizations.of(context).translate('polls_post'))),
            ],
          );
        });
  }

  /*
   * goToCreatePostPage navigates onto to create post page and can be
   * done from any of the tabs within the HomePage navigator.
   */
  Future<void> goToCreatePostPage(context, loggedInAccount) async {
    var newPost = await Navigator.pushNamed(context, r'/createPostPage',
        arguments: ProfileArguments(loggedInAccount));
    if (newPost == null) {
      print("Nothing was inputed");
    } else {
      insertOnlineDatabase(newPost);
    }
  }

  Future<void> goToCreatePollsPage(context) async {
    var newPoll = await Navigator.pushNamed(
      context,
      r'/createNewPoll',
    );
    if (newPoll == null) {
      print("Nothing was Inputted");
    } else {
      insertPollDatabase(newPoll);
    }
  }
}
