import 'package:intl/intl.dart';

class PercentFormatter {
  PercentFormatter._();

  static String format(double value) {
    final formatted = NumberFormat('+0.00%;-0.00%').format(value / 100);
    return formatted;
  }

  static bool isPositive(double value) => value >= 0;
}
