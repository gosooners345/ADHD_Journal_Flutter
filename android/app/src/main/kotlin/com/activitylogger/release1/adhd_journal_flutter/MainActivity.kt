package com.activitylogger.release1.adhd_journal_flutter

import android.content.Context
import android.content.SharedPreferences
import android.provider.MediaStore.Audio.Media
import android.app.Activity
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.annotation.NonNull
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import java.lang.Exception
import android.content.Intent
import java.io.ByteArrayOutputStream
import io.flutter.plugin.common.StandardMethodCodec
import java.io.File
import java.io.FileNotFoundException
import java.util.*
import android.graphics.Bitmap
import java.lang.SecurityException


class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.activitylogger.release1/ADHDJournal"
    //private lateinit var sharePreferences : SharedPreferences
companion object{
    private const val REQUEST_IMAGE_CAPTURE = 1
}
private lateinit var channel: MethodChannel
    //private val appContext = this.context;


    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger,CHANNEL,StandardMethodCodec.INSTANCE)
        channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "openCamera" -> {
                        val intent = Intent(android.provider.MediaStore.ACTION_IMAGE_CAPTURE)
                        try{
                            startActivityForResult(intent,REQUEST_IMAGE_CAPTURE)
                        } catch (e:SecurityException){
                            result.error("CAMERA_PERMISSION","Camera permission not granted",e.localizedMessage)
                        } catch (e: Exception){
                            result.error("CAMERA_START_FAILED","Failed to start camera",e.localizedMessage)
                        }

//                        val data = intent.data
                        //result.success(data)
                    }
                    else -> {
                        result.notImplemented()
                    }
                }

        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_IMAGE_CAPTURE){
            if(resultCode == Activity.RESULT_OK) {
                val journalImage = data?.extras?.get("data") as? Bitmap
                if (journalImage != null) {
                    val stream = ByteArrayOutputStream()
                    journalImage.compress(Bitmap.CompressFormat.JPEG, 100, stream)
                    val byteArray = stream.toByteArray()
                    android.util.Log.d("MainActivity", "Sending ${byteArray.size} bytes to Flutter for image.")
                    android.util.Log.d("MainActivity", "Bitmap details: Width=${journalImage.width}, Height=${journalImage.height}, Config=${journalImage.config}")

                    channel.invokeMethod("onPictureTaken", byteArray)
                } else{
                    channel.invokeMethod("onPictureTakenError", "Image capture failed")
                }
            }
                else if (resultCode == Activity.RESULT_CANCELED) {
                    channel.invokeMethod("onPictureCancelled", "Image capture cancelled")
                } else {
                    channel.invokeMethod(
                        "onPictureTakenError",
                        "Camera operation failed with resultCode: $resultCode"
                    )
                }
            }
    }













}







