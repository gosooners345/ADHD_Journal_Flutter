import 'dart:typed_data';

import 'package:flutter_onedrive/flutter_onedrive.dart';


class OneDriveSyncClass{

  final oneDriveUtility = OneDrive(clientID: 'abdfccc0-c909-4782-aab7-c6db9400c042', redirectURL: '');


  void pushFileToCloud(String fileName){

    oneDriveUtility.push(Uint8List(2), fileName);
  }

  void downloadFileFromCloud(String fileName){
    oneDriveUtility.pull(fileName);
  }

}