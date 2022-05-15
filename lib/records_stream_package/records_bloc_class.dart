import 'package:adhd_journal_flutter/records_data_class_db.dart';
import 'records_repository.dart';

import 'dart:async';

class RecordsBloc{
  final _recordsRepo = RecordsRepository();

  //Master stream controller, hopefully performant
  final _recordsController = StreamController<List<Records>>.broadcast();
    List<Records> recordHolder=[];
  get recordStuffs => _recordsController.stream;

  RecordsBloc() {
    getRecords();
  }

  getRecords() async{
    _recordsController.sink.add(await _recordsRepo.getRecords());
    recordHolder = await _recordsRepo.getRecords();
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



}