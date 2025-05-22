import 'package:fast_timer/data/providers/timer_record_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/timer_record.dart';

// 단일 기록 상세 Provider
final timerRecordDetailProvider = FutureProvider.family<TimerRecord?, int>((ref, id) async {
  final repo = ref.watch(timerRecordRepositoryProvider);
  return await repo.fetchById(id);
});
