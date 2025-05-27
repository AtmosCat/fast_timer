import 'package:fast_timer/data/dao/timer_item_dao.dart';
import 'package:fast_timer/data/model/timer_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimerItemNotifier extends StateNotifier<List<TimerItem>> {
  TimerItemNotifier() : super([]);

  // 타이머 리스트 불러오기
  Future<void> loadTimers() async {
    final timers = await TimerItemDao().getAll();
    state = timers;
  }

  // 특정 타이머 상태 업데이트
  Future<void> updateTimer(TimerItem updated) async {
    await TimerItemDao().update(updated);
    state = [
      for (final t in state)
        if (t.id == updated.id) updated else t
    ];
  }

  // 타이머 초기화
  Future<void> resetTimer(int id) async {
    final timer = state.firstWhere((t) => t.id == id);
    final reset = timer.copyWith(
      remainingSeconds: timer.targetSeconds,
      progress: 1.0,
      isRunning: false,
    );
    await updateTimer(reset);
  }

  // 타이머 재생/일시정지 토글
  Future<void> toggleTimer(int id, bool isRunning) async {
    final timer = state.firstWhere((t) => t.id == id);
    final updated = timer.copyWith(isRunning: isRunning);
    await updateTimer(updated);
  }
}

final timerItemListViewModelProvider = StateNotifierProvider<TimerItemNotifier, List<TimerItem>>(
  (ref) => TimerItemNotifier()..loadTimers(),
);
