/// Base class for all exceptions in the application.
///
/// Exceptions are thrown by the data layer and caught by repositories,
/// which then convert them to [Failure] objects.
abstract class AppException implements Exception {
  const AppException(this.message, [this.error, this.stackTrace]);

  final String message;
  final dynamic error;
  final StackTrace? stackTrace;

  @override
  String toString() => 'AppException: $message';
}

/// Exception representing server-related errors.
class ServerException extends AppException {
  const ServerException(super.message, [super.error, super.stackTrace]);
}

/// Exception representing database-related errors.
class DatabaseException extends AppException {
  const DatabaseException(super.message, [super.error, super.stackTrace]);
}

/// Exception representing network connectivity errors.
class NetworkException extends AppException {
  const NetworkException(super.message, [super.error, super.stackTrace]);
}

/// Exception representing input validation errors.
class ValidationException extends AppException {
  const ValidationException(super.message, [super.error, super.stackTrace]);
}

/// Exception representing cache-related errors.
class CacheException extends AppException {
  const CacheException(super.message, [super.error, super.stackTrace]);
}

/// Exception representing unknown or unexpected errors.
class UnknownException extends AppException {
  const UnknownException(super.message, [super.error, super.stackTrace]);
}

/// Exception representing permission-related errors.
class PermissionException extends AppException {
  const PermissionException(super.message, [super.error, super.stackTrace]);
}

/// Exception representing file system errors.
class FileSystemException extends AppException {
  const FileSystemException(super.message, [super.error, super.stackTrace]);
}
