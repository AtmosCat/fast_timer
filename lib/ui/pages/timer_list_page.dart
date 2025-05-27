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

  // 실시간 남은 시간 계산 (isRunning일 때만)
  int _elapsedFor(TimerItem timer) {
    if (!timer.isRunning) return 0;
    // 실제로는 타이머 시작 시각, 배속 등 추가 정보 필요
    // 간단 예시: DateTime.now() - timer.lastStartedAt
    return 0; // 구현 필요
  }

  // 실시간 진행률 계산 (isRunning일 때만)
  double _progressFor(TimerItem timer) {
    if (!timer.isRunning) return timer.progress;
    // 실제로는 남은 시간/전체 시간으로 계산
    return 1.0; // 구현 필요
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timers = ref.watch(timerItemListViewModelProvider);

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
                  child: Text('등록된 타이머가 없습니다.\n오른쪽 아래 + 버튼을 눌러 타이머를 추가해보세요!'),
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
                    return GestureDetector(
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => TimerRunningPage(
                                    timerId: timer.id!,
                                    speed: timer.speed,
                                    timerName: timer.name,
                                    targetSeconds: timer.targetSeconds,
                                  ),
                            ),
                          ),
                      child: TimerCard(
                        speed: timer.speed,
                        title: timer.name,
                        currentTime: _formatTime(
                          timer.isRunning
                              ? (timer.remainingSeconds -
                                  _elapsedFor(timer)) // 실시간 계산
                              : timer.remainingSeconds,
                        ),
                        totalTime: _formatHMS(timer.targetSeconds),
                        progress:
                            timer.isRunning
                                ? _progressFor(timer)
                                : timer.progress,
                        isRunning: timer.isRunning,
                        onReset:
                            () => ref
                                .read(timerItemListViewModelProvider.notifier)
                                .resetTimer(timer.id!),
                        onToggle:
                            () => ref
                                .read(timerItemListViewModelProvider.notifier)
                                .toggleTimer(timer.id!, !timer.isRunning),
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
    if (result.isEmpty) result = "0초";
    return result;
  }
}

class TimerCard extends StatelessWidget {
  final double speed;
  final String title;
  final String currentTime;
  final String totalTime;
  final double progress;
  final bool isRunning;
  final VoidCallback onReset;
  final VoidCallback onToggle;

  const TimerCard({
    super.key,
    required this.speed,
    required this.title,
    required this.currentTime,
    required this.totalTime,
    required this.progress,
    required this.isRunning,
    required this.onReset,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
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
                    'x${speed.toStringAsFixed(1)}배속',
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
                    title,
                    style: TextStyle(
                      color: AppColor.defaultBlack.of(context),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  "총 $totalTime",
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
                    currentTime,
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
                      onPressed: onReset,
                    ),
                    const SizedBox(width: 6),
                    _smallCircleButton(
                      icon: isRunning ? Icons.pause : Icons.play_arrow,
                      color:
                          isRunning
                              ? AppColor.primaryRed.of(context)
                              : AppColor.primaryBlue.of(context),
                      onPressed: onToggle,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: AppColor.lightGray20.of(context),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isRunning
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
