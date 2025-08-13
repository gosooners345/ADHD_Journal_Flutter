// MainActivity.kt - Complete version with all TFLite and Camera methods

package com.activitylogger.release1.adhd_journal_flutter

import android.app.Activity
import android.content.Intent
import android.content.res.AssetFileDescriptor
import android.graphics.Bitmap
import android.util.Log
import androidx.annotation.NonNull
//import androidx.compose.ui.semantics.error
//import com.google.android.gms.tflite.java.TfLite
//import com.google.android.gms.tflite.client.TfLiteClient
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMethodCodec
import org.tensorflow.lite.Interpreter
import org.tensorflow.lite.flex.FlexDelegate
import java.io.ByteArrayOutputStream
import java.io.FileInputStream
import java.lang.Exception
import java.io.FileNotFoundException
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.MappedByteBuffer
//import java.nio.channels.FileChanne
import java.lang.SecurityException
//import java.nio.MappedByteBuffer
import java.nio.channels.FileChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.activitylogger.release1/ADHDJournal"

    companion object {
        private const val REQUEST_IMAGE_CAPTURE = 1
    }

    private lateinit var channel: MethodChannel
    private var flexDelegate: FlexDelegate? = null
    private var interpreter: org.tensorflow.lite.Interpreter? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL, StandardMethodCodec.INSTANCE)

        // This is the initializer for the GMS TFLite module. It's safe to call early.
       // TfLite.initialize(this)

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "initFlexInterpreter" -> {
                    setupInterpreter(result)
                   // setupInterpreterWithFlex(result)
                }
                // ADD THIS ENTIRE 'predict' BLOCK
                "predict" -> {
                    if (interpreter == null) {
                        result.error("NOT_INITIALIZED", "Interpreter is not ready.", null)
                        return@setMethodCallHandler
                    }
                    try {
                        // --- CORRECTED ARGUMENT PARSING ---
                        val arguments = call.arguments as? Map<String, Any>
                        if (arguments == null) {
                            Log.e("MainActivity", "Arguments map itself is null!")
                            result.error("INVALID_ARGS", "Arguments map is null", null)
                            return@setMethodCallHandler
                        }

                        // Log what we receive for each key for debugging
                        Log.d("MainActivity", "Received arguments['keywords']: ${arguments["keywords"]} (type: ${arguments["keywords"]?.javaClass?.name})")
                        Log.d("MainActivity", "Received arguments['content']: ${arguments["content"]} (type: ${arguments["content"]?.javaClass?.name})")
                        Log.d("MainActivity", "Received arguments['rating']: ${arguments["rating"]} (type: ${arguments["rating"]?.javaClass?.name})")

                        // Directly cast to the correct primitive array types.
                        // Dart's Int32List maps to IntArray, and Float32List maps to FloatArray.
                        val keywordInput: IntArray? = arguments["keywords"] as? IntArray
                        val contentInput: IntArray? = arguments["content"] as? IntArray
                        val ratingInput: FloatArray? = arguments["rating"] as? FloatArray
                        // NEW
                        val sleepInput: FloatArray? = arguments["sleep"] as? FloatArray
                        val medicationInput: IntArray? = arguments["medication"] as? IntArray





                        // Combined null check for all inputs
                        if (keywordInput == null || contentInput == null || ratingInput == null) {
                            var errorMsg = "Input data is missing or in the wrong format: "
                            if (keywordInput == null) errorMsg += "Keywords expected IntArray. "
                            if (contentInput == null) errorMsg += "Content expected IntArray. "
                            if (ratingInput == null) errorMsg += "Rating expected FloatArray."
                            if (sleepInput == null) errorMsg += "Sleep expected FloatArray. " // NEW
                            if (medicationInput == null) errorMsg += "Medication expected IntArray. " // NEW
                            Log.e("MainActivity", errorMsg)
                            result.error("INVALID_ARGS", errorMsg, null)
                            return@setMethodCallHandler
                        }

                        // From here on, Kotlin knows these are non-nullable arrays.
                        Log.d("MainActivity", "Successfully parsed keywordInput size: ${keywordInput.size}")
                        Log.d("MainActivity", "Successfully parsed contentInput size: ${contentInput.size}")
                        Log.d("MainActivity", "Successfully parsed ratingInput size: ${ratingInput.size}")
                        Log.d("MainActivity", "Received arguments['sleep']: ${arguments["sleep"]?.javaClass?.name})")
                        Log.d("MainActivity", "Received arguments['medication']: ${arguments["medication"]?.javaClass?.name})")


                        // --- PREPARE BUFFERS AND RUN INFERENCE ---

                        // Prepare input buffers for the model
                        val keywordBuffer = ByteBuffer.allocateDirect(keywordInput.size * Int.SIZE_BYTES)
                            .order(ByteOrder.nativeOrder())
                        keywordBuffer.asIntBuffer().put(keywordInput)
                        keywordBuffer.rewind() // Or .position(0)

                        val contentBuffer = ByteBuffer.allocateDirect(contentInput.size * Int.SIZE_BYTES)
                            .order(ByteOrder.nativeOrder())
                        contentBuffer.asIntBuffer().put(contentInput)
                        contentBuffer.rewind() // Or .position(0)

                        val ratingBuffer = ByteBuffer.allocateDirect(ratingInput.size * Float.SIZE_BYTES)
                            .order(ByteOrder.nativeOrder())
                        ratingBuffer.asFloatBuffer().put(ratingInput)
                        ratingBuffer.rewind() // Or .position(0)

                        //New Arrays
                        val sleepBuffer = ByteBuffer.allocateDirect(sleepInput!!.size * Float.SIZE_BYTES)
                            .order(ByteOrder.nativeOrder())
                        sleepBuffer.asFloatBuffer().put(sleepInput)
                        sleepBuffer.rewind()

                        val medicationBuffer = ByteBuffer.allocateDirect(medicationInput!!.size * Int.SIZE_BYTES)
                            .order(ByteOrder.nativeOrder())
                        medicationBuffer.asIntBuffer().put(medicationInput)
                        medicationBuffer.rewind()


                        // The 'inputs' array for the interpreter
                        val inputs = arrayOf<Any>(sleepBuffer,keywordBuffer,  ratingBuffer,contentBuffer,medicationBuffer)

                        // Prepare output buffer
                        val outputTensor = interpreter!!.getOutputTensor(0)
                        val outputShape = outputTensor.shape()
                        val outputElementCount = outputShape.fold(1) { acc, i -> acc * i }
                        val outputBuffer = ByteBuffer.allocateDirect(outputElementCount * Float.SIZE_BYTES)
                            .order(ByteOrder.nativeOrder())
                        val outputMap = mapOf(0 to outputBuffer)

                        // Run inference using the native interpreter
                        /// Remember to implement the iOS equivalent of this so the code is consistenly executed
                        interpreter?.runForMultipleInputsOutputs(inputs, outputMap)

                        outputBuffer.rewind()
                        val predictionResults = FloatArray(outputElementCount)
                        outputBuffer.asFloatBuffer().get(predictionResults)
                        Log.d("MainActivity", "Native prediction results: ${predictionResults.toList()}")

                        // Convert FloatArray to List<Double> for Dart, as MethodChannel handles this well.
                        result.success(predictionResults.map { it.toDouble() })

                    } catch (e: Exception) {
                        result.error("PREDICTION_FAILED", "Native prediction failed", e.localizedMessage)
                    }
                }


                "closeInterpreter" -> {
                    closeInterpreter()
                    result.success(true)
                }
                "openCamera" -> {
                    val intent = Intent(android.provider.MediaStore.ACTION_IMAGE_CAPTURE)
                    try {
                        startActivityForResult(intent, REQUEST_IMAGE_CAPTURE)
                    } catch (e: SecurityException) {
                        result.error("CAMERA_PERMISSION", "Camera permission not granted", e.localizedMessage)
                    } catch (e: Exception) {
                        result.error("CAMERA_START_FAILED", "Failed to start camera", e.localizedMessage)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }


    private fun setupInterpreter(result: MethodChannel.Result) {
        if (interpreter != null) {
            Log.d("MainActivity", "Interpreter already initialized. Skipping.")
            result.success(true) // If already initialized, it's a success
            return
        }

        try {
            val success = initInterpreterWithFlex("flutter_assets/assets/adhd_predictor_v2.tflite")
            // Send the boolean result back to Dart
            result.success(success)
        } catch (e: Exception) {
            Log.e("MainActivity", "A critical error occurred during interpreter creation.", e)
            result.error("INIT_FAILED", "A critical error occurred during interpreter creation.", e.localizedMessage)
        }
    }



    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_IMAGE_CAPTURE) {
            if (resultCode == Activity.RESULT_OK) {
                val journalImage = data?.extras?.get("data") as? Bitmap
                if (journalImage != null) {
                    val stream = ByteArrayOutputStream()
                    journalImage.compress(Bitmap.CompressFormat.JPEG, 100, stream)
                    val byteArray = stream.toByteArray()
                    channel.invokeMethod("onPictureTaken", byteArray)
                } else {
                    channel.invokeMethod("onPictureTakenError", "Image capture failed")
                }
            } else if (resultCode == Activity.RESULT_CANCELED) {
                channel.invokeMethod("onPictureCancelled", "Image capture cancelled")
            } else {
                channel.invokeMethod(
                    "onPictureTakenError",
                    "Camera operation failed with resultCode: $resultCode"
                )
            }
        }
    }




    private fun initInterpreterWithFlex(assetModelName: String): Boolean {
        // If able to load, then this will be true
        val model = loadModelFromAssets(assetModelName)
            if(model==null){
                Log.w("MainActivity", "Model file not found yet");
                return false
            }
        try {
            // Using the nested Options class, as you confirmed works.
            val options = org.tensorflow.lite.Interpreter.Options()
            flexDelegate = FlexDelegate()
            options.addDelegate(flexDelegate)
            interpreter = org.tensorflow.lite.Interpreter(model, options)
            
            // --- ADD THIS DIAGNOSTIC CODE ---
            Log.d("MainActivity", "--- TFLite Model Input Tensor Details ---")
            val inputTensorCount = interpreter!!.inputTensorCount
            for (i in 0 until inputTensorCount) {
                val tensor = interpreter!!.getInputTensor(i)
                val shape = tensor.shape().joinToString(", ")
                Log.d("MainActivity", "Input Tensor Index $i: Name=${tensor.name()}, Shape=[$shape], DataType=${tensor.dataType()}")
            }
            Log.d("MainActivity", "-----------------------------------------")
            // --- END OF DIAGNOSTIC CODE ---

            Log.d("MainActivity", "Interpreter initialized successfully with FlexDelegate.")
            return true
        } catch (e: java.lang.Exception) {
            closeInterpreter() // Clean up on failure
            //throw IllegalStateException("Failed to initialize TFLite with FlexDelegate.", e)
            return false
        }
    }

    private fun loadModelFromAssets(assetName: String): MappedByteBuffer? {
        try{
           // val finalAssetName = assetName.removePrefix("assets/")
            //Log.d("MainActivity", "Loading model from sanitized asset path: $finalAssetName")
            val afd: AssetFileDescriptor = context.assets.openFd(assetName)
            FileInputStream(afd.fileDescriptor).channel.use { fc ->
                return fc.map(
                    FileChannel.MapMode.READ_ONLY,
                    afd.startOffset,
                    afd.declaredLength
                )
            }
        } catch (e: FileNotFoundException) {
            Log.w("MainActivity", "Model file not found yet")
            return null
        }catch(e:Exception){
            Log.e("MainActivity", "Failed to load model from assets.", e)
            return null
        }



    }

    override fun onDestroy() {
        super.onDestroy()
        closeInterpreter()
    }

    private fun closeInterpreter() {
        interpreter?.close()
        interpreter = null
        flexDelegate?.close()
        flexDelegate = null
        Log.d("MainActivity", "Interpreter closed.")
    }
}
