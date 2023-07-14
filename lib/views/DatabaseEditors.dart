/*
  DataBaseEditors contains multiple classes used to modify both the online
  and offline databases associated to the app.
  @author Andre Alix
  @version Group Project Check-In
  @since 2022-11-11
 */
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:groupproject/models/Polls.dart';
import 'package:provider/provider.dart';
import '../models/PostOffline.dart';
import '../models/PostOnline.dart';
import 'HomePage.dart';

Future updatePollDatabase(selectedIndex, updatedPost, fireBaseInstance) async{
  QuerySnapshot querySnapshot = await fireBaseInstance.get();
  PostOnline post =  PostOnline.fromMap(querySnapshot.docs[selectedIndex].data(), reference: querySnapshot.docs[selectedIndex].reference);
  await FirebaseFirestore.instance.collection('polls').doc(post.reference?.id.toString()).set(updatedPost.toMapOnline());
}

Future insertPollDatabase(newPolls) async{
  await FirebaseFirestore.instance.collection('polls').doc().set(newPolls.toMapOnline());
}

Future deletePollDatabase(selectedIndex, fireBaseInstance) async{
  QuerySnapshot querySnapshot = await fireBaseInstance.get();
  Polls poll = Polls.fromMap(querySnapshot.docs[selectedIndex].data(), reference: querySnapshot.docs[selectedIndex].reference);

  poll.reference!.delete();
}

// insertOnlineDatabase adds a new post to the firebase database
Future insertOnlineDatabase(newPost) async{
  await FirebaseFirestore.instance.collection('posts').doc().set(newPost.toMapOnline());
}

// updateOnlineDatabase updates a post within the firebase database
Future updateOnlineDatabase(selectedIndex, updatedPost, fireBaseInstance) async{
  QuerySnapshot querySnapshot = await fireBaseInstance.get();
  PostOnline post =  PostOnline.fromMap(querySnapshot.docs[selectedIndex].data(), reference: querySnapshot.docs[selectedIndex].reference);
  await FirebaseFirestore.instance.collection('posts').doc(post.reference?.id.toString()).set(updatedPost.toMapOnline());
}

// deleteOnlineDatabase deletes a post within the firebase database
Future deleteOnlineDatabase(selectedIndex, fireBaseInstance) async{
  QuerySnapshot querySnapshot = await fireBaseInstance.get();
  PostOnline post = PostOnline.fromMap(querySnapshot.docs[selectedIndex].data(), reference: querySnapshot.docs[selectedIndex].reference);

  post.reference!.delete();
}

/*
  Populates the PostsListBLoC listener with the contents of the
  sqlite offline database.
  Also updates the lastInsertedId to the highest found id within the
  offline database.
 */
Future initializeOfflineDataBase(context) async{
  PostsListBLoC postsListBLoC = Provider.of<PostsListBLoC>(context, listen: false);
  List posts = await model.getAllPosts();
  postsListBLoC.posts = posts as List<PostOffline>;

  try {
    print("Loading saved offline database!");
    lastInsertedId = posts[posts.length - 1].id!;
  }
  catch(RangeError){
    print("No offline database currently found!");
    lastInsertedId = 0;
  }

}

// deleteOfflineDatabase deletes a PostOffline from the sqlite database
void deleteOfflineDatabase(int selectedIndex, context){
  PostsListBLoC postsListBLoC = Provider.of<PostsListBLoC>(context, listen: false);

  model.deletePostByID(postsListBLoC.posts[selectedIndex].id!);
  postsListBLoC.removePost(selectedIndex);

}

// readOfflineDatabase prints out the contents of the sqlite database
Future readOfflineDatabase()  async{
  List posts = await model.getAllPosts();
  print("Post Offline Database:");
  for (PostOffline post in posts){
    print(post);
  }
}

// addOfflineDatabase adds a PostOffline to the sqlite database
Future addOfflineDatabase(PostOffline post, context) async{
  PostsListBLoC postsListBLoC = Provider.of<PostsListBLoC>(context, listen: false);
  lastInsertedId = await model.insertPosts(post);
  postsListBLoC.addPost(post);
  print("Post Inserted to offline database: ${post.toString()}");
}