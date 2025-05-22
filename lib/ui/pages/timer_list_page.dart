import 'package:fast_timer/ui/pages/timer_create_page.dart';
import 'package:flutter/material.dart';
import 'package:fast_timer/theme/colors.dart';

class TimerListPage extends StatelessWidget {
  const TimerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 더미 데이터
    final timers = [
      {
        'speed': 1.5,
        'title': '중간고사 타이머',
        'current': '01:49:30',
        'total': '01:50:00',
        'progress': 0.98,
      },
      {
        'speed': 2.0,
        'title': '퍼즐 도전',
        'current': '00:09:12',
        'total': '00:10:00',
        'progress': 0.92,
      },
      {
        'speed': 1.2,
        'title': '논리학 과제',
        'current': '00:23:10',
        'total': '00:30:00',
        'progress': 0.77,
      },
    ];

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
            // 뒤로가기 액션
          },
          icon: Icon(Icons.menu, color: AppColor.defaultBlack.of(context)),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                itemCount: timers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final timer = timers[index];
                  return TimerCard(
                    speed: timer['speed'] as double,
                    title: timer['title'] as String,
                    currentTime: timer['current'] as String,
                    totalTime: timer['total'] as String,
                    progress: timer['progress'] as double,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.primaryOrange.of(context),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return TimerCreatePage();
          }));
        },
        child: const Icon(Icons.add, color: Colors.white),
        shape: const CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const _CustomBottomNavigationBar(),
    );
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
            // 옵션 메뉴 (오른쪽 상단)
            Positioned(
              right: 0,
              top: 0,
              child: Icon(Icons.more_vert, color: AppColor.gray20.of(context)),
            ),
            // 메인 내용
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // 배속 배지
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
                    const SizedBox(width: 8),
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
                          color: AppColor.gray30.of(context),
                          fontSize: 30, // 현재 시간: 더 크게
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                        ),
                      ),
                      TextSpan(
                        text: ' / ',
                        style: TextStyle(
                          color: AppColor.gray30.of(context),
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

class _CustomBottomNavigationBar extends StatelessWidget {
  const _CustomBottomNavigationBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColor.containerWhite.of(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowBlack.of(context).withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _BottomNavTab(
            icon: Icons.timer_rounded,
            label: '타이머 설정',
            isActive: true,
          ),
          _BottomNavTab(
            icon: Icons.directions_run,
            label: '질주 기록',
            isActive: false,
          ),
        ],
      ),
    );
  }
}

class _BottomNavTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _BottomNavTab({
    required this.icon,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isActive
            ? AppColor.primaryOrange.of(context)
            : AppColor.gray20.of(context);
    return Expanded(
      child: InkWell(
        onTap: () {
          // 탭 이동 액션
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
