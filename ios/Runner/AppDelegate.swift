import UIKit
import Flutter
import SQLCipher
import NSUserDefaults
import SQLite




@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

let prefs = NSUserDefaults.standardUserDefaults()


  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

  // Code to implement the DB Stuff
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
let dbHandler = FlutterMethodChannel(name: "com.activitylogger.release1/ADHDJournal",
binaryMessenger: controller.binaryMessenger)
dbHandler.setMethodCallHandler({
(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
guard call.method == "changeDBPasswords" else
{
result(FlutterMethodNotImplemented)
return
}

})


    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

private func changeDBPasswords(){
    let oldDBPassword = prefs.objectForKey("dbPassword")
    let newDBPassword = prefs.objectForKey("loginPassword")
let dbName = "activitylogger_db.db"
    let dbPath = [NSString stringWithFormat:@"%@/%@",[self applicationDocumentsDirectory], dbName];
    
    decryptDB(password: oldDBPassword, path: dbPath, newPassword: newDBPassword)
//changeDBPassword()
//encryptDB()

}

    func decryptDB(password: String,path : String, newPassword : String)  {
        let db = try Connection(path)
        try db.key(key: password)
        try db.rekey(newPassword)
    }        // changeDBPassword(){}
    func encryptDB(newPassword : String , path : String) {
        
    }




}
