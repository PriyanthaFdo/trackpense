/// Validator for date values.
class DateValidator {
  /// Validates that a date is not in the future.
  static String? validateNotInFuture(DateTime? date) {
    if (date == null) {
      return 'Date is required';
    }

    final now = DateTime.now();
    if (date.isAfter(now)) {
      return 'Date cannot be in the future';
    }

    return null;
  }

  /// Validates that a date is not too far in the past.
  static String? validateNotTooOld(DateTime? date, {int maxDays = 365}) {
    if (date == null) {
      return 'Date is required';
    }

    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > maxDays) {
      return 'Date cannot be more than $maxDays days in the past';
    }

    return null;
  }

  /// Validates that a date is within the editable window.
  static String? validateEditableWindow(DateTime? date, {int days = 7}) {
    if (date == null) {
      return 'Date is required';
    }

    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > days) {
      return 'This transaction can no longer be edited (more than $days days old)';
    }

    return null;
  }
}
