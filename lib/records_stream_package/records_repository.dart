import 'package:adhd_journal_flutter/records_data_class_db.dart';
import 'records_dao.dart';


class RecordsRepository{
  final recordsDao = RecordsDao();

  Future<List<Records>> getRecords() => recordsDao.getRecords();
  Future insertRecord(Records record) => recordsDao.createRecords(record);
  Future updateRecord(Records record) => recordsDao.updateRecords(record);
  Future deleteRecord(int ID) => recordsDao.deleteRecord(ID);

  void changePassword() {recordsDao.changeDBPasswords();}

}