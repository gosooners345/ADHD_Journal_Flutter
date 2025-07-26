
import 'package:adhd_journal_flutter/record_data_package/records_data_class_db.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'records_repository.dart';
import '../project_resources/global_vars_andpaths.dart';
import 'dart:async';

class RecordsBloc {
  final _recordsRepo = RecordsRepository();
  int maxID = 0;





  final _recordsController = StreamController<List<Records>>.broadcast(sync: false);
  List<Records> _recordHolder = [];
  get recordStuffs => _recordsController.stream;


  Stream<List<Records>> get recordsStream =>_recordsController.stream;
  List<Records> get currentRecordHolder => List.unmodifiable(_recordHolder);



  RecordsBloc(bool googleDrive) {
    getRecords(googleDrive);
  }
  RecordsBloc.changePasswords(String newPassword) {
    getRecords(false);
    changeDBPasswords(newPassword);
    getRecords(false);
  }

  RecordsBloc.searchedList(String query) {
    getSearchedRecords(query);
  }

  getSearchedRecords(String query) async {
    _recordsController.sink.add(await _recordsRepo.getSearchedRecords(query));
  }

  getSortedRecords(String type) async {
    _recordsController.sink
        .add(await _recordsRepo.getRecordsSortedByType(type));
  }


  Future<void> getRecords(bool googleDrive) async {
    try{
      var records = await _recordsRepo.getRecords();
      _recordHolder=records;
      if(!_recordsController.isClosed){

       _recordsController.sink.add(List.unmodifiable(records));

      if(kDebugMode){
        print("Records added to the stream sink (${records.length})");
        print('RecordsBloc getRecords: this instance hash: ${this.hashCode}');

      }
       if (kDebugMode) {
         print("RecordsBloc: Data added to sink. Controller closed? ${_recordsController.isClosed}. Has listener? ${_recordsController.hasListener}");
       }

      } else{
        if (kDebugMode) {
          print("RecordsBloc: _recordsController is closed, cannot add records.");
        }
        return;
      }
      if(_recordHolder.isNotEmpty){
        maxID = getMaxID();
      } else{
        maxID = 0;
      }
      await _updateDerivedDataStream();
      if (kDebugMode) {
        print(maxID);
      }
    } catch (e,s){
      if(kDebugMode){
        print("Error in getRecords: $e");
      }
      if(!_recordsController.isClosed){
        _recordsController.sink.addError(e);
      }
    }
   // final records = await _recordsRepo.getRecords();
    //_recordHolder=records;
    //_recordsController.sink.add(List.unmodifiable(records));
    //recordHolder = await _recordsRepo.getRecords();
   // if (_recordHolder.isNotEmpty) {
    //  maxID = getMaxID();
    //} else {
      //maxID = 0;
    //}
//await _updateDerivedDataStream();
  //  if (kDebugMode) {
    //  print(maxID);
    //}
  }


  // Testing close and reopen Methods here:
   handleDBSwapRefresh() async{
    if(kDebugMode){
      print("RecordsBloc: Attempting db swap and refresh process");
    }
    try{
      await _recordsRepo.prepareForDBSwap().whenComplete(() async{
       if(kDebugMode){
         print("RecordsBloc: Finalizing DB Swap");
       }

        await _recordsRepo.finalizeDBSwap().whenComplete((){
          if(kDebugMode){
            print("RecordsBloc: DB swap and refresh complete");
          }
          getRecords(false);
        });
      });

    }    on Exception catch(e,s){
print(e);
print(s);
    }

  }




 Future<void> addRecord(Records record) async {
    await _recordsRepo.insertRecord(record);
    getRecords(false);
  }

  Future<void> updateRecord(Records record) async {
    await _recordsRepo.updateRecord(record);
    getRecords(false);
  }

  Future<void> deleteRecordByID(int ID) async {
    await _recordsRepo.deleteRecord(ID);
    getRecords(false);
  }

  changeDBPasswords(String newPassword) {
    _recordsRepo.changePassword(newPassword);
    getRecords(false);
  }

  void writeCheckpoint() {
    _recordsRepo.writeCheckpoint();
  }

  dispose() {
    _recordsController.close();
    _recordsRepo.writeCheckpoint();
    _recordsRepo.close();
    _ratingsController.close();
    _successController.close();
    _symptomController.close();
    _emotionController.close();
  }

  int getMaxID() {
    var id = 0;
    _recordHolder.sort((a, b) => a.comparableIDs(a.id, b.id));
    id = _recordHolder.last.id + 1;
    _recordHolder.sort((a, b) => a.compareTimesCreated(b.timeCreated));
    return id;
  }


// Section testing the record List management:
  static const platform =   MethodChannel('com.activitylogger.release1/ADHDJournal');

   StreamController<List<RecordRatingStats>> _ratingsController = StreamController<List<RecordRatingStats>>.broadcast(sync: false);
   Stream<List<RecordRatingStats>> get ratingsStuffs => _ratingsController.stream;

   StreamController<List<RecordDataStats>> _successController = StreamController<List<RecordDataStats>>.broadcast(sync: false);
   Stream<List<RecordDataStats>> get successStuffs => _successController.stream;

   StreamController<List<RecordDataStats>> _symptomController = StreamController<List<RecordDataStats>>.broadcast(sync: false);
   Stream<List<RecordDataStats>> get symptomStuffs => _symptomController.stream;

   StreamController<List<RecordDataStats>> _emotionController = StreamController<List<RecordDataStats>>.broadcast(sync: false);
   Stream<List<RecordDataStats>> get emotionStuffs => _emotionController.stream;





   List<RecordDataStats> _emotionsList = [];
   List<RecordDataStats> _successList = [];
   List<RecordRatingStats> _ratingsList = [];
   List<RecordDataStats> _symptomList = [];

   List<RecordDataStats> get emotionsList => List.unmodifiable(_emotionsList);
   List<RecordDataStats> get successList => List.unmodifiable(_successList);
   List<RecordRatingStats> get ratingsList => List.unmodifiable(_ratingsList);
   List<RecordDataStats> get symptomList => List.unmodifiable(_symptomList);




   ///Manages the RecordList Streams
  Future<void>  _updateDerivedDataStream() async {
    _emotionsList = await _getEmotionCounts(_recordHolder);
    _symptomList = await _getSymptomCounts(_recordHolder);
    _ratingsList = await _getRatingsListFromData(_recordHolder);
    _successList = getSuccessList(_recordHolder);

    _emotionController.sink.add(List.unmodifiable(_emotionsList));
    _successController.sink.add(List.unmodifiable(_successList));
    _symptomController.sink.add(List.unmodifiable(_symptomList));
    _ratingsController.sink.add(List.unmodifiable(_ratingsList));

  }







// List Methods for the lists above
   List<RecordDataStats> getSuccessList(List<Records> currentRecords) {
    List<RecordDataStats> successData = [];
    successData.add(RecordDataStats('Success', 0.0));
    successData.add(RecordDataStats('Fail', 0.0));
    for (Records record in currentRecords) {
      if (record.success) {
        successData[0].value++;
      } else if (!record.success) {
        successData[1].value++;
      }
    }
    return successData;
  }

// Futures are for those that will potentially take a long time or will have a huge data set.
   Future<List<RecordDataStats>> _getEmotionCounts(List<Records> currentRecords) async {
    List<String> emotionCounts = List.empty(growable: true);
    List<RecordDataStats> emotionList = List.empty(growable: true);

    var countMap = Map();
    for (Records record in _recordHolder) {
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

      if (Global.anger_emotion_cluster.contains(sanitizedElement)) {
        countMap['Anger']++;
      } else if (Global.fear_emotion_cluster.contains(sanitizedElement)) {
        countMap['Anxiety']++;
      } else if (Global.joy_emotion_cluster.contains(sanitizedElement)) {
        countMap['Joy']++;
      } else if (Global.apathetic_emotion_cluster.contains(sanitizedElement)) {
        countMap['Apathetic']++;
      } else if (Global.peaceful_emotion_cluster.contains(sanitizedElement)) {
        countMap['Peace']++;
      } else if (Global.confidence_emotion_cluster.contains(sanitizedElement)) {
        countMap['Confident']++;
      } else if (Global.sorrow_emotion_cluster.contains(sanitizedElement)) {
        countMap['Sad']++;
      } else if (Global.body_pain_emotion_cluster.contains(sanitizedElement)) {
        countMap['Physical pain']++;
      } else if (Global.conviction_based_emotion_cluster.contains(sanitizedElement)) {
        countMap['Convicted']++;
      } else if (Global.stress_based_emotion_cluster.contains(sanitizedElement)) {
        countMap['Stressed']++;
      } else if (Global.mindful_state_emotion_cluster.contains(sanitizedElement)) {
        countMap['Mindful']++;
      } else if (Global.hurt_emotion_cluster.contains(sanitizedElement)) {
        countMap['Hurt']++;
      } else if (Global.wanting_emotion_cluster.contains(sanitizedElement)) {
        countMap['Wanting']++;
      } else if (Global.shame_emotion_cluster.contains(sanitizedElement)) {
        countMap['Shame']++;
      } else if (Global.love_emotion_cluster.contains(sanitizedElement)) {
        countMap['Love']++;
      } else if (Global.surprised_emotion_cluster.contains(sanitizedElement)) {
        countMap['Surprised']++;
      } else if (Global.body_exhaustion_cluster.contains(sanitizedElement)) {
        countMap['Physically tired']++;
      } else if (Global.weak_emotional_cluster.contains(sanitizedElement)) {
        countMap['Weak']++;
      } else if (Global.confused_emotion_cluster.contains(sanitizedElement)) {
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
   Future<List<RecordDataStats>> _getSymptomCounts(List<Records> currentRecords) async {
    List<String> symptomCounts = List.empty(growable: true);
    List<RecordDataStats> symptomList = List.empty(growable: true);
    var countMap = Map();
    _recordHolder.forEach((element) {
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

// Ratings List Stream
   Future<List<RecordRatingStats>> _getRatingsListFromData(List<Records> currentRecords) async {
 //rewriting code
    List<RecordRatingStats> ratingsData = List.empty(growable: true);
   var sortedRecords = List<Records>.from(currentRecords);
   sortedRecords.sort((a, b) => a.timeCreated.compareTo(b.timeCreated));
   for(Records record in sortedRecords){
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
