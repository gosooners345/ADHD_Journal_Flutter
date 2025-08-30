// lib/adhd_machine_learning/adhd_feature_service.dart
import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle, MethodChannel, PlatformException;
import 'package:adhd_journal_flutter/record_data_package/records_data_class_db.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../project_resources/global_vars_andpaths.dart';
import 'package:flutter/foundation.dart';

class AdhdMlService {
  late Interpreter _interpreter;
  late Map<String, int> _keywordVocab;
  late Map<String, int> _contentVocab;
  late Map<String, int> _medicationVocab;
  late List<String> _successLabels;
  late List<String> _dayTypeLabels;
  late int _keywordSequenceLength;
  late int _contentSequenceLength;
  late int _medicationSequenceLength;
  late double _ratingScaleMin;
  late double _ratingScaleMax;
  late double _sleepScaleMin;
  late double _sleepScaleMax;

  bool _isInitialized = false;
  Map<String,int> get medicationVocabulary => _isInitialized?_medicationVocab:{};
  Map<String, int> get keywordVocabulary => _isInitialized ? _keywordVocab : {}; // Public getter
  Map<String, int> get contentVocabulary => _isInitialized ? _contentVocab : {}; // Public getter
  List<String> get successLabels => _isInitialized ? _successLabels : []; // Public getter
  List<String> get dayTypeLabels => _isInitialized ? _dayTypeLabels : []; // Public getter
  int get keywordSequenceLength => _isInitialized ? _keywordSequenceLength : 0; // Public getter
  int get contentSequenceLength => _isInitialized ? _contentSequenceLength : 0;
  int get medicationSequenceLength => _isInitialized ? _medicationSequenceLength : 0;
  double get ratingScaleMin => _isInitialized ? _ratingScaleMin : 0.0; // Public getter
  double get ratingScaleMax => _isInitialized ? _ratingScaleMax : 100.0;



  bool get isInitialized => _isInitialized;
  static const MethodChannel _channel =
      MethodChannel(Global.PLATFORMCHANNEL_PATH);

  // This code is fine as is
  Future<void> initialize() async {
    bool isNativeInterpreterReady = false;
    const int maxRetries = 5;
    const Duration retryDelay = Duration(seconds: 2);
    if (_isInitialized) return;

    if(Platform.isAndroid){

    int attempt = 0;

    while (attempt < maxRetries && !isNativeInterpreterReady) {
      attempt++;
      if (kDebugMode) {
        print("Initializing ML Service, attempt #$attempt");
      }
      try {
        final bool? result = await _channel.invokeMethod('initFlexInterpreter');
        isNativeInterpreterReady = result ?? false;
        if (!isNativeInterpreterReady && attempt < maxRetries) {
          if (kDebugMode) {
            print("Native interpreter not ready, retrying in $retryDelay");
          }
          await Future.delayed(retryDelay);
        }
        if (isNativeInterpreterReady) {
          break;
        }

      } catch (e) {
        if (kDebugMode) {
          print("Error initializing native interpreter: $e");
        }
        // On a hard error (like an exception from native code), we stop trying.
        break;
      }
    }
    if(isNativeInterpreterReady){
      await _loadDartAssets();
      _isInitialized = true;

      if (kDebugMode) {
        print("✅ AdhdMlService initialized successfully.");
      }



    } else {
    if(kDebugMode) {
    print("Failed to initialize native interpreter after $maxRetries attempts.");
    }
    throw Exception(
    'Failed to initialize ML Service after $maxRetries attempts.');
    }}


    else if (Platform.isIOS){
      _isInitialized =   await _channel.invokeMethod('init');
      await _loadDartAssets();

      if(kDebugMode) {
        print("✅ AdhdMlService initialized $_isInitialized.");
      }
    }

  }



Future<void> _loadDartAssets() async{
    _keywordVocab = await _loadVocab('assets/vocab_keywords.txt');
  _contentVocab = await _loadVocab('assets/vocab_content.txt');
  _medicationVocab = await _loadVocab('assets/vocab_medication.txt');
    if (kDebugMode) {
      print("✅ Vocabularies loaded.");
    }

    final definitionsString =
    await rootBundle.loadString('assets/ml_definitions.json');
    final definitions = json.decode(definitionsString);
    _successLabels = List<String>.from(definitions['success_labels']);
    _dayTypeLabels = List<String>.from(definitions['day_type_labels']);
    // Keywords and content
    // Symptoms and emotions?
    _keywordSequenceLength = definitions['keyword_sequence_length'];
    // Content context
    _contentSequenceLength = definitions['content_sequence_length'];
    // Ratings
    _ratingScaleMin = (definitions['RATING_MIN'] as num).toDouble();
    _ratingScaleMax = (definitions['RATING_MAX'] as num).toDouble();
    _sleepScaleMin = (definitions['RATING_MIN'] as num).toDouble();
    _sleepScaleMax = (definitions['RATING_MAX'] as num).toDouble();
    _medicationSequenceLength = definitions['medication_sequence_length'];

    if (kDebugMode) {
      print( "✅ Definitions loaded. Rating scale [$_ratingScaleMin, $_ratingScaleMax]");
    }

}

  Future<Map<String, int>> _loadVocab(String path) async {
    final vocabString = await rootBundle.loadString(path);
    final vocabList = vocabString.split('\n');
    return {for (int i = 0; i < vocabList.length; i++) vocabList[i]: i};
  }


  List<int> publicTokenizeText({
    required String text,
    required Map<String, int> vocab,
    required int sequenceLength,
  })
  {
    final vector = List<int>.filled(sequenceLength, 0); // 0 for padding (PAD token)
    final punctuationRegex = RegExp(r'[!"#$%&()*+,-./:;<=>?@\[\\\]^_`{|}~]');
    final textWithSpaces = text.toLowerCase().replaceAll(punctuationRegex, ' ');

    final words = textWithSpaces.trim().split(RegExp(r'\s+'));
    int index = 0;
    for (final word in words) {
      if (index >= sequenceLength) break;
      if (word.isEmpty) continue;
      final sanitizedWord = word.replaceAll(punctuationRegex, '');
      if (sanitizedWord.isEmpty) continue;
      // Use 1 for OOV/Unknown token if your vocab is set up that way,
      // or whatever your <unk> token ID is. Assuming 1 for <unk>.
      vector[index++] = vocab[sanitizedWord] ?? 1;
    }
    return vector;
  }
  List<int> _vectorizeContentText({
    required String text,
    required Map<String, int> vocab,
    required int sequenceLength,
  })
  {
    final vector =
    List<int>.filled(sequenceLength, 0); // Use double for Float32List
    final punctuationRegex = RegExp(r'[!"#$%&()*+,-./:;<=>?@\[\\\]^_`{|}~]');
    final textWithSpaces = text.toLowerCase().replaceAll(punctuationRegex, ' ');

    final words = textWithSpaces.trim().split(RegExp(r'\s+'));
    int index = 0;
    for (final word in words) {
      if (index >= sequenceLength) break;
      if (word.isEmpty) continue;
      final sanitizedWord = word.replaceAll(punctuationRegex, '');
      if (sanitizedWord.isEmpty) continue;
      // Use 1 for OOV/Unknown token
      vector[index++] = (vocab[sanitizedWord] ?? 1);
    }
    return vector;
  }
  // FIX: This should return a List<double> for easier use with Float32List
  List<double> _vectorizeText({
    required String text,
    required Map<String, int> vocab,
    required int sequenceLength,
  })
  {
    final vector =
        List<double>.filled(sequenceLength, 0.0); // Use double for Float32List
    final punctuationRegex = RegExp(r'[!"#$%&()*+,-./:;<=>?@\[\\\]^_`{|}~]');
    final textWithSpaces = text.toLowerCase().replaceAll(punctuationRegex, ' ');

    final words = textWithSpaces.trim().split(RegExp(r'\s+'));
    int index = 0;
    for (final word in words) {
      if (index >= sequenceLength) break;
      if (word.isEmpty) continue;
      final sanitizedWord = word.replaceAll(punctuationRegex, '');
      if (sanitizedWord.isEmpty) continue;
      // Use 1 for OOV/Unknown token
      vector[index++] = (vocab[sanitizedWord] ?? 1).toDouble();
    }
    return vector;
  }

  List<double> publicNormalizeRating({required double userRating})
  {
    if (!_isInitialized) { // Ensure params are loaded
      print("Error: Rating normalization called before service initialized.");
      return [0.0]; // Default or throw error
    }
    var clampedRating = userRating.clamp(_ratingScaleMin, _ratingScaleMax);
    double normalized;
    if ((_ratingScaleMax - _ratingScaleMin).abs() < 1e-6) {
      normalized = 0.0; // Avoid division by zero
    } else {
      normalized = (clampedRating - _ratingScaleMin) / (_ratingScaleMax - _ratingScaleMin);
    }
    return [normalized]; // Return as List<double> as your predict method expects
  }

List<double> publicNormalizeSleep({required double userSleep}) {
    if (!_isInitialized) { // Ensure params are loaded
      print("Error: Sleep normalization called before service initialized.");
      return [0.0]; // Default or throw error
    }
    var clampedSleep = userSleep.clamp(_ratingScaleMin, _ratingScaleMax);
    double normalized;
 if((_ratingScaleMax - _ratingScaleMin).abs() < 1e-6) {
      normalized = 0.0; // Avoid division by zero
    } else {
      normalized = (clampedSleep - _ratingScaleMin) / (_ratingScaleMax - _ratingScaleMin);
  }
    return [normalized]; // Return as List<double> as your predict method expects
}

  Map<String, double> softmax(Map<String, double> logits) {
    // Find the maximum logit value for numerical stability
    final double maxLogit = logits.values.reduce(max);

    // Exponentiate and normalize
    final Map<String, double> expScores = logits.map((key, value) => MapEntry(key, exp(value - maxLogit)));
    final double sumExpScores = expScores.values.reduce((a, b) => a + b);

    if (sumExpScores == 0) return logits; // Avoid division by zero

    final Map<String, double> probabilities = expScores.map((key, value) => MapEntry(key, value / sumExpScores));

    return probabilities;
  }




  Future<Map<String, double>> predictRecord(Records record) async {
    if (!_isInitialized) {
      if (kDebugMode) {
        print("⚠️ AdhdMlService.predictRecord: Service not initialized. Attempting to initialize...");
      }
      await initialize();
      if (!_isInitialized) {
        if (kDebugMode) {
          print("⚠️ AdhdMlService.predictRecord: Service initialization failed. Cannot predict.");
        }
        // Return an empty map or throw an exception, depending on desired error handling
        return {};
      }
    }

        if (kDebugMode) {
          print("AdhdMlService.predictRecord: Preprocessing record ID: ${record.id}");
        }

    final String keywordString = "${record.symptoms ?? ''} ${record.emotions ?? ''}";
    final List<int> processedKeywords = publicTokenizeText(
      text: keywordString,
      vocab: _keywordVocab,
      sequenceLength: _keywordSequenceLength,
    );

    final String contentString = "${record.title ?? ''} ${record.content ?? ''}";
    final List<int> processedContent = publicTokenizeText(
      text: contentString,
      vocab: _contentVocab,
      sequenceLength: _contentSequenceLength,
    );

    double currentRatingValue = record.rating ?? ((_ratingScaleMin + _ratingScaleMax) / 2.0);
    final List<double> processedRating = publicNormalizeRating( // This already uses internal _ratingScaleMin/Max
      userRating: currentRatingValue,
    );

    double currentSleepValue = record.sleep ?? ((_ratingScaleMin + _ratingScaleMax) / 2.0);
    final List<double> processedSleep = publicNormalizeSleep( // This already uses internal _ratingScaleMin/Max
userSleep: currentSleepValue,);

    final List<int> processedMedication = publicTokenizeText(
      text:record.medication, vocab:_medicationVocab,sequenceLength: _medicationSequenceLength
    );

if(kDebugMode) {
  print(
      "AdhdMlService.predictRecord - Preprocessed Keywords (len: ${processedKeywords
          .length}): $processedKeywords");
  print(
      "AdhdMlService.predictRecord - Preprocessed Content (len: ${processedContent
          .length}): $processedContent");
  print("AdhdMlService.predictRecord - Preprocessed Rating: $processedRating");
}
    // 2. Call the existing 'predict' method with the preprocessed data
    //    The 'record' object is passed along for context as the first argument to 'predict'.
    return await predict(record,
       // Pass the original record object as the first argument
      keywords: processedKeywords,
      content: processedContent,
      rating: processedRating,
      sleep: processedSleep,
      medication: processedMedication

    );
  }
  //Is this actually used?
  double _normalizeRating(double userRating) {
    var clampedRating = userRating.clamp(_ratingScaleMin, _ratingScaleMax);
    if ((_ratingScaleMax - _ratingScaleMin).abs() < 1e-6) return 0.0;
    return (clampedRating - _ratingScaleMin) /
        (_ratingScaleMax - _ratingScaleMin);
  }


  Future<Map<String, double>> _predictWithCoreML({required Map<String, dynamic> inputs}) async{
    try {
      final Map<dynamic, dynamic>? rawOutput = await _channel.invokeMethod('predict', inputs);
      final Map<String, double> successLogits =
          (rawOutput!['success_probabilities'] as Map<dynamic, dynamic>?)?.cast<String, double>() ?? {};
      final Map<String, double> dayTypeLogits =
          (rawOutput['day_type_probabilities'] as Map<dynamic, dynamic>?)?.cast<String, double>() ?? {};

      // 3. Apply the softmax function to convert logits to probabilities.
      final Map<String, double> successProbabilities = softmax(successLogits);
      final Map<String, double> dayTypeProbabilities = softmax(dayTypeLogits);

      if (kDebugMode) {
        print("✅ Success Probabilities: $successProbabilities");
        print("✅ Day Type Probabilities: $dayTypeProbabilities");
      }

      // 4. Return the day type probabilities for the advice logic.
      return dayTypeProbabilities;

    } on PlatformException catch (e) {
      if (kDebugMode) print("❌ Failed to get Core ML prediction: '${e.message}'.");
      return {};
    }
  }

  // --- Android Logic ---
  Future<Map<String, double>> _predictWithTFLite ({required Map<String, dynamic> inputs}) async{
    if ( !_isInitialized) throw StateError("Android interpreter is not initialized.");

    try
    {
      // 3. Invoke the 'predict' method on the native side and await the results // The native side will return a list of probabilities.
      final Map<dynamic, dynamic>? rawOutput = await _channel.invokeMethod('predict', inputs);

      if(rawOutput==null){
        if(kDebugMode){
          print("❌ Native prediction returned null.");
        }
        return {};
      }
      final Map<String, List<double>>? typedOutputMap = rawOutput
          .map((key, value) => MapEntry(key.toString(), (value as List<dynamic>).cast<double>()));

      if (typedOutputMap == null) {
        if (kDebugMode) {
          print("❌ Failed to cast native output map.");
        }
        return {};
      }
      final List<double>? successProbabilities = typedOutputMap['success_probabilities'];
      final List<double>? dayTypeProbabilities = typedOutputMap['day_type_probabilities'];
      if (successProbabilities == null || dayTypeProbabilities == null) {
        if (kDebugMode) {
          print("❌ Missing 'success_probabilities' or 'day_type_probabilities' in native output.");
        }
        return {};
      }
      if (dayTypeProbabilities.length != _dayTypeLabels.length) {
        if (kDebugMode) {
          print("❌ Mismatch between day_type_probabilities length (${dayTypeProbabilities.length}) and _dayTypeLabels length (${_dayTypeLabels.length}).");
        }
        // Handle this error: maybe return empty, or throw, or try to take min length
        return {};
      }
      final Map<String, double> dayTypePredictions = {};
      for (int i = 0; i < _dayTypeLabels.length; i++) {
        dayTypePredictions[_dayTypeLabels[i]] = dayTypeProbabilities[i];
      }

      if (kDebugMode) {
        final Map<String, double> successPredictionsForDebug = {};
        if (successProbabilities.length == _successLabels.length) {
          for (int i = 0; i < _successLabels.length; i++) {
            successPredictionsForDebug[_successLabels[i]] = successProbabilities[i];
          }
          print("✅ Android Success Probabilities (labeled): $successPredictionsForDebug");
        } else {
          print("⚠️ Android Success Probabilities (raw): $successProbabilities (Label count mismatch)");
        }
        print("✅ Android Day Type Probabilities (labeled): $dayTypePredictions");
      }
      return dayTypePredictions;
    } catch (e, s) {
      if(kDebugMode) {
        print("❌ NATIVE INFERENCE FAILED: $e");
        print("   StackTrace: $s");
      }
      return {};
    }




  }


// Reduce unused variables in this method to make it more readable
  Future<Map<String, double>> predict(  Records record ,{
    required List<int> keywords, required List<int> content, required List<double> rating, required List<double> sleep, required List<int> medication }) async
  {
    if (!_isInitialized) {
      print("⚠️ Prediction called before service was initialized.");
      return {};
    }

else {
      // 1. Prepare all inputs in Dart (this part is the same)
      final String keywordString =          "${record.symptoms ?? ''} ${record.emotions ?? ''}";
      final String contentString =          "${record.title ?? ''} ${record.content ?? ''}";

      if(Platform.isIOS){
        final Map<String, dynamic> inputs = {
          'keywords': Int32List.fromList(keywords),
          'content': Int32List.fromList(content),
          'rating': Float32List.fromList(rating),
          'sleep': Float32List.fromList(sleep),
          'medication': Int32List.fromList(medication),
        };
        return await _predictWithCoreML(inputs:inputs);
      }
      else if(Platform.isAndroid){
        final Map<String, dynamic> inputs = {
          'keywords': Int32List.fromList(keywords),
          'content': Int32List.fromList(content),
          'rating': Float32List.fromList(rating),
          'sleep': Float32List.fromList(sleep),
          'medication': Int32List.fromList(medication),
        };
        return await _predictWithTFLite(
          inputs:inputs);//keywords:  Int32List.fromList(keywords), content: Int32List.fromList(content), medication: Int32List.fromList(medication), rating: Float32List.fromList(rating), sleep:Float32List.fromList(sleep) );
      }
      else{
        return {};
      }
//Address this 8/27

    }
}


  void dispose() {
    _interpreter.close();
  }


}

