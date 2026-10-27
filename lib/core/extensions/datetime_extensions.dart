import 'package:intl/intl.dart';

extension KbDateTimeFormatting on DateTime {
  String format({String format = 'd/MMM/yyyy HH:mm:ss'}) {
    final DateFormat dateFormat = DateFormat(format);
    return dateFormat.format(this);
  }
}
