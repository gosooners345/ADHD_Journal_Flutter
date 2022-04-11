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



class RecordsDB {

  late final Store recordStore;
  RecordsDB._create(this.recordStore){

  }
  static final EncryptedSharedPreferences encryptedSharedPreferences =
  EncryptedSharedPreferences();



}



