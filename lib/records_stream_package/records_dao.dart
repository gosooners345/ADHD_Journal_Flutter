import 'dart:async';
import 'dart:io';
import 'package:adhd_journal_flutter/app_start_package/login_screen_file.dart';
import 'package:adhd_journal_flutter/app_start_package/splash_screendart.dart';
import 'package:flutter/foundation.dart';
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
  }

  deleteRecord(int id) async {
    final db = await recordsDB.database;
    await db.delete('records', where: 'id =?', whereArgs: [id]);
    await db.batch().commit();
  }


  // Possible replacement for old method if things don't work properly
  changePasswords(String newPassword) async{
    var db = await recordsDB.database;

    var query = "PRAGMA key = ${dbPassword};";

    var query2 = "PRAGMA rekey = ${newPassword};";
try {
  var disposal = await db.query("records");
 if(Platform.isAndroid){
  await db.rawQuery(query);await db.rawQuery(query2);}
 else{
   await db.execute(query); await db.execute(query2);
 }
  disposal = await db.query("records");
print(disposal.length);
 await Future.sync(()=>writeCheckpoint(db));
await db.close();
// Replacing old files

 await Future.delayed(Duration(seconds: 2),(){
   if(Platform.isAndroid){
     File walfile = File("$dbLocation-wal");
     File shmFile = File("$dbLocation-shm");
     if(walfile.existsSync()){
       walfile.deleteSync();
     }
     if(shmFile.existsSync()){
       shmFile.deleteSync();
     }

   }
   googleDrive.deleteOutdatedBackups(dbName);
   googleDrive.uploadFileToGoogleDrive(File(dbLocation));
   //googleDrive.uploadFileToGoogleDrive(File("$dbLocation-wal"));
   //googleDrive.uploadFileToGoogleDrive(File("$dbLocation-shm"));
 });

  query = "PRAGMA key = $newPassword;";
  dbPassword = newPassword;
  db = await recordsDB.database;
  if(Platform.isAndroid){await db.rawQuery(query);}
  else{await db.execute(query);}

  disposal = await db.query("records");
  print(disposal.length);

  if (kDebugMode) {
    print("Success");
  }
  await encryptedSharedPrefs.setString("dbPassword", newPassword);
  dbPassword = newPassword;
}on Exception catch(e){
  if (kDebugMode) {
    print(e);
  }
}
  }

  // Test force the wal into the db and clean it out.
  void writeCheckpoint(Database db) async{
//final db = await recordsDB.database;
var query = "PRAGMA SQLITE_DEFAULT_WAL_AUTOCHECKPOINT = 1";
try {if(Platform.isAndroid){ await db.rawQuery(query);}
else{  await db.execute(query);}
  query = "PRAGMA wal_checkpoint(full)";
if(Platform.isAndroid){await db.rawQuery(query);}
else{  await db.execute(query);}
await db.batch().commit();
} on Exception catch(e){

  if (kDebugMode) {
    print(e.toString());
  }
}
  }
  void writemoreCheckpoint() async{
final db = await recordsDB.database;
    var query = "PRAGMA SQLITE_DEFAULT_WAL_AUTOCHECKPOINT = 1";
    try {if(Platform.isAndroid){ await db.rawQuery(query);}
    else{  await db.execute(query);}
    query = "PRAGMA wal_checkpoint(full)";
    if(Platform.isAndroid){await db.rawQuery(query);}
    else{  await db.execute(query);}
    await db.batch().commit();
    } on Exception catch(e){

      if (kDebugMode) {
        print(e.toString());
      }
    }
  }
}
