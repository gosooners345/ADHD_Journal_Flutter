import 'dart:async';

import 'package:adhd_journal_flutter/app_start_package/login_screen_file.dart';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:flutter/services.dart';

class RecordsDB {
  static const platform =
      MethodChannel('com.activitylogger.release1/ADHDJournal');

  static final RecordsDB recordDB = RecordsDB();

  Future<Database> get database async {
    return await openOrCreateDatabase();
  }

  openOrCreateDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'activitylogger_db.db'),
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
      database.execute( "DROP TABLE IF EXISTS android_metadata; DROP TABLE IF EXISTS room_master_table; ");
        },
      singleInstance: true,
      version: 7,
    );
  }
}
