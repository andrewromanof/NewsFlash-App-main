import 'package:cloud_firestore/cloud_firestore.dart';

class Polls{
  String? userName;
  String? title;
  String? timeString;
  String? description;
  List<dynamic>? pollOptions;
  List<dynamic>? pollResults;


  DocumentReference? reference;

  Polls({this.title, this.timeString, this.description, this.pollOptions, this.pollResults, this.userName});

  Polls.fromMap(var map, {this.reference}){
    this.title = map['title'];
    this.timeString = map['timeString'];
    this.description = map['description'];
    this.pollOptions = map['pollOptions'];
    this.pollResults = map['pollResults'];
    this.userName = map['userName'];
  }

  Map<String, Object?> toMapOnline(){
    return{
      // 'name' : this.name,
      'title' :this.title,
      'timeString':this.timeString,
      'description':this.description,
      'pollOptions' :this.pollOptions,
      'pollResults' :this.pollResults,
      'userName' :this.userName
    };
  }

  String toString(){
    return "$title";
  }
}
