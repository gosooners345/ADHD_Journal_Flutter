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
  RSAPrivateKey? privKey;
  RSAPublicKey? pubKey;

  void assignRSAKeysOffline() {
    String privKeyFilePath = join(keyLocation, "journ_privkey.pem");
    io.File privateKeyStorage = io.File(privKeyFilePath);
    String pubKeyFilePath = join(keyLocation, "journ_pubKey.pem");
    io.File publicKeyStorage = io.File(pubKeyFilePath);
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
  void assignRSAKeys(GoogleDrive drive) async {
    String privKeyFilePath = join(keyLocation, "journ_privkey.pem");
    io.File privateKeyStorage = io.File(privKeyFilePath);
    String pubKeyFilePath = join(keyLocation, "journ_pubKey.pem");
    io.File publicKeyStorage = io.File(pubKeyFilePath);
    try {
      if (privateKeyStorage.existsSync() && publicKeyStorage.existsSync()) {
        assignRSAKeysOffline();
      } else {
        throw Exception("No File");
      }
    } on Exception catch (tm) {
      var checkKeysOnline = await drive.checkForFile("journ_pubKey.pem");
      var checkPrivKey = await drive.checkForFile('journ_privKey.pem');
      if (checkKeysOnline && checkPrivKey) {
        downloadRSAKeys(drive);
      } else {
        encryptRsaKeysAndUpload(drive);
      }
    }
  }

  //Download and  Assign RSA Keys
  Future<void> downloadRSAKeys(GoogleDrive drive) async {
    try {
      await drive.syncBackupFiles("journ_pubKey.pem");
      await drive.syncBackupFiles('journ_privkey.pem');
      assignRSAKeys(drive);
    } on Exception catch (ex) {
      print(ex);
    }
  }

  //Download latest Preferences file
  Future<void> downloadPrefsCSVFile(GoogleDrive drive) async {
    try {
      await Future.sync(() => drive.syncBackupFiles("journalStuff.txt"));
      if (privKey == null) {
        assignRSAKeys(drive);
      }
      io.File csvFile = io.File(docsLocation);
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

  void generateRSAKeys() {
    io.File privateKeyStorage = io.File(join(keyLocation, "journ_privkey.pem"));
    io.File publicKeyStorage = io.File(join(keyLocation, "journ_pubKey.pem"));
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
  void encryptRsaKeysAndUpload(GoogleDrive drive) async {
    try {
      io.File privateKeyStorage =
          io.File(join(keyLocation, "journ_privkey.pem"));
      io.File publicKeyStorage = io.File(join(keyLocation, "journ_pubKey.pem"));
      if (privateKeyStorage.existsSync() == false) {
        generateRSAKeys();
      }
      bool checkPubKey = await drive.checkForFile("journ_pubkey.pem");
      if (checkPubKey) {
        throw Exception("We have keys in the cloud already");
      }
      drive.uploadFileToGoogleDrive(privateKeyStorage);
      drive.uploadFileToGoogleDrive(publicKeyStorage);
      print("RSA Keys Generated and uploaded");
      if (kriss.kDebugMode) {
        print("data encrypted");
      }
    } on Exception catch (ex) {
      if (kriss.kDebugMode) {
        print("Keys already exist in cloud");
      }
    }
  }

  //Replace RSA Keys with new keys
  void replaceRsaKeys(GoogleDrive drive) async {
    bool checkPubKey = await drive.checkForFile("journ_pubkey.pem");
    if (checkPubKey) {
      print("Keys exist, just clearing them out now");
      drive.deleteOutdatedBackups("journ_pubkey.pem");
      drive.deleteOutdatedBackups('journ_privkey.pem');
    }
    encryptRsaKeysAndUpload(drive);
  }

// Encrypt the Preferences file for secure uploading
  void encryptData(String data, GoogleDrive drive) {
    assignRSAKeys(drive);
    var testBytes = CryptoUtils.rsaEncrypt(data, pubKey!);
    print("data encrypted, uploading now");
    uploadPrefsCSVFile(testBytes, drive);
    print("Preferences uploaded");
  }

  Future<void> uploadPrefsCSVFile(String cipherText, GoogleDrive drive) async {
    try {
      io.File csvFile = io.File(docsLocation);
      if (!csvFile.existsSync()) {
        csvFile.createSync();
      }
      csvFile.writeAsStringSync(cipherText);
      drive.deleteOutdatedBackups('journalStuff.txt');
      drive.uploadFileToGoogleDrive(csvFile);
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
