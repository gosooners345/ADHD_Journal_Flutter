import 'dart:async';
import 'dart:io';
import 'package:adhd_journal_flutter/records_data_class_db.dart';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' as cipher;
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';





class RecordsDB {

static late cipher.Database _database ;
static const String createTables =  'CREATE TABLE records(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, title TEXT, content TEXT, emotions TEXT)';
static String dbPassword = "";
static String newDBPassword = '';
static String oldDBPassword = '';
static String path = '';
static String tempPath = '';
static String dbName = 'activitylogger_db.db';
static String tempDB = 'temp.db';


static Future<cipher.Database> db() async{

  initializePasswords();

  return cipher.openDatabase(join(await getDatabasesPath(), 'activitylogger_db.db'),
    password: dbPassword,
    onCreate: (database, version) {
      return database.execute(createTables);
    },
    version: 2,
  );
}

  void start() async{
  WidgetsFlutterBinding.ensureInitialized();

  }


static Future<void> initializePasswords() async{
  EncryptedSharedPreferences prefs = EncryptedSharedPreferences();
  dbPassword = await prefs.getString('dbPassword');
  newDBPassword = await prefs.getString('loginPassword');
  oldDBPassword = await prefs.getString('dbPassword');
  path = join(await getDatabasesPath(), 'activitylogger_db.db');
  tempPath = join(await getDatabasesPath(),tempDB);

  if(oldDBPassword != newDBPassword)
    {
rekeyDB();
    }

}


Future<Database> get database async {
  _database = await initializeDB();
  return _database;
}
 Future<Database> initializeDB() async{
  var ourDB = await cipher.openDatabase(join(await getDatabasesPath(), 'activitylogger_db.db'),
    password: '1234',
    onCreate: (database, version) {
      return database.execute(createTables);
    },
    version: 1,
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
static Future<int> updateRecords(Records record) async{
  final db = await RecordsDB.db();
  final result = await db.update('records', record.toMapForDB(),where: 'id =?', whereArgs: [record.id]);
  return result;
}
static Future<int> deleteRecord(int id) async{
  final db = await RecordsDB.db();
  return await db.delete('records',where: 'id =?',whereArgs: [id]);

}
static Future<int> insertRecord(Records record) async {
  final db = await RecordsDB.db();
  await db.insert('records', record.toMapForDB(),conflictAlgorithm: ConflictAlgorithm.replace);
  return record.id;
}

/// Changing DB Passwords and encrypting the DB with the new DB Password Methods below

static void rekeyDB(){
decryptDB(path, oldDBPassword, tempPath);
encryptDB(path, newDBPassword, tempPath);

}

  static Future<void> decryptDB(String path, String oldDBPassword, String tempFile) async{
    try {
      String attachKey = "ATTACH DATABASE ? AS records  KEY ''";
      String exportCommand = "SELECT sqlcipher_export('records')";
      String detachCommand = "DETACH DATABASE records";
      var newFile = File(tempPath);
      await newFile.open(mode: FileMode.write);
      File testFile = File(path);
      {
        var db = await openDatabase(
          testFile.path, version: 2, onConfigure: (db) {},
          password: oldDBPassword, readOnly: false);
      var version = await db.getVersion();
      db.close();



        db = await openDatabase(
          tempPath, version: version, onCreate: (database, version) {
          //   database.execute(createTables);
          database.execute(attachKey);
          database.execute(exportCommand);
          database.execute(detachCommand);
        }
          ,);
        db.close();
        testFile.deleteSync();
        newFile.renameSync(path);
        print("Test success");
      }

    }
    on Exception catch (ex) {
      print(ex);
    }


  }

  static Future<void> encryptDB(String path, String newPassword, String tempPath) async{
    try{
      var attachKey = "ATTACH DATABASE ? AS records KEY ''";
      var exportCommand = "SELECT sqlcipher_export('main','records)";
      var detachCommand = "DETACH DATABASE records";
      File testFile = File(path);
      if(testFile.existsSync()){
        var newFile = File(tempPath);
        newFile.createSync();
        var db = await openDatabase(path,version: 2,password : "",readOnly: false);
        var version =await db.getVersion();
        db.close();
        db = await openDatabase(tempPath,version: version,onCreate: (db,version){
          db.execute(attachKey);
          db.execute(exportCommand);
          db.execute(detachCommand);
        },
            password: newPassword
        );
        db.close();
        testFile.deleteSync();
        newFile.renameSync(testFile.path);
        print("success");
      }
      else{
        throw Exception("FileNotFound");
      }
    }
    on Exception catch(ex){
      print(ex);
    }


  }




}



