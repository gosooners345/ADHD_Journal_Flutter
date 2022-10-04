import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:adhd_journal_flutter/app_start_package/splash_screendart.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart' as kriss;
import 'package:path/path.dart';
import 'package:pointycastle/export.dart';
import 'package:pointycastle/src/platform_check/platform_check.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../app_start_package/login_screen_file.dart';
import 'google_drive_backup_class.dart';
import 'CryptoUtils.dart';
import 'package:adhd_journal_flutter/settings.dart';
import 'dart:io' as io;

class PreferenceBackupAndEncrypt {
  RSAKeyGenerator keyGen = RSAKeyGenerator();
  late enc.Encrypter encrypter;
  late RSAPrivateKey  privKey;
  late RSAPublicKey pubKey;

 // Generates new keys on each encryption sequence

  Future<void> downloadRSAKeys(GoogleDrive drive) async{
   try{
     await drive.syncBackupFiles("journ_pubKey.pem");
   await drive.syncBackupFiles('journ_privkey.pem');
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
     else{
       throw Exception();
     }
     if(publicKeyStorage.existsSync()){
       var pubKeyReader = publicKeyStorage.readAsStringSync();

       var prePubKeyString = pubKeyReader;
       pubKey = CryptoUtils.rsaPublicKeyFromPemPkcs1(prePubKeyString);
     }
     else{
throw Exception();
     }

   } on Exception catch(ex){
     print(ex);
   }
  }

  /// Open the file, write into it, close it.
  /// Upload it - later


  //Encrypt the CSV File instead of the data going into it.
  void encryptRSAKEYSANDDataInCSV(String data,GoogleDrive drive) async{
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
    bool checkPrivKey = await drive.checkForCSVFile("journ_privkey.pem");
    if(checkPrivKey){
      drive.deleteOutdatedBackups("journ_privkey.pem");
    }
    bool checkPubKey = await drive.checkForCSVFile("journ_pubkey.pem");
    if(checkPubKey){
      drive.deleteOutdatedBackups("journ_pubkey.pem");
    }
    drive.uploadFileToGoogleDrive(privateKeyStorage);
    drive.uploadFileToGoogleDrive(publicKeyStorage);
    print("RSA Keys Generated and uploaded");
    var testBytes = CryptoUtils.rsaEncrypt(data, pubKey);

    if (kriss.kDebugMode) {
      print("data encrypted");
    }
    uploadPrefsCSVFile(testBytes,drive);


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


//Decrypt the CSV file


  Future<void> downloadPrefsCSVFile(GoogleDrive drive) async{

    try{
   await   downloadRSAKeys(drive);
      drive.syncBackupFiles("journalStuff.txt");
      io.File csvFile = io.File(docsLocation);
      if(csvFile.existsSync()){
        var dataArray = CryptoUtils.rsaDecrypt(csvFile.readAsStringSync(encoding: Encoding.getByName("utf-8")!), privKey); //await decryptDataInCSV(csvFile.readAsBytesSync());
print(dataArray);
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













}