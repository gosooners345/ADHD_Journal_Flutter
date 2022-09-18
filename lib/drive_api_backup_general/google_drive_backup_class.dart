import 'dart:io';
import 'package:adhd_journal_flutter/app_start_package/login_screen_file.dart';
import 'package:adhd_journal_flutter/app_start_package/splash_screendart.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'security_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:firebase_auth/firebase_auth.dart';



const _clientId = "639171720797-1947q85ikvusptoul5tdhjffodrlhlrh.apps.googleusercontent.com";
const _scopes = ['https://www.googleapis.com/auth/drive.file'];

class GoogleDrive {

  String fileID = "";
  //Get Authenticated Http Client
  Future<http.Client> getHttpClient() async {

    final googleSignIn = signIn.GoogleSignIn.standard(scopes: [ga.DriveApi.driveScope,
        ga.DriveApi.driveAppdataScope]);
     signIn.GoogleSignInAccount? account;
      if(userActiveBackup = false) {
        account = await googleSignIn.signIn();
      } else {
        account = await googleSignIn.signInSilently(reAuthenticate: true);
      }
      var authHeaders = await account?.authHeaders;
      var authenticateClient = GoogleAuthClient(authHeaders!);

    print(authenticateClient._headers);
      return authenticateClient;

    }


  // check if the directory folder is already available in drive , if available return its id
  // if not available create a folder in drive and return id
  //   if not able to create id then it means user authentication has failed
  Future<String?> _getFolderId(ga.DriveApi driveApi) async {
    const mimeType = "application/vnd.google-apps.folder";


    try {
      final found = await driveApi.files.list(
        q: "mimeType = '$mimeType' and name = '$driveStoreDirectory'",
        $fields: "files(id, name)",
      );
      final files = found.files;
      if (files == null) {
        print("Sign-in first Error");
        return null;
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
      print("Folder ID: ${folderCreation.id}");

      return folderCreation.id;
    } catch (e) {
      print(e);
      return null;
    }
  }


  uploadFileToGoogleDrive(File file) async {
    var client = await getHttpClient();
    var drive = ga.DriveApi(client);
    String? folderId =  await _getFolderId(drive);
    if(folderId == null){
      print("Sign-in first Error");
    }else {
      ga.File fileToUpload = ga.File();
      fileToUpload.parents = [folderId];
      fileToUpload.name = p.basename(file.absolute.path);

      var response = await drive.files.create(
        fileToUpload,
        uploadMedia: ga.Media(file.openRead(), file.lengthSync()),
      );
      final queryDrive = await drive.files.list (
        q: "name contains 'activitylogger_db.db'",
        $fields: "files(id, name,createdTime)",

      );
      final files = queryDrive.files;
      var saveThis = files?.first;
      var idList = [];
      int? test = files?.length!;
      for(int i = 0; i <= test!-1!;i++)
        {
          if(files?[i].id != saveThis!.id )
            idList.add(files?[i].id);
        }
      for (var element in idList) {drive.files.delete(element);}
      }
    final queryDrive = await drive.files.list (
      q: "name contains 'activitylogger_db.db'",
      $fields: "files(id, name,createdTime)",

    );
    final files = queryDrive.files;
    print(files?.length);
    }


  Future<void> downloadGoogleDriveFile(String fName) async {
    const mimeType = "application/vnd.google-apps.folder";
    var client = await getHttpClient();
    var drive = ga.DriveApi(client);

final queryDrive = await drive.files.list (
q: "name contains 'activitylogger_db.db'",
    $fields: "files(id, name)",

);
    final files = queryDrive.files;
final subFiles = files?.last;
String? fileID = subFiles?.id;
    ga.Media file = await drive.files.get(fileID!, downloadOptions: ga.DownloadOptions.fullMedia) as ga.Media;

    final saveFile = File(dbLocation);
    List<int> dataStore = [];
    file.stream.listen((data) {
      print("DataReceived: ${data.length}");
      dataStore.insertAll(dataStore.length, data);
    }, onDone: () {
      print("Task Done");
      saveFile.writeAsBytes(dataStore);
      print("File saved at ${saveFile.path}");
    }, onError: (error) {
      print("Some Error");
    });
  }
}
class GoogleAuthClient extends http.BaseClient{
  final Map<String,String> _headers;
  final http.Client _client = new http.Client();
  GoogleAuthClient(this._headers);
  final storage = SecureStorage();
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }



}