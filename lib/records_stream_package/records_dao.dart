import 'dart:async';
import 'dart:io';
import 'package:adhd_journal_flutter/app_start_package/login_screen_file.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../project_resources/global_vars_andpaths.dart';
import 'records_db_class.dart';
import 'package:adhd_journal_flutter/record_data_package/records_data_class_db.dart';

class RecordsDao {
  final RecordsDB recordsDB = RecordsDB.recordDB;

  //Add Records
  createRecords(Records record) async {
    final db = await recordsDB.database;
    await db.insert('records', record.toMapForDB(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    await saveImageToDb(record.id, record.media);
    await db.batch().commit();
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
          where:
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
          media: maps[index]['media'] ?? Uint8List(0),
          success: maps[index]['success'] == 0 ? false : true,
          medication: maps[index]['medication']??'',
          sleep: maps[index]['sleep']??'',
          timeCreated:
              DateTime.fromMillisecondsSinceEpoch(maps[index]['time_created']),
          timeUpdated:
              DateTime.fromMillisecondsSinceEpoch(maps[index]['time_updated']));
    }, growable: true);
    list.sort((a, b) => a.compareTo(b));
    return list;
  }




// Test image
Uint8List testImage(Map<String,dynamic>map)  {
  final Object? blobData = map['media'];
  if (blobData != null && blobData is Uint8List) {
    print("DB: Loaded ${blobData.lengthInBytes} bytes from BLOB .");
    return blobData;
  } else if (blobData != null) {
    print("DB: Loaded data for map,  but it's not Uint8List. Type: ${blobData
        .runtimeType}");
    if (blobData is List<int>) {
      return Uint8List.fromList(blobData);
    }else {
      print("DB: No image data in BLOB for id  column is null.");
    }
  } return Uint8List(0);
  }


  //Get all records
  Future<List<Records>> getRecords() async {
    final database = await recordsDB.database;
    final List<Map<String, dynamic>> maps = await database.query('records');
    List<Records> list =  List.generate(maps.length, (index)  {
      Records record = Records(
          id: maps[index]['id'],
          title: maps[index]['title'],
          content: maps[index]['content'],
          emotions: maps[index]['emotions'],
          sources: maps[index]['sources'],
          rating: maps[index]['rating'],
          symptoms: maps[index]['symptoms'],
          tags: maps[index]['tags'],
          media:convertBytestoList( maps[index]['media']) ?? Uint8List(0) ,
          success: maps[index]['success'] == 0 ? false : true,
          medication: maps[index]['medication']??'',
          sleep: maps[index]['sleep']??0.0,
          timeCreated:
              DateTime.fromMillisecondsSinceEpoch(maps[index]['time_created']),
          timeUpdated:
              DateTime.fromMillisecondsSinceEpoch(maps[index]['time_updated']));
      //record.media = id) as Uint8List;
      return record;
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
          sleep: maps[index]['sleep']??0.0,
          medication: maps[index]['medication']??'',
          media:  testImage( maps[index]['media']) ?? Uint8List(0),
          success: maps[index]['success'] == 0 ? false : true,
          timeCreated:
              DateTime.fromMillisecondsSinceEpoch(maps[index]['time_created']),
          timeUpdated:
              DateTime.fromMillisecondsSinceEpoch(maps[index]['time_updated']));
    }, growable: true);
    return list;
  }
 Future<bool> isOpen() async{
    final db = await recordsDB.database;
    if(db.isOpen){
      return true;
    } else {
      return false;
    }
 }
  updateRecords(Records record) async {
    final db = await recordsDB.database;

    await db.update('records', record.toMapForDB(),
        where: 'id =?', whereArgs: [record.id]);
    await saveImageToDb(record.id, record.media);
    await db.batch().commit();
  }

  deleteRecord(int id) async {
    final db = await recordsDB.database;
    await db.delete('records', where: 'id =?', whereArgs: [id]);
    await db.batch().commit();
  }

  // Possible replacement for old method if things don't work properly
  changePasswords(String newPassword) async {
    var db = await recordsDB.database;
    var query = "PRAGMA key = $dbPassword;";

    var query2 = "PRAGMA rekey = $newPassword;";
    try {
      var disposal = await db.query("records");
      if (Platform.isAndroid) {
        await Future.sync(() {
          db.rawQuery(query);
          db.rawQuery(query2);
        });
      } else {
        await Future.sync(() {
          db.execute(query);
          db.execute(query2);
        });
      }
      disposal = await db.query("records");
      print(disposal.length);
      await Future.sync(() => writeCheckpoint(db));
      await Future.sync(() => db.close());
// Replacing old files

      //if(Platform.isAndroid){
      File walfile = File("${Global.databaseName}-wal");
     File shmFile = File("${Global.databaseName}-shm");

      Global.googleDrive.deleteOutdatedBackups(Global.databaseName);
      Global.googleDrive.uploadFileToGoogleDrive(File(Global.fullDeviceDBPath),Global.databaseName);

    /*  if (walfile.existsSync()) {
        if (kDebugMode) {
          print(walfile.existsSync());
        }
        Global.googleDrive.uploadFileToGoogleDrive(File("${Global.databaseName}-wal"),walfile.path);
      }
      if (shmFile.existsSync()) {
        Global.googleDrive.uploadFileToGoogleDrive(File("${Global.databaseName}-shm"),shmFile.path);
      }*/

      query = "PRAGMA key = $newPassword;";
      dbPassword = newPassword;
      db = await recordsDB.database;
      if (Platform.isAndroid) {
        await Future.sync(() {
          db.rawQuery(query);
        });
      } else {
        await Future.sync(() {
          db.execute(query);
        });
      }

      disposal = await db.query("records");
      if (kDebugMode) {
        print(disposal.length);
      }

      if (kDebugMode) {
        print("Success");
      }
      await Global.encryptedSharedPrefs.setString("dbPassword", newPassword);
      dbPassword = newPassword;
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

 Future<void> closeDBConnection()async{
    if(kDebugMode){
      print("RecordsDAO: Requesting DB Close from RecordsDB");
    }
    await recordsDB.closeCurrentDBInstance();
 }
 Future<void> replaceAndOpenDBConnection()async{
    if(kDebugMode){
      print("RecordsDAO: Requesting DB Close from RecordsDB");
    }
    await recordsDB.replaceandReOpenDBInstance();
 }

  Future<void> saveImageToDb(int id, Uint8List image) async {
    var db = await recordsDB.database;
    await db.update('records', {'media': image}, where: 'id =?', whereArgs: [id]);
    print("DB: Saved ${image.lengthInBytes} bytes to BLOB for id $id.");

  }


  // Test force the wal into the db and clean it out.
  void writeCheckpoint(Database db) async {
//final db = await recordsDB.database;
    var query = "PRAGMA SQLITE_DEFAULT_WAL_AUTOCHECKPOINT = 1";
    try {
      if (Platform.isAndroid) {
        await db.rawQuery(query);
      } else {
        await db.execute(query);
      }
      query = "PRAGMA wal_checkpoint(full)";
      if (Platform.isAndroid) {
        await db.rawQuery(query);
      } else {
        await db.execute(query);
      }
      await db.batch().commit();
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  void writemoreCheckpoint() async {
    final db = await recordsDB.database;
    var query = "PRAGMA SQLITE_DEFAULT_WAL_AUTOCHECKPOINT = 1";
    try {
      if (Platform.isAndroid) {
        await db.rawQuery(query);
      } else {
        await db.execute(query);
      }
      query = "PRAGMA wal_checkpoint(full)";
      if (Platform.isAndroid) {
        await db.rawQuery(query);
      } else {
        await db.execute(query);
      }
      await db.batch().commit();
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }


///Required for Media conversion

Uint8List convertBytestoList(dynamic bytedata){
    if(bytedata!=null){
    Uint8List list = Uint8List.fromList(bytedata);
  return list;} else {
      return Uint8List(0);
    }
}


}
