import 'package:trackpense/core/error/exceptions.dart';
import 'package:trackpense/core/error/failures.dart';

/// Utility class for handling errors and converting exceptions to failures.
class ErrorHandler {
  /// Converts an [AppException] to the corresponding [Failure].
  static Failure handleException(AppException exception) {
    switch (exception) {
      case ServerException _:
        return ServerFailure(exception.message, exception.error, exception.stackTrace);
      case DatabaseException _:
        return DatabaseFailure(exception.message, exception.error, exception.stackTrace);
      case NetworkException _:
        return NetworkFailure(exception.message, exception.error, exception.stackTrace);
      case ValidationException _:
        return ValidationFailure(exception.message, exception.error, exception.stackTrace);
      case CacheException _:
        return CacheFailure(exception.message, exception.error, exception.stackTrace);
      case PermissionException _:
        return PermissionFailure(exception.message, exception.error, exception.stackTrace);
      case FileSystemException _:
        return FileSystemFailure(exception.message, exception.error, exception.stackTrace);
      default:
        return UnknownFailure(exception.message, exception.error, exception.stackTrace);
    }
  }

  /// Handles any exception and converts it to a [Failure].
  static Failure handleAnyException(dynamic exception, [StackTrace? stackTrace]) {
    if (exception is AppException) {
      return handleException(exception);
    }
    
    return UnknownFailure(
      exception.toString(),
      exception,
      stackTrace,
    );
  }

  /// Returns a user-friendly message for a given [Failure].
  static String getUserMessage(Failure failure) {
    switch (failure) {
      case ServerFailure _:
        return 'Server error occurred. Please try again later.';
      case DatabaseFailure _:
        return 'Database error occurred. Please try again.';
      case NetworkFailure _:
        return 'Network error. Please check your internet connection.';
      case ValidationFailure _:
        return failure.message;
      case CacheFailure _:
        return 'Cache error occurred. Please try again.';
      case PermissionFailure _:
        return 'Permission denied. Please grant the required permissions.';
      case FileSystemFailure _:
        return 'File system error occurred. Please try again.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
