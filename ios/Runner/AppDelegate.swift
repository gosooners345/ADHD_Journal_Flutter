import UIKit
import Flutter
import SQLCipher





@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {



  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

/// calls upon the flutter method channel to execute native code for tasks like changing passwords and more.
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

/// This method handles rekeying the database after the db password has been changed.
    /// Tested and passed : 05/09/2022
    private func changeDBPasswords(_ call: FlutterMethodCall){
        if let args = call.arguments as? Dictionary<String,Any>,
           let oldDBPassword = args["oldDBPassword"] as? String,
           let newDBPassword = args["newDBPassword"] as? String{
 
let dbName = "activitylogger_db.db"
let path = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true).first!
do{

   var rc : Int32
    var db : OpaquePointer? = nil
    var statement: OpaquePointer? = nil
  rc = sqlite3_open(path + dbName , &db)
    rc = sqlite3_key(db,oldDBPassword,Int32(oldDBPassword.utf8CString.count))
   rc = sqlite3_rekey(db,newDBPassword,Int32(newDBPassword.utf8CString.count))
sqlite3_close(db)
    
}
catch {
print(error)
}
        }



    }
    
}

    

    

