import 'dart:async';
import 'dart:math';
import 'package:fast_timer/data/model/timer_record.dart';
import 'package:fast_timer/data/viewmodel/timer_item_viewmodel.dart';
import 'package:fast_timer/ui/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';
import 'package:fast_timer/data/model/timer_item.dart';
import 'package:fast_timer/data/dao/timer_item_dao.dart';
import 'package:fast_timer/data/dao/timer_record_dao.dart';
import 'package:fast_timer/theme/colors.dart';
import 'package:fast_timer/ui/pages/timer_list_page.dart';
import 'package:fast_timer/ui/pages/timer_create_page.dart';

enum TimerState { running, paused }

class TimerRunningPage extends ConsumerStatefulWidget {
  final int timerId;
  const TimerRunningPage({super.key, required this.timerId});

  @override
  ConsumerState<TimerRunningPage> createState() => _TimerRunningPageState();
}

class _TimerRunningPageState extends ConsumerState<TimerRunningPage> {
  Timer? _timer;
  bool _isVibrating = false;
  bool _vibrationButtonDisabled = false;

  void _startVibration() async {
    if (!_isVibrating) {
      _isVibrating = true;
      Vibration.vibrate(pattern: [0, 500, 500, 500, 500, 500], repeat: 0);
      if (mounted) setState(() {});
    }
  }

  void _stopVibration() {
    if (_isVibrating && !_vibrationButtonDisabled) {
      setState(() {
        _vibrationButtonDisabled = true; // 버튼 비활성화
      });
      Vibration.cancel();
      setState(() {
        _isVibrating = false;
        // // 0.5초 후 버튼 다시 활성화(원하는 대로)
        // Future.delayed(const Duration(milliseconds: 500), () {
        //   if (mounted) setState(() => _vibrationButtonDisabled = false);
        // });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onBackPressed() {
    Navigator.of(context).pop();
  }

  Future<void> _pauseTimer(TimerItem timer) async {
    await ref
        .read(timerItemListViewModelProvider.notifier)
        .toggleTimer(timer.id!, false);
  }

  Future<void> _resumeTimer(TimerItem timer) async {
    await ref
        .read(timerItemListViewModelProvider.notifier)
        .toggleTimer(timer.id!, true);
  }

  Future<void> _resetTimer(TimerItem timer) async {
    // 진동 상태 리셋
    setState(() {
      _isVibrating = false;
      _vibrationButtonDisabled = false;
    });

    // 1. 일시정지로 현재 시간 기록
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

  Future<String?> _showFinishDialog(BuildContext context, TimerItem timer) {
    final int targetSeconds = timer.targetSeconds;
    final double speed = timer.speed;

    // 남은 시간 계산: isRunning이 아니어도 lastStartTime이 있으면 오버타임 반영
    int remaining = timer.remainingSeconds;
    // if (timer.lastStartTime != null) {
    //   final elapsed =
    //       DateTime.now().difference(timer.lastStartTime!).inMilliseconds *
    //       timer.speed;
    //   final elapsedSeconds = (elapsed / 1000).floor();
    //   remaining = timer.remainingSeconds - elapsedSeconds;
    // }

    final int realElapsedSeconds = timer.targetSeconds - remaining;
    final String timerName = timer.name;

    // 오버타임(0초 이후 더 걸린 시간)
    int overtime = realElapsedSeconds - targetSeconds;

    // diff: 목표 - 실제 (양수면 빠름, 0이면 딱 맞춤, 음수면 느림)
    int diff = targetSeconds - realElapsedSeconds;

    // 문구 결정
    String resultMessage;
    if (realElapsedSeconds > targetSeconds) {
      resultMessage = "느리게 목표를 달성했어요!";
    } else if (realElapsedSeconds == targetSeconds) {
      resultMessage = "0초 빠르게 목표를 달성했어요!";
    } else {
      resultMessage = "빠르게 목표를 달성했어요!";
    }

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
                          if (realElapsedSeconds != targetSeconds)
                            formatHMSRich(
                              (realElapsedSeconds - targetSeconds).abs(),
                            ),
                          Text(
                            resultMessage,
                            style: TextStyle(
                              color:
                                  realElapsedSeconds > targetSeconds
                                      ? AppColor.primaryRed.of(context)
                                      : AppColor.gray30.of(context),
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
                      onPressed: () {
                        Navigator.pop(ctx, true);
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

  Future<void> _deleteTimer() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
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
            title: Text(
              '타이머 삭제',
              style: TextStyle(
                color: AppColor.gray30.of(context),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
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
    if (!mounted || timer == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimerCreatePage(timerItem: timer),
      ),
    );

    if (!mounted) return;
    ref.invalidate(timerItemListViewModelProvider);
  }

  @override
  Widget build(BuildContext context) {
    final timers = ref.watch(timerItemListViewModelProvider).timers;
    final timer =
        timers.where((t) => t.id == widget.timerId).isNotEmpty
            ? timers.firstWhere((t) => t.id == widget.timerId)
            : null;

    if (timer == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      });
      return const SizedBox.shrink();
    }

    int remaining = timer.remainingSeconds;
    double progress = timer.progress;
    Duration elapsedReal = Duration.zero;
    DateTime realStartTime = timer.lastStartTime ?? DateTime.now();

    if (timer.isRunning && timer.lastStartTime != null) {
      final elapsed =
          DateTime.now().difference(timer.lastStartTime!).inMilliseconds *
          timer.speed;
      final elapsedSeconds = (elapsed / 1000).floor();
      remaining = timer.remainingSeconds - elapsedSeconds;
      progress =
          timer.targetSeconds > 0
              ? (remaining > 0 ? remaining / timer.targetSeconds : 0.0)
              : 0.0;
      elapsedReal = Duration(seconds: timer.targetSeconds - remaining);
      realStartTime = timer.lastStartTime!;
    }

    if (remaining <= 0 && !_isVibrating) {
      _startVibration();
    }
    if (remaining > 0 && _isVibrating) {
      _stopVibration();
    }

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
                          Text(
                            _formatHMS(timer.targetSeconds),
                            style: TextStyle(
                              color: AppColor.gray20.of(context),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatTime(remaining),
                            style: TextStyle(
                              color:
                                  remaining < 0
                                      ? AppColor.primaryRed.of(context)
                                      : AppColor.defaultBlack.of(context),
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
            if (_isVibrating)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton.icon(
                  icon: Icon(Icons.vibration, color: Colors.white),
                  label: Text(
                    "진동 해제",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _vibrationButtonDisabled
                            ? AppColor.gray30.of(context)
                            : Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                  ),
                  onPressed: _vibrationButtonDisabled ? null : _stopVibration,
                ),
              ),

            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:
                    timer.isRunning
                        ? [
                          _circleButton(
                            icon: Icons.refresh,
                            color: AppColor.gray30.of(context),
                            onPressed: () async {
                              _stopVibration();
                              await _resetTimer(timer);
                            },
                          ),
                          _circleButton(
                            icon: Icons.pause,
                            color: AppColor.primaryRed.of(context),
                            onPressed: () async {
                              _stopVibration();
                              await _pauseTimer(timer);
                            },
                          ),
                          _circleButton(
                            icon: Icons.stop,
                            color: AppColor.primaryOrange.of(context),
                            onPressed: () async {
                              _stopVibration();

                              final timerNow = ref
                                  .read(timerItemListViewModelProvider)
                                  .timers
                                  .firstWhere((t) => t.id == widget.timerId);

                              // 타이머가 시작되지 않은 경우 경고 메시지
                              if (!timerNow.isRunning &&
                                  timerNow.remainingSeconds ==
                                      timerNow.targetSeconds) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("타이머를 시작한 후에 종료할 수 있습니다."),
                                    backgroundColor: AppColor.primaryRed.of(
                                      context,
                                    ),
                                  ),
                                );
                                return;
                              }

                              // 일시정지(내부 시간 저장)
                              await ref
                                  .read(timerItemListViewModelProvider.notifier)
                                  .toggleTimer(widget.timerId, false);

                              // 최신 timer 객체로 다이얼로그
                              final updatedTimer = ref
                                  .read(timerItemListViewModelProvider)
                                  .timers
                                  .firstWhere((t) => t.id == widget.timerId);

                              final result = await _showFinishDialog(
                                context,
                                updatedTimer,
                              );

                              if (!mounted) return;

                              if (result == 'save') {
                                await TimerRecordDao().insert(
                                  TimerRecord(
                                    timerId: updatedTimer.id!,
                                    targetSeconds: updatedTimer.targetSeconds,
                                    speed: updatedTimer.speed,
                                    recordedSeconds:
                                        updatedTimer.targetSeconds -
                                        updatedTimer.remainingSeconds,
                                    actualSeconds:
                                        (updatedTimer.targetSeconds -
                                            updatedTimer.remainingSeconds) ~/
                                        updatedTimer.speed,
                                    startedAt:
                                        updatedTimer.lastStartTime ??
                                        DateTime.now(),
                                    endedAt: DateTime.now(),
                                  ),
                                );
                                SnackbarUtil.showToastMessage('기록이 저장되었습니다!');
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
                                SnackbarUtil.showToastMessage(
                                  '기록을 저장하지 않고 초기화되었습니다.',
                                );
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
                            },
                          ),
                        ]
                        : [
                          _circleButton(
                            icon: Icons.refresh,
                            color: AppColor.gray30.of(context),
                            onPressed: () async {
                              _stopVibration();
                              await _resetTimer(timer);
                            },
                          ),
                          _circleButton(
                            icon: Icons.play_arrow,
                            color: AppColor.primaryBlue.of(context),
                            onPressed: () async {
                              _stopVibration();
                              await _resumeTimer(timer);
                            },
                          ),
                          _circleButton(
                            icon: Icons.stop,
                            color: AppColor.primaryOrange.of(context),
                            onPressed: () async {
                              _stopVibration();

                              final timerNow = ref
                                  .read(timerItemListViewModelProvider)
                                  .timers
                                  .firstWhere((t) => t.id == widget.timerId);

                              // 타이머가 시작되지 않은 경우 경고 메시지
                              if (!timerNow.isRunning &&
                                  timerNow.remainingSeconds ==
                                      timerNow.targetSeconds) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("타이머를 시작한 후에 종료할 수 있습니다."),
                                    backgroundColor: AppColor.primaryRed.of(
                                      context,
                                    ),
                                  ),
                                );
                                return;
                              }

                              // 일시정지(내부 시간 저장)
                              await ref
                                  .read(timerItemListViewModelProvider.notifier)
                                  .toggleTimer(widget.timerId, false);

                              // 최신 timer 객체로 다이얼로그
                              final updatedTimer = ref
                                  .read(timerItemListViewModelProvider)
                                  .timers
                                  .firstWhere((t) => t.id == widget.timerId);

                              final result = await _showFinishDialog(
                                context,
                                updatedTimer,
                              );

                              if (!mounted) return;

                              if (result == 'save') {
                                await TimerRecordDao().insert(
                                  TimerRecord(
                                    timerId: updatedTimer.id!,
                                    targetSeconds: updatedTimer.targetSeconds,
                                    speed: updatedTimer.speed,
                                    recordedSeconds:
                                        updatedTimer.targetSeconds -
                                        updatedTimer.remainingSeconds,
                                    actualSeconds:
                                        (updatedTimer.targetSeconds -
                                            updatedTimer.remainingSeconds) ~/
                                        updatedTimer.speed,
                                    startedAt:
                                        updatedTimer.lastStartTime ??
                                        DateTime.now(),
                                    endedAt: DateTime.now(),
                                  ),
                                );
                                SnackbarUtil.showToastMessage('기록이 저장되었습니다!');
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
                                SnackbarUtil.showToastMessage(
                                  '기록을 저장하지 않고 초기화되었습니다.',
                                );
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

class _TimerProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  _TimerProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 12.0;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint =
        Paint()
          ..color = color.withOpacity(0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

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

String _formatTime(int seconds) {
  final isNegative = seconds < 0;
  final absSeconds = seconds.abs();

  final h = absSeconds ~/ 3600;
  final m = (absSeconds % 3600) ~/ 60;
  final s = absSeconds % 60;

  final timeStr =
      "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  return isNegative ? "-$timeStr" : timeStr;
}

String _formatHMS(int seconds) {
  final isNegative = seconds < 0;
  final absSeconds = seconds.abs();

  final h = absSeconds ~/ 3600;
  final m = (absSeconds % 3600) ~/ 60;
  final s = absSeconds % 60;

  String result = "";
  if (h > 0) result += "$h시간 ";
  if (m > 0) result += "$m분 ";
  if (s > 0) result += "$s초";
  if (result.isEmpty) result = "0초";
  return isNegative ? "-$result" : result;
}
