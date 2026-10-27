import 'package:trackpense/core/config/app_config.dart';

/// Validator for description values.
class DescriptionValidator {
  /// Validates a description value.
  /// 
  /// Returns null if valid, otherwise returns an error message.
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Description is required';
    }

    if (value.trim().isEmpty) {
      return 'Description cannot be empty';
    }

    if (value.length > AppConfig.maxDescriptionLength) {
      return 'Description cannot exceed ${AppConfig.maxDescriptionLength} characters';
    }

    return null;
  }

  /// Validates a description value (optional).
  static String? validateOptional(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.trim().isEmpty) {
      return 'Description cannot be empty';
    }

    if (value.length > AppConfig.maxDescriptionLength) {
      return 'Description cannot exceed ${AppConfig.maxDescriptionLength} characters';
    }

    return null;
  }
}
