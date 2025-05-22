import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/timer_record_repository.dart';
import '../model/timer_record.dart';
import 'timer_record_provider.dart';

// 액션(추가/수정/삭제)용 AsyncNotifier
class TimerRecordActionNotifier extends AsyncNotifier<void> {
  late final TimerRecordRepository _repo;

  @override
  Future<void> build() async {
    _repo = ref.read(timerRecordRepositoryProvider);
  }

  Future<void> addRecord(TimerRecord record) async {
    state = const AsyncLoading();
    try {
      await _repo.add(record);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateRecord(TimerRecord record) async {
    state = const AsyncLoading();
    try {
      await _repo.update(record);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteRecord(int id) async {
    state = const AsyncLoading();
    try {
      await _repo.delete(id);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

// Provider 등록
final timerRecordActionProvider =
    AsyncNotifierProvider<TimerRecordActionNotifier, void>(TimerRecordActionNotifier.new);
