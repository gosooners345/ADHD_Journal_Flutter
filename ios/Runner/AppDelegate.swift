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
   print("Keying Db with new key")
    let newDBPassString : String = "\(String(describing: newDBPassword))"
          try dbPath.key( "\(dbPasswordString)")
    try dbPath.rekey("\(newDBPassString)")
    try dbPath.key("\(newDBPassString)")

  //   decryptOldDBPassword(oldPassword: dbPasswordString,dbPath:path+"/\(dbName)")
   //encryptNewDBPassword(newPassword: newDBPassString,dbPath:path+"/\(dbName)")
    
    //EncryptNewDB
    
}
catch {
print(error)
}
        }


//
//    func decryptOldDBPassword(oldPassword : String,dbPath: String){
//        let attachKey = "ATTACH DATABASE ? AS records  KEY ''"
//let  exportToDecrypteDBCommand = "SELECT sqlcipher_export('records')"
//        let detachCommand = "DETACH DATABASE records"
//
//        do{
//            var db = try! Connection(dbPath)
//            try db.key(key: oldPassword)
//
//            var newDBFile = FileManager.createFile(atPath: dbPath+"-temp.db", contents: "")
//            var version = db.userVersion
//            try db.close()
//            var newDB = try! Connection(dbPath+"-temp.db")
//            var newDBStatement = newDB.prepare(attachKey)
//            newDBStatement.run(1,dbPath)
//            newDB.run(exportToDecrypteDBCommand)
//            newDB.run(detachCommand)
//            newDB.userVersion = version
//            newDB.close()
//            newDB.
//
//        }
//        catch{
//        print(error)
//            print("Decryption Failed")
//        }
//        }
//
//        func encryptNewDBPassword(newPassword : String,dbPath: String){
//            do{
//            var db = try! Connection(dbPath)
//                try db.key("")
//                try db.rekey(newPassword)
//            }
//            catch{
//                print(error)
//
//            }
//            }
//            }
    }
    
}

    

    

