import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fast_timer/theme/colors.dart';

class TimerCreatePage extends StatefulWidget {
  const TimerCreatePage({super.key});

  @override
  State<TimerCreatePage> createState() => _TimerCreatePageState();
}

class _TimerCreatePageState extends State<TimerCreatePage> {
  int _selectedHour = 1;
  int _selectedMinute = 50;
  int _selectedSecond = 0;
  final TextEditingController _nameController = TextEditingController(text: "");

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                    onPressed: () => Navigator.of(context).pop(),
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
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0), // 전체 패딩
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 18),
              // 시간 피커 라벨과 피커를 한 Row로 묶어서 정렬
              SizedBox(
                height: 250, // 원하는 높이
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 시간 피커
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
                                  (val) => setState(() => _selectedHour = val),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 콜론
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
                    // 분 피커
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
                                  (val) =>
                                      setState(() => _selectedMinute = val),
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
                    // 초 피커
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
                                  (val) =>
                                      setState(() => _selectedSecond = val),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              // 타이머 이름
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
              const Spacer(),
              // 생성 버튼
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      // 타이머 생성 로직
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryOrange.of(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "타이머 생성",
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
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerColon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Text(
        ":",
        style: TextStyle(
          color: AppColor.gray20.of(context),
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
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
