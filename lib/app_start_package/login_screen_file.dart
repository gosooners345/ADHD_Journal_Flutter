
import 'dart:async';
import 'dart:convert';
import 'package:adhd_journal_flutter/project_resources/project_strings_file.dart';
import 'package:adhd_journal_flutter/records_stream_package/records_bloc_class.dart';
import 'package:flutter/foundation.dart';
//import 'package:googleapis/drive/v3.dart' as ga;
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import '../backup_providers/google_drive_backup_class.dart';
import '../backup_utils_package/crypto_utils.dart';
import '../project_resources/file_manager_helper.dart';
import '../project_resources/project_colors.dart';
import 'splash_screendart.dart';
import 'onboarding_widget_class.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhd_journal_flutter/backup_utils_package/preference_backup_class.dart';
import 'dart:io';

/// Required to open the application , simple login form to start. The performance of this screen can be examined to test for improvements.
/// The second point of failure in the bug that results in two journals being uploaded simply because it was opened. If Google Drive permits SHA256 checks, this may allow us to validate if the files are the same.
///

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    Key? key,
    required this.swapper,
  }) : super(key: key);
  final ThemeSwap? swapper;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

bool passwordEnabled = true;
String dbPassword = '';
String userPassword = '';
bool isPasswordChecked = false;
String greeting = '';
TextField loginField = const TextField();
String dlDBPassword = '';
String dlUserPassword = "";
int dlColorSeed = 0;
String dlGreeting = '';
String dlPasswordHint = '';
bool dlPasswordEnabled = false;
String decipheredData = "";
bool isThisReturning = false;

///Handles the states of the application.
class _LoginScreenState extends State<LoginScreen> {
  String loginPassword = '';
  String loginGreeting = '';
  var encryptedOrNot = false;
  late SharedPreferences sharedPrefs;
  late TextEditingController stuff;
  TextField loginField = const TextField();
  Row greetingField = const Row(
    children: [],
  );
  String hintText = '';
  String hintPrompt = '';
  late ElevatedButton driveButton;
  String connectionState = "";
  @override
  void initState() {
    super.initState();
    getNetStatus();
    loadStateStuff();
    // Migrate check code to separate class and have it called from either place IOS : Login, Android: Splashscreen
    if (passwordHint == '') {
      hintText = 'Enter secure password';
      hintPrompt =
          'The app now allows you to store a hint so it\'s easier to remember your password in case you forget. \r\n Set it to something memorable.\r\n This will be encrypted like your password so nobody can read your hint.'
          '\r\n You can enter this in settings.';
    } else {
      hintText = 'Password Hint is : $passwordHint';
    }
    setState(() {
      driveButton = ElevatedButton(
          onPressed: () async {
            var authenticated = prefs.getBool("authenticated") ?? false;
            if (authenticated == false) {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Backup and Sync Feature "),
                      content: const Text(
                          "You're about to turn on Backup and Sync for ADHD Journal. The service uses your Google Drive account to store your Journal and related files with it. "
                          "All encrypted. Your journal, passwords, and preferences sync between all devices linked with your gmail and this app. For more information, check out the help page in settings."),
                      actions: <Widget>[
                        TextButton(
                          child: const Text("Yes"),
                          onPressed: () {
                            if (connected == true) {
                              //insert google drive method here to work for the app.
                              logIntoGoogle();

                              //drive. = await  googleDrive.getHttpClient();
                            //  googleIsDoingSomething(true);
                              //Check for DB on device ,

                            } else {
                              showMessage(connection_Error_Message_String);
                            }
                          },
                        ),
                        TextButton(
                            onPressed: () {
                              userActiveBackup = false;
                              prefs.setBool("testBackup", userActiveBackup);
                              showMessage(
                                  "To turn Backup & Sync on, simply hit Backup to Google Drive and hit Yes next time!");
                              Navigator.of(context).pop();
                            },
                            child: const Text("No"))
                      ],
                    );
                  });
            } else {
              if (connected == true) {
               googleDrive.initVariables();
                /*googleDrive.client =
                    await Future.sync(() => googleDrive.getHttpClient());*/
              //  await Future.sync(() => checkForAllFiles("Drive"))
              await checkGoogleDrive()
                    .whenComplete(() {
                          resetLoginFieldState();
                          setState(() {
                            Future.sync(() => getSyncStateStatus());
                          });
                        });
              } else {
                showMessage(connection_Error_Message_String);
              }
            }
          },
          child: Row(
            children: [
              Image.asset(
                'images/GoogleDriveLogo.png',
                height: 35,
              ),
              const SizedBox(
                width: 40,
              ),
              const Text("Backup with Google Drive")
            ],
          ));
      stuff = TextEditingController();
    });
  }

  void logIntoGoogle() async{
    googleDrive=GoogleDrive();
    googleDrive.initVariables();
    await checkGoogleDrive()
        .whenComplete(() {
      resetLoginFieldState();
      setState(() async{
        await getSyncStateStatus();
        if(mounted) {
          Navigator.of(context).pop();
        }
      });

    });

  }
  //Find a way to migrate most of the code to a single method outside of this class. Probably put it in Google Drive?

/*  Future<void> checkFileAge() async {
    isThisReturning = false;
    if (kDebugMode) {
      print("Login Check File Age Called");
    }
    File file = File(dbLocation); // DB
    googleIsDoingSomething(true);
    File privKeyFile = File(path.join(keyLocation, privateKeyFileName));
    try {
      bool fileCheckAge = false;
      fileCheckAge = await Future.sync(
              () => googleDrive.checkFileAge(databaseName, dbLocation));
      String dataForEncryption =
          '$userPassword,$dbPassword,$passwordHint,${passwordEnabled.toString()},$greeting,$colorSeed';
      var onlineKeys = await googleDrive.checkForFile(privateKeyFileName);
// Keys first
      if (onlineKeys) {
        await preferenceBackupAndEncrypt.downloadRSAKeys(googleDrive);
      } else if (!privKeyFile.existsSync() && !onlineKeys) {
        preferenceBackupAndEncrypt.encryptRsaKeysAndUpload(googleDrive);
      } else {
        preferenceBackupAndEncrypt.assignRSAKeys(googleDrive);
      }

      bool fileCheckCSV = await googleDrive.checkForFile(prefsName);
      bool txtFileCheckAge = false;
      //Check for file
      if (fileCheckCSV) {
        // If file exists on Google Drive execute
        txtFileCheckAge =
        await googleDrive.checkFileAge(prefsName, docsLocation);
        if (txtFileCheckAge) {
          // if file is older in the cloud
          preferenceBackupAndEncrypt.encryptData(
              dataForEncryption, googleDrive);
        } else {
          await preferenceBackupAndEncrypt.downloadPrefsCSVFile(googleDrive);
          if (dataForEncryption == decipheredData) {
            isDataSame = true;
          } else {
            isDataSame = false;
          }
        }
      } else {
        //otherwise
        File checkPrefsTxt = File(docsLocation);
        if (checkPrefsTxt.existsSync()) {
          checkPrefsTxt.deleteSync();
        } else {
          await preferenceBackupAndEncrypt.downloadPrefsCSVFile(googleDrive);
          if (dataForEncryption == decipheredData) {
            isDataSame = true;
          } else {
            isDataSame = false;
          }
        }
      }
      bool isDBOnline = await googleDrive.checkForFile(databaseName);

//Last DB
      if (fileCheckAge == false || file.existsSync() == false) {
        if (isDBOnline) {
          await Future.sync(() => restoreDBFiles());
        } else {
          throw Exception(
              "File not on Google Drive, you'll need to open app first");
        }
      } else {
        await uploadDBFiles();
        googleIsDoingSomething(false);
      }
      if (isDataSame == false) {
        googleIsDoingSomething(true);
        setState(() {
          updateValues();
        });
        googleIsDoingSomething(false);
      }
    } on Exception catch (ex) {
      showMessage(ex.toString());
      await Future.sync(() => restoreDBFiles());
      preferenceBackupAndEncrypt.downloadRSAKeys(googleDrive);
      await preferenceBackupAndEncrypt.downloadPrefsCSVFile(googleDrive);
      if (isDataSame == false) {
        googleIsDoingSomething(true);
        setState(() {
          updateValues();
        });
        googleIsDoingSomething(false);
      } else {
        googleIsDoingSomething(false);
      }
    }
  }*/
  Future<bool> checkPreferences() async {
    File preferencesFile = File(docsLocation);
    String decipheredData = CryptoUtils.rsaDecrypt(preferencesFile.readAsStringSync(
        encoding: Encoding.getByName("utf-8")!),preferenceBackupAndEncrypt.privKey!);

    String dataForEncryption =
        '$userPassword,$dbPassword,$passwordHint,${passwordEnabled
        .toString()},$greeting,$colorSeed';
    googleIsDoingSomething(true);
    if (dataForEncryption == decipheredData) {
      setState(() {
        showMessage( "Preferences are up to date");
      });
      return true;
    }
    else {
      setState(() {
        showMessage(
        "Preferences are out of date, we will need to update the local version.");
      });
      return false;
    }
  }
  Future<void> checkFilesExistV2(String localFileName,String remoteFileName, String fileType)async{
    var fileChecker = ManagedFile(localFileName,remoteFileName);
    //Check for existence of files and age.
    print("Checking $fileType");
    await fileChecker.checkLocalExistence();
    await fileChecker.checkRemoteExistence(googleDrive);
    await fileChecker.checkRemoteIsNewer(googleDrive);
    //Check file existence first locally then remotely. If file exists in cloud, but not on device, then download it.
    //Done
    if(!fileChecker.localExists){
      //Check if file exists on cloud.
      if(!fileChecker.remoteExists){
        if(kDebugMode) {
          print("File does not exist on device or cloud");
        }

        showMessage( "$fileType does not exist on device or cloud");
        showMessage( "You will need to open the journal to create the file");


      } //Download if exists in cloud.
      else{
        if(kDebugMode){
          print("File exists on cloud but not on device");
        }

        showMessage( "$fileType exists on cloud but not on device");
        showMessage( "Downloading $fileType now");

        //Use Switch Case statement to handle file delivery
        switch (fileType) {
          case "Journal":
            await restoreDBFiles();
            break;
          case "Preferences":
            await preferenceBackupAndEncrypt.downloadPrefsCSVFile(googleDrive).whenComplete((){
              updateValues();
            });
            //Process file.
            break;
          case "Keys":
            await preferenceBackupAndEncrypt.downloadRSAKeys(googleDrive);
            break;
        }
      }
    }
    //If cloud copy doesn't exist, then we can upload it.
    if(!fileChecker.remoteExists && fileChecker.localExists){
      if(kDebugMode){
        print("$fileType exists on device but does not exist on device or cloud, uploading to Drive");}
      setState(() {
        showMessage( "$fileType does not exist on device or cloud");
      });
      //use switch case statement to handle file delivery, uploading here
      switch (fileType) {
        case "Journal":
          await uploadDBFiles();
          break;
        case "Preferences":
          String dataForEncryption =
              '$userPassword,$dbPassword,$passwordHint,${passwordEnabled.toString()},$greeting,$colorSeed';
          googleIsDoingSomething(true);
          await preferenceBackupAndEncrypt.encryptData(dataForEncryption, googleDrive).whenComplete(() {
            setState(() {
              showMessage( "Preferences Uploaded");
            });
            googleIsDoingSomething(false);});

          break;
        case "Keys":
          await preferenceBackupAndEncrypt.encryptRsaKeysAndUpload(googleDrive).whenComplete(() {
            setState(() {
              showMessage( "Encryption keys Uploaded");
            });
            googleIsDoingSomething(false);
          });
          break;
      }
    }
    if(fileChecker.localExists && fileChecker.remoteExists){
      if(fileChecker.localIsNewer!){
//In future update, integrate file IDs
        showMessage( "$fileType exists on device and cloud but is newer on device. Replacing file in cloud with new local copy.");
        //Use switch case statement to handle file delivery,
        switch (fileType) {
        // Future update integrate DB ID to reduce frequency of double uploading
          case "Journal":
            await uploadDBFiles();
            break;
          case "Preferences":
            String dataForEncryption =
                '$userPassword,$dbPassword,$passwordHint,${passwordEnabled.toString()},$greeting,$colorSeed';
            googleIsDoingSomething(true);
            await preferenceBackupAndEncrypt.encryptData(dataForEncryption, googleDrive).whenComplete(() {
              setState(() {
                showMessage( "Preferences Uploaded");
              });
              googleIsDoingSomething(false);});
            break;
          case "Keys":
            await preferenceBackupAndEncrypt.encryptRsaKeysAndUpload(googleDrive).whenComplete(() {
              setState(() {
                showMessage( "Encryption keys Uploaded");
              });
              googleIsDoingSomething(false);
            });
            break;
        }
      }
      else{
        showMessage( "$fileType exists on device and cloud but is newer on cloud");
        showMessage( "Downloading updated $fileType now");
        googleIsDoingSomething(true);
        //Use switch case statement to handle file delivery
        switch (fileType) {
          case "Journal":
            await restoreDBFiles().whenComplete(() {
              showMessage( "Journal Updated");
            });
            break;
          case "Preferences":
            await preferenceBackupAndEncrypt.downloadPrefsCSVFile(googleDrive).whenComplete(() {
              showMessage( "Updated preferences downloaded, checking for mismatches");
            });
            final isDataSame = await checkPreferences();
            if(!isDataSame){
              showMessage( "Preferences are out of date, we will need to update the local version.");
              googleIsDoingSomething(true);
              await Future.sync(() => updateValues()).whenComplete(() {
                showMessage( "Preferences Updated");
                googleIsDoingSomething(false);
              });
            }
            else{showMessage( "Preferences are up to date");}

            break;
          case "Keys":
            await preferenceBackupAndEncrypt.downloadRSAKeys(googleDrive).whenComplete(() {
              showMessage( "Encryption keys Updated");
            });
            break;
        }

      }
    }
  }

  Future<void> checkGoogleDrive() async{
    if (connected == true) {
      userActiveBackup = prefs.getBool('testBackup') ?? false;
      print("Backup is turned on: $userActiveBackup");
    }
    if (userActiveBackup) {

      //showMessage( "You have backup and sync enabled! Signing into Google Drive!");

      //googleDrive = GoogleDrive();
      try{
        //googleDrive.initVariables();
        if(googleDrive.client == null){
          throw Exception("Google Drive needs initialized");
        }
        print("Intialized google drive variables");
      }
      on Exception catch(ex){
        if(kDebugMode){
          print(ex);
        }
        googleDrive.client = await  googleDrive.getHttpClient();
        googleDrive.initV2();
      }
      googleIsDoingSomething(true);
      if (googleDrive.client != null) {
        if (userActiveBackup) {

          print("Checking Keys");
          await checkFilesExistV2(path.join(keyLocation, privateKeyFileName), privateKeyFileName, "Keys").whenComplete(()
          async {
            await checkFilesExistV2(path.join(keyLocation, pubKeyFileName), pubKeyFileName, "Keys");
            print("Checking Journal");
            await checkFilesExistV2(dbLocation, databaseName, "Journal");
            print("Checking Preferences");
            await checkFilesExistV2(docsLocation, prefsName, "Preferences");});//3x

        }
      }
      else {
        userActiveBackup = false;
    //    showMessage(
      //  "To protect your data, you'll need to sign into Google Drive and approve application access to backup your stuff!";
      }
    }
    else {
      showMessage(
      "You have backup and sync disabled! You can enable this  "
          "by hitting Sign into Google Drive! You can disable this feature in Settings ");
    }

  }

/*  Future<void> checkForAllFiles(String callBack) async {
    if (kDebugMode) {
      print("Check all files called");
    }
    //Check for DB on device
    var checkDB = File(dbLocation);
    //Check for Keys on device
    var checkPrivateKeys = File(path.join(keyLocation, privateKeyFileName));
    var checkPublicKeys = File(path.join(keyLocation, pubKeyFileName));
    //Check for preferences on device
    var checkPrefs = File(docsLocation);
    //Check for Journals file on Google Drive
    var checkJournalFileExist =
        await Future.sync(() => googleDrive.checkForFile(driveStoreDirectory));
    if (checkJournalFileExist) {
      var checkPrivateKeyOnline =
          await Future.sync(() => googleDrive.checkForFile(privateKeyFileName));
      var checkPublicKeyOnline =
          await Future.sync(() => googleDrive.checkForFile(pubKeyFileName));
      //Check for preferences file online
      var checkPrefsOnline =
          await Future.sync(() => googleDrive.checkForFile(prefsName));
      //Check for DB online
      var checkDBOnline =
          await Future.sync(() => googleDrive.checkForFile(databaseName));
//Condition statements here
      if (callBack == "Drive" || callBack == "") {
        if (checkDBOnline &&
            checkPrefsOnline &&
            checkPrivateKeyOnline &&
            checkPublicKeyOnline) {
          if (checkDB.existsSync() ||
              checkPrefs.existsSync() ||
              checkPrivateKeys.existsSync() ||
              checkPublicKeys.existsSync()) {
            switch (callBack) {
              case "Drive":
                if(!mounted){ break;}

               showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Data exists online already"),
                        content: const Text(
                            "It appears you have data online from another device, do you want to download it to this device and overwrite what's already on here?"),
                        actions: [
                          TextButton(
                            child: const Text("Yes"),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              if (checkPublicKeys.existsSync()) {
                                checkPublicKeys.deleteSync();
                              }
                              if (checkPrivateKeys.existsSync()) {
                                checkPrivateKeys.deleteSync();
                              }
                              await Future.sync(() => preferenceBackupAndEncrypt
                                  .downloadRSAKeys(googleDrive));
                              if (checkPrefs.existsSync()) {
                                checkPrefs.deleteSync();
                                await Future.sync(() =>
                                    preferenceBackupAndEncrypt
                                        .downloadPrefsCSVFile(googleDrive));
                              }
                              if (checkDB.existsSync()) {
                                checkDB.deleteSync();
                                await Future.sync(() => restoreDBFiles());
                              }
                            },
                          ),
                          TextButton(
                              onPressed: () async {
                                if (checkPrivateKeys.existsSync() &&
                                    checkPublicKeys.existsSync()) {
                                  preferenceBackupAndEncrypt
                                      .encryptRsaKeysAndUpload(googleDrive);
                                }
                                if (checkPrefs.existsSync()) {
                                  String dataForEncryption =
                                      '$userPassword,$dbPassword,$passwordHint,${passwordEnabled.toString()},$greeting,$colorSeed';
                                  if (kDebugMode) {
                                    print("Data is being encrypted and uploaded");
                                  }
                                  googleIsDoingSomething(true);
                                  preferenceBackupAndEncrypt.encryptData(
                                      dataForEncryption, googleDrive);
                                  googleIsDoingSomething(true);
                                }
                                if (checkDB.existsSync()) {
                                  uploadDBFiles();
                                }
                              },
                              child: const Text("No"))
                        ],
                      );
                    });
                break;
// Trying to get the files to sync to device , use splashscreen approach
              default:
                await checkGoogleDrive();
                break;
            }
          } else if (!checkDB.existsSync() ||
              !checkPrefs.existsSync() ||
              !checkPrivateKeys.existsSync() ||
              !checkPublicKeys.existsSync()) {
            if (!checkPrivateKeys.existsSync() ||
                !checkPublicKeys.existsSync()) {
              await Future.sync(() =>
                  preferenceBackupAndEncrypt.downloadRSAKeys(googleDrive));
            }
            if (!checkPrivateKeys.existsSync()) {
              await Future.sync(() =>
                  preferenceBackupAndEncrypt.downloadPrefsCSVFile(googleDrive));
              String dataForEncryption =
                  '$userPassword,$dbPassword,$passwordHint,${passwordEnabled.toString()},$greeting,$colorSeed';
              if (dataForEncryption != decipheredData) {
                isDataSame = false;
              }
            }
            if (!checkDB.existsSync()) {
              await Future.sync(() => restoreDBFiles());
            }
            if (isDataSame == false) {
              updateValues();
            }
          }
        } else {
          if (kDebugMode) {
            print("Keys are not online");
          }
          preferenceBackupAndEncrypt.encryptRsaKeysAndUpload(googleDrive);
          googleIsDoingSomething(true);
          if (kDebugMode) {
            print("Prefs are not online");
          }
          String dataForEncryption =
              '$userPassword,$dbPassword,$passwordHint,${passwordEnabled.toString()},$greeting,$colorSeed';
          if (kDebugMode) {
            print("Data is being encrypted and uploaded");
          }
          googleIsDoingSomething(true);
          preferenceBackupAndEncrypt.encryptData(
              dataForEncryption, googleDrive);
          googleIsDoingSomething(true);
          showMessage("Preferences Uploaded");
        }
      }
    } else {
      print("Creating Journals folder");
      ga.File journalFile = ga.File();
      journalFile.name = driveStoreDirectory;
      var mimetype = "application/vnd.google-apps.folder";
      journalFile.mimeType = mimetype;
      await Future.sync(() => googleDrive.drive.files.create(journalFile));
      if (checkDB.existsSync() == true ||
          checkPrefs.existsSync() == true ||
          checkPublicKeys.existsSync() == true &&
              checkPrivateKeys.existsSync() == true) {
        googleIsDoingSomething(true);
        if (kDebugMode) {
          print("Uploading keys");
        }
        preferenceBackupAndEncrypt.encryptRsaKeysAndUpload(googleDrive);
        if (kDebugMode) {
          print("Data is being encrypted and uploaded");
        }
        String dataForEncryption =
            '$userPassword,$dbPassword,$passwordHint,${passwordEnabled.toString()},$greeting,$colorSeed';
        preferenceBackupAndEncrypt.encryptData(dataForEncryption, googleDrive);
        if (checkDB.existsSync() == true) {
          await Future.sync(() => uploadDBFiles())
              .whenComplete(() => googleIsDoingSomething(false));
        }
      } else {
        if (checkPublicKeys.existsSync() == false ||
            checkPrivateKeys.existsSync() == false) {
          if (kDebugMode) {
            print("Keys aren't online");
          }
          googleIsDoingSomething(true);
          preferenceBackupAndEncrypt.encryptRsaKeysAndUpload(googleDrive);
          googleIsDoingSomething(true);
          showMessage("Encryption keys Uploaded");
        }
        if (checkPrefs.existsSync() == false) {
          if (kDebugMode) {
            print("Prefs are not online");
          }
          String dataForEncryption =
              '$userPassword,$dbPassword,$passwordHint,${passwordEnabled.toString()},$greeting,$colorSeed';
          if (kDebugMode) {
            print("Data is being encrypted and uploaded");
          }
          googleIsDoingSomething(true);
          preferenceBackupAndEncrypt.encryptData(
              dataForEncryption, googleDrive);
          googleIsDoingSomething(true);
          showMessage("Preferences Uploaded");
        }
        if (checkDB.existsSync() == false) {
          showMessage(
              "You need to open the journal up once to create the DB file for backup & sync");
          googleIsDoingSomething(false);
        }
      }
    }
  }*/

  Future<bool> getNetStatus() async {
    if (connected) {
      userActiveBackup = prefs.getBool('testBackup') ?? false;
    }
    return connected;
  }

  void loadStateStuff() async {
    prefs = await SharedPreferences.getInstance();
    passwordEnabled = prefs.getBool('passwordEnabled') ?? true;
    greeting = prefs.getString("greeting") ?? '';
    loginGreeting = await Future.sync(() => getGreeting());

    userPassword = await encryptedSharedPrefs.getString('loginPassword');
    //Dumb bug flutter imposed on shared prefs with index out of range exceptions
    try {
      dbPassword = await encryptedSharedPrefs.getString('dbPassword');
    } on Exception catch (ex) {
      if (kDebugMode) {
        print(ex);
      }
      try {
        await encryptedSharedPrefs.remove('dbPassword');
      } on Exception catch (ex) {
        if (kDebugMode) {
          print(ex);
        }
      }
      dbPassword = userPassword;
      await encryptedSharedPrefs.setString('dbPassword', dbPassword);
    }
    passwordHint = await getPasswordHint();
    isPasswordChecked = passwordEnabled;
    if (userPassword != dbPassword) {
      dbPassword = userPassword;
    }
    setState(() {
      resetLoginFieldState();
    });
    googleIsDoingSomething(true);
    await Future.delayed(const Duration(seconds: 2), checkDataFiles);
    googleIsDoingSomething(false);
  }

  void checkDataFiles() async {
    if (userActiveBackup) {
      if (isThisReturning == true || Platform.isIOS) {
        // if the app is Running on iOS, the app will run this
        if (Platform.isIOS) {
          if (googleDrive.client == null) {
            googleIsDoingSomething(true);
          }
        }
        // This is simply checking all files
        if (googleDrive.client != null) {
          await checkGoogleDrive();
          //await Future.sync(() => checkForAllFiles(""));
        }
        else{
          googleDrive = GoogleDrive();
          googleDrive.initVariables();
          await checkGoogleDrive();
        }
      }
      if (isDataSame == false) {
        googleIsDoingSomething(true);
        updateValues();
        googleIsDoingSomething(false);
      }
      if (Platform.isAndroid) {
        googleIsDoingSomething(false);
      }
    } else {
      googleIsDoingSomething(false);
    }
  }

  Future<String> getGreeting() async {
    greeting = prefs.getString('greeting') ?? '';
    String opener = 'Welcome ';
    String closer = (passwordEnabled == true)
        ? '! Sign in with your password below.'
        : "! Hit the Login Button to sign in.";

    return opener + greeting + closer;
  }

  Future<String> getPasswordHint() async {
    return encryptedSharedPrefs.getString("passwordHint");
  }

  Future<bool> getSyncStateStatus() async {
    return userActiveBackup;
  }

  Future<bool> getPasswordEnabledState() async {
    return prefs.getBool('passwordEnabled') ?? true;
  }

  void refreshPrefs() async {
    prefs.reload();
    await Future.sync(() => encryptedSharedPrefs.reload());
    await Future.delayed(const Duration(seconds: 1), loadStateStuff);
  }

  void resetLoginFieldState() async {
    final recordsBloc = Provider.of<RecordsBloc>(context,listen: false);

    setState(() {
      if (passwordHint == '' || passwordHint == ' ') {
        hintText = 'Enter secure password';
      } else {
        hintText = 'Password Hint is : $passwordHint';
      }
      greetingField = Row(children: [
        Expanded(
            child: Text(
          loginGreeting,
          style: const TextStyle(
            fontSize: 20.0,
          ),
          textAlign: TextAlign.center,
        ))
      ]);

      if (passwordEnabled) {
        loginField = TextField(
          obscureText: true,
          controller: stuff,
          decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Password',
              hintText: hintText),
          onChanged: (text) {
            loginPassword = text;
            if (text.length == userPassword.length) {
              if (text == userPassword) {
                recordsBloc.getRecords();
                Navigator.pushReplacementNamed(context, '/success').then((value) => {
                      isThisReturning = true,
                      refreshPrefs(),
                      //recordsBloc.currentRecordHolder.clear(),
                      stuff.clear(),
                    });
              } else {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text(
                          "Invalid password",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        content: const Text(
                            'You have entered the incorrect password. Please try again.'),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Ok"))
                        ],
                      );
                    });
              }
            }
          },
          enabled: true,
        );
      } else {
        loginField = TextField(
          obscureText: true,
          controller: stuff,
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Password Disabled. Hit Login to continue',
              hintText: 'Password Disabled. Hit Login to continue'),
          onChanged: (text) {
            loginPassword = text;
          },
          enabled: false,
        );
      }
    });
    googleIsDoingSomething(false);
  }
//This needs to move
  /// Check the user's Google Drive for age of file or even if the file exists


//Experimental
  Future<void> uploadDBFiles() async {
    googleIsDoingSomething(true);
    googleDrive.deleteOutdatedBackups(databaseName);
    googleDrive.uploadFileToGoogleDrive(File(dbLocation));
    googleDrive.uploadFileToGoogleDrive(File("$dbLocation-wal"));
    googleDrive.uploadFileToGoogleDrive(File("$dbLocation-shm"));
    googleIsDoingSomething(false);
    showMessage('Your journal is now uploaded!');
  }

  //Experimental
  Future<void> restoreDBFiles() async {
    try {
      googleIsDoingSomething(true);
      await Future.sync(() => googleDrive.syncBackupFiles(databaseName))
          .whenComplete(() => googleIsDoingSomething(false));
      var getFileTime = File(dbLocation);
      var time = getFileTime.lastModifiedSync();
      showMessage('Your journal is synced as of ${time.toLocal()}');
    } on Exception {
      showMessage('You need to open up the journal once to back it up.');
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void googleIsDoingSomething(bool value) {
    readyButton.boolSink.add(value);
  }

  void updateValues() async {
    googleIsDoingSomething(true);
    readyButton.boolSink.add(true);
    showMessage("Updating preferences");
    if (decipheredData == '') {
      File prefsFile = File(docsLocation);
      googleIsDoingSomething(true);
      if (prefsFile.existsSync()) {
        decipheredData = CryptoUtils.rsaDecrypt(
            prefsFile.readAsStringSync(encoding: Encoding.getByName("utf-8")!),
            preferenceBackupAndEncrypt.privKey!);
      } else {
        preferenceBackupAndEncrypt.downloadPrefsCSVFile(googleDrive);
      }
    }
    var newValues = decipheredData.split(',');
    dlUserPassword = newValues[0];
    dlDBPassword = newValues[1];
    dlPasswordHint = newValues[2];
    dlPasswordEnabled = newValues[3] == "true" ? true : false;
    dlGreeting = newValues[4];
    dlColorSeed = int.parse(newValues[5]);
    if (userPassword != dlUserPassword || userPassword != dbPassword) {
      userPassword = dlUserPassword;
      var test = await encryptedSharedPrefs.getString('dbPassword');
      if (test != dbPassword) {
        if (kDebugMode) {
          print(test);
        }
      }
      if (dbPassword != userPassword) {
        dbPassword = userPassword;
      }
      await encryptedSharedPrefs.setString('loginPassword', userPassword);
    }
    if (passwordEnabled != dlPasswordEnabled) {
      passwordEnabled = dlPasswordEnabled;
      prefs.setBool('passwordEnabled', passwordEnabled);
      getPasswordEnabledState();
    }
    if (passwordHint != dlPasswordHint) {
      passwordHint = dlPasswordHint;
      await Future.sync(
          () => encryptedSharedPrefs.setString('passwordHint', passwordHint));
    }
    if (greeting != dlGreeting) {
      greeting = dlGreeting;
      prefs.setString('greeting', greeting);
    }
    if (colorSeed != dlColorSeed) {
      colorSeed = dlColorSeed;
      prefs.setInt('apptheme', colorSeed);
      setState(() {
        super.widget.swapper?.themeColor = colorSeed;
      });
    }
    if (kDebugMode) {
      print("updated Values in array");
    }
    isDataSame = true;
    decipheredData = '';
    googleIsDoingSomething(false);
    readyButton.boolSink.add(false);
    refreshPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeSwap>(builder: (context, swapper, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("ADHD Journal"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(15,60,15,10),
                child: greetingField,
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                child: loginField,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 60.0),
                child: Center(),
              ),
              SizedBox(
                height: 50,
                width: 250,
                child: StreamBuilder<bool>(
                    stream: readyButton.controller.stream,
                    builder:
                        (BuildContext context, AsyncSnapshot<bool> snapshot) {
                      final recordsBloc = Provider.of<RecordsBloc>(context,listen: false);
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text("Updating Files on device");
                      } else {
                        if (snapshot.hasError) {
                          return const Text("Error retrieving information");
                        } else if (snapshot.hasData) {
                          if (snapshot.data == false) {
                            return FutureBuilder(
                                future: getPasswordEnabledState(),
                                builder: (
                                  BuildContext context,
                                  AsyncSnapshot<bool> snapshot,
                                ) {
                                  if (snapshot.hasError) {
                                    return const Text(
                                        'Error returning password  information');
                                  } else if (snapshot.hasData) {
                                    return ElevatedButton(
                                      onPressed: () {
                                        callingCard = true;
                                        if (loginPassword == userPassword &&
                                            passwordEnabled) {
                                          loginPassword = '';
                                          recordsBloc.getRecords();
                                          Navigator.pushNamed(
                                                  context, '/success')
                                              .then((value) => {
                                                    isThisReturning = true,
                                                    stuff.clear(),
                                                    refreshPrefs(),
                                                  });
                                        } else if (!passwordEnabled) {
                                          recordsBloc.getRecords();
                                          loginPassword = '';
                                          stuff.clear();
                                          Navigator.pushNamed(
                                                  context, '/success')
                                              .then((value) => {
                                                    isThisReturning = true,
                                                    refreshPrefs(),
                                                  });
                                        }
                                      },
                                      child: const Text(
                                        'Login',
                                        style: TextStyle(fontSize: 25),
                                      ),
                                    );
                                  } else if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return ElevatedButton(
                                      onPressed: () {
                                        if (loginPassword == userPassword) {
                                          recordsBloc.getRecords();
                                          Navigator.pushNamed(
                                                  context, '/success')
                                              .then((value) => {
                                                    isThisReturning = true,
                                                    refreshPrefs(),
                                                  });
                                          stuff.clear();
                                        }
                                      },
                                      child: const Text(
                                        'Login',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 25),
                                      ),
                                    );
                                  } else {
                                    return const Text('Waiting for password info');
                                  }
                                });
                          } else {
                            return const Text("Updating Values, Please wait!");
                          }
                        } else {
                          return const Text("Something is wrong");
                        }
                      }
                    }),
              ),
              const SizedBox(
                height: 130,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: FutureBuilder<bool>(
                    future: getNetStatus(),
                    builder:
                        (BuildContext context, AsyncSnapshot<bool> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text("Getting Connection Status");
                      } else {
                        if (snapshot.hasData) {
                          if (snapshot.data == true) {
                            return Center(
                              child: FutureBuilder(
                                  future: getSyncStateStatus(),
                                  builder: (
                                    BuildContext context,
                                    AsyncSnapshot<bool> snapshot,
                                  ) {
                                    if (snapshot.hasError) {
                                      return const Text("Error");
                                    } else if (snapshot.hasData) {
                                      if (snapshot.data! == true) {
                                        return const Text("");
                                      } else {
                                        return driveButton;
                                      }
                                    } else {
                                      return const Text("Waiting");
                                    }
                                  }),
                            );
                          } else {
                            return const Center(
                              child: Text(connection_Error_Message_String),
                            );
                          }
                        } else {
                          return Center(
                            child: FutureBuilder(
                                future: getSyncStateStatus(),
                                builder: (
                                  BuildContext context,
                                  AsyncSnapshot<bool> snapshot,
                                ) {
                                  if (snapshot.hasError) {
                                    return const Text("Error");
                                  } else if (snapshot.hasData) {
                                    if (snapshot.data! == true) {
                                      return const Text("");
                                    } else {
                                      return driveButton;
                                    }
                                  } else {
                                    return const Text("Waiting");
                                  }
                                }),
                          );
                        }
                      }
                    }),
              ),
              const SizedBox(
                height: 40,
              ),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                   await checkGoogleDrive();
                    // await Future.sync(() => checkForAllFiles(""));
                  },
                  child: const Text(
                    'Update Files',
                    style: TextStyle(fontSize: 25),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void googleSignIn() async {
    googleDrive.client = await googleDrive.getHttpClient();
  }
}

PreferenceBackupAndEncrypt preferenceBackupAndEncrypt =
    PreferenceBackupAndEncrypt();
LoginButtonReady readyButton = LoginButtonReady();

class LoginButtonReady {
  StreamController<bool> controller =
      StreamController<bool>.broadcast(sync: true);
  StreamSink<bool> get boolSink => controller.sink;
  StreamSubscription? listener;
  bool ready = false;
  LoginButtonReady() {
    listener = controller.stream.listen((event) {
      switch (event) {
        case true:
          {
            ready = false;
            break;
          }
        case false:
          {
            ready = true;
            break;
          }
        }
    });
  }
  dispose() {
    listener?.cancel();
    controller.close();
  }
}
