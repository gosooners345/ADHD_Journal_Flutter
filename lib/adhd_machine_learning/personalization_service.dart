import 'package:adhd_journal_flutter/record_data_package/records_data_class_db.dart';
import 'package:adhd_journal_flutter/adhd_machine_learning/personalization_data.dart';
import 'package:flutter/foundation.dart';

/// PersonalizationService is responsible for the "learning" part of the on-device AI.
///
/// Its primary role is to compare the model's prediction with the user's actual
/// outcome. If the model was incorrect, this service calculates an adjustment
/// and updates the personalization database, making future predictions for similar
/// inputs more accurate.
class PersonalizationService {
  /// A reference to the database that stores ML adjustments.
  final dbHelper = PersonalizationDbHelper.instance;

  /// LEARNING_RATE determines how much the model adjusts its weights on each
  /// correction. A smaller value leads to slower, more stable learning.
  /// A larger value leads to faster, but potentially more volatile, learning.
  static const double LEARNING_RATE = 0.05;

  /// This is the core learning function of the personalization system.
  /// Call this method after a user saves a record.
  ///
  /// It requires:
  /// - [modelPrediction]: The raw output from the TFLite model.
  /// - [userProvidedSuccess]: The actual outcome chosen by the user (true for success, false for failure).
  /// - [record]: The journal record containing the text features (symptoms, emotions).
  Future<void> learnFromCorrection({
    required Map<String, double> modelPrediction,
    required bool userProvidedSuccess,
    required Records record,
  }) async {
    // 1. Determine what the model predicted based on the highest score.
    final double successScore = modelPrediction['true'] ?? 0.0;
    final double failureScore = modelPrediction['false'] ?? 0.0;
    final String predictedLabel = (successScore > failureScore) ? '1' : '0';

    // 2. Convert the user's boolean choice into the same label format.
    final String userLabel = userProvidedSuccess ? '1' : '0';

    // 3. If the model's prediction matches the user's choice, no learning is needed.
    if (predictedLabel == userLabel) {
      if (kDebugMode) {
        print("✅ Model was correct. No correction needed.");
      }
      return;
    }

    // 4. If the model was wrong, we initiate the learning process.
    print("🧠 Model was wrong. Learning from correction...");
    print("   - Model Predicted: $predictedLabel, User Chose: $userLabel");

    // 5. Determine the direction of the adjustment.
    // If user said SUCCESS ('1') but model predicted FAILURE, we need to INCREASE the score.
    // If user said FAILURE ('0') but model predicted SUCCESS, we need to DECREASE the score.
    final double adjustmentDirection = (userLabel == '1') ? 1.0 : -1.0;
    final double adjustmentValue = LEARNING_RATE * adjustmentDirection;

    // 6. Extract the key text features (words) from the record.
    final Set<String> features = _extractFeatures(record);
    if (features.isEmpty) {
      print("   - No features found in record to learn from. Aborting.");
      return;
    }
    print("   - Learning from features: $features");

    // 7. For each feature, apply the adjustment to the personalization database.
    for (String feature in features) {
      await dbHelper.updateAdjustment(
        feature: feature,
        adjustment: adjustmentValue,
      );
    }

    print("   - Personalization database updated.");
  }

  /// A helper method to extract and clean unique words from a record's
  /// text fields to be used as features for the ML model.
  Set<String> _extractFeatures(Records record) {
    // Combine all relevant text fields into a single string.
    final String combinedText = "${record.symptoms ?? ''} ${record.emotions ?? ''}";

    if (combinedText.trim().isEmpty) {
      return {};
    }

    // Convert to lowercase, split by spaces or commas, and return a set of unique words.
    return combinedText
        .toLowerCase()
        .trim()
        .split(RegExp(r'[\s,]+')) // Splits by one or more spaces or commas
        .where((word) => word.isNotEmpty) // Remove any empty strings from the split
        .toSet();
  }
}