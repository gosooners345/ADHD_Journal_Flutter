import 'dart:async';
import 'dart:io';

import 'package:adhd_journal_flutter/app_start_package/login_screen_file.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' as sqlCipher;
import 'package:flutter/services.dart';

class RecordsDB {
  static const platform =
      MethodChannel('com.activitylogger.release1/ADHDJournal');

  static final RecordsDB recordDB = RecordsDB._internal();
  RecordsDB._internal();
  sqlCipher.Database? _database;

  Future<sqlCipher.Database> get database async {
   // return await openOrCreateDatabase();
    if(_database == null&&_database!.isOpen){
      return _database!;
    } else {
      _database = await openOrCreateDatabase();
      return _database!;
      //return await openOrCreateDatabase();
    }

  }

  openOrCreateDatabase() async {
    return await sqlCipher.openDatabase(
      join(await sqlCipher.getDatabasesPath(), 'activitylogger_db.db'),
      password: dbPassword,
      onCreate: (database, version) {
        return database.execute(
            'CREATE TABLE records(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, title TEXT, content TEXT, emotions TEXT, sources TEXT,symptoms TEXT,rating DOUBLE, tags TEXT,success INT,time_updated INT, time_created INT, media BLOB)');
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if(oldVersion <= 6){
          await database.execute("ALTER TABLE records ADD COLUMN media BLOB;");
        }
      },
      onOpen: (database) {
        //database.execute("DROP TABLE IF EXISTS android_metadata; DROP TABLE IF EXISTS room_master_table;");
    if(Platform.isAndroid) {
      database.execute( "DROP TABLE IF EXISTS android_metadata; DROP TABLE IF EXISTS room_master_table; ");
    }
        },
      singleInstance: true,
      version: 7,
    );
  }

 closeCurrentDBInstance() async{
    if(_database!=null&&_database!.isOpen){
      await _database!.close();
      _database = null;
      print("DB: Database closed.");
          } else{
      print("DB: Database is already closed.");
    }
 }

 Future<sqlCipher.Database> replaceandReOpenDBInstance() async{
    if(kDebugMode){
      print("Closing any existing instances of Journal");
 }
    await closeCurrentDBInstance();
   _database = await openOrCreateDatabase();
   if (kDebugMode) {
     print("RecordsDB: New Journal instance opened.");
   }
return _database!;

  }

}
