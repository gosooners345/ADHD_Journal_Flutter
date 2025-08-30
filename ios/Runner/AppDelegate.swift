


// AppDelegate.swift
import UIKit
import Flutter
import Photos
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

//    private let tfLiteManager = TFLiteManager()
    private let coreMLManager = CoreMLManager()
    private var cameraResult: FlutterResult? // A dedicated result for the async camera operation

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        guard let controller = window?.rootViewController as? FlutterViewController else {
            fatalError("rootViewController is not type FlutterViewController")
        }

        let channel = FlutterMethodChannel(
            name: "com.activitylogger.release1/ADHDJournal",
            binaryMessenger: controller.binaryMessenger
        )

        channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard let self = self else { return }

            switch call.method {
            case "init": return self.coreMLManager.initialized ? result(true) : result(false)
            case "predict":
                            // All prediction logic is now handled by the CoreMLManager
                            self.coreMLManager.predict(arguments: call.arguments, result: result)


            case "openCamera":
                // Store the result callback and start the camera flow
                self.cameraResult = result
                self.checkCameraPermission()

            default:
                result(FlutterMethodNotImplemented)
            }
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // MARK: - Camera Logic (Remains mostly the same, but uses `cameraResult`)

    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            openCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.openCamera()
                    } else {
                        self?.sendCameraError(code: "PERMISSION_DENIED", message: "Camera permission was denied.")
                    }
                }
            }
        case .denied, .restricted:
            sendCameraError(code: "PERMISSION_RESTRICTED", message: "Camera access is denied or restricted. Please enable it in Settings.")
        @unknown default:
            sendCameraError(code: "UNKNOWN_PERMISSION", message: "Unknown camera permission status.")
        }
    }
    
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            sendCameraError(code: "NOT_AVAILABLE", message: "Camera is not available on this device.")
            return
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.allowsEditing = false
        window?.rootViewController?.present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            sendCameraError(code: "PROCESSING_ERROR", message: "Could not process the captured image.")
            return
        }
        
        cameraResult?(FlutterStandardTypedData(bytes: imageData))
        cameraResult = nil
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        cameraResult?(nil) // User cancelled
        cameraResult = nil
    }

    private func sendCameraError(code: String, message: String) {
        cameraResult?(FlutterError(code: code, message: message, details: nil))
        cameraResult = nil
    }
}
