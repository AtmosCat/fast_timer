import 'package:fast_timer/data/model/dao/timer_item_dao.dart';

import '../model/timer_item.dart';

class TimerItemRepository {
  final TimerItemDao _dao;

  TimerItemRepository(this._dao);

  Future<int> addTimerItem(TimerItem item) async {
    try {
      return await _dao.insert(item);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TimerItem>> fetchAllTimerItems() async {
    try {
      return await _dao.getAll();
    } catch (e) {
      rethrow;
    }
  }

  Future<TimerItem?> fetchTimerItemById(int id) async {
    try {
      return await _dao.getById(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<int> updateTimerItem(TimerItem item) async {
    try {
      return await _dao.update(item);
    } catch (e) {
      rethrow;
    }
  }

  Future<int> deleteTimerItem(int id) async {
    try {
      return await _dao.delete(id);
    } catch (e) {
      rethrow;
    }
  }
}
