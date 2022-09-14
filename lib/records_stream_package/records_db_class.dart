import 'dart:async';
import 'dart:io';

import 'package:adhd_journal_flutter/app_start_package/login_screen_file.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:flutter/services.dart';
import 'package:adhd_journal_flutter/app_start_package/splash_screendart.dart';

class RecordsDB {
  static const platform =
      MethodChannel('com.activitylogger.release1/ADHDJournal');

  /// Remains here because it can be called from other methods
  void changePasswords() async {
    _changeDBPassword(dbPassword, userPassword);
  }

  static final RecordsDB recordDB = RecordsDB();

  Future<Database> get database async {
    return await openOrCreateDatabase();
  }

  openOrCreateDatabase() async {
    dbLocation = join(await getDatabasesPath(),'activitylogger_db.db');
    return await openDatabase(
      join(await getDatabasesPath(), 'activitylogger_db.db'),
      password: dbPassword,
      onCreate: (database, version) {
        return database.execute(
            'CREATE TABLE records(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, title TEXT, content TEXT, emotions TEXT, sources TEXT,symptoms TEXT,rating DOUBLE, tags TEXT,success INT,time_updated INT, time_created INT)');
      },
      onOpen: (database) {
        database.execute(
            "DROP TABLE IF EXISTS android_metadata; DROP TABLE IF EXISTS room_master_table;");
      },
      singleInstance: true,
      version: 5,
    );
  }

  Future<void> _changeDBPassword(String oldPassword, String newPassword) async {
    try {

      await platform.invokeMethod('changeDBPasswords',
          {'oldDBPassword': oldPassword, 'newDBPassword': newPassword});
      dbPassword = newPassword;
      await encryptedSharedPrefs.setString('dbPassword', newPassword);
    } on Exception catch (ex) {
      if (kDebugMode) {
        print(ex);
      }
    }
  }
}

String dbLocation = "";