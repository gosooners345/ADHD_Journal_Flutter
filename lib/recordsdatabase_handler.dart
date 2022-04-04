import 'dart:async';

import 'dart:io' as locker;
import 'package:adhd_journal_flutter/records_data_class_db.dart';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' as cipher;
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart';
import 'settings.dart';




class RecordsDB {

  static final EncryptedSharedPreferences encryptedSharedPreferences =
  EncryptedSharedPreferences();


static Future<cipher.Database> db() async{
 String path =join(await getDatabasesPath(), 'activitylogger_db.db');
  String oldDBPassword =  await encryptedSharedPreferences.getString(dbPasswordKey);
  String newDBPassword =  await encryptedSharedPreferences.getString(loginPasswordKey);
  if (oldDBPassword == '')
    {
      oldDBPassword = '1234';
      encryptedSharedPreferences.setString(dbPasswordKey, oldDBPassword);
    }
  //late SqlCipherOpenDatabaseOptions openDB1;
/* if(oldDBPassword != newDBPassword){

var openDB = cipher.openDatabase(path,version: 3,
  onCreate: (database, version) {
    return database.execute(
        'CREATE TABLE records(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
            'title TEXT, content TEXT, emotions TEXT sources TEXT )');
  },
  onUpgrade: (db, oldVersion, newVersion) async{
    var batch = db.batch();
    if(oldVersion==2){
      _upgradeFromV2to3(batch);
    }
    await batch.commit();

  },
  password: oldDBPassword
);
var db = await openDB;
var newDB = locker.File.fromUri(Uri(path: path)).create(recursive: false);
db.close();



 }*/


  return cipher.openDatabase(path,
    password: oldDBPassword,
    onCreate: (database, version) {
      return database.execute(
          'CREATE TABLE records(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, title TEXT, content TEXT, emotions TEXT sources TEXT )');
    },
    onUpgrade: (db, oldVersion, newVersion) async{
      var batch = db.batch();
      if(oldVersion==2){
        _upgradeFromV2to3(batch);
      }
      await batch.commit();

    },
    onConfigure: (db){

    },

    version: 3,
  );
}

static void _upgradeFromV2to3(Batch batch){
  batch.execute('ALTER TABLE records ADD sources TEXT');
}

  void start() async{
  WidgetsFlutterBinding.ensureInitialized();

  }

static Future<int> insertRecord(Records record) async {
  final db = await RecordsDB.db();
   await db.insert('records', record.toMapForDB(),conflictAlgorithm: ConflictAlgorithm.replace);
   return record.id;
}
static Future<List<Records>> records() async{
  final db = await RecordsDB.db();

  final List<Map<String, dynamic>> maps = await db.query('records');
  return List.generate(maps.length, (index) {
    return Records(id :maps[index]['id'], title: maps[index]['title'], content: maps[index]['content'],emotions:maps[index]['emotions'],
    sources: maps[index]['sources'],
      /*rating: maps[index]['rating'],
      tags: maps[index]['tags'], success: maps[index]['success'],  symptoms: maps[index]['symptoms'], ,*/
    );
  }
  );
}
static Future<int> updateRecords(Records record) async{
  final db = await RecordsDB.db();
  final result = await db.update('records', record.toMapForDB(),where: 'id =?', whereArgs: [record.id]);
  return result;
}
static Future<int> deleteRecord(int id) async{
  final db = await RecordsDB.db();
  return await db.delete('records',where: 'id =?',whereArgs: [id]);

}


}



