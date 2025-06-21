import UIKit
import Flutter
import Photos
import AVFoundation




@main
@objc class AppDelegate: FlutterAppDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //var controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    var flutterResult: FlutterResult?
    
    
    
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        /// calls upon the flutter method channel to execute native code for tasks like changing passwords and more.
       
        
        guard let controller = window?.rootViewController as? FlutterViewController else {
                  fatalError("rootViewController is not type FlutterViewController")
              }
        var appChannel = FlutterMethodChannel(name: "com.activitylogger.release1/ADHDJournal",
                                              binaryMessenger: controller.binaryMessenger)
        
        appChannel.setMethodCallHandler({
           [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard let self = self else { return }
            
            if call.method == "openCamera" {
                                self.checkPermission()
                self.flutterResult = result

            } else{
                result(FlutterMethodNotImplemented)
                return
            }
        })
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    ///Check Permissions first
    func checkPermission() {
        let cameraPermission = AVCaptureDevice.authorizationStatus(for: .video)
        switch cameraPermission {
        case .authorized:
            self.openCamera()
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async{
                    if granted{
                        self!.openCamera()
                    } else{
                        self?.flutterResult?(FlutterError(code:"CAMERA_PERMISSION_DENIED", message:"Camera permission denied", details: nil))
                        self?.flutterResult=nil
                    }
                }
            }
            break
        case .denied, .restricted:
            self.flutterResult?(FlutterError(code: "CAMERA_PERMISSION_DENIED_OR_RESTRICTED",
                                             message: "Camera access is denied or restricted. Please enable it in Settings.",
                                             details: nil))
            self.flutterResult = nil
            break
        @unknown default:
                    self.flutterResult?(FlutterError(code: "UNKNOWN_CAMERA_PERMISSION",
                                                      message: "Unknown camera permission status.",
                                                      details: nil))
                    self.flutterResult = nil
                
            
            
        }
        
    }
    /// This method should launch the iOS Camera App and return the image back to the application
    func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            self.flutterResult?(FlutterError(code: "CAMERA_NOT_AVAILABLE",
                                             message: "Camera is not available on this device.",
                                             details: nil))
            self.flutterResult = nil
            return
        }
        DispatchQueue.main.async{
            let imagePicker=UIImagePickerController()
            imagePicker.delegate=self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing=false
            
            if let rootVC = self.window?.rootViewController{
                rootVC.present(imagePicker,animated: true,completion: nil)
            } else{
                self.flutterResult?(FlutterError(code:"VIEW_CONTROLLER_ERROR",message:"Could not get root view controller to present camera",details:nil))
                self.flutterResult=nil
            }
        }
        
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true, completion: nil)

            guard let image = info[.originalImage] as? UIImage else {
                self.flutterResult?(FlutterError(code: "IMAGE_PICKING_ERROR",
                                                  message: "Could not get the picked image.",
                                                  details: nil))
                self.flutterResult = nil
                return
            }

            // Convert UIImage to Data (e.g., JPEG)
            // Adjust compressionQuality as needed (0.0 to 1.0)
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                self.flutterResult?(FlutterError(code: "IMAGE_CONVERSION_ERROR",
                                                  message: "Could not convert image to JPEG data.",
                                                  details: nil))
                self.flutterResult = nil
                return
            }

            // Send data back to Flutter
            self.flutterResult?(FlutterStandardTypedData(bytes: imageData))
            self.flutterResult = nil // Clear the stored result
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
            self.flutterResult?(nil) // Send nil or a specific error for cancellation
            // self.flutterResult?(FlutterError(code: "USER_CANCELLED", message: "User cancelled the camera.", details: nil))
            self.flutterResult = nil // Clear the stored result
        }
    
    
}

    

    

