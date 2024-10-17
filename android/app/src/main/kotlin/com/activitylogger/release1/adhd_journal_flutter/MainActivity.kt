package com.activitylogger.release1.adhd_journal_flutter

import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.annotation.NonNull
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import java.lang.Exception
//import net.sqlcipher.database.SQLiteDatabase
import java.io.File
import java.io.FileNotFoundException
import java.util.*


class MainActivity: FlutterActivity(){
    private val CHANNEL = "com.activitylogger.release1/ADHDJournal"
    //private lateinit var sharePreferences : SharedPreferences



//private val appContext = this.context;
  /*  override  fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)



        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result  -> {
            // This is where any list methods should be initialized.


            when (call.method) {
                "PushFile" -> {

var arg1 = call.argument() as String?


                }
                "PullFile" -> {
                    var arg1 = call.argument() as String?
                }


                }

            }}
        }*/
}







