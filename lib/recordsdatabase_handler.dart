import 'dart:async';
import 'package:adhd_journal_flutter/records_data_class_db.dart';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

late Database db;


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
   db = await openDatabase(join(await getDatabasesPath(),'activitylogger_db.db'),
      password: '1234',
onCreate: (database,version){
    return database.execute('CREATE TABLE records(id INTEGER PRIMARY KEY, title TEXT, content TEXT)');

  },
     version: 1,

  );

}


Future<void> insertRecord(Records record) async {
   await db.insert('records', record.toMap(),conflictAlgorithm: ConflictAlgorithm.replace);
}
Future<List<Records>> records() async{
  final List<Map<String, dynamic>> maps = await db.query('records');
  return List.generate(maps.length, (index) {
    return Records(id: maps[index]['id'], title: maps[index]['title'], content: maps[index]['content']);
  }
  );
}
Future<void> updateRecords(Records record) async{
  await db.update('records', record.toMap(),where: 'id =?', whereArgs: [record.id]);
}
Future<void > deleteRecord(int id) async{
  await db.delete('records',where: 'id =?',whereArgs: [id]);
}