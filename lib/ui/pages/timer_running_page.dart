import 'dart:async';
import 'dart:math';
import 'package:fast_timer/data/dao/timer_item_dao.dart';
import 'package:fast_timer/data/dao/timer_record_dao.dart';
import 'package:fast_timer/data/model/timer_item.dart';
import 'package:fast_timer/data/model/timer_record.dart';
import 'package:fast_timer/data/viewmodel/timer_item_viewmodel.dart';
import 'package:fast_timer/ui/pages/timer_create_page.dart';
import 'package:fast_timer/ui/pages/timer_list_page.dart';
import 'package:fast_timer/ui/pages/timer_start_page.dart';
import 'package:fast_timer/ui/utils/snackbar_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fast_timer/theme/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TimerState { running, paused }

class TimerRunningPage extends ConsumerStatefulWidget {
  final int timerId;
  const TimerRunningPage({super.key, required this.timerId});

  @override
  ConsumerState<TimerRunningPage> createState() => _TimerRunningPageState();
}

class _TimerRunningPageState extends ConsumerState<TimerRunningPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // 100ms마다 setState로 실시간 갱신
    _timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => setState(() {}),
    );
  }

  void _resetTimer(TimerItem timer) async {
    // 1. 먼저 타이머를 일시정지
    await ref
        .read(timerItemListViewModelProvider.notifier)
        .toggleTimer(timer.id!, false);

    // 2. 다이얼로그 띄우기
    final confirmed = await _showResetConfirmDialog(context, timer);

    // 3. 확인 시에만 초기화
    if (confirmed == true) {
      await ref
          .read(timerItemListViewModelProvider.notifier)
          .resetTimer(timer.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("타이머가 초기화되었습니다."),
          backgroundColor: AppColor.primaryOrange.of(context),
        ),
      );
    }
  }

  void _pauseTimer(TimerItem timer) {
    ref
        .read(timerItemListViewModelProvider.notifier)
        .toggleTimer(timer.id!, false);
  }

  void _resumeTimer(TimerItem timer) {
    ref
        .read(timerItemListViewModelProvider.notifier)
        .toggleTimer(timer.id!, true);
  }

  void _onBackPressed() {
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<String?> _showFinishDialog(BuildContext context, TimerItem timer) {
    final int targetSeconds = timer.targetSeconds;
    final double speed = timer.speed;

    // 실시간 남은 시간 계산
    int remaining = timer.remainingSeconds;
    Duration elapsedReal = Duration.zero;
    if (timer.isRunning && timer.lastStartTime != null) {
      final elapsed =
          DateTime.now().difference(timer.lastStartTime!).inMilliseconds *
          timer.speed;
      final elapsedSeconds = (elapsed / 1000).floor();
      remaining = (timer.remainingSeconds - elapsedSeconds).clamp(
        0,
        timer.targetSeconds,
      );
      elapsedReal = Duration(seconds: timer.targetSeconds - remaining);
    } else {
      elapsedReal = Duration(
        seconds: timer.targetSeconds - timer.remainingSeconds,
      );
    }

    final int recordedSeconds = timer.targetSeconds - remaining;
    final int realElapsedSeconds = elapsedReal.inSeconds;
    final String timerName = timer.name;

    int diff = targetSeconds - realElapsedSeconds;
    int diffH = diff ~/ 3600;
    int diffM = (diff % 3600) ~/ 60;
    int diffS = diff % 60;

    RichText formatHMSRich(int seconds) {
      int h = seconds ~/ 3600;
      int m = (seconds % 3600) ~/ 60;
      int s = seconds % 60;
      List<InlineSpan> spans = [];
      if (h > 0) {
        spans.add(
          TextSpan(
            text: "$h시간 ",
            style: TextStyle(
              color: AppColor.primaryOrange.of(context),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        );
      }
      if (m > 0) {
        spans.add(
          TextSpan(
            text: "$m분 ",
            style: TextStyle(
              color: AppColor.primaryOrange.of(context),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        );
      }
      if (s > 0) {
        spans.add(
          TextSpan(
            text: "$s초",
            style: TextStyle(
              color: AppColor.primaryOrange.of(context),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        );
      }
      if (spans.isEmpty) {
        spans.add(
          TextSpan(
            text: "0초",
            style: TextStyle(
              color: AppColor.primaryOrange.of(context),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        );
      }
      return RichText(text: TextSpan(children: spans));
    }

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          titlePadding: const EdgeInsets.only(
            left: 24,
            right: 12,
            top: 24,
            bottom: 0,
          ),
          title: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 36),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (diffH > 0 || diffM > 0 || diffS > 0)
                            formatHMSRich(diff),
                          Text(
                            " 빠르게 목표를 달성했어요!",
                            style: TextStyle(
                              color: AppColor.gray30.of(context),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -12,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.close, color: AppColor.gray20.of(context)),
                  splashRadius: 18,
                  onPressed: () => Navigator.pop(ctx, null), // 닫기: 다시 진행
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow("설정한 시간", formatHMSRich(targetSeconds)),
              const SizedBox(height: 6),
              _infoRow(
                "설정한 배속",
                Text(
                  "x${speed.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: AppColor.primaryOrange.of(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              _infoRow("실제 걸린 시간", formatHMSRich(realElapsedSeconds)),
              const SizedBox(height: 20),
              Text(
                "$timerName에 이 기록을 저장할까요?",
                style: TextStyle(
                  color: AppColor.gray30.of(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx, 'delete');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.gray30.of(context),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "저장 안 함",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx, 'save');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryOrange.of(context),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "저장",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool?> _showResetConfirmDialog(BuildContext context, TimerItem timer) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          titlePadding: const EdgeInsets.only(
            left: 24,
            right: 12,
            top: 24,
            bottom: 0,
          ),
          title: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 36),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "타이머를 초기화할까요?",
                            style: TextStyle(
                              color: AppColor.gray30.of(context),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "초기화하면 타이머가 처음 상태로 돌아갑니다.",
                style: TextStyle(
                  color: AppColor.gray30.of(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.gray30.of(context),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "취소",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryOrange.of(context),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "초기화",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, Widget value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              color: AppColor.gray20.of(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: value),
      ],
    );
  }

  String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return "${h.toString().padLeft(1, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
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
    final timer = ref
        .watch(timerItemListViewModelProvider)
        .timers
        .firstWhere((t) => t.id == widget.timerId);

    // 실시간 남은 시간/진행률 계산
    int remaining = timer.remainingSeconds;
    double progress = timer.progress;
    Duration elapsedReal = Duration.zero;
    DateTime realStartTime = timer.lastStartTime ?? DateTime.now();

    if (timer.isRunning && timer.lastStartTime != null) {
      final elapsed =
          DateTime.now().difference(timer.lastStartTime!).inMilliseconds *
          timer.speed;
      final elapsedSeconds = (elapsed / 1000).floor();
      remaining = (timer.remainingSeconds - elapsedSeconds).clamp(
        0,
        timer.targetSeconds,
      );
      progress =
          timer.targetSeconds > 0 ? remaining / timer.targetSeconds : 0.0;
      elapsedReal = Duration(seconds: timer.targetSeconds - remaining);
      realStartTime = timer.lastStartTime!;
    }

    // 아래에서 remaining, progress, elapsedReal, realStartTime 사용

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
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColor.gray30.of(context),
                  ),
                  onPressed: _onBackPressed,
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
            // 타이틀 + 아이콘
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
                    timer.name,
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
                child: SizedBox(
                  width: 260,
                  height: 260,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(260, 260),
                        painter: _TimerProgressPainter(
                          progress: progress,
                          color: AppColor.primaryOrange.of(context),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 목표 시간
                          Text(
                            _formatHMS(timer.targetSeconds),
                            style: TextStyle(
                              color: AppColor.gray20.of(context),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 남은 시간
                          Text(
                            _formatTime(remaining),
                            style: TextStyle(
                              color: AppColor.defaultBlack.of(context),
                              fontSize: 44,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 하단 버튼 3개: 상태에 따라 UI 변경
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:
                    timer.isRunning
                        ? [
                          // 초기화
                          _circleButton(
                            icon: Icons.refresh,
                            color: AppColor.gray30.of(context),
                            onPressed: () => _resetTimer(timer),
                          ),
                          // 일시정지
                          _circleButton(
                            icon: Icons.pause,
                            color: AppColor.primaryRed.of(context),
                            onPressed: () => _pauseTimer(timer),
                          ),
                          // 종료
                          _circleButton(
                            icon: Icons.stop,
                            color: AppColor.primaryOrange.of(context),
                            onPressed: () async {
                              // 1. 종료(저장) 버튼을 누르면 일단 타이머를 일시정지
                              ref
                                  .read(timerItemListViewModelProvider.notifier)
                                  .toggleTimer(widget.timerId, false);

                              // Provider에서 최신 TimerItem을 가져옴
                              final timer = ref
                                  .read(timerItemListViewModelProvider)
                                  .timers
                                  .firstWhere((t) => t.id == widget.timerId);

                              // 2. Dialog 표시
                              final result = await _showFinishDialog(
                                context,
                                timer,
                              );

                              if (!mounted) return;

                              if (result == 'save') {
                                // 기록 저장
                                await TimerRecordDao().insert(
                                  TimerRecord(
                                    timerId: timer.id!,
                                    targetSeconds: timer.targetSeconds,
                                    speed: timer.speed,
                                    recordedSeconds:
                                        timer.targetSeconds -
                                        timer.remainingSeconds,
                                    actualSeconds:
                                        (timer.targetSeconds -
                                            timer.remainingSeconds) ~/
                                        timer.speed,
                                    startedAt:
                                        timer.lastStartTime ?? DateTime.now(),
                                    endedAt: DateTime.now(),
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text("기록이 저장되었습니다!"),
                                    backgroundColor: AppColor.primaryOrange.of(
                                      context,
                                    ),
                                  ),
                                );
                                // 3. 저장/저장안함 모두 타이머를 초기화
                                await ref
                                    .read(
                                      timerItemListViewModelProvider.notifier,
                                    )
                                    .resetTimer(widget.timerId);

                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => TimerListPage(),
                                  ),
                                  (route) => false,
                                );
                              } else if (result == 'delete') {
                                // 저장 안 함 → 타이머 초기화
                                await ref
                                    .read(
                                      timerItemListViewModelProvider.notifier,
                                    )
                                    .resetTimer(widget.timerId);

                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => TimerListPage(),
                                  ),
                                  (route) => false,
                                );
                              }
                              // 닫기(X) 버튼 등은 아무 동작도 하지 않음 (다이얼로그만 닫힘)
                            },
                          ),
                        ]
                        : [
                          // 초기화
                          _circleButton(
                            icon: Icons.refresh,
                            color: AppColor.gray30.of(context),
                            onPressed: () => _resetTimer(timer),
                          ),
                          // 계속
                          _circleButton(
                            icon: Icons.play_arrow,
                            color: AppColor.primaryBlue.of(context),
                            onPressed: () => _resumeTimer(timer),
                          ),
                          // 종료
                          _circleButton(
                            icon: Icons.stop,
                            color: AppColor.primaryOrange.of(context),
                            onPressed: () async {
                              // 1. 종료(저장) 버튼을 누르면 일단 타이머를 일시정지
                              ref
                                  .read(timerItemListViewModelProvider.notifier)
                                  .toggleTimer(widget.timerId, false);

                              // Provider에서 최신 TimerItem을 가져옴
                              final timer = ref
                                  .read(timerItemListViewModelProvider)
                                  .timers
                                  .firstWhere((t) => t.id == widget.timerId);

                              // 2. Dialog 표시
                              final result = await _showFinishDialog(
                                context,
                                timer,
                              );

                              if (!mounted) return;

                              if (result == 'save') {
                                // 기록 저장
                                await TimerRecordDao().insert(
                                  TimerRecord(
                                    timerId: timer.id!,
                                    targetSeconds: timer.targetSeconds,
                                    speed: timer.speed,
                                    recordedSeconds:
                                        timer.targetSeconds -
                                        timer.remainingSeconds,
                                    actualSeconds:
                                        (timer.targetSeconds -
                                            timer.remainingSeconds) ~/
                                        timer.speed,
                                    startedAt:
                                        timer.lastStartTime ?? DateTime.now(),
                                    endedAt: DateTime.now(),
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text("기록이 저장되었습니다!"),
                                    backgroundColor: AppColor.primaryOrange.of(
                                      context,
                                    ),
                                  ),
                                );
                                // 3. 저장/저장안함 모두 타이머를 초기화
                                await ref
                                    .read(
                                      timerItemListViewModelProvider.notifier,
                                    )
                                    .resetTimer(widget.timerId);

                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => TimerListPage(),
                                  ),
                                  (route) => false,
                                );
                              } else if (result == 'delete') {
                                // 저장 안 함 → 타이머 초기화
                                await ref
                                    .read(
                                      timerItemListViewModelProvider.notifier,
                                    )
                                    .resetTimer(widget.timerId);

                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => TimerListPage(),
                                  ),
                                  (route) => false,
                                );
                              }
                              // 닫기(X) 버튼 등은 아무 동작도 하지 않음 (다이얼로그만 닫힘)
                            },
                          ),
                        ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: const CircleBorder(),
            elevation: 0,
            minimumSize: const Size(64, 64),
          ),
          child: Icon(icon, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}

// CustomPainter로 원형 타이머 프로그레스 구현
class _TimerProgressPainter extends CustomPainter {
  final double progress; // 1.0 ~ 0.0
  final Color color;

  _TimerProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 12.0;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.width - strokeWidth) / 2;

    // 전체 배경 원
    final bgPaint =
        Paint()
          ..color = color.withOpacity(0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // 진행 원
    final progressPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    // 12시 방향에서 반시계 방향으로
    final startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TimerProgressPainter old) =>
      old.progress != progress || old.color != color;
}
