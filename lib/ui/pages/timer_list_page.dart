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
    final timerListAsync = ref.watch(timerItemListViewModelProvider);

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
        child: timerListAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('타이머를 불러올 수 없습니다.\n$e')),
          data: (timers) {
            if (timers.isEmpty) {
              return Center(
                child: Text(
                  '등록된 타이머가 없습니다.\n오른쪽 아래 + 버튼을 눌러 타이머를 추가해보세요!',
                  style: TextStyle(
                    color: AppColor.gray20.of(context),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              itemCount: timers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final timer = timers[index];
                final totalSeconds = 
                    timer.hour * 3600 + timer.minute * 60 + timer.second;
                final currentTime = _formatTime(
                  totalSeconds,
                ); // 실제 앱에서는 진행중 시간으로 대체
                final totalTime = _formatHMS(totalSeconds);
                return GestureDetector(
                  onTap: () {
                    final int targetSeconds =
                        timer.hour * 3600 + timer.minute * 60 + timer.second;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => TimerRunningPage(
                              timerId: timer.id!,
                              timerName: timer.name,
                              targetSeconds: targetSeconds,
                              speed: timer.speed,
                            ),
                      ),
                    );
                  },
                  child: TimerCard(
                    speed: timer.speed,
                    title: timer.name,
                    currentTime: currentTime, // 남은 시간
                    totalTime: totalTime, // 전체 시간
                    progress: timer.progress, // 진행률 (0.0~1.0)
                    isRunning: timer.isRunning, // 실제 상태값
                    onReset: () {
                      // 초기화 로직
                    },
                    onToggle: () {
                      // 재생/일시정지 토글 로직
                    },
                  ),
                );
              },
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
  final VoidCallback onToggle; // 재생/일시정지
  // 필요시 onTap 등 추가

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
            // 상단: 배속 칩 + 이름 + 전체 시간
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 배속 칩
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
                // 타이머 이름
                Text(
                  title,
                  style: TextStyle(
                    color: AppColor.defaultBlack.of(context),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Spacer(),
                // Image.asset(
                //   'lib/assets/icons/timer.png',
                //   color: AppColor.gray10.of(context),
                //   height: 14,
                // ),
                // SizedBox(width: 4),
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
            // 하단: 남은 시간 + 버튼들
            Row(
              children: [
                // 남은 시간 (크게)
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
                // 버튼들
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
            // ProgressBar
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
