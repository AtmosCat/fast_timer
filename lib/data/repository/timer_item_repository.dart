import '../dao/timer_item_dao.dart';
import '../model/timer_item.dart';

class TimerItemRepository {
  final TimerItemDao _dao;

  TimerItemRepository(this._dao);

  Future<List<TimerItem>> fetchAll() => _dao.getAll();
  Future<TimerItem?> fetchById(int id) => _dao.getById(id);
  Future<int> add(TimerItem item) => _dao.insert(item);
  Future<int> update(TimerItem item) => _dao.update(item);
  Future<int> delete(int id) => _dao.delete(id);
}
