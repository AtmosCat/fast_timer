import 'package:fast_timer/data/dao/timer_item_dao.dart';
import 'package:fast_timer/data/model/timer_item.dart';
import 'package:fast_timer/data/repository/timer_item_repository.dart';
import 'package:fast_timer/data/viewmodel/timer_item_viewmodel.dart';
import 'package:fast_timer/ui/ads/banner_ad_widget.dart';
import 'package:fast_timer/ui/pages/timer_list_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fast_timer/theme/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimerCreatePage extends StatefulWidget {
  final TimerItem? timerItem; // 추가

  const TimerCreatePage({super.key, this.timerItem});

  @override
  State<TimerCreatePage> createState() => _TimerCreatePageState();
}

class _TimerCreatePageState extends State<TimerCreatePage> {
  late int _selectedHour;
  late int _selectedMinute;
  late int _selectedSecond;
  late double _speed;
  final TextEditingController _nameController = TextEditingController();

  double min = 1.0;
  double max = 3.0;

  final labelValues = [1.0, 2.0, 3.0];

  late final TimerItemRepository _timerItemRepository;

  @override
  void initState() {
    super.initState();
    _timerItemRepository = TimerItemRepository(TimerItemDao());
    if (widget.timerItem != null) {
      _nameController.text = widget.timerItem!.name;
      _selectedHour = widget.timerItem!.targetSeconds ~/ 3600;
      _selectedMinute = (widget.timerItem!.targetSeconds % 3600) ~/ 60;
      _selectedSecond = widget.timerItem!.targetSeconds % 60;
      _speed = widget.timerItem!.speed;
    } else {
      _selectedHour = 1;
      _selectedMinute = 50;
      _selectedSecond = 0;
      _speed = 1.0;
    }
  }

  void _onSavePressed() async {
    final timerName = _nameController.text.trim();
    final totalSeconds =
        _selectedHour * 3600 + _selectedMinute * 60 + _selectedSecond;

    if (timerName.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("타이머 이름을 입력해 주세요."),
          backgroundColor: AppColor.containerGray30.of(context),
        ),
      );
      return;
    }
    if (totalSeconds == 0) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("타이머 시간을 1초 이상으로 설정해 주세요."),
          backgroundColor: AppColor.containerGray30.of(context),
        ),
      );
      return;
    }

    if (widget.timerItem != null) {
      // 수정 모드
      final updatedTimer = widget.timerItem!.copyWith(
        name: timerName,
        targetSeconds: totalSeconds,
        speed: _speed,
        remainingSeconds: totalSeconds,
        isRunning: false,
        progress: 1.0,
        lastStartTime: null,
      );
      await _timerItemRepository.update(updatedTimer);

      // Provider invalidate를 Navigator 이동 전에 반드시 호출!
      if (!context.mounted) return;
      final container = ProviderScope.containerOf(context, listen: false);
      container.invalidate(timerItemListViewModelProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("타이머가 수정되었습니다."),
          backgroundColor: AppColor.primaryOrange.of(context),
        ),
      );

      // 이제 Navigator 이동
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const TimerListPage()),
        (route) => false,
      );
    } else {
      // 생성 모드
      final timerItem = TimerItem(
        name: timerName,
        speed: _speed,
        targetSeconds: totalSeconds,
        remainingSeconds: totalSeconds,
        isRunning: false,
        progress: 1.0,
        lastStartTime: null,
      );
      await _timerItemRepository.add(timerItem);

      // Provider invalidate를 Navigator 이동 전에 반드시 호출!
      if (!context.mounted) return;
      final container = ProviderScope.containerOf(context, listen: false);
      container.invalidate(timerItemListViewModelProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("타이머가 생성되었습니다."),
          backgroundColor: AppColor.primaryOrange.of(context),
        ),
      );

      // 이제 Navigator 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TimerListPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.timerItem != null;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.scaffoldGray.of(context),
        bottomNavigationBar: const BannerAdWidget(),
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
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  Text(
                    "타이머 생성",
                    style: TextStyle(
                      color: AppColor.defaultBlack.of(context),
                      fontSize: 20,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: AppColor.gray30.of(context),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
        // --- 여기부터 수정 ---
        body: SafeArea(
          child: SingleChildScrollView(
            // 키보드가 올라와도 스크롤 가능!
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      kToolbarHeight, // 앱바 높이만큼 빼기
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 350,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "시간",
                                    style: TextStyle(
                                      color: AppColor.gray20.of(context),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: _TimePicker(
                                      value: _selectedHour,
                                      max: 23,
                                      onSelectedItemChanged:
                                          (val) => setState(
                                            () => _selectedHour = val,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: Text(
                                "\n:",
                                style: TextStyle(
                                  color: AppColor.gray20.of(context),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "분",
                                    style: TextStyle(
                                      color: AppColor.gray20.of(context),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: _TimePicker(
                                      value: _selectedMinute,
                                      max: 59,
                                      onSelectedItemChanged:
                                          (val) => setState(
                                            () => _selectedMinute = val,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: Text(
                                "\n:",
                                style: TextStyle(
                                  color: AppColor.gray20.of(context),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "초",
                                    style: TextStyle(
                                      color: AppColor.gray20.of(context),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: _TimePicker(
                                      value: _selectedSecond,
                                      max: 59,
                                      onSelectedItemChanged:
                                          (val) => setState(
                                            () => _selectedSecond = val,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "타이머 이름",
                        style: TextStyle(
                          color: AppColor.gray30.of(context),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        style: TextStyle(
                          color: AppColor.defaultBlack.of(context),
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: "예시: 중간고사 대비",
                          hintStyle: TextStyle(
                            color: AppColor.gray10.of(context),
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                          filled: true,
                          fillColor: AppColor.containerWhite.of(context),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColor.primaryOrange.of(context),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
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
                      Column(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 5,
                              activeTrackColor: AppColor.primaryOrange.of(
                                context,
                              ),
                              inactiveTrackColor: AppColor.containerLightGray20
                                  .of(context),
                              thumbColor: AppColor.primaryOrange.of(context),
                              overlayColor: AppColor.primaryOrange
                                  .of(context)
                                  .withOpacity(0.15),
                              valueIndicatorColor: AppColor.primaryOrange.of(
                                context,
                              ),
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
                              divisions:
                                  ((max - min) / 0.1).round(), // 0.1 단위로 분할
                              label:
                                  "x${_speed.toStringAsFixed(1)}", // 소수점 1자리 표시
                              value: _speed,
                              onChanged: (val) {
                                setState(() {
                                  // 0.1 단위로 반올림
                                  _speed = (val * 10).round() / 10.0;
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
                      const Spacer(),
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _onSavePressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primaryOrange.of(
                                context,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              isEdit ? "타이머 수정" : "타이머 생성",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 70),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // --- 여기까지 수정 ---
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  final int value;
  final int max;
  final ValueChanged<int> onSelectedItemChanged;

  const _TimePicker({
    required this.value,
    required this.max,
    required this.onSelectedItemChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker(
      scrollController: FixedExtentScrollController(initialItem: value),
      itemExtent: 36,
      onSelectedItemChanged: onSelectedItemChanged,
      magnification: 1.15,
      squeeze: 1.2,
      useMagnifier: true,
      selectionOverlay: Container(), // 기본 selection overlay 제거
      children: List.generate(max + 1, (index) {
        final isSelected = index == value;
        return Center(
          child: Text(
            index.toString().padLeft(2, '0'),
            style: TextStyle(
              color:
                  isSelected
                      ? AppColor.defaultBlack.of(context)
                      : AppColor.gray20.of(context),
              fontSize: isSelected ? 24 : 17,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      }),
    );
  }
}
