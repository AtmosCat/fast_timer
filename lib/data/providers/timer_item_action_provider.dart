import 'package:fast_timer/data/providers/timer_item_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/timer_item_repository.dart';

final timerItemActionProvider = Provider<TimerItemRepository>((ref) {
  return ref.watch(timerItemRepositoryProvider);
});

