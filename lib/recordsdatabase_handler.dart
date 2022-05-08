import 'dart:async';
import 'dart:io' as locker;
import 'package:adhd_journal_flutter/login_screen_file.dart';
import 'package:adhd_journal_flutter/main.dart';
import 'package:adhd_journal_flutter/records_data_class_db.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' as cipher;
import 'login_screen_file.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splash_screendart.dart';




class RecordsDB {

static late cipher.Database Databases ;
static const platform = MethodChannel('com.activitylogger.release1/ADHDJournal');


/*static Future<cipher.Database> db() async{
//dbPassword="1234";
  if(userPassword != dbPassword) {
    _changeDBPasswords(dbPassword,userPassword);

  }
try{
  return cipher.openDatabase(join(await getDatabasesPath(), 'activitylogger_db.db'),
    password: dbPassword,
    onCreate: (database, version) {
      return database.execute(
          'CREATE TABLE records(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, title TEXT, content TEXT, emotions TEXT, sources TEXT,symptoms TEXT,rating DOUBLE, tags TEXT,success INT, time_created INT, time_updated INT)');
    },
    onOpen: (database) {
    database.execute("DROP TABLE IF EXISTS android_metadata; DROP TABLE IF EXISTS room_master_table;");
    },

    version: 5,
  );}
  on Exception catch(ex){
    print(ex);
    throw Exception(ex);
  }
}*/
void go() async{
  WidgetsFlutterBinding.ensureInitialized();
}

void changePasswords()async{

  _changeDBPassword(dbPassword,userPassword );
}
void startRecords() async {
  recordHolder = await getRecords();
}




Future<void> _changeDBPassword(String oldPassword, String newPassword)async {
  try{


    await platform.invokeMethod('changeDBPasswords',{'oldDBPassword': oldPassword,'newDBPassword': newPassword });
    encryptedSharedPrefs.setString('dbPassword', userPassword);




  }on Exception catch(ex){
    print(ex);
  }
}


Future<void> insertRecords(Records record) async {
  final db = await RecordsDB().database;
  await db.insert('records', record.toMapForDB(),conflictAlgorithm: ConflictAlgorithm.replace);
}


Future<Database> get database async {
  Databases = await initializeDB();
  return Databases;
}
 Future<Database> initializeDB() async{

   if(userPassword != dbPassword) {
     _changeDBPassword(dbPassword,userPassword);
     dbPassword = userPassword;
   }

  var ourDB = await cipher.openDatabase(join(await getDatabasesPath(), 'activitylogger_db.db'),
    password: dbPassword,
    onCreate: (database, version) {
      return database.execute(
          'CREATE TABLE records(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, title TEXT, content TEXT, emotions TEXT, sources TEXT,symptoms TEXT,rating DOUBLE, tags TEXT,success INT,time_updated INT, time_created INT)'
              );

    },
    onOpen: (database) {
      database.execute("DROP TABLE IF EXISTS android_metadata; DROP TABLE IF EXISTS room_master_table;");
    },


    version: 5,
  );
  return ourDB;
}

Future<List<Records>> getRecords() async{
  final database = await RecordsDB().database;
  final List<Map<String, dynamic>> maps = await database.query('records');
  return List.generate(maps.length, (index) {
    return Records(id: maps[index]['id'],
      title: maps[index]['title'],
      content: maps[index]['content'],
      emotions: maps[index]['emotions'],
      sources: maps[index]['sources'],
      rating: maps[index]['rating'],
      symptoms: maps[index]['symptoms'],
      tags: maps[index]['tags'],
      success: maps[index]['success'] == 0 ? false : true,
      timeCreated: DateTime.fromMillisecondsSinceEpoch(
          maps[index]['time_created']),
      timeUpdated: DateTime.fromMillisecondsSinceEpoch(
          maps[index]['time_updated'])
    );});}

void getDBLoaded() async{
  recdatabase = await this.initializeDB();
}

/*
static Future<List<Records>> records() async{
  final db = await RecordsDB.db();

  final List<Map<String, dynamic>> maps = await db.query('records');
  return List.generate(maps.length, (index) {
    return Records(id :maps[index]['id'], title: maps[index]['title'], content: maps[index]['content'],emotions:maps[index]['emotions'],
        sources: maps[index]['sources'], rating: maps[index]['rating'],symptoms: maps[index]['symptoms'],
      tags: maps[index]['tags'], success: maps[index]['success'] == 0 ? false : true,
timeCreated:DateTime.fromMillisecondsSinceEpoch( maps[index]['time_created']),
      timeUpdated: DateTime.fromMillisecondsSinceEpoch( maps[index]['time_updated']),
    );
  }
  );
}
*/

/*static Future<void> updateRecords(Records record) async{
  final db = await RecordsDB.db();
          await db.update('records', record.toMapForDB(),where: 'id =?', whereArgs: [record.id]);
}*/
 Future<void> updateRecord(Records record) async{
  final db = await RecordsDB().database;
  await db.update('records', record.toMapForDB(),where: 'id =?', whereArgs: [record.id]);
}
 Future<void> deleteRecord(int id) async{
  final db = await RecordsDB().database;
  await db.delete('records',where: 'id =?',whereArgs: [id]);

}


}



