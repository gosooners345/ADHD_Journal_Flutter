import UIKit
import Flutter
//import SQLCipher
//import Foundation
import SQLite




@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

//let prefs = NSUserDefaults.standardUserDefaults()
//var prefs = UserDefaults

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

    private func changeDBPasswords(_ call: FlutterMethodCall){
        if let args = call.arguments as? Dictionary<String,Any>,
           let oldDBPassword = args["oldDBPassword"] as? String,
           let newDBPassword = args["newDBPassword"] as? String{
 
let dbName = "activitylogger_db.db"
let path = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true).first!
do{
let dbPath = try!  Connection("\(path)/\(dbName)")
    let dbPasswordString : String = "\(String(describing: oldDBPassword))"
    let newDBPassString : String = "\(String(describing: newDBPassword))"
    try dbPath.key( "\(dbPasswordString)")
    try dbPath.rekey("\(newDBPassString)")
}
catch {
print(error)
}
        }

}




}
