import 'dart:io';
import 'package:adhd_journal_flutter/app_start_package/splash_screendart.dart';
import 'package:adhd_journal_flutter/backup_utils_package/authextension.dart';
import 'package:flutter/foundation.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;
import '../project_resources/project_strings_file.dart';
import 'dart:convert' as convert;
import 'package:crypto/crypto.dart' as crypto;

class GoogleDrive {
  String fileID = "";
  late ga.DriveApi drive;
  bool firstUse = false;
  //Test variables for improving Google Drive performance
  Map<String,String> _driveFileIDs = {};
  final String _driveFileIDsPrefKey='google_drive_file_id';
  String? appfolderID;

  /// Variable for holding Google Drive client instance, could use better name
  http.Client? client;
  GoogleSignInAccount? account;
  /// Variable for checking activity on Google Drive API
  bool isDoingSomething = false;

 // Functional, see why IOS keeps prompting sign in
  GoogleSignIn googleSignIn =
      GoogleSignIn(signInOption: SignInOption.standard, scopes: [
    ga.DriveApi.driveAppdataScope,
    ga.DriveApi.driveFileScope,
  ]);

  // Have the user sign into Google Drive with their Google Account
  Future<auth.AuthClient?> getHttpClient() async {
    userActiveBackup = true;
    prefs.setBool('testBackup', userActiveBackup);
    prefs.reload();
    userActiveBackup = prefs.getBool("testBackup") ?? false;
    firstUse = true;
    prefs.setBool("authenticated", firstUse);
    account = await googleSignIn.signIn();
    var authenticateClient = googleSignIn.authenticatedClient();
    return authenticateClient;
  }

  // Check to see if the folder used for storing app data exists in Drive
  Future<String?> _getFolderId(ga.DriveApi driveApi) async {



    const mimeType = "application/vnd.google-apps.folder";
    try {
      final found = await Future.sync(() => driveApi.files.list(
            q: "mimeType = '$mimeType' and name = '$driveStoreDirectory' and trashed = false",
            $fields: "files(id, name)", //spaces:'drive'
          ));
      final files = found.files;
      if (files == null) {
        if (kDebugMode) {
          print("Sign-in first Error");
        }
        return null;
      }
      if (kDebugMode) {
        print(files.length);
      }
      // The folder already exists
      if (files.isNotEmpty) {

        return files.first.id;
      }
      // Create a folder
      ga.File folder = ga.File();
      folder.name = driveStoreDirectory;
      folder.mimeType = mimeType;
      final folderCreation = await driveApi.files.create(folder);
      if (kDebugMode) {
        print("Folder ID: ${folderCreation.id}");
      }
      return folderCreation.id;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  //This is an alternate method in case I didn't feel like passing the file Variable in
  // Delete method after the final testing of the main method is completed.
  /*uploadFileToGoogleDriveString(String fileName) async {
    File file = File(fileName);
    drive = ga.DriveApi(client!);
    String? folderId = await _getFolderId(drive);
    if (folderId == null) {
      if (kDebugMode) {
        print("Sign-in first Error");
      }
    } else {
      ga.File fileToUpload = ga.File();
      fileToUpload.parents = [folderId];
      fileToUpload.name = p.basename(file.absolute.path);
      try {
        var response = await drive.files.create(
          fileToUpload,
          uploadMedia: ga.Media(file.openRead(), file.lengthSync()),
        );
        return 1;
      } on Exception catch (ex) {
        if (kDebugMode) {
          print(ex);
        }
        return 0;
      }
    }
  }*/

  // Original method
  // See if there's a way to validate SHA256 cryptography.
  uploadFileToGoogleDrive(File file) async {
    drive = ga.DriveApi(client!);
    //appfolderID = await _getFolderId(drive);
    String? folderId = await _getFolderId(drive);
    if (folderId == null)  //(appfolderID == null)
    {
      if (kDebugMode) {
        print("Sign-in first Error");
      }
    } else {
      ga.File fileToUpload = ga.File();
      fileToUpload.parents = [folderId]; //[appfolderID];
      fileToUpload.name = p.basename(file.absolute.path);
      try {

        var response = await drive.files.create(
          fileToUpload,
          uploadMedia: ga.Media(file.openRead(), file.lengthSync()),
        );
        return 1;
      } on Exception catch (ex) {
        if (kDebugMode) {
          print(ex);
        }
        return 0;
      }
    }
  }

  // Double check to see if this method is doing it's job properly, method checks file age on device vs. Drive.
  //Improvements here could be using file IDs and SHA256 checking
  Future<bool> checkFileAge(String fileName, String directoryName) async {
    client ??= await getHttpClient();
    try {
      drive = ga.DriveApi(client!);

      File file = File(directoryName);
      if (file.existsSync() == true) {
        var modifiedTime = file.lastModifiedSync();

        //Query for files on Drive to test against device
        var queryDrive = await drive.files.list(
          q: "name contains '$fileName'",
          $fields: "files(id, name,createdTime,modifiedTime)",
        );
        var files = queryDrive.files;
        // Need for repeating until query is loaded or no file exists
        if (files!.isEmpty) {
          var queryDrive = await drive.files.list(
            q: "name contains '$fileName'",
            $fields: "files(id, name,createdTime,modifiedTime)",
          );
          print(queryDrive.files);
        }
        if (files.isNotEmpty) {
          files = queryDrive.files;
          var checkFile = files!.first;
          var checkTime = checkFile.createdTime;
          return (checkTime!.isBefore(modifiedTime));
        } else if (files.isEmpty) {
          return true;
        } else {
          return false;
        }
      } else {
        throw Exception("File not found $fileName");
      }
    } on Exception catch (ex) {
      if (kDebugMode) {
        print(ex);
      }
      return false;
    }
  }



  /// Get File Ids from the user's Google Drive

Future<void> _loadDriveFileIDs() async{
    ///Use encrypted shared prefs since they are in use across the application
  final String? idsJson = prefs.getString(_driveFileIDsPrefKey);
  if(idsJson!=null){
    _driveFileIDs = Map<String,String>.from(convert.json.decode(idsJson));
  }

}
Future<void> _saveDriveFileIds(String fileName, String driveID) async{
    _driveFileIDs[fileName] = driveID;
    await prefs.setString(_driveFileIDsPrefKey, convert.json.encode(_driveFileIDs));
}

//Get remote file metadata to validate SHA Hash and timestamps
  /*Future<ga.File?> _getRemoteMetadata(String fileName) async{
    if( drive==null) return null;
    final driveID = _driveFileIDs[fileName];
    if(driveID!=null){
      try{
        //return await drive.files.get(driveID,);
      }
    }


  }*/




  /// Check to see if the file exists in Google Drive
  /// Using a stored fileID will help with managing this.
  Future<bool> checkForFile(String fileName) async {
    drive = ga.DriveApi(client!);

    var queryDrive = await drive.files.list(
      q: "name contains '$fileName'",
      $fields: "files(id, name,createdTime,modifiedTime)",
    );
    var files = queryDrive.files;
    var i = 0;
    if (files!.isEmpty) {
      var queryDrive = await drive.files.list(
        q: "name contains '$driveStoreDirectory/$fileName'",
        $fields: "files(id, name,createdTime,modifiedTime)",
      );
      files = queryDrive.files;
    }
    if (files!.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }
// Delete only if the file in the cloud is older and ensure the device's DB is newer before upload.
  deleteOutdatedBackups(String fileName) async {
    drive = ga.DriveApi(client!);
    final queryDrive = await drive.files.list(
      q: "name contains '$fileName'",
      $fields: "files(id, name,createdTime,modifiedTime)",
    );
    final files = queryDrive.files;
    if (files?.isNotEmpty == true) {
      var idList = [];
      int? test = files?.length;
      for (int i = 0; i <= test! - 1; i++) {
        idList.add(files?[i].id);
      }
      //Removes outdated backups.
      for (var element in idList) {
        drive.files.delete(element);
      }
    }
  }
// Check for usages to see if there is a check being placed before syncing
  Future<void> syncBackupFiles(String fileName) async {
    isDoingSomething = true;
    drive = ga.DriveApi(client!);
    String fileLocation = keyLocation;
    final queryDrive = await drive.files.list(
      q: "name contains '$fileName'",
      $fields: "files(id, name,createdTime,modifiedTime)",
    );
    final files = queryDrive.files;
    var idList = [];
    var nameList = [];
    int? queryCt = files?.length;
    if (queryCt! > 0) {
      for (int i = 0; i < queryCt; i++) {
        idList.add(files?[i].id);
        nameList.add(files?[i].name);
      }
      for (int i = 0; i < idList.length; i++) {
        ga.Media file = await drive.files.get(idList[i],
            downloadOptions: ga.DownloadOptions.fullMedia) as ga.Media;

        final saveFile = File(p.join(fileLocation, nameList[i]));
        List<int> dataStore = [];
        file.stream.listen((data) {
          dataStore.insertAll(dataStore.length, data);
        }, onDone: () {
          if (kDebugMode) {
            print("Task Done");
          }
          saveFile.writeAsBytes(dataStore);
          if (kDebugMode) {
            print("File saved at ${saveFile.path}");
          }
          isDoingSomething = false;
        }, onError: (error) {
          if (kDebugMode) {
            print("Some Error");
          }
          isDoingSomething = false;
        });
      }
    } else {
      if (kDebugMode) {
        print("Nothing's here");
      }
      isDoingSomething = false;
    }
  }
}
