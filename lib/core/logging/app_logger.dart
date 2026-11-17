import 'dart:developer';

/// Log level enum.
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// Application logger service.
class AppLogger {
  static LogLevel _currentLevel = LogLevel.debug;
  static bool _enabled = true;

  /// Sets the minimum log level.
  static void setLogLevel(LogLevel level) {
    _currentLevel = level;
  }

  /// Enables or disables logging.
  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Logs a debug message.
  static void debug(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, error: error, stackTrace: stackTrace);
  }

  /// Logs an info message.
  static void info(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, error: error, stackTrace: stackTrace);
  }

  /// Logs a warning message.
  static void warning(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, error: error, stackTrace: stackTrace);
  }

  /// Logs an error message.
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, error: error, stackTrace: stackTrace);
  }

  static void _log(LogLevel level, String message, {Object? error, StackTrace? stackTrace}) {
    if (!_enabled || level.index < _currentLevel.index) {
      return;
    }

    final levelString = level.name.toUpperCase();
    final timestamp = DateTime.now().toIso8601String();

    log(
      '[$timestamp] [$levelString] $message',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Logs an exception.
  static void exception(
    String message,
    dynamic exception, [
    StackTrace? stackTrace,
  ]) {
    error(message, error: exception, stackTrace: stackTrace);
  }

  /// Logs a BLoC event.
  static void blocEvent(String blocName, String eventName, Object? data) {
    debug('BLoC Event: $blocName.$eventName ${data != null ? "with data: $data" : ""}');
  }

  /// Logs a BLoC state change.
  static void blocState(String blocName, String stateName, Object? data) {
    debug('BLoC State: $blocName.$stateName ${data != null ? "with data: $data" : ""}');
  }

  /// Logs a navigation event.
  static void navigation(String from, String to) {
    info('Navigation: $from -> $to');
  }

  /// Logs an API call.
  static void apiCall(String method, String url, {Map<String, dynamic>? params}) {
    info('API Call: $method $url ${params != null ? "with params: $params" : ""}');
  }

  /// Logs a database operation.
  static void database(String operation, String table, {Object? data}) {
    debug('Database: $operation on $table ${data != null ? "with data: $data" : ""}');
  }
}
