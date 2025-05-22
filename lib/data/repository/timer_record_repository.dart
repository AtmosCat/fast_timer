import 'package:fast_timer/data/model/dao/timer_record_dao.dart';
import '../model/timer_record.dart';

class TimerRecordRepository {
  final TimerRecordDao _dao;

  TimerRecordRepository(this._dao);

  Future<int> addTimerRecord(TimerRecord record) async {
    try {
      return await _dao.insert(record);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TimerRecord>> fetchAllTimerRecords() async {
    try {
      return await _dao.getAll();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TimerRecord>> fetchRecordsByTimerId(int timerId) async {
    try {
      return await _dao.getByTimerId(timerId);
    } catch (e) {
      rethrow;
    }
  }

  Future<TimerRecord?> fetchTimerRecordById(int id) async {
    try {
      return await _dao.getById(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<int> updateTimerRecord(TimerRecord record) async {
    try {
      return await _dao.update(record);
    } catch (e) {
      rethrow;
    }
  }

  Future<int> deleteTimerRecord(int id) async {
    try {
      return await _dao.delete(id);
    } catch (e) {
      rethrow;
    }
  }
}
