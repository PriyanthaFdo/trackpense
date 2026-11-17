/// Base class for all failures in the application.
///
/// Failures represent errors that occur during use case execution
/// and are returned to the presentation layer for user-facing error handling.
abstract class Failure {
  const Failure(this.message, [this.error, this.stackTrace]);

  final String message;
  final dynamic error;
  final StackTrace? stackTrace;

  @override
  String toString() => 'Failure: $message';
}

/// Failure representing server-related errors.
class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.error, super.stackTrace]);
}

/// Failure representing database-related errors.
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, [super.error, super.stackTrace]);
}

/// Failure representing network connectivity errors.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.error, super.stackTrace]);
}

/// Failure representing input validation errors.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.error, super.stackTrace]);
}

/// Failure representing cache-related errors.
class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.error, super.stackTrace]);
}

/// Failure representing unknown or unexpected errors.
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, [super.error, super.stackTrace]);
}

/// Failure representing permission-related errors.
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, [super.error, super.stackTrace]);
}

/// Failure representing file system errors.
class FileSystemFailure extends Failure {
  const FileSystemFailure(super.message, [super.error, super.stackTrace]);
}
