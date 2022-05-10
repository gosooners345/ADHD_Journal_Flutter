import 'dart:async';
import 'package:adhd_journal_flutter/login_screen_file.dart';
import 'package:adhd_journal_flutter/records_data_class_db.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'login_screen_file.dart';
import 'package:flutter/services.dart';
import 'splash_screendart.dart';

class RecordsDB {
  static late Database Databases;
  static const platform =
      MethodChannel('com.activitylogger.release1/ADHDJournal');

  void changePasswords() async {
    _changeDBPassword(dbPassword, userPassword);
  }



/// Change user password when called
  /// Tested and Passed: 05/09/2022

  Future<void> _changeDBPassword(String oldPassword, String newPassword) async {
    try {
      await platform.invokeMethod('changeDBPasswords',
          {'oldDBPassword': oldPassword, 'newDBPassword': newPassword});
      dbPassword=newPassword;
      await encryptedSharedPrefs.setString('dbPassword', newPassword);
    }

    on Exception catch (ex) {
      if(kDebugMode){
        print(ex);
      }


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
    Databases = await initializeDB();
    return Databases;
  }
/// Load the Database into the application
  /// Edit : 5/10/2022 - removed an unnecessary variable from the code to make it concise
   /// Tested and Passed: 05/09/2022
  Future<Database> initializeDB() async {
// Open the database with the given variables loaded and stored.
    return  await openDatabase(
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

/// Returns a list of records for the application

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
  void getDBLoaded() async {
      recdatabase = await initializeDB();
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
