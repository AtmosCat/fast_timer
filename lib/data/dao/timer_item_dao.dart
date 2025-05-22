import 'package:fast_timer/data/model/timer_item.dart';
import 'package:fast_timer/data/repository/sql_database.dart';

class TimerItemDao {
  final String tableName = 'timer_items';

  Future<int> insert(TimerItem item) async {
    try {
      final db = await SqlDatabase.instance.database;
      return await db.insert(tableName, item.toMap());
    } catch (e) {
      print('TimerItem insert error: $e');
      rethrow;
    }
  }

  Future<List<TimerItem>> getAll() async {
    try {
      final db = await SqlDatabase.instance.database;
      final maps = await db.query(tableName);
      return maps.map((e) => TimerItem.fromMap(e)).toList();
    } catch (e) {
      print('TimerItem getAll error: $e');
      rethrow;
    }
  }

  Future<TimerItem?> getById(int id) async {
    try {
      final db = await SqlDatabase.instance.database;
      final maps = await db.query(tableName, where: 'id = ?', whereArgs: [id]);
      if (maps.isNotEmpty) {
        return TimerItem.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('TimerItem getById error: $e');
      rethrow;
    }
  }

  Future<int> update(TimerItem item) async {
    try {
      final db = await SqlDatabase.instance.database;
      return await db.update(
        tableName,
        item.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
      );
    } catch (e) {
      print('TimerItem update error: $e');
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
      print('TimerItem delete error: $e');
      rethrow;
    }
  }
}
