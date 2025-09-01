import 'package:intl/intl.dart';

extension DoubleExtensions on double {
  String toCommaString({int decimalDigits = 2}) {
    final formatter = NumberFormat('#,##0.${'0' * decimalDigits}');
    return formatter.format(this);
  }
}
