import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dao/timer_record_dao.dart';
import '../repository/timer_record_repository.dart';
import '../model/timer_record.dart';

// Repository Provider
final timerRecordRepositoryProvider = Provider<TimerRecordRepository>((ref) {
  return TimerRecordRepository(TimerRecordDao());
});

// 전체 기록 리스트
final timerRecordListProvider = FutureProvider<List<TimerRecord>>((ref) async {
  final repo = ref.watch(timerRecordRepositoryProvider);
  return await repo.fetchAll();
});

// 특정 타이머의 기록 리스트
final timerRecordByTimerIdProvider = FutureProvider.family<List<TimerRecord>, int>((ref, timerId) async {
  final repo = ref.watch(timerRecordRepositoryProvider);
  return await repo.fetchByTimerId(timerId);
});

// 단일 기록 조회
final timerRecordProvider = FutureProvider.family<TimerRecord?, int>((ref, id) async {
  final repo = ref.watch(timerRecordRepositoryProvider);
  return await repo.fetchById(id);
});
