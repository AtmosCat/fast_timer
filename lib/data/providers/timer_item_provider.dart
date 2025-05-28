import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dao/timer_item_dao.dart';
import '../repository/timer_item_repository.dart';
import '../model/timer_item.dart';

// Repository Provider (싱글턴)
final timerItemRepositoryProvider = Provider<TimerItemRepository>((ref) {
  return TimerItemRepository(TimerItemDao());
});

// // 타이머 전체 리스트를 비동기로 제공
// final timerItemListProvider = FutureProvider<List<TimerItem>>((ref) async {
//   final repo = ref.watch(timerItemRepositoryProvider);
//   return await repo.fetchAll();
// });

// 타이머 단건 조회 Provider (예시)
final timerItemProvider = FutureProvider.family<TimerItem?, int>((
  ref,
  id,
) async {
  final repo = ref.watch(timerItemRepositoryProvider);
  return await repo.fetchById(id);
});

final timerTickProvider = StreamProvider<int>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (x) => x);
});
