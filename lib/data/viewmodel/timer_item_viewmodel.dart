import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/timer_item.dart';
import '../repository/timer_item_repository.dart';
import '../dao/timer_item_dao.dart';

// Repository Provider
final timerItemRepositoryProvider = Provider<TimerItemRepository>((ref) {
  return TimerItemRepository(TimerItemDao());
});

// AsyncNotifier for TimerItem List
class TimerItemListNotifier extends AsyncNotifier<List<TimerItem>> {
  late final TimerItemRepository _repo;

  @override
  Future<List<TimerItem>> build() async {
    _repo = ref.read(timerItemRepositoryProvider);
    return await _repo.fetchAll();
  }

  Future<void> addItem(TimerItem item) async {
    await _repo.add(item);
    state = AsyncData(await _repo.fetchAll());
  }

  Future<void> updateItem(TimerItem item) async {
    await _repo.update(item);
    state = AsyncData(await _repo.fetchAll());
  }

  Future<void> deleteItem(int id) async {
    await _repo.delete(id);
    state = AsyncData(await _repo.fetchAll());
  }
}

// Provider 등록
final timerItemListViewModelProvider =
    AsyncNotifierProvider<TimerItemListNotifier, List<TimerItem>>(TimerItemListNotifier.new);

// 단일 타이머 상세 Provider
final timerItemDetailProvider = FutureProvider.family<TimerItem?, int>((ref, id) async {
  final repo = ref.watch(timerItemRepositoryProvider);
  return await repo.fetchById(id);
});
