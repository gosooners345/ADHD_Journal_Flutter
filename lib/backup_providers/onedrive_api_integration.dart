import 'dart:typed_data';

import 'package:flutter_onedrive/flutter_onedrive.dart';

/// Need to expand OneDrive class to go further and force authentication when activated or else the data can easily be accessed or backups will not work properly
class OneDriveSyncClass{

  final oneDriveUtility = OneDrive(clientID: 'abdfccc0-c909-4782-aab7-c6db9400c042', redirectURL: 'https://login.live.com/oauth20_desktop.srf');


  void pushFileToCloud(String fileName){

    oneDriveUtility.push(Uint8List(2), fileName);
  }

  void downloadFileFromCloud(String fileName){
    oneDriveUtility.pull(fileName);
  }

}