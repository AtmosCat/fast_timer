import 'dart:async';
import 'package:fast_timer/data/dao/timer_item_dao.dart';
import 'package:fast_timer/data/model/timer_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. 상태 모델
class TimerListState {
  final bool isLoading;
  final List<TimerItem> timers;

  TimerListState({required this.isLoading, required this.timers});

  TimerListState copyWith({bool? isLoading, List<TimerItem>? timers}) {
    return TimerListState(
      isLoading: isLoading ?? this.isLoading,
      timers: timers ?? this.timers,
    );
  }

  factory TimerListState.initial() =>
      TimerListState(isLoading: true, timers: []);
}

// 2. StateNotifier
class TimerItemNotifier extends StateNotifier<TimerListState> {
  StreamSubscription? _autoRefreshSub;

  TimerItemNotifier() : super(TimerListState.initial()) {
    loadTimers();
    _startAutoRefresh();
  }

  Future<void> loadTimers() async {
    state = state.copyWith(isLoading: true);
    final timers = await TimerItemDao().getAll();
    state = state.copyWith(isLoading: false, timers: timers);
  }

  Future<void> updateTimer(TimerItem updated) async {
    await TimerItemDao().update(updated);
    await loadTimers();
  }

  Future<void> resetTimer(int id) async {
    final timer = state.timers.firstWhere((t) => t.id == id);
    final reset = timer.copyWith(
      remainingSeconds: timer.targetSeconds,
      progress: 1.0,
      isRunning: false,
      lastStartTime: null,
    );
    await updateTimer(reset);
  }

  Future<void> toggleTimer(int id, bool isRunning) async {
    final timer = state.timers.firstWhere((t) => t.id == id);

    if (isRunning) {
      // 재생: 기준 시각을 현재로
      final updated = timer.copyWith(
        isRunning: true,
        lastStartTime: DateTime.now(),
      );
      await updateTimer(updated);
    } else {
      // 일시정지: 경과 시간 계산, 남은 시간 업데이트
      int newRemaining = timer.remainingSeconds;
      if (timer.isRunning && timer.lastStartTime != null) {
        final elapsed =
            DateTime.now().difference(timer.lastStartTime!).inMilliseconds *
            timer.speed;
        final elapsedSeconds = (elapsed / 1000).floor();
        newRemaining = timer.remainingSeconds - elapsedSeconds;
      }
      final updated = timer.copyWith(
        isRunning: false,
        remainingSeconds: newRemaining,
        progress:
            timer.targetSeconds > 0
                ? (newRemaining > 0 ? newRemaining / timer.targetSeconds : 0.0)
                : 0.0,
        lastStartTime: null,
      );
      await updateTimer(updated);
    }
  }

  void _startAutoRefresh() {
    // Stream 구독을 필드에 저장
    _autoRefreshSub = Stream.periodic(
      const Duration(seconds: 1),
    ).listen((_) => loadTimers());
  }

  @override
  void dispose() {
    // Provider가 dispose될 때 Stream 구독도 해제
    _autoRefreshSub?.cancel();
    super.dispose();
  }
}

// 3. Provider 등록
final timerItemListViewModelProvider =
    StateNotifierProvider<TimerItemNotifier, TimerListState>(
      (ref) => TimerItemNotifier(),
    );
