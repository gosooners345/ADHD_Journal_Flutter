import 'dart:typed_data';
import '../app_start_package/splash_screendart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_onedrive/flutter_onedrive.dart';
import '../project_resources/project_strings_file.dart';
/// Need to expand OneDrive class to go further and force authentication when activated or else the data can easily be accessed or backups will not work properly
class OneDriveSyncClass{

  final oneDriveUtility = OneDrive(clientID: 'abdfccc0-c909-4782-aab7-c6db9400c042', redirectURL:redirectOneDriveURL);





  void pushFileToCloud(String fileName){

    oneDriveUtility.push(Uint8List(2), fileName);
  }

  void downloadFileFromCloud(String fileName){
    oneDriveUtility.pull(fileName);
  }


  Widget connectButton(){
    return FutureBuilder(
      future: oneDriveUtility.isConnected(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data ?? false) {
          // Has connected
          return const Text("Connected");
        } else {
          // Hasn't connected
          return ElevatedButton(
            child: const Text("Connect"),
            onPressed: () async {
              final success = await oneDriveUtility.connect(context);
              if (success) {
                // Download files
                print("connected");
                final txtBytes = await oneDriveUtility.pull("/$driveStoreDirectory/test.txt");
                // Upload files
                await oneDriveUtility.push(txtBytes!, "/$driveStoreDirectory/xxx.txt");
              }
            },
          );
        }
      },
    );
  }



}