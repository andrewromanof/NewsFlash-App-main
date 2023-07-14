/*
  Contains Post Offline class and Post Offline listener which are used to create the files needed
  for the sqlite (offline database) used within the program.
  PostListBLoC is used to store a list of offline posts and used to update the listview within
  whenever a change is made to the list.
  @author Andre Alix
  @version Group Project Check-In
  @since 2022-11-11
*/
import 'package:flutter/material.dart';


/*
  PostOffline class contains the info needed to populate an offline post
  "userName" Contains the username associated to the post
  "timeString" Contains the time the post was created
  "longDescription" Contains the full version of the article
  "shortDescription" Contains a shorter version of the article
  "imageURL" Contains the online link to the photo
  "title" Contains the title of the post
  "id" Contains the id that corresponds to the sqlite database
 */
class PostOffline{

  String? userName;
  String? timeString;
  String? longDescription;
  String? shortDescription;
  String? imageURL;
  String? title;

  int? id;

  //constructor to create the an PostOffline
  PostOffline({this.userName, this.timeString, this.longDescription, this.imageURL, this.title, this.shortDescription, this.id});

  //Converts the map into a PostOffline
  Map<String, Object?> toMapOffline(){
    return{
      // 'name' : this.name,
      'userName' :this.userName,
      'timeString':this.timeString,
      'longDescription' :this.longDescription,
      'shortDescription':this.shortDescription,
      'imageURL':this.imageURL,
      'title' :this.title,
      'id':this.id,
    };
  }

  //Converts a PostOffline into a map
  PostOffline.fromMap(Map map){
    this.userName = map['userName'];
    this.timeString = map['timeString'];
    this.longDescription = map['longDescription'];
    this.shortDescription = map['shortDescription'];
    this.imageURL = map['imageURL'];
    this.title = map['title'];
    this.id = map['id'];
  }

  String toString(){
    return "$id : $userName";
  }

}

/*
  PostListBLoC contains a listener to manage the list of offline post within the app
  Multiple methods are found within to make sure that the offline tab within the app
  contains updated information found within the sqlite database
  "_posts" contains a list of posts that is used to display offline post within the app
 */
class PostsListBLoC with ChangeNotifier{

  List<PostOffline> _posts = [
    PostOffline(),
  ];

  //gets the lists of post
  List<PostOffline> get posts => _posts;

  //sets tbe list to a given list
  set posts(newPostList){
    _posts = newPostList;
    notifyListeners();
  }

  //removes a post of a given index
  removePost(index){
    _posts.removeAt(index);
    notifyListeners();
  }

  //add a given post to the list
  addPost(newPost){
    _posts.add(newPost);
    notifyListeners();
  }

}
