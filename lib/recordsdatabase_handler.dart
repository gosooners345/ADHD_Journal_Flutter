import 'dart:async';
import 'dart:io';
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
  static late cipher.Database Databases;
  static const platform =
      MethodChannel('com.activitylogger.release1/ADHDJournal');


  void go() async {
    WidgetsFlutterBinding.ensureInitialized();
  }


/// Unsure why this method needed to be called. Look into deleting later.
  ///
  void changePasswords() async {
    _changeDBPassword(dbPassword, userPassword);
  }
/// similar reason.
  void startRecords() async {
    recordHolder = await getRecords();
  }





/// Change user password when called
  /// Tested and Passed: 05/09/2022

  Future<void> _changeDBPassword(String oldPassword, String newPassword) async {
    try {
      await platform.invokeMethod('changeDBPasswords',
          {'oldDBPassword': oldPassword, 'newDBPassword': newPassword});
    }

    on Exception catch (ex) {
      print(ex);
    }
  }
/// Insert Records into the database
  /// Tested and Passed: 05/09/2022
  Future<int> insertRecords(Records record) async {
    final db = await RecordsDB().database;
     return await db.insert('records', record.toMapForDB(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<Database> get database async {
    Databases = await initializeDB(false);
    return Databases;
  }
/// Load the Database into the application
  /// Edit : 5/10/2022 - removed an unnecessary variable from the code to make it concise
   /// Tested and Passed: 05/09/2022
  Future<Database> initializeDB(bool isCalledFromSettings) async {
  /// To be safe, I set the password here in case
    if (isCalledFromSettings) {
      dbPassword = userPassword;
      await encryptedSharedPrefs.setString('dbPassword', dbPassword);
    }

    return  await cipher.openDatabase(
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
      singleInstance: false,
      version: 5,
    );

  }

/// Load the results from the initialize DB method into a list for the records to load

  Future<List<Records>> getRecords() async {
    final database = await RecordsDB().database;
    final List<Map<String, dynamic>> maps = await database.query('records');
    return List.generate(maps.length, (index) {
      return Records(
          id: maps[index]['id'],
          title: maps[index]['title'],
          content: maps[index]['content'],
          emotions: maps[index]['emotions'],
          sources: maps[index]['sources'],
          rating: maps[index]['rating'],
          symptoms: maps[index]['symptoms'],
          tags: maps[index]['tags'],
          success: maps[index]['success'] == 0 ? false : true,
          timeCreated:
              DateTime.fromMillisecondsSinceEpoch(maps[index]['time_created']),
          timeUpdated:
              DateTime.fromMillisecondsSinceEpoch(maps[index]['time_updated']));
    });
  }
/// This was to avoid having to use await in the settings part of the main dart class file
  void getDBLoaded(bool settingsCalled) async {
      recdatabase = await initializeDB(settingsCalled);
  }
/// Update an existing record
   /// Tested and Passed: 05/09/2022
  Future<int> updateRecord(Records record) async {
    final db = await RecordsDB().database;
    return await db.update('records', record.toMapForDB(),
        where: 'id =?', whereArgs: [record.id]);
  }
/// Deletes an existing record
  /// Tested and Passed: 05/09/2022
  Future<void> deleteRecord(int id) async {
    final db = await RecordsDB().database;
    await db.delete('records', where: 'id =?', whereArgs: [id]);
  }


}
