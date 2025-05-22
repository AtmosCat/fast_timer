import 'package:intl/intl.dart';

class NumberUtils {
  static String formatWithCommas(double number) {
    final formatter = NumberFormat("#,##0.##"); // 소수점 2자리까지 표시
    return formatter.format(number);
  }

  static String formatPercentage(double value) {
    String percentage = (value * 100).toStringAsFixed(1);
    if (value > 0) {
      return '+$percentage%';
    } else if (value < 0) {
      return '$percentage%';
    } else {
      return '0.0%';
    }
  }
}
