import 'package:flutter/material.dart';
import 'package:adhd_journal_flutter/project_resources/project_utils.dart';

class OneDriveAPICalls {
  Future<bool> pushFilesToCloud(String fileNames) async {
    if ((await platform.invokeMethod('PushFile', fileNames))) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> pullFilesFromCloud(String fileNames) async {
    if ((await platform.invokeMethod('PullFile', fileNames))) {
      return true;
    } else {
      return false;
    }
  }
}
