/*
  Contains Post Online class which is used to store the variables needed to create a post
  within the app.
  Also contains classes that are used to edit the contents within a online post
  @author Andre Alix
  @version Group Project Check-In
  @since 2022-11-11
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';


/*
  PostOnline class contains the info needed to populate an online post
  "userName" Contains the username associated to the post
  "timeString" Contains the time the post was created
  "longDescription" Contains the full version of the article
  "shortDescription" Contains a shorter version of the article
  "imageURL" Contains the online link to the photo
  "title" Contains the title of the post
  "comments" Contains the comments associated to a post
  "numReposts" Contains the amount of times a post has been reposted
  "numLikes" Contains the amount of times a post has been liked
  "numDislikes" Contains the amount of times a post has been disliked
  "DocumentReference" contains the id that corresponds to the firebase database
 */
class PostOnline{
  String? userName;
  String? timeString;
  String? longDescription;
  String? shortDescription;
  String? imageURL;
  String? title;
  List<dynamic>? comments;
  String? location;

  int? numReposts;
  int? numLikes;
  int? numDislikes;

  DocumentReference? reference;

  //Constructor to create an Online Post
  PostOnline({this.userName, this.timeString, this.longDescription, this.imageURL, this.title, this.shortDescription, this.numLikes, this.numDislikes, this.numReposts, this.comments, this.location});


  //Converts a map into a PostOnline
  PostOnline.fromMap(var map, {this.reference}){
    this.userName = map['userName'];
    this.timeString = map['timeString'];
    this.longDescription = map['longDescription'];
    this.shortDescription = map['shortDescription'];
    this.imageURL = map['imageURL'];
    this.title = map['title'];
    this.comments = map['comments'];
    this.numReposts = map['numReposts'];
    this.numLikes = map['numLikes'];
    this.numDislikes = map['numDislikes'];
    this.location = map['location'];
  }

  //Converts a PostOnline into a map
  Map<String, Object?> toMapOnline(){
    return{
      // 'name' : this.name,
      'userName' :this.userName,
      'timeString':this.timeString,
      'longDescription' :this.longDescription,
      'shortDescription':this.shortDescription,
      'imageURL':this.imageURL,
      'title' :this.title,
      'comments':this.comments,
      'numReposts' :this.numReposts,
      'numLikes':this.numLikes,
      'numDislikes':this.numDislikes,
      'location':this.location,
    };
  }

  //Adds a comment into the comment list
  void addComment(newComment){
    comments?.add(newComment);
  }

  //Deletes a comment from the comment list
  void deleteComment(commentIndex){
    comments?.removeAt(commentIndex);
  }

  //Edits a comment from the comment list
  void editComment(newComment, commentIndex){
    comments![commentIndex] = newComment;
  }

  @override
  String toString() {
    return "$shortDescription";
  }
}