
// Helper class to manage file information
import 'dart:io';
import '../backup_providers/google_drive_backup_class.dart';

class ManagedFile {
  final String localPath;
  final String remoteFileName;
  final File localFile;
  bool localExists = false;
  bool remoteExists = false;
  bool? localIsNewer; // Null if no comparison needed or possible

  ManagedFile(this.localPath, this.remoteFileName) : localFile = File(localPath);

  Future<void> checkLocalExistence() async {
    localExists = await localFile.exists();
  }

  // Assumes googleDrive instance is available
  Future<bool> checkRemoteExistence(GoogleDrive googleDrive) async {
    remoteExists = await googleDrive.checkForFile(remoteFileName);
    return remoteExists;
  }

  // Assumes googleDrive instance is available and localFile exists
  ////If Local is newer, then
  Future<void> checkRemoteIsNewer(GoogleDrive googleDrive) async {
    if (localExists && remoteExists) {
      print("both sides exist");
      localIsNewer = await googleDrive.isLocalFileNewer(remoteFileName,localFile.path);
      print("localIsNewer: $localIsNewer");
    }
  }
}
