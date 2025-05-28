import 'package:fast_timer/data/model/timer_item.dart';
import 'package:fast_timer/data/providers/timer_item_provider.dart';
import 'package:fast_timer/data/viewmodel/timer_item_viewmodel.dart';
import 'package:fast_timer/ui/pages/timer_running_page.dart';
import 'package:fast_timer/ui/pages/widgets/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fast_timer/theme/colors.dart';
import 'package:fast_timer/ui/pages/timer_create_page.dart';

class TimerListPage extends ConsumerWidget {
  const TimerListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1초마다 rebuild (timerTickProvider 활용)
    ref.watch(timerTickProvider);
    final state = ref.watch(timerItemListViewModelProvider);

    if (state.isLoading) {
      return Scaffold(
        backgroundColor: AppColor.scaffoldGray.of(context),
        appBar: AppBar(
          backgroundColor: AppColor.containerWhite.of(context),
          elevation: 1,
          title: Text(
            '타이머 목록',
            style: TextStyle(
              color: AppColor.defaultBlack.of(context),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              // 메뉴 또는 뒤로가기 액션
            },
            icon: Icon(Icons.menu, color: AppColor.defaultBlack.of(context)),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColor.primaryOrange.of(context),
                ),
                const SizedBox(height: 20),
                Text(
                  '타이머 목록을 불러오는 중...',
                  style: TextStyle(
                    color: AppColor.primaryOrange.of(context),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final timers = state.timers;

    return Scaffold(
      backgroundColor: AppColor.scaffoldGray.of(context),
      appBar: AppBar(
        backgroundColor: AppColor.containerWhite.of(context),
        elevation: 1,
        title: Text(
          '타이머 목록',
          style: TextStyle(
            color: AppColor.defaultBlack.of(context),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            // 메뉴 또는 뒤로가기 액션
          },
          icon: Icon(Icons.menu, color: AppColor.defaultBlack.of(context)),
        ),
      ),
      body: SafeArea(
        child:
            timers.isEmpty
                ? Center(
                  child: Text(
                    '등록된 타이머가 없습니다.\n오른쪽 아래 + 버튼을 눌러 타이머를 추가해보세요!',
                    style: TextStyle(
                      color: AppColor.gray20.of(context),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
                : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  itemCount: timers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final timer = timers[index];
                    final now = DateTime.now();
                    int remaining = timer.remainingSeconds;
                    double progress = timer.progress;

                    if (timer.isRunning && timer.lastStartTime != null) {
                      final elapsed =
                          now.difference(timer.lastStartTime!).inMilliseconds *
                          timer.speed;
                      final elapsedSeconds = (elapsed / 1000).floor();
                      remaining = (timer.remainingSeconds - elapsedSeconds)
                          .clamp(0, timer.targetSeconds);
                      progress =
                          timer.targetSeconds > 0
                              ? remaining / timer.targetSeconds
                              : 0.0;
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    TimerRunningPage(timerId: timer.id!),
                          ),
                        );
                      },
                      child: TimerCard(
                        timer: timer.copyWith(
                          remainingSeconds: remaining,
                          progress: progress,
                        ),
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.primaryOrange.of(context),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TimerCreatePage()),
          );
          // 타이머 생성 후 돌아오면 리스트 새로고침
          ref.invalidate(timerItemListViewModelProvider);
        },
        child: const Icon(Icons.add, color: Colors.white),
        shape: const CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: CustomBottomNavigationBar(activeIndex: 0),
    );
  }
}

class TimerCard extends ConsumerWidget {
  final TimerItem timer;

  const TimerCard({super.key, required this.timer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(timerItemListViewModelProvider.notifier);

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      color: AppColor.containerWhite.of(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.primaryOrange.of(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'x${timer.speed.toStringAsFixed(1)}배속',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    timer.name,
                    style: TextStyle(
                      color: AppColor.defaultBlack.of(context),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  "총 ${_formatHMS(timer.targetSeconds)}",
                  style: TextStyle(
                    color: AppColor.gray20.of(context),
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _formatTime(timer.remainingSeconds),
                    style: TextStyle(
                      color: AppColor.defaultBlack.of(context),
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Row(
                  children: [
                    _smallCircleButton(
                      icon: Icons.refresh,
                      color: AppColor.gray30.of(context),
                      onPressed: () => notifier.resetTimer(timer.id!),
                    ),
                    const SizedBox(width: 6),
                    _smallCircleButton(
                      icon: timer.isRunning ? Icons.pause : Icons.play_arrow,
                      color:
                          timer.isRunning
                              ? AppColor.primaryRed.of(context)
                              : AppColor.primaryBlue.of(context),
                      onPressed:
                          () =>
                              notifier.toggleTimer(timer.id!, !timer.isRunning),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: timer.progress,
                minHeight: 5,
                backgroundColor: AppColor.lightGray20.of(context),
                valueColor: AlwaysStoppedAnimation<Color>(
                  timer.isRunning
                      ? AppColor.primaryOrange.of(context)
                      : AppColor.gray20.of(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 시간 포맷 함수
  String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  String _formatHMS(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    String result = "";
    if (h > 0) result += "$h시간 ";
    if (m > 0) result += "$m분 ";
    if (s > 0) result += "$s초";
    return result.isNotEmpty ? result : "0초";
  }
}

Widget _smallCircleButton({
  required IconData icon,
  required Color color,
  required VoidCallback onPressed,
}) {
  return SizedBox(
    width: 36,
    height: 36,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: const CircleBorder(),
        elevation: 0,
        padding: EdgeInsets.zero,
        minimumSize: const Size(36, 36),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    ),
  );
}
