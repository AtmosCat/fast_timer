import 'package:fast_timer/data/dao/timer_item_dao.dart';
import 'package:fast_timer/data/dao/timer_record_dao.dart';
import 'package:fast_timer/data/viewmodel/timer_item_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:fast_timer/theme/colors.dart';
import 'package:fast_timer/data/model/timer_item.dart';
import 'package:fast_timer/data/model/timer_record.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class TimerRecordDetailPage extends StatefulWidget {
  final TimerItem timer;
  final List<TimerRecord> records;

  const TimerRecordDetailPage({
    super.key,
    required this.timer,
    required this.records,
  });

  @override
  State<TimerRecordDetailPage> createState() => _TimerRecordDetailPageState();
}

class _TimerRecordDetailPageState extends State<TimerRecordDetailPage> {
  late List<TimerRecord> _records;

  @override
  void initState() {
    super.initState();
    // 최신순(종료시각 내림차순) 정렬
    _records = List<TimerRecord>.from(widget.records)
      ..sort((a, b) => b.endedAt.compareTo(a.endedAt));
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

  String _formatDate(DateTime dt, {bool withSec = false}) {
    return DateFormat(
      withSec ? 'yyyy.MM.dd HH:mm:ss' : 'yyyy.MM.dd HH:mm',
    ).format(dt);
  }

  Future<void> _deleteTimer(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Text(
              '타이머 삭제',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            content: const Text('이 타이머와 모든 기록을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('취소', style: TextStyle(color: Colors.black87)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('삭제', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
    if (confirm == true) {
      await TimerRecordDao().deleteByTimerId(widget.timer.id!); // 모든 기록 삭제
      await TimerItemDao().delete(widget.timer.id!); // 타이머 삭제

      // Provider invalidate로 TimerListPage에 즉시 반영
      ProviderScope.containerOf(
        context,
        listen: false,
      ).invalidate(timerItemListViewModelProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('타이머와 모든 기록이 삭제되었습니다.'),
            backgroundColor: AppColor.primaryOrange.of(context),
          ),
        );
        Navigator.of(context).pop(true); // <- true 반환
      }
    }
  }

  Future<void> _clearRecords(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Text(
              '기록 초기화',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            content: const Text('이 타이머의 모든 기록을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('취소', style: TextStyle(color: Colors.black87)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('초기화', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
    if (confirm == true) {
      await TimerRecordDao().deleteByTimerId(widget.timer.id!);

      setState(() {
        _records.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('기록이 모두 삭제되었습니다.'),
            backgroundColor: AppColor.primaryOrange.of(context),
          ),
        );
      }
    }
  }

  int get _goalSeconds =>
      widget.timer.hour * 3600 + widget.timer.minute * 60 + widget.timer.second;

  int get _avgSeconds =>
      _records.isEmpty
          ? 0
          : _records.map((r) => r.actualSeconds).reduce((a, b) => a + b) ~/
              _records.length;

  int get _bestSeconds =>
      _records.isEmpty ? 0 : _records.map((r) => r.actualSeconds).reduce(min);

  @override
  Widget build(BuildContext context) {
    final records = _records;

    return Scaffold(
      backgroundColor: AppColor.scaffoldGray.of(context),
      appBar: AppBar(
        backgroundColor: AppColor.containerWhite.of(context),
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColor.defaultBlack.of(context),
          ),
          onPressed: () => Navigator.of(context).pop(true),
        ),
        title: Text(
          widget.timer.name,
          style: TextStyle(
            color: AppColor.defaultBlack.of(context),
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: AppColor.gray20.of(context)),
            onPressed: () async {
              final selected = await showMenu<String>(
                context: context,
                position: RelativeRect.fromLTRB(1000, 80, 0, 0), // 우측 상단에 메뉴 표시
                items: [
                  const PopupMenuItem(
                    value: 'clearRecords',
                    child: Text('기록 초기화'),
                  ),
                  const PopupMenuItem(
                    value: 'deleteTimer',
                    child: Text('타이머 삭제'),
                  ),
                ],
              );
              if (selected == 'deleteTimer') {
                await _deleteTimer(context);
              } else if (selected == 'clearRecords') {
                await _clearRecords(context);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          children: [
            // 꺾은선그래프
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: AppColor.containerWhite.of(context),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: SizedBox(
                height: 180,
                child:
                    records.isEmpty
                        ? Center(
                          child: Text(
                            "기록이 없습니다.",
                            style: TextStyle(
                              color: AppColor.gray20.of(context),
                            ),
                          ),
                        )
                        : LineChart(
                          LineChartData(
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            minY: 0,
                            maxY:
                                records.isEmpty
                                    ? 10.0
                                    : records
                                            .map(
                                              (r) => r.actualSeconds.toDouble(),
                                            )
                                            .reduce((a, b) => a > b ? a : b) *
                                        1.2,
                            lineBarsData: [
                              LineChartBarData(
                                spots: [
                                  for (int i = 0; i < records.length; i++)
                                    FlSpot(
                                      i.toDouble(),
                                      records[i].actualSeconds.toDouble(),
                                    ),
                                ],
                                isCurved: true,
                                color: AppColor.primaryOrange.of(context),
                                barWidth: 4,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, bar, index) {
                                    return FlDotCirclePainter(
                                      radius: 6,
                                      color: AppColor.primaryOrange.of(context),
                                      strokeColor: Colors.white,
                                      strokeWidth: 2,
                                    );
                                  },
                                ),
                                belowBarData: BarAreaData(show: false),
                              ),
                            ],
                            lineTouchData: LineTouchData(
                              handleBuiltInTouches: true,
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipColor: (touchedSpot) => Colors.white,
                                tooltipBorderRadius: BorderRadius.circular(10),
                                tooltipPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                tooltipMargin: 8,
                                getTooltipItems: (touchedSpots) {
                                  return touchedSpots.map((spot) {
                                    final sec =
                                        records[spot.spotIndex].actualSeconds;
                                    return LineTooltipItem(
                                      _formatHMS(sec),
                                      TextStyle(
                                        color: AppColor.primaryOrange.of(
                                          context,
                                        ),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 24),
            // 목표, 평균, 최고 기록
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Image.asset(
                    'lib/assets/icons/flag.png',
                    height: 20,
                    color: AppColor.primaryOrange.of(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "목표: ${_formatHMS(_goalSeconds)}",
                    style: TextStyle(
                      color: AppColor.defaultBlack.of(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Icon(
                    Icons.show_chart,
                    color: AppColor.primaryOrange.of(context),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "평균 기록: ${_formatHMS(_avgSeconds)}",
                    style: TextStyle(
                      color: AppColor.defaultBlack.of(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: AppColor.primaryOrange.of(context),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "최고 기록: ${_formatHMS(_bestSeconds)}",
                    style: TextStyle(
                      color: AppColor.defaultBlack.of(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Image.asset(
                    'lib/assets/icons/run.png',
                    height: 18,
                    color: AppColor.primaryOrange.of(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${records.length}개의 타이머 기록",
                    style: TextStyle(
                      color: AppColor.gray30.of(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 기록 리스트
            Container(
              decoration: BoxDecoration(
                color: AppColor.containerWhite.of(context),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _records.length,
                separatorBuilder:
                    (_, __) => Divider(
                      height: 1,
                      color: AppColor.containerGray20.of(context),
                    ),
                itemBuilder: (context, idx) {
                  final rec = _records[idx];
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder:
                            (ctx) => AlertDialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              title: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: AppColor.primaryOrange.of(context),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "기록 상세",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _infoRow(
                                    "설정 시간",
                                    _formatHMS(_goalSeconds),
                                    context,
                                  ),
                                  const SizedBox(height: 6),
                                  _infoRow(
                                    "설정 배속",
                                    "x${rec.speed.toStringAsFixed(2)}",
                                    context,
                                  ),
                                  const SizedBox(height: 6),
                                  _infoRow(
                                    "시작",
                                    _formatDate(rec.startedAt, withSec: true),
                                    context,
                                  ),
                                  const SizedBox(height: 6),
                                  _infoRow(
                                    "종료",
                                    _formatDate(rec.endedAt, withSec: true),
                                    context,
                                  ),
                                  // const SizedBox(height: 6),
                                  // _infoRow(
                                  //   "기록된 시간",
                                  //   _formatHMS(rec.recordedSeconds),
                                  //   context,
                                  // ),
                                  const SizedBox(height: 6),
                                  _infoRow(
                                    "실제 소요 시간",
                                    _formatHMS(rec.actualSeconds),
                                    context,
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text(
                                    '닫기',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.vertical(
                          top:
                              idx == 0
                                  ? const Radius.circular(18)
                                  : Radius.zero,
                          bottom:
                              idx == _records.length - 1
                                  ? const Radius.circular(18)
                                  : Radius.zero,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 6,
                        ),
                        leading: Text(
                          _formatHMS(rec.actualSeconds),
                          style: TextStyle(
                            color: AppColor.defaultBlack.of(context),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        title: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _formatDate(rec.endedAt),
                            style: TextStyle(
                              color: AppColor.gray20.of(context),
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.close,
                            color: AppColor.gray20.of(context),
                          ),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder:
                                  (ctx) => AlertDialog(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    title: const Text(
                                      '기록 삭제',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    content: const Text('이 기록을 정말 삭제하시겠습니까?'),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(ctx, false),
                                        child: const Text(
                                          '취소',
                                          style: TextStyle(color: Colors.black87),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(ctx, true),
                                        child: const Text(
                                          '삭제',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                            );
                            if (confirm == true) {
                              await TimerRecordDao().delete(rec.id!);
                              setState(() {
                                _records.removeAt(idx);
                              });
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('기록이 삭제되었습니다.'),
                                    backgroundColor: AppColor.primaryOrange.of(
                                      context,
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, BuildContext context) {
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
              fontSize: 15,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: AppColor.defaultBlack.of(context),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
