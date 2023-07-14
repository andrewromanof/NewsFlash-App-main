/*
  PostModel contains multiple classes uses to edit the sqlite
  database
  @author Andre Alix
  @version Group Project Check-In
  @since 2022-11-11
 */

import 'package:sqflite/sqflite.dart';
import 'dart:async';
import '../../../models/PostOffline.dart';
import 'db_utils.dart';

class PostModel {

  //adds a post to the sqlite database
  Future<int> insertPosts(PostOffline post) async{
    final db = await DBUtils.init();
    // print("model : $grade");
    // print(grade.toMap());
    return db.insert(
      'downloaded_posts_manager',
      post.toMapOffline(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //deletes a post to from the sqlite database
  Future<int> deletePostByID(int id) async{
    final db = await DBUtils.init();
    return db.delete(
      'downloaded_posts_manager',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //updates post from the sqlite database
  Future<int> updatePost(PostOffline post) async{
    final db = await DBUtils.init();
    return db.update(
      'downloaded_posts_manager',
      post.toMapOffline(),
      where: 'id = ?',
      whereArgs: [post.id],
    );
  }

  //gets all post from the sqlite database
  Future getAllPosts() async{
    final db = await DBUtils.init();
    final List maps = await db.query('downloaded_posts_manager');
    List<PostOffline> result = [];
    for (int i = 0; i < maps.length; i++){
      result.add(
          PostOffline.fromMap(maps[i])
      );
    }
    return result;
  }

}