/*
  db_utils contains the code needed to setup an sqlite database
  within the phone
  @author Andre Alix
  @version Group Project Check-In
  @since 2022-11-11
 */

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

/*
  DBUtils create the template for the database and the name
  for the offline database "downloaded_posts_manager.db"
 */
class DBUtils{
  static Future init() async{
    //set up the database
    var database = openDatabase(
      path.join(await getDatabasesPath(), 'downloaded_posts_manager.db'),
      onCreate: (db, version){
        db.execute(
            'CREATE TABLE downloaded_posts_manager(id INTEGER PRIMARY KEY, userName TEXT, timeString TEXT, longDescription TEXT, shortDescription TEXT, imageURL TEXT, title TEXT)'
        );
      },
      version: 1,
    );

    print("Created DB $database");
    return database;
  }
}