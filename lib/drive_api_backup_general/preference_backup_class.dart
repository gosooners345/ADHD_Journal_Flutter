import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/export.dart';
import 'package:path/path.dart';
import '../app_start_package/login_screen_file.dart';
import 'google_drive_backup_class.dart';
import 'package:adhd_journal_flutter/settings.dart';
import 'dart:io' as io;

class PreferenceBackupAndEncrypt {

  late Encrypter encrypter;
  final iv = IV.fromLength(16);

  //Encrypt the CSV File instead of the data going into it.
  void encryptDataInCSV(String data) async{
    Key listOBytes = Key.fromUtf8(apiKey);
    Uint8List paddedDataBytes = Uint8List.fromList(data.codeUnits);
    encrypter=Encrypter(AES(listOBytes,mode:AESMode.cbc,padding:'PKCS7'));
    final cipherText = encrypter.encryptBytes(paddedDataBytes,iv: iv);
    print("data encrypted");
    uploadPrefsCSVFile(cipherText);
    decryptDataInCSV(cipherText);

  }
//Decrypt the CSV file
  void  decryptDataInCSV(Encrypted cipherText) async{
    Key listOBytes = Key.fromUtf8(apiKey);
    var decryptedData =encrypter.decryptBytes(cipherText,iv: iv);
    var stringData = String.fromCharCodes(decryptedData);

    print(stringData);
    print("Data Decrypted");

  }

  Future<void> downloadPrefsCSVFile() async{

  }
  /// Open the file, write into it, close it.
  /// Upload it - later
  Future<void> uploadPrefsCSVFile(Encrypted cipherText) async{


  }



  ///Check the age of the file on the device and in google drive.
  ///Call the method in Google Drive before calling download or upload.
  Future<void> checkCSVAgeAndData() async{




  }



}