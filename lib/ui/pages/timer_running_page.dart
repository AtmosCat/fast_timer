import 'dart:async';
import 'dart:math';
import 'package:fast_timer/data/dao/timer_record_dao.dart';
import 'package:fast_timer/data/model/timer_record.dart';
import 'package:fast_timer/ui/pages/timer_list_page.dart';
import 'package:fast_timer/ui/pages/timer_start_page.dart';
import 'package:flutter/material.dart';
import 'package:fast_timer/theme/colors.dart';

enum TimerState { running, paused }

class TimerRunningPage extends StatefulWidget {
  final int timerId;
  final String timerName;
  final int targetSeconds;
  final double speed; // 배속

  const TimerRunningPage({
    super.key,
    required this.timerId,
    required this.timerName,
    required this.targetSeconds,
    required this.speed,
  });

  @override
  State<TimerRunningPage> createState() => _TimerRunningPageState();
}

class _TimerRunningPageState extends State<TimerRunningPage> {
  late int _remainingSeconds;
  late double _progress;
  Timer? _timer;
  late DateTime _realStartTime;
  Duration _elapsedReal = Duration.zero;

  TimerState _timerState = TimerState.running;

  @override
  void initState() {
    super.initState();
    _resetTimer();
    _startTimer();
  }

  void _resetTimer() {
    _remainingSeconds = widget.targetSeconds;
    _progress = 1.0;
    _elapsedReal = Duration.zero;
    _realStartTime = DateTime.now();
    _timerState = TimerState.running;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _elapsedReal = DateTime.now().difference(_realStartTime);
        final elapsed = _elapsedReal.inMilliseconds * widget.speed;
        final elapsedSeconds = (elapsed / 1000).floor();
        _remainingSeconds = max(widget.targetSeconds - elapsedSeconds, 0);
        _progress = _remainingSeconds / widget.targetSeconds;

        if (_remainingSeconds <= 0) {
          _timer?.cancel();
          _progress = 0.0;
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _timerState = TimerState.paused;
    });
  }

  void _resumeTimer() {
    setState(() {
      _realStartTime = DateTime.now().subtract(
        Duration(
          milliseconds:
              ((widget.targetSeconds - _remainingSeconds) *
                  1000 ~/
                  widget.speed),
        ),
      );
      _timerState = TimerState.running;
    });
    _startTimer();
  }

  Future<String?> _showFinishDialog(BuildContext context) {
    final int targetSeconds = widget.targetSeconds;
    final double speed = widget.speed;
    final int recordedSeconds = widget.targetSeconds - _remainingSeconds;
    final int realElapsedSeconds = _elapsedReal.inSeconds;
    final String timerName = widget.timerName;

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
                  onPressed: () => Navigator.pop(ctx, 'paused'), // 닫기: 다시 진행
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return "${h.toString().padLeft(1, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
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
                // const Spacer(),
                // Icon(Icons.more_vert, color: AppColor.gray30.of(context)),
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
                child: SizedBox(
                  width: 260,
                  height: 260,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(260, 260),
                        painter: _TimerProgressPainter(
                          progress: _progress,
                          color: AppColor.primaryOrange.of(context),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 목표 시간
                          Text(
                            _formatTime(widget.targetSeconds),
                            style: TextStyle(
                              color: AppColor.gray20.of(context),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 남은 시간
                          Text(
                            _formatTime(_remainingSeconds),
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
                    _timerState == TimerState.running
                        ? [
                          // 초기화
                          _circleButton(
                            icon: Icons.refresh,
                            color: AppColor.gray30.of(context),
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder:
                                      (_) => TimerStartPage(
                                        timerId: widget.timerId,
                                        timerName: widget.timerName,
                                        targetSeconds: widget.targetSeconds,
                                      ),
                                ),
                                (route) => false,
                              );
                            },
                          ),
                          // 일시정지
                          _circleButton(
                            icon: Icons.pause,
                            color: AppColor.primaryRed.of(context),
                            onPressed: _pauseTimer,
                          ),
                          // 종료
                          _circleButton(
                            icon: Icons.stop,
                            color: AppColor.primaryOrange.of(context),
                            onPressed: () async {
                              _pauseTimer(); // 타이머를 정지 상태로
                              final result = await _showFinishDialog(context);
                              if (!mounted) return;

                              if (result == 'save') {
                                // DB에 기록 저장 (예시)
                                await TimerRecordDao().insert(
                                  TimerRecord(
                                    timerId: widget.timerId,
                                    targetSeconds: widget.targetSeconds,
                                    speed: widget.speed,
                                    recordedSeconds:
                                        widget.targetSeconds -
                                        _remainingSeconds,
                                    actualSeconds: _elapsedReal.inSeconds,
                                    startedAt: _realStartTime,
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
                                // TimerStartPage로 이동
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => TimerStartPage(
                                          timerId: widget.timerId,
                                          timerName: widget.timerName,
                                          targetSeconds: widget.targetSeconds,
                                        ),
                                  ),
                                  (route) => false,
                                );
                              } else if (result == 'delete' || result == null) {
                                // 저장 안 함 → TimerStartPage로 이동
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => TimerStartPage(
                                          timerId: widget.timerId,
                                          timerName: widget.timerName,
                                          targetSeconds: widget.targetSeconds,
                                        ),
                                  ),
                                  (route) => false,
                                );
                              } 
                            },
                          ),
                        ]
                        : [
                          // 초기화
                          _circleButton(
                            icon: Icons.refresh,
                            color: AppColor.gray30.of(context),
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder:
                                      (_) => TimerStartPage(
                                        timerId: widget.timerId,
                                        timerName: widget.timerName,
                                        targetSeconds: widget.targetSeconds,
                                      ),
                                ),
                                (route) => false,
                              );
                            },
                          ),

                          // 계속
                          _circleButton(
                            icon: Icons.play_arrow,
                            color: AppColor.primaryBlue.of(context),
                            onPressed: _resumeTimer,
                          ),
                          // 종료
                          _circleButton(
                            icon: Icons.stop,
                            color: AppColor.primaryOrange.of(context),
                            onPressed: () async {
                              _pauseTimer(); // 타이머를 정지 상태로
                              final result = await _showFinishDialog(context);
                              if (!mounted) return;

                              if (result == 'save') {
                                // DB에 기록 저장 (예시)
                                await TimerRecordDao().insert(
                                  TimerRecord(
                                    timerId: widget.timerId,
                                    targetSeconds: widget.targetSeconds,
                                    speed: widget.speed,
                                    recordedSeconds:
                                        widget.targetSeconds -
                                        _remainingSeconds,
                                    actualSeconds: _elapsedReal.inSeconds,
                                    startedAt: _realStartTime,
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
                                // TimerStartPage로 이동
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => TimerStartPage(
                                          timerId: widget.timerId,
                                          timerName: widget.timerName,
                                          targetSeconds: widget.targetSeconds,
                                        ),
                                  ),
                                  (route) => false,
                                );
                              } else if (result == 'delete' || result == null) {
                                // 저장 안 함 → TimerStartPage로 이동
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => TimerStartPage(
                                          timerId: widget.timerId,
                                          timerName: widget.timerName,
                                          targetSeconds: widget.targetSeconds,
                                        ),
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
