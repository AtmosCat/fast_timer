import 'package:fast_timer/data/viewmodel/timer_item_viewmodel.dart';
import 'package:fast_timer/ui/pages/widgets/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fast_timer/theme/colors.dart';
import 'package:fast_timer/ui/pages/timer_create_page.dart';
import 'package:fast_timer/ui/pages/timer_start_page.dart';

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
                final totalTime = _formatTime(totalSeconds);
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => TimerStartPage(
                              timerName: timer.name,
                              targetSeconds: totalSeconds,
                              timerId: timer.id!,
                            ),
                      ),
                    );
                  },
                  child: TimerCard(
                    speed: 1.0, // 실제 배속 정보가 있다면 적용
                    title: timer.name,
                    currentTime: currentTime,
                    totalTime: totalTime,
                    progress: 1.0, // 실제 진행률로 대체
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
}

class TimerCard extends StatelessWidget {
  final double speed;
  final String title;
  final String currentTime;
  final String totalTime;
  final double progress; // 0.0 ~ 1.0

  const TimerCard({
    super.key,
    required this.speed,
    required this.title,
    required this.currentTime,
    required this.totalTime,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      color: AppColor.containerWhite.of(context),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: [
            // // 옵션 메뉴 (오른쪽 상단)
            // Positioned(
            //   right: 0,
            //   top: 0,
            //   child: Icon(Icons.more_vert, color: AppColor.gray20.of(context)),
            // ),
            // 메인 내용
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // // 배속 배지
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 8,
                    //     vertical: 2,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     color: AppColor.primaryOrange.of(context),
                    //     borderRadius: BorderRadius.circular(8),
                    //   ),
                    //   child: Text(
                    //     'x${speed.toStringAsFixed(1)}배속',
                    //     style: const TextStyle(
                    //       color: Colors.white,
                    //       fontSize: 12,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                    // ),
                    Image.asset(
                      'lib/assets/icons/run.png',
                      height: 27,
                      color: AppColor.primaryOrange.of(context),
                    ),
                    const SizedBox(width: 12),
                    // 타이머 제목
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
                  ],
                ),
                const SizedBox(height: 20),
                // 현재 시간 / 전체 시간
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: currentTime,
                        style: TextStyle(
                          color: AppColor.defaultBlack.of(context),
                          fontSize: 30, // 현재 시간: 더 크게
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                        ),
                      ),
                      TextSpan(
                        text: ' / ',
                        style: TextStyle(
                          color: AppColor.defaultBlack.of(context),
                          fontSize: 22,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      TextSpan(
                        text: totalTime,
                        style: TextStyle(
                          color: AppColor.gray30.of(context),
                          fontSize: 20, // 목표 시간: 작게
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                // ProgressBar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: AppColor.containerLightGray30.of(context),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColor.primaryOrange.of(context),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
