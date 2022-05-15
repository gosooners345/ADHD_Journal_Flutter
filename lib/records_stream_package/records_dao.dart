import 'dart:async';
import 'package:sqflite_sqlcipher/sqflite.dart';

import 'records_db_class.dart';
import 'package:adhd_journal_flutter/records_data_class_db.dart';



class RecordsDao{
  final RecordsDB recordsDB = RecordsDB.recordDB;

  //Add Records
    createRecords(Records record) async {
    final db = await recordsDB.database;
    await db.insert('records', record.toMapForDB(),conflictAlgorithm: ConflictAlgorithm.replace);
    await db.batch().commit();
   // return result;
  }

  //Get all records
Future<List<Records>> getRecords() async {
  final database = await recordsDB.database;
  final List<Map<String, dynamic>> maps = await database.query('records');
  var list = List.generate(maps.length, (index) {
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
  },growable: true);
  list.sort((a,b)=>a.compareTo(b));
  return list;
}

 updateRecords(Records record) async{
  final db = await recordsDB.database;

   await db.update('records', record.toMapForDB(),
      where: 'id =?', whereArgs: [record.id]);
   await db.batch().commit();
  //return result;
}

 deleteRecord(int id) async{
    final db = await recordsDB.database;
  await db.delete('records', where: 'id =?', whereArgs: [id]);
await    db.batch().commit();
  //return result;
}

 void changeDBPasswords() async{
       recordsDB.changePasswords();
}

}