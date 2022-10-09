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
import net.sqlcipher.database.SQLiteDatabase
import java.io.File
import java.io.FileNotFoundException
import java.util.*


class MainActivity: FlutterActivity(){
    private val CHANNEL = "com.activitylogger.release1/ADHDJournal"
    //private lateinit var sharePreferences : SharedPreferences



//private val appContext = this.context;
    override  fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
    SQLiteDatabase.loadLibs(applicationContext)


        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            // This is where any list methods should be initialized.


            when (call.method) {
                "changeDBPasswords" -> {
                    try {
var arg1 = call.argument("oldDBPassword") as String?
var arg2 = call.argument("newDBPassword") as String?
var oldDBPassword = SQLiteDatabase.getBytes(arg1?.toCharArray())
                        var newDBPassCode = SQLiteDatabase.getBytes(arg2?.toCharArray())
                        val dbName = "activitylogger_db.db"
                        val dbPath = context.getDatabasePath(dbName)
                        var db = SQLiteDatabase.openDatabase(
                            dbPath.absolutePath,oldDBPassword,null,SQLiteDatabase.OPEN_READWRITE,null,null)
                       db.rawExecSQL("PRAGMA rekey = $newDBPassCode")
                    } catch (ex: Exception) {
                        print(ex)
                        Log.i("EXCEPTION", ex.message.toString())
                    }
                }
                "migrateUserPassword"->{
                    val appPreferences = getSecretSharedPref(this.context)
val userPassword = appPreferences.getString("password","")
                    result.success(userPassword)

                }
                "migrateDBPassword"->{
                    val appPreferences = getSecretSharedPref(this.context)
val dbPasswordGet = appPreferences.getString("dbPassword","")
                    result.success(dbPasswordGet)
                }
                "migrateGreeting" ->{
                    val appPreferences = getSecretSharedPref(this.context)
                    val greeting = appPreferences.getString("greeting","")
                    result.success(greeting)
                }
                "migratePasswordPrefs" ->{
                    val appPreferences = getSecretSharedPref(this.context)
                    val passprefs = appPreferences.getBoolean("enablePassword",true)
                    result.success(passprefs)
                }

                "checkForDB" -> {
                    var testPath = false
                    val context = applicationContext;
                    val dbFile = context.getDatabasePath("activitylogger_db.db")

                if(dbFile.exists()) {
                    val appPreferences = getSecretSharedPref(context)
                    val testPassword = appPreferences.getString("dbPassword", "")

                    if (testPassword == "")
                        testPath = true
                }
                    result.success(testPath)
                }

            }
        }
    }


    private fun getSecretSharedPref(context: Context): SharedPreferences
    {
        val masterKey = MasterKey.Builder(context)
            .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
            .build()
        return EncryptedSharedPreferences.create(
            context,
            "com.activitylogger.release1_preferences" + "_secured",
            masterKey,
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
        )
    }

    }

