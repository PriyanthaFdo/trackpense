import 'package:intl/intl.dart';

/// Helper class for date operations.
class DateHelper {
  /// Formats a date to a readable string.
  static String formatDate(DateTime date, {String format = 'dd/MMM/yyyy'}) {
    return DateFormat(format).format(date);
  }

  /// Formats a date to a time string.
  static String formatTime(DateTime date, {String format = 'hh:mm a'}) {
    return DateFormat(format).format(date);
  }

  /// Formats a date to a date and time string.
  static String formatDateTime(DateTime date, {String format = 'dd/MMM/yyyy hh:mm a'}) {
    return DateFormat(format).format(date);
  }

  /// Formats a date to a day name.
  static String formatDayName(DateTime date) {
    return DateFormat('E').format(date);
  }

  /// Formats a date to a month name.
  static String formatMonthName(DateTime date) {
    return DateFormat('MMMM').format(date);
  }

  /// Gets the start of the day.
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Gets the end of the day.
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Gets the start of the week.
  static DateTime startOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - DateTime.monday));
  }

  /// Gets the end of the week.
  static DateTime endOfWeek(DateTime date) {
    return date.add(Duration(days: DateTime.daysPerWeek - date.weekday));
  }

  /// Gets the start of the month.
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month);
  }

  /// Gets the end of the month.
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  /// Checks if two dates are the same day.
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// Checks if a date is today.
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// Checks if a date is yesterday.
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  /// Gets a relative date string (e.g., "Today", "Yesterday", "2 days ago").
  static String getRelativeDateString(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (isToday(date)) {
      return 'Today';
    } else if (isYesterday(date)) {
      return 'Yesterday';
    } else if (difference.inDays == 2) {
      return '2 days ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else {
      return '${(difference.inDays / 365).floor()} years ago';
    }
  }
}
