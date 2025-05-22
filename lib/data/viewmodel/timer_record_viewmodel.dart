import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/timer_record.dart';
import '../repository/timer_record_repository.dart';
import '../dao/timer_record_dao.dart';

// Repository Provider
final timerRecordRepositoryProvider = Provider<TimerRecordRepository>((ref) {
  return TimerRecordRepository(TimerRecordDao());
});

// AsyncNotifier for TimerRecord List (전체)
class TimerRecordListNotifier extends AsyncNotifier<List<TimerRecord>> {
  late final TimerRecordRepository _repo;

  @override
  Future<List<TimerRecord>> build() async {
    _repo = ref.read(timerRecordRepositoryProvider);
    return await _repo.fetchAll();
  }

  Future<void> addRecord(TimerRecord record) async {
    await _repo.add(record);
    state = AsyncData(await _repo.fetchAll());
  }

  Future<void> updateRecord(TimerRecord record) async {
    await _repo.update(record);
    state = AsyncData(await _repo.fetchAll());
  }

  Future<void> deleteRecord(int id) async {
    await _repo.delete(id);
    state = AsyncData(await _repo.fetchAll());
  }
}

// Provider 등록
final timerRecordListViewModelProvider =
    AsyncNotifierProvider<TimerRecordListNotifier, List<TimerRecord>>(TimerRecordListNotifier.new);

// 특정 타이머의 기록 리스트 Provider
final timerRecordByTimerIdProvider = FutureProvider.family<List<TimerRecord>, int>((ref, timerId) async {
  final repo = ref.watch(timerRecordRepositoryProvider);
  return await repo.fetchByTimerId(timerId);
});

// 단일 기록 상세 Provider
final timerRecordDetailProvider = FutureProvider.family<TimerRecord?, int>((ref, id) async {
  final repo = ref.watch(timerRecordRepositoryProvider);
  return await repo.fetchById(id);
});
