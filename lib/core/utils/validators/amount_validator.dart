import 'package:trackpense/core/config/app_config.dart';

/// Validator for amount values.
class AmountValidator {
  /// Validates an amount value.
  ///
  /// Returns null if valid, otherwise returns an error message.
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }

    final cleanValue = value.replaceAll(',', '').trim();
    final amount = double.tryParse(cleanValue);

    if (amount == null) {
      return 'Please enter a valid amount';
    }

    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }

    // Check decimal places
    if (cleanValue.contains('.')) {
      final decimalPart = cleanValue.split('.')[1];
      if (decimalPart.length > AppConfig.maxDecimalDigits) {
        return 'Amount cannot have more than ${AppConfig.maxDecimalDigits} decimal places';
      }
    }

    return null;
  }

  /// Validates an amount as a double.
  static String? validateDouble(double? value) {
    if (value == null) {
      return 'Amount is required';
    }

    if (value <= 0) {
      return 'Amount must be greater than 0';
    }

    return null;
  }
}
