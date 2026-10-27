import 'package:intl/intl.dart';
import 'package:trackpense/core/config/app_config.dart';

/// Helper class for currency operations.
class CurrencyHelper {
  static final _currencyFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: AppConfig.maxDecimalDigits,
  );

  /// Formats a double as a currency string.
  static String formatCurrency(double amount, {String? symbol}) {
    if (symbol != null) {
      final format = NumberFormat.currency(
        symbol: symbol,
        decimalDigits: AppConfig.maxDecimalDigits,
      );
      return format.format(amount);
    }
    return _currencyFormat.format(amount);
  }

  /// Formats a double as a number string with commas.
  static String formatNumber(double amount, {int decimalDigits = AppConfig.maxDecimalDigits}) {
    final format = NumberFormat('#,##0.${'0' * decimalDigits}');
    return format.format(amount);
  }

  /// Parses a string to a double, handling commas.
  static double parseStringToDouble(String value) {
    final clean = value.replaceAll(',', '').trim();
    return double.tryParse(clean) ?? 0.0;
  }

  /// Formats a double as a comma-separated string.
  static String formatToCommaString(double amount, {int decimalDigits = AppConfig.maxDecimalDigits}) {
    return formatNumber(amount, decimalDigits: decimalDigits);
  }

  /// Checks if a string is a valid currency amount.
  static bool isValidCurrency(String value) {
    final clean = value.replaceAll(',', '').trim();
    return double.tryParse(clean) != null;
  }

  /// Formats an amount for display with appropriate sign.
  static String formatWithSign(double amount, {bool isExpense = true}) {
    final formatted = formatCurrency(amount.abs());
    return isExpense ? '-$formatted' : '+$formatted';
  }
}
