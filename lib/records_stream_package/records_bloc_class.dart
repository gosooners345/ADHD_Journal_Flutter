import 'dart:math';

import 'package:adhd_journal_flutter/records_data_class_db.dart';
import 'package:flutter/foundation.dart';
import 'records_repository.dart';

import 'dart:async';

class RecordsBloc{
  final _recordsRepo = RecordsRepository();
  int maxID =0;

  //Master stream controller, hopefully performant
  final _recordsController = StreamController<List<Records>>.broadcast(sync: true);
    List<Records> recordHolder=[];
  get  recordStuffs => _recordsController.stream;

  RecordsBloc() {
    getRecords();
  }

  RecordsBloc.searchedList(String query){
    getSearchedRecords(query);
  }

  getSearchedRecords(String query) async{
    _recordsController.sink.add(await _recordsRepo.getSearchedRecords(query));

  }

  getSortedRecords(String type) async{
    _recordsController.sink.add(await _recordsRepo.getRecordsSortedByType(type));
  }

  getRecords() async{
    _recordsController.sink.add(await _recordsRepo.getRecords());
    recordHolder = await _recordsRepo.getRecords();
    if(recordHolder.length>0)
    maxID=getMaxID();
    else
      maxID=0;

    if ( kDebugMode) {
      print(maxID);
    }
  }
  addRecord(Records record) async{
    await _recordsRepo.insertRecord(record);
    getRecords();
  }
  updateRecord(Records record) async{
    await _recordsRepo.updateRecord(record);
    getRecords();
  }
 deleteRecordByID(int ID) async{
    await _recordsRepo.deleteRecord(ID);
    getRecords();
 }
 void changeDBPasswords(){
    _recordsRepo.changePassword();
 }
 dispose(){
   _recordsController.close();
 }

 int getMaxID(){
    var id =0;
    recordHolder.sort((a,b)=>a.comparableIDs(a.id, b.id));
    id =recordHolder.last.id+1;
    recordHolder.sort((a,b) => a.compareTimesCreated(b.timeCreated));
    return id;
 }


}