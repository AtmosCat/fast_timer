import 'package:fast_timer/ui/pages/timer_record_detail_page.dart';
import 'package:fast_timer/ui/pages/widgets/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:fast_timer/theme/colors.dart';
import 'package:fast_timer/data/model/timer_item.dart';
import 'package:fast_timer/data/model/timer_record.dart';
import 'package:fast_timer/data/dao/timer_item_dao.dart';
import 'package:fast_timer/data/dao/timer_record_dao.dart';

class TimerRecordListPage extends StatefulWidget {
  const TimerRecordListPage({super.key});

  @override
  State<TimerRecordListPage> createState() => _TimerRecordListPageState();
}

class _TimerRecordListPageState extends State<TimerRecordListPage> {
  late Future<List<_TimerWithRecords>> _timerWithRecordsFuture;

  @override
  void initState() {
    super.initState();
    _timerWithRecordsFuture = _loadTimersWithRecords();
  }

  Future<List<_TimerWithRecords>> _loadTimersWithRecords() async {
    final timerItems = await TimerItemDao().getAll();
    final timerRecords = await TimerRecordDao().getAll();

    // 타이머별로 기록 개수 매핑
    return timerItems.map((timer) {
      final records = timerRecords.where((r) => r.timerId == timer.id).toList();
      return _TimerWithRecords(timer, records);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldGray.of(context),
      appBar: AppBar(
        backgroundColor: AppColor.containerWhite.of(context),
        elevation: 1,
        title: Text(
          '타이머 기록',
          style: TextStyle(
            color: AppColor.defaultBlack.of(context),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.menu, color: AppColor.defaultBlack.of(context)),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<_TimerWithRecords>>(
          future: _timerWithRecordsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('기록을 불러올 수 없습니다.'));
            }
            final list = snapshot.data ?? [];
            if (list.isEmpty) {
              return Center(
                child: Text(
                  '저장된 타이머 기록이 없습니다.',
                  style: TextStyle(
                    color: AppColor.gray20.of(context),
                    fontSize: 16,
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final timer = list[index].timer;
                final records = list[index].records;
                return _TimerRecordCard(
                  timer: timer,
                  recordCount: records.length,
                  // itemBuilder 내부
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => TimerRecordDetailPage(
                              timer: timer,
                              records: records,
                            ),
                      ),
                    );
                    if (result == true) {
                      // 삭제 등 변경이 있었으면 새로고침
                      setState(() {
                        _timerWithRecordsFuture = _loadTimersWithRecords();
                      });
                    }
                  },
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(activeIndex: 1),
    );
  }
}

// 타이머+기록 묶음 클래스
class _TimerWithRecords {
  final TimerItem timer;
  final List<TimerRecord> records;
  _TimerWithRecords(this.timer, this.records);
}

// 카드 위젯
class _TimerRecordCard extends StatelessWidget {
  final TimerItem timer;
  final int recordCount;
  final VoidCallback onTap;

  const _TimerRecordCard({
    super.key,
    required this.timer,
    required this.recordCount,
    required this.onTap,
  });

  String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return " ${h.toString().padLeft(1, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.containerWhite.of(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Row(
            children: [
              // 좌측 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목
                    Text(
                      timer.name,
                      style: TextStyle(
                        color: AppColor.defaultBlack.of(context),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 목표 시간
                    Row(
                      children: [
                        Image.asset(
                          'lib/assets/icons/flag.png',
                          height: 24,
                          color: AppColor.defaultBlack.of(context),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _formatHMS(timer.targetSeconds),
                          style: TextStyle(
                            color: AppColor.defaultBlack.of(context),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // 기록 개수
                    Row(
                      children: [
                        Image.asset(
                          'lib/assets/icons/run.png',
                          height: 24,
                          color: AppColor.defaultBlack.of(context),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          " $recordCount개의 기록",
                          style: TextStyle(
                            color: AppColor.defaultBlack.of(context),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 우측 화살표
              GestureDetector(
                onTap: onTap,
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: AppColor.gray20.of(context),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
