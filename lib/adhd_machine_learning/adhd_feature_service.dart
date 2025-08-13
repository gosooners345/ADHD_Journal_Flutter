// lib/adhd_machine_learning/adhd_feature_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle, MethodChannel;
import 'package:adhd_journal_flutter/record_data_package/records_data_class_db.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../project_resources/global_vars_andpaths.dart';
import 'package:flutter/foundation.dart';

class AdhdMlService {
  late Interpreter _interpreter;
  late Map<String, int> _keywordVocab;
  late Map<String, int> _contentVocab;
  late Map<String, int> _medicationVocab;
  late List<String> _outputLabels;
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
  List<String> get outputLabels => _isInitialized ? _outputLabels : []; // Public getter
  int get keywordSequenceLength => _isInitialized ? _keywordSequenceLength : 0; // Public getter
  int get contentSequenceLength => _isInitialized ? _contentSequenceLength : 0;
  int get medicationSequenceLength => _isInitialized ? _medicationSequenceLength : 0;
  double get ratingScaleMin => _isInitialized ? _ratingScaleMin : 0.0; // Public getter
  double get ratingScaleMax => _isInitialized ? _ratingScaleMax : 100.0;



  bool get isInitialized => _isInitialized;
  static const MethodChannel _channel =
      MethodChannel(Global.PLATFORMCHANNEL_PATH);

  // This is the correct initialization flow for a model requiring FlexDelegate
  Future<void> initialize() async {
    if (_isInitialized) return;
    const int maxRetries = 5;
    const Duration retryDelay = Duration(seconds: 2);
    int attempt = 0;
    bool isNativeInterpreterReady = false;
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
      } catch (e) {
        if (kDebugMode) {
          print("Error initializing native interpreter: $e");
        }
        // On a hard error (like an exception from native code), we stop trying.
        break;
      }
    }
    if (isNativeInterpreterReady) {
      try {
        _keywordVocab = await _loadVocab('assets/vocab_keywords.txt');
        _contentVocab = await _loadVocab('assets/vocab_content.txt');
        _medicationVocab = await _loadVocab('assets/vocab_medication.txt');
        if (kDebugMode) {
          print("✅ Vocabularies loaded.");
        }

        final definitionsString =
            await rootBundle.loadString('assets/ml_definitions.json');
        final definitions = json.decode(definitionsString);
        _outputLabels = List<String>.from(definitions['output_label_vocab']);
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

        _isInitialized = true;

        if (kDebugMode) {
          print("✅ AdhdMlService initialized successfully.");
        }
      } catch (e, s) {
        if(kDebugMode){
        print("Failed loading Dart-side assets $e");
        print("StackTrace: $s");
        }
        rethrow;
      }
    } else {
      if(kDebugMode) {
        print("Failed to initialize native interpreter after $maxRetries attempts.");
      }
      throw Exception(
          'Failed to initialize ML Service after $maxRetries attempts.');
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
  }) {
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

  // FIX: This should return a List<double> for easier use with Float32List
  List<double> _vectorizeText({
    required String text,
    required Map<String, int> vocab,
    required int sequenceLength,
  }) {
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

  List<double> publicNormalizeRating({required double userRating}) {
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
// Reduce unused variables in this method to make it more readable
  Future<Map<String, double>> predict(  Records record ,{
    required List<int> keywords, required List<int> content, required List<double> rating, required List<double> sleep, required List<int> medication }) async {
    if (!_isInitialized) {
      print("⚠️ Prediction called before service was initialized.");
      return {};
    } // 1. Prepare all inputs in Dart (this part is the same)
    final String keywordString =
        "${record.symptoms ?? ''} ${record.emotions ?? ''}";
    final String contentString =
        "${record.title ?? ''} ${record.content ?? ''}";
    final keywordVector = _vectorizeText(
        text: keywordString,
        vocab: _keywordVocab,
        sequenceLength: _keywordSequenceLength);
    final contentVector = _vectorizeText(
        text: contentString,
        vocab: _contentVocab,
        sequenceLength: _contentSequenceLength);
    double currentRating =
        record.rating ?? ((_ratingScaleMin + _ratingScaleMax) / 2.0);
    double normalizedRating = _normalizeRating(currentRating);
    // 2. Package the inputs into a map to send over the method channel
    final Map<String, dynamic> inputs = {
      'keywords': Int32List.fromList(keywords),
      'content': Int32List.fromList(content),
      'rating': Float32List.fromList(rating),
      'sleep': Float32List.fromList(sleep),
      'medication': Int32List.fromList(medication),
    };
    try {
      // 3. Invoke the 'predict' method on the native side and await the results // The native side will return a list of probabilities.
      final List<dynamic>? predictionsList =
          await _channel.invokeMethod('predict', inputs);
      if (predictionsList == null) {
        if (kDebugMode) {
          print("❌ Native prediction returned null.");
        }
        return {};
      }

// 4. Process the results received from the native side
      final Map<String, double> predictions = {};
      final List<double> probabilities = predictionsList.cast<double>();

      for (int i = 0; i < _outputLabels.length; i++) {
        predictions[_outputLabels[i]] = probabilities[i];
      }
      if (kDebugMode) {
        print("✅ Prediction results from native: $predictions");
      }
      return predictions;
    } catch (e, s) {
      if(kDebugMode) {
        print("❌ NATIVE INFERENCE FAILED: $e");
        print("   StackTrace: $s");
      }
      return {};
    }
  }

/*  Map<String, double> predict(Records record) {
    if (!_isInitialized) return {};

    // 1. Prepare all inputs
    final String keywordString = "${record.symptoms ?? ''} ${record.emotions ?? ''}";
    final String contentString = "${record.title ?? ''} ${record.content ?? ''}";

    // These are now List<double>
    final keywordVector = _vectorizeText(
        text: keywordString, vocab: _keywordVocab, sequenceLength: _keywordSequenceLength);
    final contentVector = _vectorizeText(
        text: contentString, vocab: _contentVocab, sequenceLength: _contentSequenceLength);

    double currentRating = record.rating ?? ((_ratingScaleMin + _ratingScaleMax) / 2.0);
    double normalizedRating = _normalizeRating(currentRating);

    // 2. Create buffers with the correct shape and type
    final keywordInput = Float32List.fromList(keywordVector).reshape([1, _keywordSequenceLength]);
    final contentInput = Float32List.fromList(contentVector).reshape([1, _contentSequenceLength]);
    // FIX: Correct shape for the rating input
    final ratingInput = Float32List.fromList([normalizedRating]).reshape([1, 1]);

    final inputs = [keywordInput, contentInput, ratingInput];

    // 3. Prepare output buffer
    final outputShape = _interpreter.getOutputTensor(0).shape;
    final outputBuffer = Float32List(outputShape.reduce((a, b) => a * b)).reshape(outputShape);
    final output = {0: outputBuffer};

    // 4. Run inference
    try {
      _interpreter.runForMultipleInputs(inputs, output);
    } catch (e, s) {
      print("❌ TFLITE INFERENCE FAILED: $e");
      print("   StackTrace: $s");
      return {};
    }

    // 5. Process results
    final Map<String, double> predictions = {};
    // FIX: Correct way to access the output. It's already a List<double> or similar.
    final List<double> probabilities = outputBuffer[0];
    for (int i = 0; i < _outputLabels.length; i++) {
      predictions[_outputLabels[i]] = probabilities[i];
    }
    print("✅ Prediction results: $predictions");
    return predictions;
  }*/

  void dispose() {
    _interpreter.close();
  }


}

/*class AdhdMlService {
  late Interpreter _interpreter;
  late Map<String, int> _keywordVocab;
  late Map<String, int> _contentVocab;
  late List<String> _outputLabels;
  late int _keywordSequenceLength;
  late int _contentSequenceLength;
  late double _ratingScaleMin;
  late double _ratingScaleMax;
  List<String>? _inputTensorNames;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
static const MethodChannel _channel = MethodChannel(Global.PLATFORMCHANNEL_PATH);

  Future<void> _ensureFlexReady() async {
    try {
      final ok = await _channel.invokeMethod("warmUpFlex");
      if (ok == true) {
        print("✅ Flex warm-up succeeded.");
      } else {
        print("⚠️ Flex warm-up returned non-true; proceeding anyway.");
      }
    } catch (e) {
      // Not fatal if Android deps are correct, but this helps detect integration gaps early.
      print("⚠️ Flex warm-up channel call failed: $e");
    }
  }

Future<void> initialize() async {
    if (_isInitialized) return;
    try {
            print("--- Initializing AdhdMlService (v4) with Native FlexDelegate---");

await _ensureFlexReady();
      // Load vocabularies
      _keywordVocab = await _loadVocab('assets/vocab_keywords.txt');
      _contentVocab = await _loadVocab('assets/vocab_content.txt');
      print("✅ Vocabularies loaded.");

      // Load definitions
      final definitionsString = await rootBundle.loadString('assets/ml_definitions.json');
      final definitions = json.decode(definitionsString);
      _outputLabels = List<String>.from(definitions['output_label_vocab']);
      _keywordSequenceLength = definitions['keyword_sequence_length'];
      _contentSequenceLength = definitions['content_sequence_length'];
      _ratingScaleMin = (definitions['RATING_MIN'] as num).toDouble();
      _ratingScaleMax = (definitions['RATING_MAX'] as num).toDouble();
      if (definitions.containsKey('input_names')) {
        _inputTensorNames = List<String>.from(definitions['input_names']);
      }
  _interpreter = await Interpreter.fromAsset('assets/adhd_predictor_v2.tflite'
  , options: InterpreterOptions()
  ..threads = 4
  ..useNnApiForAndroid = false
  );

      print("✅ Definitions loaded.");

      // Load TFLite model
  //    _interpreter = await Interpreter.fromAsset('assets/adhd_predictor_v2.tflite');
      print("✅ TFLite model loaded.");

      _isInitialized = true;
      print("✅ AdhdMlService initialized successfully.");
    } catch (e, s) {
      print("❌ Failed to initialize AdhdMlService: $e");
      print("   StackTrace: $s");
    }
  }

  Future<Map<String, int>> _loadVocab(String path) async {
    final vocabString = await rootBundle.loadString(path);
    final vocabList = vocabString.split('\n');
    final Map<String, int> vocabMap = {};
    for (int i = 0; i < vocabList.length; i++) {
      vocabMap[vocabList[i]] = i;
    }
    return vocabMap;
  }

  List<int> _vectorizeText({
    required String text,
    required Map<String, int> vocab,
    required int sequenceLength,
  })
  {
    final vector = List<int>.filled(sequenceLength, 0); // 0 is padding
    final punctuationRegex = RegExp(r'[!"#$%&()*+,-./:;<=>?@\[\\\]^_`{|}~]');
    final textWithSpaces = text.toLowerCase().replaceAll(punctuationRegex, ' ');

    final words = textWithSpaces.toLowerCase().trim().split(RegExp(r'\s+'));
    int index = 0;
    for (final word in words) {
      if (index >= sequenceLength) break;
      if (word.isEmpty) continue;
      final sanitizedWord = word.replaceAll(punctuationRegex, '');
      if (sanitizedWord.isEmpty) continue;
      vector[index++] = vocab[sanitizedWord] ?? 1; // 1 is OOV/Unknown
    }
    return vector;
  }

/// New Rating method to help with newer training.
  double _normalizeRating(double userRating) {
    var clampedRating = userRating.clamp(_ratingScaleMin, _ratingScaleMax);
    if ((_ratingScaleMax - _ratingScaleMin).abs() < 1e-6) return 0.0; // Avoid division by zero for identical min/max
    return (clampedRating - _ratingScaleMin) / (_ratingScaleMax - _ratingScaleMin);
  }

  Map<String, double> predict(Records record) {
    if (!_isInitialized) return {};

    final String keywordString = "${record.symptoms ?? ''} ${record.emotions ?? ''}";
    final String contentString = "${record.title ?? ''} ${record.content ?? ''}";

    final keywordVector = _vectorizeText(
        text: keywordString,
        vocab: _keywordVocab,
        sequenceLength: _keywordSequenceLength);
//final keywordInputForModel = [keywordVector];
    final contentVector = _vectorizeText(
        text: contentString,
        vocab: _contentVocab,
        sequenceLength: _contentSequenceLength);
//final contentInputForModel = [contentVector];
    double currentRating = record.rating ?? ((_ratingScaleMin + _ratingScaleMax) / 2.0); // Default if null
    double normalizedRating = _normalizeRating(currentRating);
    // TFLite expects Float32List for float inputs. Shape [1, 1]
   // final ratingInputForModel = [Float32List.fromList([normalizedRating])];

    // The model now expects three inputs.
    // The order must match the Keras model's input layer definition.
    // Typically: keywords, content, rating.
    final inputs = [
      [keywordVector],
      [contentVector],
      [normalizedRating]
    ];

    final outputShape = _interpreter!.getOutputTensor(0).shape;
    final outputBuffer = List.generate(outputShape[0], (_) =>Float32List(outputShape[1]));


    // The output is a list of probabilities, shape [1, num_labels]
    final output = {0: outputBuffer};

    try {
      _interpreter.runForMultipleInputs(inputs, output);
    } catch (e, s) {
      print("❌ TFLITE INFERENCE FAILED: $e");
      print("   StackTrace: $s");
      return {};
    }

    final Map<String, double> predictions = {};
    final probabilities = output[0]![0] as List<double>;
    //final probabilities = output[0]![0].map((e) => e.toDouble()).toList();
    for (int i = 0; i < _outputLabels.length; i++) {
      predictions[_outputLabels[i]] = probabilities[i];
    }
    print("✅ Prediction results: $predictions");
    return predictions;
  }

  void dispose() {
    _interpreter.close();
  }
}*/
