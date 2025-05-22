import '../dao/timer_record_dao.dart';
import '../model/timer_record.dart';

class TimerRecordRepository {
  final TimerRecordDao _dao;

  TimerRecordRepository(this._dao);

  Future<int> add(TimerRecord record) => _dao.insert(record);
  Future<List<TimerRecord>> fetchAll() => _dao.getAll();
  Future<List<TimerRecord>> fetchByTimerId(int timerId) => _dao.getByTimerId(timerId);
  Future<TimerRecord?> fetchById(int id) => _dao.getById(id);
  Future<int> update(TimerRecord record) => _dao.update(record);
  Future<int> delete(int id) => _dao.delete(id);
}
