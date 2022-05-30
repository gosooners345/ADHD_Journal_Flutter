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

val appPreferences = getSecretSharedPref(this)


    override  fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            // This is where any list methods should be initialized.


            when (call.method) {
                "changeDBPasswords" -> {
                    try {
                        // sharePreferences =  getSharedPreferences(BuildConfig.APPLICATION_ID, MODE_PRIVATE)
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


                }
                "migrateDBPassword"->{

                }
            }
        }
    }



  private  fun changeDBPasswords(oldDBPassword : String, newDBPassword : String){
try {
   SQLiteDatabase.loadLibs(context)
    //val oldDBPassword = sharePreferences.getString("Flutter.dbPassword", "").toString()
    //val newDBPassword = sharePreferences.getString("Flutter.loginPassword", "").toString()
    val dbName = "activitylogger_db.db"
    val dbPath = context.getDatabasePath(dbName)
    val oldDBPasscode = SQLiteDatabase.getBytes(oldDBPassword.toCharArray())
    val newDBPasscode = SQLiteDatabase.getBytes(newDBPassword.toCharArray())
decryptOldDBPassword(context,dbPath,oldDBPasscode)
    Log.i("DBState","Decryption Complete")
    encryptNewDBPassword(context,dbPath,newDBPasscode)
    Log.i("DBState","Encryption Complete")
}
catch (ex :Exception){
    print(ex)
}
  }

    private fun decryptOldDBPassword(context: Context, dbFile : File, passwordBytes: ByteArray){
        SQLiteDatabase.loadLibs(context)
        try{
            val attachKEY =
                String.format("ATTACH DATABASE ? AS records  KEY ''")
            if (dbFile.exists())
            {
                Log.i("DECRYPTION", "Decrypting database")
                val newFile = File.createTempFile("decrypted", "")
                var db = SQLiteDatabase.openDatabase(
                    dbFile.absolutePath,
                    passwordBytes, null, SQLiteDatabase.OPEN_READWRITE, null, null
                )
                val st = db.compileStatement(attachKEY)
                st.bindString(1, newFile.absolutePath)
                st.execute()
                db.rawExecSQL("SELECT sqlcipher_export('records')")
                db.rawExecSQL("DETACH DATABASE records")
                val version = db.version
                st.close()
                db.close()
                db = SQLiteDatabase.openDatabase(
                    newFile.absolutePath,
                    "",
                    null,
                    SQLiteDatabase.OPEN_READWRITE
                )
                db.version = version
                db.close()
                dbFile.delete()
                newFile.renameTo(dbFile)
            }
            else
            {
                throw FileNotFoundException(
                    dbFile.absolutePath + "not found"
                )
            }
        }
        catch (ex : Exception){
            Log.e("Exception",ex.message.toString())
        }
    }

    private fun encryptNewDBPassword(context: Context,dbFile: File,passwordBytes: ByteArray){
        val attachKEY =
            String.format("ATTACH DATABASE ? AS records KEY ''")
        SQLiteDatabase.loadLibs(context)
        try{
        if (dbFile.exists())
        {
            Log.i("ENCRYPTION", "Encrypting database")
            val newFile = File.createTempFile("encrypted", "tmp")
            var newDBs = SQLiteDatabase.openDatabase(
                dbFile.absolutePath,
                "",
                null,
                SQLiteDatabase.OPEN_READWRITE
            )
            val version = newDBs.version
            newDBs.close()
            newDBs = SQLiteDatabase.openDatabase(
                newFile.absolutePath,
                passwordBytes,
                null,
                SQLiteDatabase.OPEN_READWRITE,
                null,
                null
            )
            val st = newDBs.compileStatement(attachKEY)
            st.bindString(1, dbFile.absolutePath)
            st.execute()
            newDBs.rawExecSQL(
                "SELECT sqlcipher_export('main','records')"
            )
            newDBs.rawExecSQL("DETACH DATABASE records")
            newDBs.version = version
            dbFile.delete()
            newFile.renameTo(dbFile)
        }
        else
        {
            throw FileNotFoundException(
                dbFile.absolutePath + "not found"
            )
        }
    }
    catch (ex: Exception)
    {
        ex.printStackTrace()
    }
    }

    private fun getSecretSharedPref(context: Context): SharedPreferences
    {
        val masterKey = MasterKey.Builder(context)
            .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
            .build()
        return EncryptedSharedPreferences.create(
            context,
            "com.activitylogger.release1" + "_secured",
            masterKey,
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
        )
    }

    }

