import 'dart:async';
import 'dart:io' as locker;
import 'package:adhd_journal_flutter/records_data_class_db.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' as cipher;
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen_file.dart';
import 'splash_screendart.dart';




class RecordsDB {

static late cipher.Database Databases ;
static const platform = MethodChannel('com.activitylogger.release1/ADHDJournal');


static Future<cipher.Database> db() async{


  if(userPassword != dbPassword) {
    _changeDBPasswords(dbPassword,userPassword);
  }

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
  );
}
void go() async{
  WidgetsFlutterBinding.ensureInitialized();
}

  static void start() async{
  _changeDBPasswords(await encryptedSharedPrefs.getString("dbPassword"), await encryptedSharedPrefs.getString('loginPassword'));

 // WidgetsFlutterBinding.ensureInitialized();

  }


static Future<void> _changeDBPasswords(String oldPassword, String newPassword)async {
  try{


    await platform.invokeMethod('changeDBPasswords',{'oldDBPassword': oldPassword,'newDBPassword': newPassword });
   // encryptedSharedPrefs.setString("dbPassword", newPassword);
    //encryptedSharedPrefs.reload();


  }on Exception catch(ex){
      print(ex);
  }
}

static Future<void> insertRecord(Records record) async {
  final db = await RecordsDB.db();
   await db.insert('records', record.toMapForDB(),conflictAlgorithm: ConflictAlgorithm.replace);
}

Future<Database> get database async {
  Databases = await initializeDB();
  return Databases;
}
 Future<Database> initializeDB() async{
  var ourDB = await cipher.openDatabase(join(await getDatabasesPath(), 'activitylogger_db.db'),
    password: await encryptedSharedPrefs.getString('dbPassword'),
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

static Future<void> updateRecords(Records record) async{
  final db = await RecordsDB.db();
          await db.update('records', record.toMapForDB(),where: 'id =?', whereArgs: [record.id]);
}
static Future<void> deleteRecord(int id) async{
  final db = await RecordsDB.db();
  await db.delete('records',where: 'id =?',whereArgs: [id]);

}


}



