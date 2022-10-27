import 'package:adhd_journal_flutter/record_data_package/records_data_class_db.dart';
import 'records_dao.dart';

class RecordsRepository {
  final recordsDao = RecordsDao();

  Future<List<Records>> getRecords() => recordsDao.getRecords();
  Future<List<Records>> getRecordsSortedByType(String type) =>
      recordsDao.getRecordsSortedByType(type);
  Future<List<Records>> getSearchedRecords(String query) =>
      recordsDao.getSearchedRecords(query: query);
  Future insertRecord(Records record) => recordsDao.createRecords(record);
  Future updateRecord(Records record) => recordsDao.updateRecords(record);
  Future deleteRecord(int ID) => recordsDao.deleteRecord(ID);

  void changePassword(String newPassword) {
    recordsDao.changePasswords(newPassword);
  }
  void writeCheckpoint(){
    recordsDao.writemoreCheckpoint();
  }
void close(){

}
}
