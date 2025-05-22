import 'package:fast_timer/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatetimeUtils {
  static String getFormattedDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  static String getFormattedTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  static String getFormattedDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  // DatePicker 호출 함수
  static Future<DateTime?> selectDate(
      {required BuildContext context, DateTime? initialDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: '날짜를 선택하세요',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColor.primaryBlue.of(context), // 주요 색상 (선택 사항)
            colorScheme:
                ColorScheme.light(primary: AppColor.primaryBlue.of(context)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    return picked;
  }
}
