// ignore_for_file: prefer_collection_literals, avoid_function_literals_in_foreach_calls

import 'dart:core';

import 'package:adhd_journal_flutter/project_strings_file.dart';
import 'package:adhd_journal_flutter/records_data_class_db.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dashboard_stats_display_widget.dart';
import 'main.dart';

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
    countMap['Anger based'] = 0;
    countMap['Fear based'] = 0;
    countMap['Joy based'] = 0;
    countMap['Confidence based'] = 0;
    countMap['Sorrow based'] = 0;
    countMap['Peaceful based'] = 0;
    countMap['Motivation based'] = 0;
    countMap['Physical body based'] = 0;
    countMap['Mindful based'] = 0;
    countMap['Conviction based'] = 0;
    countMap['Stress based'] = 0;

    // This will iterate through the list to get the quantity of each specific element in the emotion list.
    emotionCounts.forEach((element) {

      var sanitizedElement = element.trimLeft().trimRight().toLowerCase();

      if(anger_emotion_cluster.contains(sanitizedElement)){
        countMap['Anger based']++;
      }
      else if(joy_emotion_cluster.contains(sanitizedElement)){
        countMap['Joy based']++;
      }
      else if(fear_emotion_cluster.contains(sanitizedElement)){
        countMap['Fear based']++;
      }
      else if(extreme_emotion_cluster.contains(sanitizedElement)){
        countMap['Motivation based']++;
      }
      else if(peaceful_emotion_cluster.contains(sanitizedElement)){
        countMap['Peaceful based']++;
      }
      else if(confidence_emotion_cluster.contains(sanitizedElement)){
        countMap['Confidence based']++;
      }
      else if(sorrow_emotion_cluster.contains(sanitizedElement)){
        countMap['Sorrow based']++;
      }
      else if(body_pain_emotion_cluster.contains(sanitizedElement)){
        countMap['Physical body based']++;
      }
      else if(conviction_based_emotion_cluster.contains(sanitizedElement)){
        countMap['Conviction based']++;
      }
      else if(stress_based_emotion_cluster.contains(sanitizedElement)){
        countMap['Stress based']++;
      }
      else if(mindful_state_emotion_cluster.contains(sanitizedElement)){
        countMap['Mindful based']++;
      }




     else if (!countMap.containsKey(sanitizedElement)) {
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
      }  else {
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
