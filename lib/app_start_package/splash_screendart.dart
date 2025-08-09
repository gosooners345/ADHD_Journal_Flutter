import 'dart:async';
import 'dart:convert';

import 'dart:io';
import 'package:adhd_journal_flutter/project_resources/project_colors.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../backup_utils_package/crypto_utils.dart';
import '../project_resources/file_manager_helper.dart';
import '../project_resources/global_vars_andpaths.dart';
import 'login_screen_file.dart';

// Splash Screen Class for application. This page will need examined for performance improvement potential

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key, this.swapper}) : super(key: key);
  final ThemeSwap? swapper;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Database testDB;

  bool checkVisitState = false;
  bool transferred = false;

  //These variables are temporary due to the app changing set passwords and stuff.
  String dbPassTransfer = "";
  String userPasswordTransfer = "";
  String greetingTransfer = "";
  bool passwordEnabledTransfer = false;

  bool checkTransferred = false;

  Text statusUpdateWidget = const Text('');
  ValueNotifier<String> appStatus = ValueNotifier("");

  @override
  Widget build(BuildContext context) {
    return initScreen(context);
  }

  @override
  void initState() {
    super.initState();

    Global.networkConnectivityChecker.initialise();

//Icon Assignments
    if (Platform.isAndroid) {
      backArrowIcon = const Icon(Icons.arrow_back);
      nextArrowIcon = const Icon(Icons.arrow_forward);
      onboardingBackIcon =
          Icon(Icons.arrow_back, color: AppColors.mainAppColor);
      onboardingForwardIcon =
          Icon(Icons.arrow_forward, color: AppColors.mainAppColor);
    }
    else {
      backArrowIcon = const Icon(Icons.arrow_back_ios);
      nextArrowIcon = const Icon(Icons.arrow_forward_ios);
      onboardingBackIcon =
          Icon(Icons.arrow_back_ios, color: AppColors.mainAppColor);
      onboardingForwardIcon = Icon(
        Icons.arrow_forward_ios,
        color: AppColors.mainAppColor,
      );
    }
    appStatus.value =
    "Welcome to ADHD Journal! We're getting your stuff ready!";

    getNetStatus();
    finishTimer();
  }

  finishTimer() async {
    //Test Code
    Global.prefs = await SharedPreferences.getInstance();
    final pathStats = await Future.sync(Global.initializeAppPaths);
    while (pathStats == false) {
      if (kDebugMode) {
        print("Getting paths");
      }
      if (pathStats == true) {
        break;
      }
    }

    if (connected == false) {
      getNetStatus();
    }
    setState(() {
      appStatus.value = "Getting Build and App Version info";
    });

    initPrefs().then((value) async {
      if (Global.userActiveBackup) {
        if (Global.googleDrive.client == null) {
          Global.googleDrive.initVariables();
          if (Global.googleDrive.client != null) {
            if (kDebugMode) {
              print("Google Drive client is not null");
            }
          }
          else {
            if (kDebugMode) {
              print("Google Drive client is null");
            }
          }
        }
      }
      await getPackageInfo();
      await loadPreferences().then((value) {
        checkG00gleDrive();
      }).onError((error, stackTrace) {
        if (kDebugMode) {
          print(error);
        print(stackTrace);
        }
      });
      //);
    });

    if (kDebugMode) {
      if (fileCheckCompleted == true) {
        print("File check completed");
      } else {
        print("File check not completed");
      }
    }

    await Future.delayed(Duration(seconds: 15), route);
  }

  //Initialize Preferences
  initPrefs() async {
    appStatus.value = "Loading preferences now";

    try {
      Global.encryptedSharedPrefs = EncryptedSharedPreferences();
      if (kDebugMode) {
        print("Global.prefs not null currently");
      }
      while (Global.encryptedSharedPrefs == null) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (kDebugMode) {
          print("Global.prefs null currently");
        }
        Global.encryptedSharedPrefs = EncryptedSharedPreferences();
      }
      //Testing google sign in
      if (connected == true) {
        await Future.delayed(const Duration(milliseconds: 100), () {
          Global.userActiveBackup = Global.prefs.getBool('testBackup') ?? false;
        });

        if (kDebugMode) {
          print("Backup is turned on: ${Global.userActiveBackup}");
        }
      }
      try {
        if (kDebugMode) {
          print("SplashScreen Sign in called");
        }
        // Reduce Null check operator fails
        if (Global.userActiveBackup == false &&
            Global.prefs.getBool('testBackup') != null) {
          Global.userActiveBackup = Global.prefs.getBool('testBackup')!;
        }
        if (Global.userActiveBackup == true) {
          Global.googleDrive.initVariables();
        } else {
          if (kDebugMode) {
            print(
                "Google Drive backups aren't activated. User can activate them upon sign in or upon setup");
          }
          appStatus.value =
          "Google Drive backups aren't activated. You  can activate them upon sign in or upon setup";
        }
      } on Exception catch (ex) {
        if (kDebugMode) {
          print(ex);
        }
        print("Backup google sign in called");
        Global.googleDrive.client = await Global.googleDrive.getHttpClient();
        Global.googleDrive.initV2();
      }
      if (Global.userActiveBackup == true) {
        while (Global.googleDrive.client == null) {
          await Future.delayed(const Duration(seconds: 2), () {
            print("Delay loading for sign in to complete");
          });
          if (Global.googleDrive.client != null) {
            break;
          }
        }
      }
    } on Exception catch (ex) {
      print(ex);
    }
  }


  Future<void> loadPreferences() async {
    if (kDebugMode) {
      print("Loading Prefs");
    }

    var tempHint = await Global.encryptedSharedPrefs.getString(
        'passwordHint') ?? "";
    userPassword = await Global.encryptedSharedPrefs.getString('loginPassword');
    bool didThingsChange = false;
    // Strange bug in 2022 with out of range exception being thrown, this code was written to catch it.
    try {
      dbPassword = await Global.encryptedSharedPrefs.getString('dbPassword');
    }
    on Exception catch (ex) {
      if (kDebugMode) {
        print(ex);
      }
      //Database password has to be handled with extra care because it unlocks the journal.
      try {
        await Global.encryptedSharedPrefs.remove('dbPassword');
      } on Exception catch (ex) {
        if (kDebugMode) {
          print(ex);
        }
      }
      dbPassword = userPassword;
      await Global.encryptedSharedPrefs.setString('dbPassword', dbPassword);
    }
    // In case if the db password and user password don't match. Be careful with this.
    if (userPassword != dbPassword) {
      //test open DB in case dbPassword is correct.
      //Try changing passwords and see if they result in the correct outcome.
      try {
        final testDB = await openDatabase(
            Global.fullDeviceDBPath, password: dbPassword);
        if (kDebugMode) {
          print("Testing Open of journal");
        }
        if (testDB.isOpen) {
          if (kDebugMode) {
            print("DB Password is correct, do not change the password");
          }

          ///Set login password to DB password because it was successful.
          userPassword = dbPassword;
          await testDB.close().whenComplete(() =>
              Global.encryptedSharedPrefs
                  .remove('loginPassword')
                  .whenComplete(() =>
                  Global.encryptedSharedPrefs.setString(
                      'loginPassword', userPassword)));
          //Temp hint to replace logged one due to password change.
          tempHint = "Use $dbPassword to login";
          await Global.encryptedSharedPrefs.setString('passwordHint', tempHint);
          didThingsChange = true;
        } else {
          throw Exception("DB is not open, db password is incorrect");
        }
      }
      on Exception catch (ex) {
        if (kDebugMode) {
          print(ex);
        }
        dbPassword = userPassword;
        await Global.encryptedSharedPrefs.setString('dbPassword', dbPassword);
        didThingsChange = true;
      }
    }
    if (didThingsChange) {
      await Global.encryptedSharedPrefs.reload().whenComplete(() async {
        userPassword =
        await Global.encryptedSharedPrefs.getString('loginPassword');
        dbPassword = await Global.encryptedSharedPrefs.getString('dbPassword');
      });
      await Global.prefs.reload();
    }

    passwordHint = await Global.encryptedSharedPrefs.getString('passwordHint');
    greeting = Global.prefs.getString('greeting') ?? '';
    colorSeed = Global.prefs.getInt("apptheme") ?? AppColors.mainAppColor.value;
    passwordEnabled = Global.prefs.getBool('passwordEnabled') ?? true;
    notificationsAllowed = Global.prefs.getBool('notifications') ?? false;
    isPasswordChecked = passwordEnabled;
// Give option to work around if user doesn't want to use Google Drive before publishing update

  }

  //Check to see if passwords were changed since last login.
  //Update passwords if needed.

  Future<bool> checkPreferences() async {
    File preferencesFile = File(Global.fullDevicePrefsPath);
    String decipheredData = CryptoUtils.rsaDecrypt(
        preferencesFile.readAsStringSync(
            encoding: Encoding.getByName("utf-8")!),
        Global.preferenceBackupAndEncrypt.privKey!);

    String dataForEncryption =
        '$userPassword,$dbPassword,$passwordHint,${passwordEnabled
        .toString()},$greeting,$colorSeed';
    googleIsDoingSomething(true);
    if (dataForEncryption == decipheredData) {
      setState(() {
        appStatus.value = "Preferences are up to date";
      });
      return true;
    }
    else {
      setState(() {
        appStatus.value =
        "Preferences are out of date, we will need to update the local version.";
      });
      return false;
    }
  }

//Missing Color seed Global.prefs.
  Future<void> updatePreferences() async {
    Completer<void> prefsUpdated = Completer();
    final preferencesFile = File(Global.fullDevicePrefsPath);
    var tempHint = "";
    String decipheredData = CryptoUtils.rsaDecrypt(
        preferencesFile.readAsStringSync(
            encoding: Encoding.getByName("utf-8")!),
        Global.preferenceBackupAndEncrypt.privKey!);
    String newLoginPW = "",
        newDBPW = "",
        newHint = "",
        newGreeting = "";
    int newColorSeed = 0;
    bool newEnabled = false;
    var newVals = decipheredData.split(",");
    newLoginPW = newVals[0];
    newDBPW = newVals[1];
    newHint = newVals[2];
    newEnabled = newVals[3] == "true" ? true : false;
    ;
    newGreeting = newVals[4];
    newColorSeed = int.parse(newVals[5]);
    if (kDebugMode) {
      print("Changing Values");
    }
    appStatus.value = "Updating Preferences";
    if (newLoginPW != userPassword || newDBPW != dbPassword) {
      try {
        final testDB = await openDatabase(
            Global.fullDeviceDBPath, password: newDBPW);
        userPassword = newLoginPW;
        if (kDebugMode) {
          print("Testing Open of journal");
        }
        if (testDB.isOpen) {
          dbPassword = newDBPW;
          if (kDebugMode) {
            print("DB Password is correct, do not change the password");
          }

          ///Set login password to DB password because it was successful.
          userPassword = dbPassword;
          await testDB.close().whenComplete(() =>
              Global.encryptedSharedPrefs
                  .remove('loginPassword')
                  .whenComplete(() =>
                  Global.encryptedSharedPrefs.setString(
                      'loginPassword', userPassword)));
          //Temp hint to replace logged one due to password change.
          tempHint = "Use $dbPassword to login";
          await Global.encryptedSharedPrefs.setString('passwordHint', tempHint);
          // didThingsChange = true;

        } else {
          throw Exception("DB is not open, db password is incorrect");
        }
      }
      on Exception catch (ex) {
        if (kDebugMode) {
          print(ex);
        }
        dbPassword = userPassword;
        await Global.encryptedSharedPrefs.setString('dbPassword', dbPassword);
      }
    }
    if (newHint != passwordHint) {
      passwordHint = newHint;
      await Global.encryptedSharedPrefs.setString('passwordHint', passwordHint);
    }
    if (newEnabled != passwordEnabled) {
      passwordEnabled = newEnabled;
      await Global.prefs.setBool('passwordEnabled', passwordEnabled);
    }
    if (greeting != newGreeting) {
      greeting = newGreeting;
      Global.prefs.setString('greeting', greeting);
    }
    if (colorSeed != dlColorSeed) {
      colorSeed = dlColorSeed;
      Global.prefs.setInt('apptheme', colorSeed);
      setState(() {
        super.widget.swapper?.themeColor = colorSeed;
      });
    }
    await Global.encryptedSharedPrefs.reload();
    Global.prefs.reload();
    prefsUpdated.complete();
    googleIsDoingSomething(false);
    return prefsUpdated.future;
  }

  //Call before doing anything with update preferences.
  Future<void> checkG00gleDrive() async {
    if (Global.userActiveBackup) {
      appStatus.value =
      "You have backup and sync enabled! Signing into Google Drive!";


      googleIsDoingSomething(true);
      if (Global.googleDrive.client != null) {
        if (Global.userActiveBackup) {
          var pubKeyLocation = Global
              .fullDevicePubKeyPath; //path.join(keyLocation, pubKeyFileName);
          var docLIst = [
            pubKeyLocation,
            Global.fullDeviceDBPath,
            Global.fullDevicePrefsPath
          ];
          print("Checking Keys");
          // Make this a for loop statement and initialize an array for the file locations.
          for (int i = 0; i < 3; i++) {
            await checkFilesExistV2(docLIst[i], Global.files_list_names[i],
                Global.files_list_types[i]).onError((error, stackTrace) {
              if (kDebugMode) {
                print("Tis but a scratch");

              print(error);
              print(stackTrace); }
            }).whenComplete(() {
              if (kDebugMode) {
                print("${Global.files_list_types[i]} check complete.");
              }
            });
          }
        }
      }
      else {
        Global.userActiveBackup = false;
        appStatus.value =
        "To protect your data, you'll need to sign into Google Drive and approve application access to backup your stuff!";
      }
    }
    else {
      appStatus.value =
      "You have backup and sync disabled! You can enable this on Login "
          "by hitting Sign into Google Drive! You can disable this feature in Settings ";
    }
    appStatus.value = 'Loading up your journal now...';
  }

  void googleIsDoingSomething(bool value) {
    Global.readyButton.boolSink.add(value);
  }

  /// Handles loading application stuff at top level. Break as much down as possible to improve code control.


  void getNetStatus() {
    Global.networkConnectivityChecker.myStream.listen((source) {
      if (source == true) {
        connected = true;
        print("Connected");
      }
    }).onData((data) {
      print(data);
      if (data == false) {
        connected = false;
        appStatus.value =
        "You're not connected to a network, we can't backup and sync your journal.";
      } else {
        appStatus.value =
        "You're connected to a network, we can backup and sync your journal if you turned backup and sync on.";
        connected = true;
      }
    });
  }

//Improved error handling, unlikely this would trigger exceptions, but wanted to be safe.
  Future<void> getPackageInfo() async {
    packInfo = await PackageInfo.fromPlatform();
    buildInfo = packInfo.version;
  }

  /// This method is responsible for checking the status of files and age of data on both sides.
  Future<void> checkFilesExistV2(String localFileName, String remoteFileName,
      String fileType) async {
    var fileChecker = ManagedFile(localFileName, remoteFileName);
    //Check for existence of files and age.
    print("Checking $fileType");
    await fileChecker.checkLocalExistence();
    await fileChecker.checkRemoteExistence(Global.googleDrive);
    await fileChecker.checkRemoteIsNewer(Global.googleDrive);
    //Check file existence first locally then remotely. If file exists in cloud, but not on device, then download it.
    //Done
    if (!fileChecker.localExists) {
      //Check if file exists on cloud.
      if (!fileChecker.remoteExists) {
        if (kDebugMode) {
          print("File does not exist on device or cloud");
        }
        appStatus.value = "$fileType does not exist on device or cloud";
        appStatus.value =
        "You will need to open the journal to create the file";
      } //Download if exists in cloud.
      else {
        if (kDebugMode) {
          print("File exists on cloud but not on device");
        }

        appStatus.value = "$fileType exists on cloud but not on device";
        appStatus.value = "Downloading $fileType now";

        //Use Switch Case statement to handle file delivery
        switch (fileType) {
          case "Journal":
            await restoreDBFiles();
            break;
          case "Preferences":
            await Global.preferenceBackupAndEncrypt.downloadPrefsCSVFile(
                Global.googleDrive).whenComplete(() {
              updatePreferences();
            });
            //Process file.
            break;
          case "Keys":
            await Global.preferenceBackupAndEncrypt.downloadRSAKeys(
                Global.googleDrive);
            break;
        }
      }
    }
    //If cloud copy doesn't exist, then we can upload it.
    if (!fileChecker.remoteExists && fileChecker.localExists) {
      if (kDebugMode) {
        print(
            "$fileType exists on device but does not exist on device or cloud, uploading to Drive");
      }
      setState(() {
        appStatus.value = "$fileType does not exist on device or cloud";
      });
      //use switch case statement to handle file delivery, uploading here
      switch (fileType) {
        case "Journal":
          await uploadDBFiles();
          break;
        case "Preferences":
          String dataForEncryption =
              '$userPassword,$dbPassword,$passwordHint,${passwordEnabled
              .toString()},$greeting,$colorSeed';
          googleIsDoingSomething(true);
          await Global.preferenceBackupAndEncrypt.encryptData(
              dataForEncryption, Global.googleDrive).whenComplete(() {
            setState(() {
              appStatus.value = "Preferences Uploaded";
            });
            googleIsDoingSomething(false);
          });

          break;
        case "Keys":
          await Global.preferenceBackupAndEncrypt.encryptRsaKeysAndUpload(
              Global.googleDrive).whenComplete(() {
            setState(() {
              appStatus.value = "Encryption keys Uploaded";
            });
            googleIsDoingSomething(false);
          });
          break;
      }
    }
    if (fileChecker.localExists && fileChecker.remoteExists) {
      if (fileChecker.localIsNewer!) {
//In future update, integrate file IDs
        appStatus.value =
        "$fileType exists on device and cloud but is newer on device. Replacing file in cloud with new local copy.";
        //Use switch case statement to handle file delivery,
        switch (fileType) {
        // Future update integrate DB ID to reduce frequency of double uploading
          case "Journal":
            await uploadDBFiles();
            break;
          case "Preferences":
            String dataForEncryption =
                '$userPassword,$dbPassword,$passwordHint,${passwordEnabled
                .toString()},$greeting,$colorSeed';
            googleIsDoingSomething(true);
            await Global.preferenceBackupAndEncrypt.encryptData(
                dataForEncryption, Global.googleDrive).whenComplete(() {
              setState(() {
                appStatus.value = "Preferences Uploaded";
              });
              googleIsDoingSomething(false);
            });
            break;
          case "Keys":
            await Global.preferenceBackupAndEncrypt.encryptRsaKeysAndUpload(
                Global.googleDrive).whenComplete(() {
              setState(() {
                appStatus.value = "Encryption keys Uploaded";
              });
              googleIsDoingSomething(false);
            });
            break;
        }
      }
      else {
        googleIsDoingSomething(true);
        appStatus.value =
        "$fileType exists on device and cloud but is newer on cloud";
        appStatus.value = "Downloading updated $fileType now";

        //Use switch case statement to handle file delivery
        switch (fileType) {
          case "Journal":
            await restoreDBFiles().whenComplete(() {
              appStatus.value = "Journal Updated";
            });
            googleIsDoingSomething(false);
            break;
          case "Preferences":
            googleIsDoingSomething(true);
            await Global.preferenceBackupAndEncrypt.downloadPrefsCSVFile(
                Global.googleDrive).whenComplete(() {
              appStatus.value =
              "Updated preferences downloaded, checking for mismatches";
              googleIsDoingSomething(false);
            });
            final isDataSame = await checkPreferences();
            if (!isDataSame) {
              appStatus.value =
              "Preferences are out of date, we will need to update the local version.";
              await updatePreferences().whenComplete(() {
                appStatus.value = "Preferences Updated";
              });
            }
            else {
              appStatus.value = "Preferences are up to date";
            }
            googleIsDoingSomething(false);
            break;
          case "Keys":
            await Global.preferenceBackupAndEncrypt.downloadRSAKeys(
                Global.googleDrive).whenComplete(() {
              appStatus.value = "Encryption keys Updated";
            });
            googleIsDoingSomething(false);
            break;
        }
      }
    }
    fileCheckCompleted = true;
  }


  Future<void> restoreDBFiles() async {
    try {
      googleIsDoingSomething(true);
      appStatus.value = Global.downloading_journal_files_message_string;
      await Global.googleDrive.syncBackupFiles(
          Global.databaseName, Global.DBPathNOFile).whenComplete(() {
        appStatus.value = "Your Journal is synced on device now";
        googleIsDoingSomething(false);
      });
      Global.dbDownloaded = true;
    } on Exception catch (ex) {
      showMessage(ex.toString());
    }
  }

  Future<void> uploadDBFiles() async {
    setState(() {
      appStatus.value = "Beginning upload of updated journal";
    });
    try {
      // readyButton.boolSink.add(true);
      googleIsDoingSomething(true);
      setState(() {
        appStatus.value = "Checking for outdated journals";
      });
      bool multipleCopies = await Global.googleDrive.checkForOutdatedFiles(
          Global.databaseName);
      if (multipleCopies) {
        await Global.googleDrive.deleteOutdatedBackups(Global.databaseName);
      } else {
        await Global.googleDrive
            .deleteOutdatedBackups(Global.databaseName)
            .whenComplete(() {
          appStatus.value = "Uploading updated journal files";
        });
      }
      /* if(File("$dbLocation-wal").existsSync()) {
        Global.googleDrive.uploadFileToGoogleDrive(File("$dbLocation-wal"));
      }
      if(File("$dbLocation-shm").existsSync()) {
        Global.googleDrive.uploadFileToGoogleDrive(File("$dbLocation-shm"));
      }*/
      await Global.googleDrive.uploadFileToGoogleDrive(
          File(Global.fullDeviceDBPath), Global.databaseName).whenComplete(() {
        setState(() {
          appStatus.value = "Finished uploading updated journal files";
        });
        googleIsDoingSomething(false);
      });
    } on Exception catch (ex) {
      if (kDebugMode) {
        print(ex);
      }
      setState(() {
        appStatus.value = "Error uploading updated journal files";
      });
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  void route() {
    var firstVisit = Global.prefs.getBool('firstVisit') ?? true;
    if (firstVisit) {
      appStatus.value = Global.first_time_user_intro_string;
      Navigator.pushReplacementNamed((context), '/onboarding');
    } else {
      appStatus.value = "Loading Login Screen Now!";
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  initScreen(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 35,
          ),
          Expanded(
            child: Image.asset('images/appicon_appstore.png'),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ValueListenableBuilder(
                valueListenable: appStatus,
                builder: (BuildContext builder, String value, Widget? child) {
                  return Text(value);
                }),
          ),
        ],
      ),
    );
  }
}

//late SharedPreferences Global.prefs;
//EncryptedSharedPreferences Global.encryptedSharedPrefs = EncryptedSharedPreferences();
late ThemeMode deviceTheme;
late PackageInfo packInfo;
late String buildInfo;
late Icon backArrowIcon;
late Icon nextArrowIcon;
late Icon onboardingBackIcon;
late Icon onboardingForwardIcon;


String passwordHint = '';
int colorSeed = AppColors.mainAppColor.value;
late ThemeData lightTheme;
late ThemeData darkTheme;

/// ID whether it would be better to let global manage these variables below.
/// if so, apply the global implementation before running.
//String dbLocation = "";
//String docsLocation = "";
//String keyLocation = "";
bool notificationsAllowed = false;

bool isDataSame = true;


bool connected = false;
bool fileCheckCompleted = false;