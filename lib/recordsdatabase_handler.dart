import 'dart:async';
import 'dart:io' as locker;
import 'package:adhd_journal_flutter/records_data_class_db.dart';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' as cipher;
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';




class RecordsDB {

static late cipher.Database _database ;
static const platform = MethodChannel('com.activitylogger.release1/ADHDJournal');


static Future<cipher.Database> db() async{
  final sharedPrefs = await SharedPreferences.getInstance();
  String? dbPassword = sharedPrefs.getString('dbPassword');
  if( dbPassword == '') {
    dbPassword = '1234';
    sharedPrefs.setString('dbPassword', dbPassword);
  }
  String? newPassword = sharedPrefs.getString('loginPassword');
  if(newPassword != dbPassword) {
    _changeDBPasswords();
  }

  return cipher.openDatabase(join(await getDatabasesPath(), 'activitylogger_db.db'),
    password: dbPassword,
    onCreate: (database, version) {
      return database.execute(
          'CREATE TABLE records(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, title TEXT, content TEXT, emotions TEXT)');
    },

    version: 2,
  );
}

  void start() async{
  WidgetsFlutterBinding.ensureInitialized();

  }


static Future<void> _changeDBPasswords()async {
  try{
    await platform.invokeMethod('changeDBPasswords');

 //   final int results = await platform.invokeMethod('changeDBPasswords');
  }on Exception catch(ex){
    print(ex);
  }
}

static Future<void> insertRecord(Records record) async {
  final db = await RecordsDB.db();
   await db.insert('records', record.toMapForDB(),conflictAlgorithm: ConflictAlgorithm.replace);
//   return record.id;
}

Future<Database> get database async {
  _database = await initializeDB();
  return _database;
}
 Future<Database> initializeDB() async{
  var ourDB = await cipher.openDatabase(join(await getDatabasesPath(), 'activitylogger_db.db'),
    password: '1234',
    onCreate: (database, version) {
      return database.execute(
          'CREATE TABLE records(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, title TEXT, content TEXT)');
    },
    version: 2,
  );
  return ourDB;
}

static Future<List<Records>> records() async{
  final db = await RecordsDB.db();

  final List<Map<String, dynamic>> maps = await db.query('records');
  return List.generate(maps.length, (index) {
    return Records(id :maps[index]['id'], title: maps[index]['title'], content: maps[index]['content'],emotions:maps[index]['emotions'] /*rating: maps[index]['rating'],
      tags: maps[index]['tags'], success: maps[index]['success'], sources: maps[index]['sources'], symptoms: maps[index]['symptoms'], ,*/
    );
  }
  );
}
static Future<void> updateRecords(Records record) async{
  final db = await RecordsDB.db();
          await db.update('records', record.toMapForDB(),where: 'id =?', whereArgs: [record.id]);
  //return result;
}
static Future<void> deleteRecord(int id) async{
  final db = await RecordsDB.db();
  await db.delete('records',where: 'id =?',whereArgs: [id]);

}


}



