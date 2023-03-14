import 'dart:typed_data';

import 'package:flutter_onedrive/flutter_onedrive.dart';


class OneDriveSyncClass{

  final oneDriveUtility = OneDrive(clientID: '', redirectURL: '');


  void pushFileToCloud(String fileName){

    oneDriveUtility.push(Uint8List(2), fileName);
  }

  void downloadFileFromCloud(String fileName){
    oneDriveUtility.pull(fileName);
  }

}