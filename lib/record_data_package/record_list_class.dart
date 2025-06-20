// ignore_for_file: prefer_collection_literals, avoid_function_literals_in_foreach_calls

import 'dart:core';

import 'package:adhd_journal_flutter/project_resources/project_strings_file.dart';
import 'package:adhd_journal_flutter/record_data_package/records_data_class_db.dart';
import 'package:flutter/services.dart';
import '../main.dart';

// Look into combining lists to help reduce memory usage if possible.
// This won't be easy because there are 5 metrics being collected and sorting them isn't easy
/// 1. make 1 or 2 lists from the record block data instead of 5 lists
/// 2. load them in the application.
/// 3.
///
class RecordList {
  static const platform =
      MethodChannel('com.activitylogger.release1/ADHDJournal');
  static List<RecordDataStats> emotionsList = [];
  static List<RecordDataStats> successList = [];
  static List<RecordRatingStats> ratingsList = [];
  static List<RecordDataStats> symptomList = [];

  static void loadLists() async {
    emotionsList = await _getEmotionCounts();
    symptomList = await _getSymptomCounts();
    ratingsList = await _getRatingsList();
    successList = getSuccessList();
  }

  //List of Integers and Dates. - Derived from the list without creating a class.
//What if this was integrated into the master stream class.
  // 1. Rating value, 2. Date value.
/*List<dynamic>  ratingList(){
  var tempratingList = [];
    Map<String,Object> ratingsMap = {};
    for(int i =0; i<recordHolder.length; i++){
      ratingsMap.
  }*/






// List Methods for the lists above
  static List<RecordDataStats> getSuccessList() {
    List<RecordDataStats> successData = [];
    successData.add(RecordDataStats('Success', 0.0));
    successData.add(RecordDataStats('Fail', 0.0));
    for (Records record in recordsBloc.recordHolder) {
      if (record.success) {
        successData[0].value++;
      } else if (!record.success) {
        successData[1].value++;
      }
    }
    return successData;
  }

// Futures are for those that will potentially take a long time or will have a huge data set.
  static Future<List<RecordDataStats>> _getEmotionCounts() async {
    List<String> emotionCounts = List.empty(growable: true);
    List<RecordDataStats> emotionList = List.empty(growable: true);

    var countMap = Map();
    for (Records record in recordsBloc.recordHolder) {
      emotionCounts.addAll(record.emotions.split(','));
    }
    countMap['Anger'] = 0;
    countMap['Anxiety'] = 0;
    countMap['Joy'] = 0;
    countMap['Confident'] = 0;
    countMap['Hurt'] = 0;
    countMap['Sad'] = 0;
    countMap['Peace'] = 0;
    countMap['Wanting'] = 0;
    countMap['Physical pain'] = 0;
    countMap['Mindful'] = 0;
    countMap['Convicted'] = 0;
    countMap['Stressed'] = 0;
    countMap['Confused'] = 0;
    countMap['Love'] = 0;
    countMap['Shame'] = 0;
    countMap['Apathetic'] = 0;
    countMap['Surprised'] = 0;
    countMap['Weak'] = 0;
    countMap['Physically tired'] = 0;

    // This will iterate through the list to get the quantity of each specific element in the emotion list.
    emotionCounts.forEach((element) {
      var sanitizedElement = element.trimLeft().trimRight().toLowerCase();

      if (anger_emotion_cluster.contains(sanitizedElement)) {
        countMap['Anger']++;
      } else if (fear_emotion_cluster.contains(sanitizedElement)) {
        countMap['Anxiety']++;
      } else if (joy_emotion_cluster.contains(sanitizedElement)) {
        countMap['Joy']++;
      } else if (apathetic_emotion_cluster.contains(sanitizedElement)) {
        countMap['Apathetic']++;
      } else if (peaceful_emotion_cluster.contains(sanitizedElement)) {
        countMap['Peace']++;
      } else if (confidence_emotion_cluster.contains(sanitizedElement)) {
        countMap['Confident']++;
      } else if (sorrow_emotion_cluster.contains(sanitizedElement)) {
        countMap['Sad']++;
      } else if (body_pain_emotion_cluster.contains(sanitizedElement)) {
        countMap['Physical pain']++;
      } else if (conviction_based_emotion_cluster.contains(sanitizedElement)) {
        countMap['Convicted']++;
      } else if (stress_based_emotion_cluster.contains(sanitizedElement)) {
        countMap['Stressed']++;
      } else if (mindful_state_emotion_cluster.contains(sanitizedElement)) {
        countMap['Mindful']++;
      } else if (hurt_emotion_cluster.contains(sanitizedElement)) {
        countMap['Hurt']++;
      } else if (wanting_emotion_cluster.contains(sanitizedElement)) {
        countMap['Wanting']++;
      } else if (shame_emotion_cluster.contains(sanitizedElement)) {
        countMap['Shame']++;
      } else if (love_emotion_cluster.contains(sanitizedElement)) {
        countMap['Love']++;
      } else if (surprised_emotion_cluster.contains(sanitizedElement)) {
        countMap['Surprised']++;
      } else if (body_exhaustion_cluster.contains(sanitizedElement)) {
        countMap['Physically tired']++;
      } else if (weak_emotional_cluster.contains(sanitizedElement)) {
        countMap['Weak']++;
      } else if (confused_emotion_cluster.contains(sanitizedElement)) {
        countMap['Confused']++;
      } else if (!countMap.containsKey(sanitizedElement)) {
        countMap[sanitizedElement] = 1;
      } else {
        countMap[sanitizedElement]++;
      }
    });
    // Take the map and convert it into an object that we can use for graphing
    countMap.forEach((key, value) {
      emotionList.add(RecordDataStats(key, double.tryParse(value.toString())!));
    });

    emotionList.sort((a, b) => a.compareTo(b));
    emotionList = emotionList.reversed.toList();
    return emotionList;
  }

//Symptom List Method
  static Future<List<RecordDataStats>> _getSymptomCounts() async {
    List<String> symptomCounts = List.empty(growable: true);
    List<RecordDataStats> symptomList = List.empty(growable: true);
    var countMap = Map();
    recordsBloc.recordHolder.forEach((element) {
      symptomCounts.addAll(element.symptoms.split(','));
    });

    symptomCounts.forEach((element) {
      var sanitizedElement = element.trimLeft().trimRight().toLowerCase();

      if (!countMap.containsKey(sanitizedElement)) {
        countMap[sanitizedElement] = 1;
      } else {
        countMap[sanitizedElement]++;
      }
    });
    countMap.forEach((key, value) {
      symptomList.add(RecordDataStats(key, double.tryParse(value.toString())!));
    });
    symptomList.sort((a, b) => a.compareTo(b));
    symptomList = symptomList.reversed.toList();
    return symptomList;
  }
//old ratings list
//Ratings List Method
  static Future<List<RecordRatingStats>> _getRatingsList() async {
    List<RecordRatingStats> ratingsData = List.empty(growable: true);
    var testList = recordsBloc.recordHolder;
    testList.sort((a, b) => a.timeCreated.compareTo(b.timeCreated));
    for (Records record in testList) {
      ratingsData.add(RecordRatingStats(record.timeCreated, record.rating));
    }
    ratingsData.sort((a, b) => a.compareTo(b));
    return ratingsData;
  }
}

class RecordRatingStats implements Comparable {
  DateTime date = DateTime.now();
  double value = 0.0;

  RecordRatingStats(this.date, this.value);
  Map<String, Object> toMap() {
    return {"date": date, "value": value};
  }

  @override
  int compareTo(other) {
    return date.compareTo(other.date);
  }
}

class RecordDataStats implements Comparable {
  String key = '';
  double value = 0.0;
  int altValue = 0;
  RecordDataStats(this.key, this.value);

  Map<String, Object> toMap() {
    return {"key": key, "value": value};
  }

  @override
  int compareTo(other) {
    final otherRecord = other as RecordDataStats;
    if (value.compareTo(otherRecord.value) == 0) {
      return key.toUpperCase().compareTo(otherRecord.key.toUpperCase());
    } else {
      return value.compareTo(otherRecord.value);
    }
  }
}
