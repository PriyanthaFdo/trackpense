import 'package:uuid/uuid.dart';

/// Application-wide configuration constants.
class AppConfig {
  // Private constructor to prevent instantiation
  AppConfig._();

  // Database
  static const String databaseName = 'trackpense.db';
  static const uuid = Uuid();

  // Validation
  static const int maxDescriptionLength = 200;
  static const int maxDecimalDigits = 2;

  // Date/Time
  static const int transactionEditWindowDays = 7;
}
