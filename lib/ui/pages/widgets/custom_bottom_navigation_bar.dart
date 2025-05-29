import 'package:fast_timer/theme/colors.dart';
import 'package:fast_timer/ui/pages/timer_list_page.dart';
import 'package:fast_timer/ui/pages/timer_record_list_page.dart';
import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int activeIndex; // 0: 타이머 설정, 1: 타이머 기록

  const CustomBottomNavigationBar({required this.activeIndex});

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
            imagePath: 'lib/assets/icons/timer.png',
            label: '타이머 설정',
            isActive: activeIndex == 0,
          ),
          _BottomNavTab(
            imagePath: 'lib/assets/icons/run.png',
            label: '타이머 기록',
            isActive: activeIndex == 1,
          ),
        ],
      ),
    );
  }
}

class _BottomNavTab extends StatelessWidget {
  final String imagePath;
  final String label;
  final bool isActive;

  const _BottomNavTab({
    required this.imagePath,
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
          if (isActive) return; // 이미 활성 탭이면 이동 X

          if (label == '타이머 설정') {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => TimerListPage()),
              (route) => false,
            );
          } else if (label == '타이머 기록') {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => TimerRecordListPage()),
              (route) => false,
            );
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 22, color: color),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
