
class DriveUploadException implements Exception {
  final String? message;
  DriveUploadException([this.message]);
  @override
  String toString() {
   if(message==null){
     return 'DriveUploadException';
   }
    return 'DriveUploadException: $message';
  }
}
class GoogleClientException implements Exception {
  final String? message;
  GoogleClientException([this.message]);
  @override
  String toString() {
    if(message==null){
      return 'GoogleClientException';
    }
    return 'GoogleClientException: $message';
  }

}
class GoogleAuthException implements Exception {
  final String? message;
  GoogleAuthException([this.message]);
  @override
  String toString() {
    if(message==null){
      return 'GoogleAuthException';
    }
    return 'GoogleAuthException: $message';
  }
}
class ConnectionException implements Exception {
  final String? message;
  ConnectionException([this.message]);
  @override
  String toString() {
    if(message==null){
      return 'ConnectionException';
    }
    return 'ConnectionException: $message';
  }
}