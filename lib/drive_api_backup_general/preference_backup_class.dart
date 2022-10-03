import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:adhd_journal_flutter/app_start_package/splash_screendart.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:encrypt/encrypt_io.dart';
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

  void downloadRSAKeys(GoogleDrive drive) async{
   try{
     String privKeyFilePath = join(await getDatabasesPath(),"journ_privkey.pem");
     io.File privateKeyStorage = io.File(privKeyFilePath);
     String pubKeyFilePath = join(await getDatabasesPath(),"journ_pubKey.pem");
     io.File publicKeyStorage = io.File(pubKeyFilePath);
     drive.syncBackupFiles("journ_pubKey.pem");
     drive.syncBackupFiles('journ_privkey.pem');
     if(privateKeyStorage.existsSync()){
       var privKeyReader = privateKeyStorage.openSync(mode: io.FileMode.read);
       var decodeBytes = <int>[];
      while(privKeyReader.readByteSync()!=-1){
        if(privKeyReader.readByteSync()== -1){
          break;
        }
        decodeBytes.add(privKeyReader.readByteSync());
      }
       privKeyReader.closeSync();
      var recodeBytes = Uint8List.fromList(decodeBytes);

       var preKeyString = String.fromCharCodes(recodeBytes);
       recodeBytes = base64Decode(preKeyString);
       preKeyString = base64Encode(recodeBytes);

       print(preKeyString);
      privKey = CryptoUtils.rsaPrivateKeyFromPemPkcs1(preKeyString);
     }
     else{
       throw Exception();
     }
     if(publicKeyStorage.existsSync()){
       var pubKeyReader = publicKeyStorage.openSync(mode: io.FileMode.read);
       var decodeBytes = <int>[];
       while(pubKeyReader.readByteSync() !=-1){
         if(pubKeyReader.readByteSync() == -1){
           break;
         }
         decodeBytes.add(pubKeyReader.readByteSync());
       }
       var prePubKeyString = String.fromCharCodes(decodeBytes);
       pubKeyReader.closeSync();
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

    Uint8List paddedDataBytes = Uint8List.fromList(data.codeUnits);
    final cipherText =rsaEncrypt(pubKey, paddedDataBytes);

    if (kriss.kDebugMode) {
      print("data encrypted");
    }
    uploadPrefsCSVFile(cipherText,drive);


  }
  Future<void> uploadPrefsCSVFile(Uint8List cipherText,GoogleDrive drive) async{
    try{
      io.File csvFile = io.File(docsLocation);
      if(!csvFile.existsSync()){
        csvFile.createSync();
      }
      var dataArray = csvFile.openSync(mode: io.FileMode.write);
      for(int i=0; i<cipherText.length;i++){
        dataArray.writeByteSync(cipherText[i]);
      }
      dataArray.closeSync();
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


  Uint8List rsaEncrypt(RSAPublicKey myPublic, Uint8List dataToEncrypt) {
    final encryptor = PKCS1Encoding(RSAEngine())
      ..init(true, PublicKeyParameter<RSAPublicKey>(myPublic)); // true=encrypt

    return _processInBlocks(encryptor, dataToEncrypt);
  }

  Uint8List rsaDecrypt(RSAPrivateKey myPrivate, Uint8List cipherText) {
    final decryptor = PKCS1Encoding(RSAEngine())
      ..init(false, PrivateKeyParameter<RSAPrivateKey>(myPrivate)); // false=decrypt

    return _processInBlocks(decryptor, cipherText);
  }
  Future<void> downloadPrefsCSVFile(GoogleDrive drive) async{
//
    try{
      downloadRSAKeys(drive);
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

        Uint8List cipherText = Uint8List.fromList(tempArray);
        decipheredData = await decryptDataInCSV((cipherText));
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
  Future<String>  decryptDataInCSV(Uint8List cipherText) async{


    var decryptedData = rsaDecrypt(privKey,cipherText);
    var stringData = String.fromCharCodes(decryptedData);
            print(stringData);
    if (kriss.kDebugMode) {
      print("Data Decrypted");
    }
     return stringData;
  }



  Uint8List _processInBlocks(AsymmetricBlockCipher engine, Uint8List input) {
    final numBlocks = input.length ~/ engine.inputBlockSize +
        ((input.length % engine.inputBlockSize != 0) ? 1 : 0);

    final output = Uint8List(numBlocks * engine.outputBlockSize);

    var inputOffset = 0;
    var outputOffset = 0;
    while (inputOffset < input.length) {
      final chunkSize = (inputOffset + engine.inputBlockSize <= input.length)
          ? engine.inputBlockSize
          : input.length - inputOffset;

      outputOffset += engine.processBlock(
          input, inputOffset, chunkSize, output, outputOffset);

      inputOffset += chunkSize;
    }

    return (output.length == outputOffset)
        ? output
        : output.sublist(0, outputOffset);
  }


/// Open file, read data into a byte array
  /// pass into decrypt data in csv and return results









}