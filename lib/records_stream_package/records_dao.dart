import 'dart:async';
import 'package:sqflite_sqlcipher/sqflite.dart';

import 'records_db_class.dart';
import 'package:adhd_journal_flutter/record_data_package/records_data_class_db.dart';

class RecordsDao {
  final RecordsDB recordsDB = RecordsDB.recordDB;

  //Add Records
  createRecords(Records record) async {
    final db = await recordsDB.database;
    await db.insert('records', record.toMapForDB(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    await db.batch().commit();
    // return result;
  }

  Future<List<Records>> getSearchedRecords({required String query}) async {
    List<String> columns = [
      'tags',
      'title',
      'content',
      'emotions',
      'sources',
      'symptoms'
    ];
    final database = await recordsDB.database;
    List<Map<String, dynamic>> maps;

    if (query.isNotEmpty) {
      maps = await database.query('records',
          where: /*title LIKE ?*/
              "title like ?  OR "
              "emotions LIKE ? OR  "
              "sources LIKE ? OR "
              "content LIKE ? OR "
              'symptoms LIKE ? OR '
              "tags LIKE ?",
          whereArgs: [
            '%$query%',
            '%$query%',
            '%$query%',
            '%$query%',
            '%$query%',
            '%$query%'
          ]);
    } else {
      maps = await database.query('records');
    }

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
    }, growable: true);
    list.sort((a, b) => a.compareTo(b));
    return list;
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
    }, growable: true);
    list.sort((a, b) => a.compareTo(b));
    return list;
  }

  Future<List<Records>> getRecordsSortedByType(String type) async {
    String columnName = '';
    String orderType = '';
    switch (type) {
      case 'Alphabetical':
        columnName = "title";
        orderType = 'ASC';
        break;
      case 'Most Recent':
        columnName = 'time_Updated';
        orderType = 'DESC';
        break;
      case 'Time Created':
        columnName = 'time_Created';
        orderType = 'ASC';
        break;
      case 'Rating':
        columnName = 'rating';
        orderType = 'DESC';
        break;
    }

    final database = await recordsDB.database;
    final List<Map<String, dynamic>> maps = await database
        .rawQuery("SELECT * FROM records ORDER BY $columnName $orderType;");

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
    }, growable: true);
    return list;
  }

  updateRecords(Records record) async {
    final db = await recordsDB.database;

    await db.update('records', record.toMapForDB(),
        where: 'id =?', whereArgs: [record.id]);
    await db.batch().commit();
    //return result;
  }

  deleteRecord(int id) async {
    final db = await recordsDB.database;
    await db.delete('records', where: 'id =?', whereArgs: [id]);
    await db.batch().commit();
    //return result;
  }

  void changeDBPasswords() async {
    recordsDB.changePasswords();
  }

  void writeCheckpoint() async{
    recordsDB.writeCheckpoint();
  }
}
