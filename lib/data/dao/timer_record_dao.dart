import 'package:fast_timer/data/model/timer_record.dart';
import 'package:fast_timer/data/repository/sql_database.dart';

class TimerRecordDao {
  final String tableName = 'timer_records';

  Future<int> insert(TimerRecord record) async {
    try {
      final db = await SqlDatabase.instance.database;
      return await db.insert(tableName, record.toMap());
    } catch (e) {
      print('TimerRecord insert error: $e');
      rethrow;
    }
  }

  Future<List<TimerRecord>> getAll() async {
    try {
      final db = await SqlDatabase.instance.database;
      final maps = await db.query(tableName);
      return maps.map((e) => TimerRecord.fromMap(e)).toList();
    } catch (e) {
      print('TimerRecord getAll error: $e');
      rethrow;
    }
  }

  Future<List<TimerRecord>> getByTimerId(int timerId) async {
    try {
      final db = await SqlDatabase.instance.database;
      final maps = await db.query(
        tableName,
        where: 'timerId = ?',
        whereArgs: [timerId],
      );
      return maps.map((e) => TimerRecord.fromMap(e)).toList();
    } catch (e) {
      print('TimerRecord getByTimerId error: $e');
      rethrow;
    }
  }

  Future<TimerRecord?> getById(int id) async {
    try {
      final db = await SqlDatabase.instance.database;
      final maps = await db.query(tableName, where: 'id = ?', whereArgs: [id]);
      if (maps.isNotEmpty) {
        return TimerRecord.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('TimerRecord getById error: $e');
      rethrow;
    }
  }

  Future<int> update(TimerRecord record) async {
    try {
      final db = await SqlDatabase.instance.database;
      return await db.update(
        tableName,
        record.toMap(),
        where: 'id = ?',
        whereArgs: [record.id],
      );
    } catch (e) {
      print('TimerRecord update error: $e');
      rethrow;
    }
  }

  Future<int> delete(int id) async {
    try {
      final db = await SqlDatabase.instance.database;
      return await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('TimerRecord delete error: $e');
      rethrow;
    }
  }
}