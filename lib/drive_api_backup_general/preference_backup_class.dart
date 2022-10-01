import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:adhd_journal_flutter/app_start_package/splash_screendart.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' as kriss;
import 'package:path/path.dart';
import '../app_start_package/login_screen_file.dart';
import 'google_drive_backup_class.dart';
import 'package:adhd_journal_flutter/settings.dart';
import 'dart:io' as io;

class PreferenceBackupAndEncrypt {
  Key keyByteArray = Key.fromUtf8(apiKey);
  late Encrypter encrypter;
  var iv = IV.fromUtf8("6873541313465981");


  //Encrypt the CSV File instead of the data going into it.
  void encryptDataInCSV(String data,GoogleDrive drive) async{

    Uint8List paddedDataBytes = Uint8List.fromList(data.codeUnits);
    encrypter = Encrypter(AES(keyByteArray,mode:AESMode.cbc,padding:"PKCS7"));
    final cipherText = encrypter.encryptBytes(paddedDataBytes,iv: iv);
    if (kriss.kDebugMode) {
      print("data encrypted");
    }
    uploadPrefsCSVFile(cipherText,drive);
   // decryptDataInCSV(cipherText);

  }
//Decrypt the CSV file
  Future<String>  decryptDataInCSV(Encrypted cipherText) async{

    encrypter = Encrypter(AES(keyByteArray,mode:AESMode.cbc,padding:"PKCS7"));
    var decryptedData = encrypter.decryptBytes(cipherText, iv: iv);
    var stringData = String.fromCharCodes(decryptedData);
      if (kriss.kDebugMode) {
        print(stringData);
      }
      if (kriss.kDebugMode) {
        print("Data Decrypted");
      }
      return stringData;

  }
/// Open file, read data into a byte array
  /// pass into decrypt data in csv and return results
  Future<void> downloadPrefsCSVFile(GoogleDrive drive) async{
//
    try{
  drive.syncBackupFiles("journalStuff.txt");
  io.File csvFile = io.File(docsLocation);
  if(csvFile.existsSync()){
   var dataArray = csvFile.openSync(mode: io.FileMode.read);
   var cipherdata = [];
 while(dataArray.readByteSync() !=-1){
   final byte =dataArray.readByteSync();
   cipherdata.add(byte);
   if(dataArray.readByteSync()==-1){
     break;
   }
 }
 dataArray.closeSync();
var tempArray = <int>[];
 for(int i =0; i<cipherdata.length;i++){
   var testVariable = cipherdata[0];
   tempArray.add(testVariable as int);
 }

 Uint8List cipherText = Uint8List(tempArray.length);
 cipherText = Uint8List.fromList(tempArray);
 //cipherText.addAll(cipherArray as Uint8List);
 decipheredData = await decryptDataInCSV(Encrypted(cipherText));
print(decipheredData);
  } else{
    throw Exception();
  }
} on Exception catch(ex){
  if (kriss.kDebugMode) {
    print(ex);
  }
}

  }
  /// Open the file, write into it, close it.
  /// Upload it - later
  Future<void> uploadPrefsCSVFile(Encrypted cipherText,GoogleDrive drive) async{
    try{
    Uint8List cipherBytes = cipherText.bytes;
    io.File csvFile = io.File(docsLocation);
    if(!csvFile.existsSync()){
      csvFile.createSync();
    }
    var dataArray = csvFile.openSync(mode: io.FileMode.write);
    for(int i=0; i<cipherBytes.length;i++){
      dataArray.writeByteSync(cipherBytes[i]);
    }
    dataArray.closeSync();
    drive.deleteOutdatedBackups('journalStuff.txt');
    drive.uploadFileToGoogleDrive(csvFile);
    } on Exception catch(ex){
      print(ex);
    }
  }







}