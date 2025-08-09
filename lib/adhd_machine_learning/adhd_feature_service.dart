// lib/adhd_machine_learning/adhd_feature_service.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:adhd_journal_flutter/record_data_package/records_data_class_db.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class AdhdMlService {
  late Interpreter _interpreter;
  late Map<String, int> _keywordVocab;
  late Map<String, int> _contentVocab;
  late List<String> _outputLabels;
  late int _keywordSequenceLength;
  late int _contentSequenceLength;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      print("--- Initializing AdhdMlService (v4) ---");

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
      print("✅ Definitions loaded.");

      // Load TFLite model
      _interpreter = await Interpreter.fromAsset('assets/adhd_predictor_v2.tflite');
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
  }) {
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

  Map<String, double> predict(Records record) {
    if (!_isInitialized) return {};

    final String keywordString = "${record.symptoms ?? ''} ${record.emotions ?? ''}";
    final String contentString = "${record.title ?? ''} ${record.content ?? ''}";

    final keywordVector = _vectorizeText(
        text: keywordString,
        vocab: _keywordVocab,
        sequenceLength: _keywordSequenceLength);

    final contentVector = _vectorizeText(
        text: contentString,
        vocab: _contentVocab,
        sequenceLength: _contentSequenceLength);

    // The model expects two inputs, both are integer vectors.
    // The shape is [1, sequence_length], so we wrap them in a list.
    final inputs = [
      [keywordVector],
      [contentVector],
    ];

    // The output is a list of probabilities, shape [1, num_labels]
    final output = {0: [List.filled(_outputLabels.length, 0.0)]};

    try {
      _interpreter.runForMultipleInputs(inputs, output);
    } catch (e, s) {
      print("❌ TFLITE INFERENCE FAILED: $e");
      print("   StackTrace: $s");
      return {};
    }

    final Map<String, double> predictions = {};
    final probabilities = output[0]![0] as List<double>;
    for (int i = 0; i < _outputLabels.length; i++) {
      predictions[_outputLabels[i]] = probabilities[i];
    }
    print("✅ Prediction results: $predictions");
    return predictions;
  }

  void dispose() {
    _interpreter.close();
  }
}
