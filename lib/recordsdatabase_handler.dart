import 'dart:async';

import 'dart:io' as locker;
import 'package:adhd_journal_flutter/records_data_class_db.dart';
import 'package:path/path.dart';
//import 'package:sqflite_sqlcipher/sqflite.dart';
//import 'package:sqflite_sqlcipher/sqflite.dart' as cipher;
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart';
import 'settings.dart';
import 'package:objectbox/objectbox.dart';
import 'objectbox.g.dart';



class RecordsDB {

  late final Store recordStore;
  late final Box<Records> recordBox;
  late final Future<List<Records>> recordList;

  //static late final Future<Query<Records>> recordStream;
  //late final List<Records> recordList;
  //late final StreamController<Query<Records>> controllers;

  RecordsDB._create(recordStore){
  recordBox = Box<Records>(recordStore);
  final queryBuilder = recordBox.query()
  ..order(Records_.timeCreated);
  recordList = records();
  }

  static Future<RecordsDB> create() async {
    final store = await openStore();
    return RecordsDB._create(store);
  }

   Future<int> insertRecord(Records record) async {
  return recordBox.put(record, mode: PutMode.insert);

   }

 Future<List<Records>> records() async {
    final maps = recordBox.query()..order(Records_.timeUpdated);
return  maps.build().find();
  }


/*   void insertRecords(Records record){
    recordBox.put(record,mode: PutMode.insert);
    recordList.add(record);
   }*/
   /*void deleteRecords(Records record){
    recordBox.remove(record.id);
    recordList.remove(record);

   }*/
/*   void updateRecords(Records record){
    recordBox.put(record,mode: PutMode.update);
    var ax =recordList.indexOf(record);
    recordList.insert(ax, record);
   }*/

  Future<bool> deleteRecord(Records record) async {
    return  recordBox.remove(record.id);
  }

  Future<int> updateRecord(Records record) async {
   return recordBox.put(record,mode: PutMode.update);
   //final queryBd = recordBox.query()..order(Records_.timeCreated);
   //recordList = queryBd.build().find();
   //return bart;
  }
  /// For Later ...
  static final EncryptedSharedPreferences encryptedSharedPreferences =
  EncryptedSharedPreferences();






}



