
import 'dart:async';
import 'dart:convert';
import 'package:adhd_journal_flutter/records_stream_package/records_bloc_class.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../backup_utils_package/crypto_utils.dart';
import '../project_resources/file_manager_helper.dart';
import '../project_resources/global_vars_andpaths.dart';
import '../project_resources/project_colors.dart';
import 'splash_screendart.dart';
import 'onboarding_widget_class.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  //Make sure the journal uploads upon closing and
 // RecordsBloc recordsBloc = Provider.of<RecordsBloc>(context);
  bool loggedInState=false;
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
      // Review Dialog submission. This part is the most fragile part of the app.
      driveButton = ElevatedButton(
          onPressed: ()  {
            var authenticated = Global.prefs.getBool("authenticated") ?? false;
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
                              logIntoGoogle();

                              //Set Navigator.Pop to execute when authenticated.
                            } else {
                              showMessage(Global.connection_Error_Message_String);
                            }
                          },
                        ),
                        TextButton(
                            onPressed: () {
                              Global.userActiveBackup = false;
                              Global.prefs.setBool("testBackup", Global.userActiveBackup);
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
               Global.googleDrive.initVariables();
               checkGoogleDrive()
                    .whenComplete(() {
                          resetLoginFieldState();
                          setState(() {
                            Future.sync(() => getSyncStateStatus());
                          });
                          if(mounted)
                          Navigator.of(context).pop();
                        });
              } else {
                showMessage(Global.connection_Error_Message_String);
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

  void signInToGoogle() async{
    Global.googleDrive.initVariables();
  /*  if(fileCheckCompleted==false){
    await checkDataFiles();
    }*/

  }

  void logIntoGoogle() async{
    if(mounted) {
      Navigator.of(context).pop();
    }
    await
        Global.googleDrive.initVariables().whenComplete(()async{
loggedInState=true;
      await checkDataFiles()
          .whenComplete(() {
        resetLoginFieldState();
       // setState(() async{
           getSyncStateStatus();

        //});

      });
    });


     //});

  }
  //Find a way to migrate most of the code to a single method outside of this class. Probably put it in Google Drive?



  Future<bool> checkPreferences() async {
    File preferencesFile = File(Global.fullDevicePrefsPath);
    String decipheredData = CryptoUtils.rsaDecrypt(preferencesFile.readAsStringSync(
        encoding: Encoding.getByName("utf-8")!),Global.preferenceBackupAndEncrypt.privKey!);

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
   // final recordsBloc = Provider.of<RecordsBloc>(context, listen: false);
    //Check for existence of files and age.
    print("Checking $fileType");
    await fileChecker.checkLocalExistence();
    await fileChecker.checkRemoteExistence(Global.googleDrive);
    await fileChecker.checkRemoteIsNewer(Global.googleDrive);
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
            await restoreDBFiles().then((value) {
              print("DB Swap Successful");
              var getFileTime = File(Global.fullDeviceDBPath);

              showMessage(
                  'Your journal is synced as of ${getFileTime
                      .lastModifiedSync()
                      .toLocal()}');
            });
            break;
          case "Preferences":
            await Global.preferenceBackupAndEncrypt.downloadPrefsCSVFile(Global.googleDrive).whenComplete((){
              updateValues();
            });
            //Process file.
            break;
          case "Keys":
            await Global.preferenceBackupAndEncrypt.downloadRSAKeys(Global.googleDrive);
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
          await Global.preferenceBackupAndEncrypt.encryptData(dataForEncryption, Global.googleDrive).whenComplete(() {
            setState(() {
              showMessage( "Preferences Uploaded");
            });
            googleIsDoingSomething(false);});

          break;
        case "Keys":
          await Global.preferenceBackupAndEncrypt.encryptRsaKeysAndUpload(Global.googleDrive).whenComplete(() {
            setState(() {
              showMessage( "Encryption keys Uploaded");
            });
            googleIsDoingSomething(false);
          });
          break;
      }
    }
    if(fileChecker.localExists && fileChecker.remoteExists){
      if(loggedInState==true){
        switch (fileType) {
          case "Journal":
            await restoreDBFiles().then((value) async {
              var getFileTime = File(Global.fullDeviceDBPath);

              showMessage(
                  'Your journal is synced as of ${getFileTime
                      .lastModifiedSync()
                      .toLocal()}');
            });
            break;
          case "Preferences":
            await Global.preferenceBackupAndEncrypt.downloadPrefsCSVFile(Global.googleDrive).whenComplete((){
              updateValues();
            });
            //Process file.
break;
          case "Keys":
            await Global.preferenceBackupAndEncrypt.downloadRSAKeys(Global.googleDrive);
            break;
        }
      }
       else if(fileChecker.localIsNewer!&& loggedInState==false){
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
            await Global.preferenceBackupAndEncrypt.encryptData(dataForEncryption, Global.googleDrive).whenComplete(() {
              setState(() {
                showMessage( "Preferences Uploaded");
              });
              googleIsDoingSomething(false);});
            break;
          case "Keys":
            await Global.preferenceBackupAndEncrypt.encryptRsaKeysAndUpload(Global.googleDrive).whenComplete(() {
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
            await Global.preferenceBackupAndEncrypt.downloadPrefsCSVFile(Global.googleDrive).whenComplete(() {
              showMessage( "Updated preferences downloaded, checking for mismatches");
            });
             isDataSame = await checkPreferences();
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
            await Global.preferenceBackupAndEncrypt.downloadRSAKeys(Global.googleDrive).whenComplete(() {
              showMessage( "Encryption keys Updated");
            });
            break;
        }

      }
    }
  }

  Future<void> checkGoogleDrive() async{
    if (connected == true) {
      Global.userActiveBackup = Global.prefs.getBool('testBackup') ?? false;
      print("Backup is turned on: $Global.userActiveBackup");
    }
    if (Global.userActiveBackup) {
      try{
        if(Global.googleDrive.client == null){
          throw Exception("Google Drive needs initialized");
        }
      }
      on Exception catch(ex){
        if(kDebugMode){
          print(ex);
        }
        Global.googleDrive.client = await  Global.googleDrive.getHttpClient();
        Global.googleDrive.initV2();
      }
      if (Global.googleDrive.client != null) {
        if (Global.userActiveBackup) {
          var docLIst=[Global.fullDeviceDBPath,Global.fullDevicePubKeyPath,Global.fullDevicePrefsPath];
          // Make this a for loop statement and initialize an array for the file locations.
          for(int i=0;i<3;i++){
            //await Future.delayed(Duration(seconds: 1));
            googleIsDoingSomething(true);
            await checkFilesExistV2(docLIst[i], Global.files_list_names[i], Global.files_list_types[i]).onError((error, stackTrace) {
              print("Tis but a scratch");
            }).whenComplete(() {
              print(Global.files_list_types[i] + " check complete.");
              googleIsDoingSomething(false);
            });
            googleIsDoingSomething(false);
          }
fileCheckCompleted=true;
        }
      }
      else {
        Global.userActiveBackup = false;
        showMessage(
        "To protect your data, you'll need to sign into Google Drive and approve application access to backup your stuff!");
      }
    }
    else {
      showMessage(
      "You have backup and sync disabled! You can enable this  "
          "by hitting Sign into Google Drive! You can disable this feature in Settings ");
    }

  }//Add method to watch for any hanging buttons\



  Future<bool> getNetStatus() async {
    if (connected) {
      Global.userActiveBackup = Global.prefs.getBool('testBackup') ?? false;
    }
    return connected;
  }
// in case Splash Screen doesn't load things in time because it moves so fast.
  void loadStateStuff() async {

    if(Global.prefs == null){
      Global.prefs = await SharedPreferences.getInstance();
    }
    passwordEnabled = Global.prefs.getBool('passwordEnabled') ?? true;
    greeting = Global.prefs.getString("greeting") ?? '';
    loginGreeting = await  getGreeting();
    userPassword = await Global.encryptedSharedPrefs.getString('loginPassword');
    //Dumb bug flutter imposed on shared Global.prefs with index out of range exceptions
    try {
      dbPassword = await Global.encryptedSharedPrefs.getString('dbPassword');
    } on Exception catch (ex) {
      if (kDebugMode) {
        print(ex);
      }
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
    passwordHint = await getPasswordHint();
    isPasswordChecked = passwordEnabled;
    if (userPassword != dbPassword) {
      dbPassword = userPassword;
    }
    setState(() {
      resetLoginFieldState();
    });
    if(fileCheckCompleted==false){
    await checkDataFiles();
    }
    googleIsDoingSomething(false);
  //  fileCheckCompleted = false;
  }
  void reloadStateStuff() async {
loggedInState=false;
    if(Global.prefs == null){
      Global.prefs = await SharedPreferences.getInstance();
    }
    passwordEnabled = Global.prefs.getBool('passwordEnabled') ?? true;
    greeting = Global.prefs.getString("greeting") ?? '';
    loginGreeting = await  getGreeting();
    userPassword = await Global.encryptedSharedPrefs.getString('loginPassword');
    //Dumb bug flutter imposed on shared Global.prefs with index out of range exceptions
    try {
      dbPassword = await Global.encryptedSharedPrefs.getString('dbPassword')??'';
    } on Exception catch (ex) {
      if (kDebugMode) {
        print(ex);
      }
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
    passwordHint = await getPasswordHint();
    isPasswordChecked = passwordEnabled;
    if (userPassword != dbPassword) {
      dbPassword = userPassword;
    }
    setState(() {
      resetLoginFieldState();
    });
if(isThisReturning==true){
  await checkDataFiles();
}
    googleIsDoingSomething(false);

  }

  Future<void> checkDataFiles() async {
    if (Global.userActiveBackup) {
      if(Global.googleDrive.client==null){
        signInToGoogle();
      } else{
        checkGoogleDrive();
      }

    } else {
      googleIsDoingSomething(false);
    }
  }

  Future<String> getGreeting() async {
    greeting = Global.prefs.getString('greeting') ?? '';
    String opener = 'Welcome ';
    String closer = (passwordEnabled == true)
        ? '! Sign in with your password below.'
        : "! Hit the Login Button to sign in.";

    return opener + greeting + closer;
  }

  Future<String> getPasswordHint() async {
    return Global.encryptedSharedPrefs.getString("passwordHint");
  }

  Future<bool> getSyncStateStatus() async {
    return Global.userActiveBackup;
  }

  Future<bool> getPasswordEnabledState() async {
    return Global.prefs.getBool('passwordEnabled') ?? true;
  }

  void refreshPrefs() async {
    Global.prefs.reload();
    await Future.sync(() => Global.encryptedSharedPrefs.reload());
    await Future.delayed(const Duration(seconds: 1), reloadStateStuff);
  }

  void resetLoginFieldState() async {

    var recordsBloc = Provider.of<RecordsBloc>(context,listen: false);


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
                recordsBloc.getRecords(true);
                Navigator.pushReplacementNamed(context, '/success').then((value) => {
                      isThisReturning = true,
                      refreshPrefs(),
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


  Future<void> uploadDBFiles() async {
    googleIsDoingSomething(true);
    Global.googleDrive.deleteOutdatedBackups(Global.databaseName);
    await Global.googleDrive.uploadFileToGoogleDrive(File(Global.fullDeviceDBPath),Global.databaseName).whenComplete((){
      googleIsDoingSomething(false);
      showMessage('Your journal is now uploaded!');
    });

  }

  //Experimental
  Future<void> restoreDBFiles() async {
    try {
      //googleIsDoingSomething(true);
      await Global.googleDrive.syncBackupFiles(Global.databaseName, Global.fullDeviceDocsPath).then((value) async{
        googleIsDoingSomething(false);
      }); Global.dbDownloaded = true;
    } on Exception {
      showMessage('You need to open up the journal once to back it up.');
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void googleIsDoingSomething(bool value) {
    Global.readyButton.boolSink.add(value);
  }

  void updateValues() async {
    googleIsDoingSomething(true);
    showMessage("Updating preferences");
    if (decipheredData == '') {
      File prefsFile = File(Global.fullDevicePrefsPath);
     // googleIsDoingSomething(true);
      if (prefsFile.existsSync()) {
        decipheredData = CryptoUtils.rsaDecrypt(
            prefsFile.readAsStringSync(encoding: Encoding.getByName("utf-8")!),
            Global.preferenceBackupAndEncrypt.privKey!);
        await Future.delayed(Duration(milliseconds: 200));
      } else {
    await    Global.preferenceBackupAndEncrypt.downloadPrefsCSVFile(Global.googleDrive);
      }
    }

    await Future.delayed(Duration(milliseconds: 200));
    var newValues = decipheredData.split(',');
    dlUserPassword = newValues[0];
    dlDBPassword = newValues[1];
    dlPasswordHint = newValues[2];
    dlPasswordEnabled = newValues[3] == "true" ? true : false;
    dlGreeting = newValues[4];
    dlColorSeed = int.parse(newValues[5]);
    if (userPassword != dlUserPassword || userPassword != dbPassword) {
      userPassword = dlUserPassword;
      var test = await Global.encryptedSharedPrefs.getString('dbPassword');
      if (test != dbPassword) {
        if (kDebugMode) {
          print(test);
        }
      }
      if (dbPassword != userPassword) {
        dbPassword = userPassword;
      }
      await Global.encryptedSharedPrefs.setString('loginPassword', userPassword);
    }
    if (passwordEnabled != dlPasswordEnabled) {
      passwordEnabled = dlPasswordEnabled;
      Global.prefs.setBool('passwordEnabled', passwordEnabled);
      getPasswordEnabledState();
    }
    if (passwordHint != dlPasswordHint) {
      passwordHint = dlPasswordHint;
      await Future.sync(
          () => Global.encryptedSharedPrefs.setString('passwordHint', passwordHint));
    }
    if (greeting != dlGreeting) {
      greeting = dlGreeting;
      Global.prefs.setString('greeting', greeting);
    }
    if (colorSeed != dlColorSeed) {
      colorSeed = dlColorSeed;
      Global.prefs.setInt('apptheme', colorSeed);
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
    googleIsDoingSomething(false);
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
                    stream: Global.readyButton.controller.stream,
                    builder:
                        (BuildContext context, AsyncSnapshot<bool> snapshot) {
                      var recordsBloc = Provider.of<RecordsBloc>(context,listen: false);
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
                                      onPressed: () async {
                                        callingCard = true;
                                        if (loginPassword == userPassword &&
                                            passwordEnabled) {
                                          loginPassword = '';
                                          if(Global.dbDownloaded == true)
                                           recordsBloc.handleDBSwapRefresh();
                                          recordsBloc.getRecords(true);
                                          Global.dbDownloaded = false;
                                          Navigator.pushNamed(
                                                  context, '/success')
                                              .then((value) => {
                                                    isThisReturning = true,
                                                    stuff.clear(),
                                                    refreshPrefs(),
                                                  });
                                        } else if (!passwordEnabled) {
                                          if(Global.dbDownloaded == true)
                                           recordsBloc.handleDBSwapRefresh();
Global.dbDownloaded = false;
                                          recordsBloc.getRecords(true);
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
                                          recordsBloc.getRecords(true);
                                          Navigator.pushNamed(
                                                  context, '/success')
                                              .then((value) => {
                                                    isThisReturning = true,
                                            recordsBloc.dispose(),
                                                    refreshPrefs(),
                                             recordsBloc = Provider.of<RecordsBloc>(context,listen: false)
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
                         /// Refers to connection status
                          if (snapshot.data == true) {
                            return Center(
                              child: FutureBuilder(
                                  future: getSyncStateStatus(),
                                  builder: (
                                    BuildContext context,
                                    AsyncSnapshot<bool> snapshot,
                                  ) {
                                    // Refers to Drive button status
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
                              child: Text(Global.connection_Error_Message_String),
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


}

//PreferenceBackupAndEncrypt Global.preferenceBackupAndEncrypt =
  //  PreferenceBackupAndEncrypt();
//LoginButtonReady readyButton = LoginButtonReady();

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
