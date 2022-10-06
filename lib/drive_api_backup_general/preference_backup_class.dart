import 'dart:convert';
import 'package:adhd_journal_flutter/app_start_package/splash_screendart.dart';
import 'package:flutter/foundation.dart' as kriss;
import 'package:path/path.dart';
import 'package:pointycastle/export.dart';
import 'package:pointycastle/src/platform_check/platform_check.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../app_start_package/login_screen_file.dart';
import 'google_drive_backup_class.dart';
import 'CryptoUtils.dart';
import 'dart:io' as io;

class PreferenceBackupAndEncrypt {
  RSAKeyGenerator keyGen = RSAKeyGenerator();
  late RSAPrivateKey  privKey;
  late RSAPublicKey pubKey;


  //Assign RSA Keys
  void assignRSAKeys() async  {
  try{

    String privKeyFilePath = join(await getDatabasesPath(),"journ_privkey.pem");
    io.File privateKeyStorage = io.File(privKeyFilePath);
    String pubKeyFilePath = join(await getDatabasesPath(),"journ_pubKey.pem");
    io.File publicKeyStorage = io.File(pubKeyFilePath);

    if(privateKeyStorage.existsSync()){
      var privKeyReader = privateKeyStorage.readAsStringSync();
      String preKeyString = privKeyReader;
      print(preKeyString);
      privKey = CryptoUtils.rsaPrivateKeyFromPemPkcs1(preKeyString);
    }
    else {
      throw Exception("File not found");
    }

    if(publicKeyStorage.existsSync()){
      var pubKeyReader = publicKeyStorage.readAsStringSync();
      var prePubKeyString = pubKeyReader;
      pubKey = CryptoUtils.rsaPublicKeyFromPemPkcs1(prePubKeyString);
    }
    else{
      throw Exception();
    }

  }on Exception catch(ex){
    print(ex);

  }


  }
  //Download and  Assign RSA Keys
  Future<void> downloadRSAKeys(GoogleDrive drive) async{
   try{
     await drive.syncBackupFiles("journ_pubKey.pem");
   await drive.syncBackupFiles('journ_privkey.pem');
   assignRSAKeys();
   } on Exception catch(ex){
     print(ex);
   }
  }
  //Download latest Preferences file
  Future<void> downloadPrefsCSVFile(GoogleDrive drive) async{
    try{
      await drive.syncBackupFiles("journalStuff.txt");
      io.File csvFile = io.File(docsLocation);
      if(csvFile.existsSync()){
        var dataArray = '';
        await Future.delayed(Duration(seconds: 6),(){dataArray = CryptoUtils.rsaDecrypt(csvFile.readAsStringSync(encoding: Encoding.getByName("utf-8")!), privKey);
        print(dataArray);
        });

        decipheredData = dataArray;

      } else{
        throw Exception();
      }
    } on Exception catch(ex){
      if (kriss.kDebugMode) {
        print(ex);
      }
    }

  }
  //Decrypt the Data
  void decryptData(String data, GoogleDrive drive){

  }

  //Encrypt RSA Keys and assign the values to the variables
  void encryptRsaKeysAndUpload(GoogleDrive drive) async{
    try {
      io.File privateKeyStorage = io.File(
          join(keyLocation, "journ_privkey.pem"));
      io.File publicKeyStorage = io.File(
          join(keyLocation, "journ_pubKey.pem"));
      int bitLength = 2048;
      SecureRandom random = exampleSecureRandom();

      keyGen.init(ParametersWithRandom(RSAKeyGeneratorParameters(
          BigInt.parse('65537'), bitLength, 64), random));
      final pair = keyGen.generateKeyPair();
      privKey = pair.privateKey as RSAPrivateKey;
      pubKey = pair.publicKey as RSAPublicKey;
      publicKeyStorage.createSync();

      var writepubKey = CryptoUtils.encodeRSAPublicKeyToPemPkcs1(pubKey);
      final pubKeyWriter = publicKeyStorage.openSync(mode: io.FileMode.write);
      pubKeyWriter.writeStringSync(writepubKey);
      pubKeyWriter.closeSync();
      privateKeyStorage.createSync();
      var writePrivKey = CryptoUtils.encodeRSAPrivateKeyToPemPkcs1(privKey);
      final privKeyWriter = privateKeyStorage.openSync(mode: io.FileMode.write);
      privKeyWriter.writeStringSync(writePrivKey);
      privKeyWriter.closeSync();

      bool checkPubKey = await drive.checkForCSVFile("journ_pubkey.pem");
      if (checkPubKey) {
        throw Exception("We have keys in the cloud already");
      }
      drive.uploadFileToGoogleDrive(privateKeyStorage);
      drive.uploadFileToGoogleDrive(publicKeyStorage);
      print("RSA Keys Generated and uploaded");
      if (kriss.kDebugMode) {
        print("data encrypted");
      }
    } on Exception catch(ex){
      print("Keys already exist in cloud");
    }
  }
  void replaceRsaKeys(GoogleDrive drive) async{
    bool checkPubKey = await drive.checkForCSVFile("journ_pubkey.pem");
    if (checkPubKey) {
      print("Keys exist, just clearing them out now");
      drive.deleteOutdatedBackups("journ_pubkey.pem");
      drive.deleteOutdatedBackups('journ_privkey.pem');
    }
    encryptRsaKeysAndUpload(drive);
  }

  void encryptData(String data,GoogleDrive drive){

    var testBytes = CryptoUtils.rsaEncrypt(data, pubKey);
    print("data encrypted, uploading now");
    uploadPrefsCSVFile(testBytes, drive);
print("Preferences uploaded");
  }
  Future<void> uploadPrefsCSVFile(String cipherText,GoogleDrive drive) async{
    try{
      io.File csvFile = io.File(docsLocation);
      if(!csvFile.existsSync()){
        csvFile.createSync();
      }
      csvFile.writeAsStringSync(cipherText);
      drive.deleteOutdatedBackups('journalStuff.txt');
      drive.uploadFileToGoogleDrive(csvFile);
    } on Exception catch(ex){
      print(ex);
    }
  }
  SecureRandom exampleSecureRandom() {

    final secureRandom = SecureRandom('Fortuna')
      ..seed(KeyParameter(
          Platform.instance.platformEntropySource().getBytes(32)));
    return secureRandom;
  }

















}