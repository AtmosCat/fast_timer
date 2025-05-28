import 'package:fast_timer/data/dao/timer_item_dao.dart';
import 'package:fast_timer/data/dao/timer_record_dao.dart';
import 'package:fast_timer/data/viewmodel/timer_item_viewmodel.dart';
import 'package:fast_timer/ui/pages/timer_create_page.dart';
import 'package:fast_timer/ui/pages/timer_list_page.dart';
import 'package:fast_timer/ui/pages/timer_running_page.dart';
import 'package:fast_timer/ui/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fast_timer/theme/colors.dart';

class TimerStartPage extends ConsumerStatefulWidget {
  final int timerId;
  final String timerName;
  final int targetSeconds; // 목표 시간(초 단위)

  const TimerStartPage({
    super.key,
    required this.timerId,
    required this.timerName,
    required this.targetSeconds,
  });

  @override
  ConsumerState<TimerStartPage> createState() => _TimerRunPageState();
}

class _TimerRunPageState extends ConsumerState<TimerStartPage> {
  double _speed = 1.0;

  double min = 0.5;
  double max = 3.0;
  int divisions = 10; // (3.0-0.5)/0.25 = 10

  final labelValues = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0];

  String get _targetTimeText {
    final h = widget.targetSeconds ~/ 3600;
    final m = (widget.targetSeconds % 3600) ~/ 60;
    final s = widget.targetSeconds % 60;
    return "${h > 0 ? '$h시간 ' : ''}${m > 0 ? '$m분 ' : ''}${s > 0 ? '$s초' : ''}"
        .trim();
  }

  String get _targetTimeDigital {
    final h = widget.targetSeconds ~/ 3600;
    final m = (widget.targetSeconds % 3600) ~/ 60;
    final s = widget.targetSeconds % 60;
    return "${h.toString().padLeft(1, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  Future<void> _deleteTimer() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Text(
              '타이머 삭제',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text('정말 타이머를 삭제하시겠습니까?\n저장된 타이머 기록도 모두 삭제됩니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx, false);
                },
                child: Text(
                  '취소',
                  style: TextStyle(color: AppColor.gray30.of(context)),
                ),
              ),
              TextButton(
                onPressed: () {
                  SnackbarUtil.showToastMessage('타이머가 삭제되었습니다.');
                  Navigator.pop(ctx, true);
                },
                child: const Text('삭제', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      await TimerItemDao().delete(widget.timerId);
      await TimerRecordDao().delete(widget.timerId);
      // Provider invalidate로 리스트 새로고침
      ref.invalidate(timerItemListViewModelProvider);
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const TimerListPage()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _editTimer() async {
    final timer = await TimerItemDao().getById(widget.timerId);
    if (mounted && timer != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TimerCreatePage(timerItem: timer),
        ),
      );
      // 수정 후 돌아오면 리스트 새로고침
      ref.invalidate(timerItemListViewModelProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldGray.of(context),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.home, color: AppColor.gray30.of(context)),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => TimerListPage()),
                      (route) => false,
                    );
                  },
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: AppColor.gray30.of(context),
                  ),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      await _editTimer();
                    } else if (value == 'delete') {
                      await _deleteTimer();
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('타이머 수정'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('타이머 삭제'),
                        ),
                      ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 타이틀 + 아이콘 (타이머 중앙 상단)
            Padding(
              padding: const EdgeInsets.only(top: 18.0, bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/assets/icons/run.png',
                    height: 27,
                    color: AppColor.gray30.of(context),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.timerName,
                    style: TextStyle(
                      color: AppColor.defaultBlack.of(context),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 원형 타이머 영역
            Expanded(
              child: Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    color: AppColor.scaffoldGray.of(context),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColor.containerLightGray20.of(context),
                      width: 10,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _targetTimeText,
                        style: TextStyle(
                          color: AppColor.gray20.of(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _targetTimeDigital,
                        style: TextStyle(
                          color: AppColor.defaultBlack.of(context),
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 배속 설정 라벨
            Text(
              "배속 설정",
              style: TextStyle(
                color: AppColor.gray30.of(context),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            // 슬라이더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 5,
                      activeTrackColor: AppColor.primaryOrange.of(context),
                      inactiveTrackColor: AppColor.containerLightGray20.of(
                        context,
                      ),
                      thumbColor: AppColor.primaryOrange.of(context),
                      overlayColor: AppColor.primaryOrange
                          .of(context)
                          .withOpacity(0.15),
                      valueIndicatorColor: AppColor.primaryOrange.of(context),
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 13,
                      ),
                      valueIndicatorTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Slider(
                      min: min,
                      max: max,
                      divisions: divisions,
                      label: "x${_speed.toStringAsFixed(2)}",
                      value: _speed,
                      onChanged: (val) {
                        setState(() {
                          _speed = (val * 4).round() / 4.0;
                        });
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:
                        labelValues.map((value) {
                          return Text(
                            "  x${value.toStringAsFixed(1)}",
                            style: TextStyle(
                              color: AppColor.gray20.of(context),
                              fontSize: 13,
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 38),

            // 시작 버튼
            Center(
              child: SizedBox(
                width: 90,
                height: 90,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                TimerRunningPage(timerId: widget.timerId),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryOrange.of(context),
                    shape: const CircleBorder(),
                    elevation: 0,
                  ),
                  child: const Text(
                    "시작",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
