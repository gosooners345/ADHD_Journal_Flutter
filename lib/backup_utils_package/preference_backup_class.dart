import 'dart:convert';
//import 'package:adhd_journal_flutter/app_start_package/splash_screendart.dart';
//import 'package:adhd_journal_flutter/project_resources/project_strings_file.dart';
import 'package:flutter/foundation.dart' as kriss;
//import 'package:path/path.dart';
import 'package:pointycastle/export.dart';
import 'package:pointycastle/src/platform_check/platform_check.dart';
import '../app_start_package/login_screen_file.dart';
import '../backup_providers/google_drive_backup_class.dart';
import '../project_resources/global_vars_andpaths.dart';
import 'crypto_utils.dart';
import 'dart:io' as io;
//import ''

//ICloud and OneDrive Integration here

class PreferenceBackupAndEncrypt {
  RSAKeyGenerator keyGen = RSAKeyGenerator();
  RSAPrivateKey? privKey;
  RSAPublicKey? pubKey;

  void assignRSAKeysOffline() {
    //String privKeyFilePath = join(keyLocation, privateKeyFileName);
    io.File privateKeyStorage = io.File(Global.fullDevicePrivKeyPath);
    //String pubKeyFilePath = join(keyLocation, pubKeyFileName);
    io.File publicKeyStorage = io.File(Global.fullDevicePubKeyPath);
    try {
      if (privateKeyStorage.existsSync()) {
        var privKeyReader = privateKeyStorage.readAsStringSync();
        String preKeyString = privKeyReader;
        privKey = CryptoUtils.rsaPrivateKeyFromPemPkcs1(preKeyString);
      }
      if (publicKeyStorage.existsSync()) {
        var pubKeyReader = publicKeyStorage.readAsStringSync();
        var prePubKeyString = pubKeyReader;
        pubKey = CryptoUtils.rsaPublicKeyFromPemPkcs1(prePubKeyString);
      }
    } on Exception catch (ex) {
      print(ex);
    }
  }

  //Assign RSA Keys
  Future<void> assignRSAKeys(GoogleDrive drive) async {
   // String privKeyFilePath = join(keyLocation, privateKeyFileName);
    io.File privateKeyStorage = io.File(Global.fullDevicePrivKeyPath);
    //String pubKeyFilePath = join(keyLocation, pubKeyFileName);
    io.File publicKeyStorage = io.File(Global.fullDevicePubKeyPath);
    try {
      if (privateKeyStorage.existsSync() && publicKeyStorage.existsSync()) {
        assignRSAKeysOffline();
      } else {
        throw Exception("No File");
      }
    } on Exception {
      var checkKeysOnline = await drive.checkForFile(Global.pubKeyFileName);
      var checkPrivKey = await drive.checkForFile(Global.privateKeyFileName);
      if (checkKeysOnline && checkPrivKey) {
        downloadRSAKeys(drive);
      } else {
      await  encryptRsaKeysAndUpload(drive);
      }
    }
  }

  //Download and  Assign RSA Keys
  Future<void> downloadRSAKeys(GoogleDrive drive) async {
    try {
      await drive.syncBackupFiles(Global.pubKeyFileName,Global.fullDeviceDocsPath);
      await drive.syncBackupFiles(Global.privateKeyFileName,Global.fullDeviceDocsPath);
      assignRSAKeys(drive);
    } on Exception catch (ex) {
      print(ex);
    }
  }

  Future<void> downloadPrefsCSVFile(GoogleDrive drive) async {
    try {
      await Future.sync(() => drive.syncBackupFiles(Global.prefsName,Global.fullDeviceDocsPath));
      if (privKey == null) {
        assignRSAKeys(drive);
      }
      io.File csvFile = io.File(Global.fullDevicePrefsPath);
      if (csvFile.existsSync()) {
        await Future.delayed(const Duration(seconds: 1), () {
          decipheredData = CryptoUtils.rsaDecrypt(
              csvFile.readAsStringSync(encoding: Encoding.getByName("utf-8")!),
              privKey!);
          if (decipheredData.isEmpty) {
            decipheredData = CryptoUtils.rsaDecrypt(
                csvFile.readAsStringSync(
                    encoding: Encoding.getByName("utf-8")!),
                privKey!);
          }
          while (decipheredData.isEmpty) {
            decipheredData = CryptoUtils.rsaDecrypt(
                csvFile.readAsStringSync(
                    encoding: Encoding.getByName("utf-8")!),
                privKey!);
          }
        });
      } else {
        throw Exception("File not found");
      }
    } on Exception catch (ex) {
      if (kriss.kDebugMode) {
        print(ex);
      }
    }
  }
///Generate new RSA Keys for encryption handling
  void generateRSAKeys() {
    io.File privateKeyStorage = io.File(Global.fullDevicePrivKeyPath);
    io.File publicKeyStorage = io.File(Global.fullDevicePubKeyPath);
    int bitLength = 2048;
    SecureRandom random = exampleSecureRandom();

    keyGen.init(ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
        random));
    final pair = keyGen.generateKeyPair();
    privKey = pair.privateKey as RSAPrivateKey;
    pubKey = pair.publicKey as RSAPublicKey;
    publicKeyStorage.createSync();

    var writepubKey = CryptoUtils.encodeRSAPublicKeyToPemPkcs1(pubKey!);
    final pubKeyWriter = publicKeyStorage.openSync(mode: io.FileMode.write);
    pubKeyWriter.writeStringSync(writepubKey);
    pubKeyWriter.closeSync();
    privateKeyStorage.createSync();
    var writePrivKey = CryptoUtils.encodeRSAPrivateKeyToPemPkcs1(privKey!);
    final privKeyWriter = privateKeyStorage.openSync(mode: io.FileMode.write);
    privKeyWriter.writeStringSync(writePrivKey);
    privKeyWriter.closeSync();
  }

  //Encrypt RSA Keys and assign the values to the variables
 Future<void> encryptRsaKeysAndUpload(GoogleDrive drive) async {
    try {
      io.File privateKeyStorage =
          io.File(Global.fullDevicePrivKeyPath);
      io.File publicKeyStorage = io.File(Global.fullDevicePubKeyPath);
      if (privateKeyStorage.existsSync() == false ||
          publicKeyStorage.existsSync() == false) {
        generateRSAKeys();
      }
      bool checkPubKey = await drive.checkForFile(Global.pubKeyFileName);
      bool checkPrivKey = await drive.checkForFile(Global.privateKeyFileName);
      if (checkPubKey && checkPrivKey) {
        throw Exception("We have keys in the cloud already");
      } else {
        drive.uploadFileToGoogleDrive(privateKeyStorage,Global.privateKeyFileName);
        drive.uploadFileToGoogleDrive(publicKeyStorage,Global.pubKeyFileName);
        print("RSA Keys Generated and uploaded");
        if (kriss.kDebugMode) {
          print("data encrypted");
        }
      }
    } on Exception {
      if (kriss.kDebugMode) {
        print("Keys already exist in cloud");
      }
    }
  }

  //Replace RSA Keys with new keys
  void replaceRsaKeys(GoogleDrive drive) async {
    bool checkPubKey = await drive.checkForFile(Global.pubKeyFileName);
    if (checkPubKey) {
      print("Keys exist, just clearing them out now");
      drive.deleteOutdatedBackups(Global.pubKeyFileName);
      drive.deleteOutdatedBackups(Global.privateKeyFileName);
    }
    encryptRsaKeysAndUpload(drive);
  }

// Encrypt the Preferences file for secure uploading
  Future<void> encryptData(String data, GoogleDrive drive) async{
    assignRSAKeys(drive);
    var testBytes = CryptoUtils.rsaEncrypt(data, pubKey!);
    print("data encrypted, uploading now");
   await  uploadPrefsCSVFile(testBytes, drive);
    print("Preferences uploaded");
  }

  Future<void> uploadPrefsCSVFile(String cipherText, GoogleDrive drive) async {
    try {
      io.File csvFile = io.File(Global.fullDevicePrefsPath);
      if (!csvFile.existsSync()) {
        csvFile.createSync();
      }
      csvFile.writeAsStringSync(cipherText);
      drive.deleteOutdatedBackups(Global.prefsName);
      drive.uploadFileToGoogleDrive(csvFile,Global.prefsName);
    } on Exception catch (ex) {
      print(ex);
    }
  }

  SecureRandom exampleSecureRandom() {
    final secureRandom = SecureRandom('Fortuna')
      ..seed(
          KeyParameter(Platform.instance.platformEntropySource().getBytes(32)));
    return secureRandom;
  }
}
