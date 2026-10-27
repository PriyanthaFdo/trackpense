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
  static const int maxNotesLength = 1000;
  static const int maxDecimalDigits = 2;

  // Date/Time
  static const int transactionEditWindowDays = 7;

  // UI
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Storage
  static const String keyTheme = 'app_theme';
  static const String keyLanguage = 'app_language';
  static const String keyFirstLaunch = 'first_launch';
}
