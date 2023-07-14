import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:groupproject/views/HomePageTabs/SearchPage/UserProfilePage.dart';
import '../../../models/Account.dart';
import 'package:http/http.dart' as http;

class SearchPage extends SearchDelegate {
  SearchPage({@required this.loggedInUser});
  final loggedInUser;

  Set<Account> Accounts = {};
  Set<String> Users = {};
  Set<String> searchTerms = {};

  // Function to get the search terms that will show up in the search bar
  // or in other words, the usernames of accounts
  Future<Set<String>> getsearchTerms() async {
    searchTerms.clear();

    // JSON file that stores some sample user accounts for functionality testing purposes
    var response = await http.get(Uri.parse('https://api.json-generator.com/templates/kxOSQepYhNiQ/data?access_token=2c20vp5dg2ugdoko5g1xodm0ib87mhoaykv9cn2c'));
    if (response.statusCode == 200) {
      // Decodes from JSON to list
      List items = jsonDecode(response.body);
      for (var item in items) {
        // Takes info from the list and builds it into class / list
        Users.add(item['username']);
        Accounts.add(Account(userName: item['username'], password: item['password'],
        email: item['email'], numposts: 0, followers: item['followers'], following: item['following']));
      }
    }

    for (var account in Users) {
      // If the logged in user isn't in the JSON file since you shouldn't need to search for yourself
      if (!(loggedInUser.userName.toLowerCase == account)) {
        searchTerms.add(account);
      }
    }

    return searchTerms;
  }

  // Function that builds the clear searchbar and accounts for the current text in the searchbar
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  // Function that builds the button that allows the user to exit out of the searchbar
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  // Function that builds the results of the searchbar on the initial load
  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
      future: getsearchTerms(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var result = snapshot.data!.elementAt(index);
                // If user / element is clicked, it brings to their user profile page
                return GestureDetector(onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserProfilePage(
                              user: Accounts.elementAt(index),
                              loggedInUser: loggedInUser,
                    )
                    ));
                },
                child: ListTile(
                  title: Text(result),
                ),
                );
              },
            );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      });
  }

  // Function that builds the results of the searchbar after something has been typed for suggestions
  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: getsearchTerms(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          List<String> matchQuery = [];
          for (var user in snapshot.data!) {
            if (user.toLowerCase().contains(query.toLowerCase())) {
              matchQuery.add(user);
            }
          }
          return ListView.builder(
            itemCount: matchQuery.length,
            itemBuilder: (context, index) {
              var result = matchQuery[index];
              // If user / element is clicked, it brings to their user profile page
              return GestureDetector(onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserProfilePage(
                              user: Accounts.elementAt(index),
                              loggedInUser: loggedInUser,
                    )
                    ));
              },
              child: ListTile(
                title: Text(result),
              ),
              );
            },
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      });
  }

}