import 'package:cloud_firestore/cloud_firestore.dart';

class Account {
  String? userName;
  String? password;
  String? email;
  int? numposts;
  int? followers;
  int? following;


  DocumentReference? reference;

  Account({ this.userName, this.password, this.email, this.numposts,this.followers, this.following });


  Account.fromMap(var map, {this.reference}){
    this.followers = map['followers'];
    this.following = map['following'];
    this.numposts = map['numposts'];
    this.email = map['email'];
    this.password = map['password'];
    this.userName = map['username'];
  }

  Map<String, Object?> toMapOnline(){
    return{
      // 'name' : this.name,
      'followers' :this.followers,
      'following':this.following,
      'numposts' :this.numposts,
      'email':this.email,
      'password':this.password,
      'username' :this.userName,
    };
  }




}

final mainaccount = Account(userName: "myusername",password: "mypassword",email: "temp@gmail.com",numposts: 0,followers: 0,following: 5 );
