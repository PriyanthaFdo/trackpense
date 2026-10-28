import 'package:trackpense/core/error/failures.dart';
import 'package:trackpense/features/transactions/domain/entities/transaction.dart';

/// Abstract repository interface for transaction operations.
abstract class TransactionRepository {
  /// Creates a new transaction.
  Future<Either<Failure, void>> createTransaction(Transaction transaction);

  /// Updates an existing transaction.
  Future<Either<Failure, void>> updateTransaction(Transaction transaction);

  /// Deletes a transaction by UUID.
  Future<Either<Failure, void>> deleteTransaction(String uuid);

  /// Gets a transaction by UUID.
  Future<Either<Failure, Transaction?>> getTransaction(String uuid);

  /// Gets all transactions as a stream, newest first.
  Stream<List<Transaction>> watchAllTransactions();
}

/// Helper class for Either type (simplified version).
/// In a real app, use the dartz package or similar.
class Either<L, R> {
  const Either._(this.value, this.isLeft);

  factory Either.left(L value) => Either._(value, true);
  factory Either.right(R value) => Either._(value, false);

  final dynamic value;
  final bool isLeft;

  bool get isRight => !isLeft;

  R? get right => isRight ? value as R : null;
  L? get left => isLeft ? value as L : null;

  /// Fold the Either value.
  T fold<T>(T Function(L) ifLeft, T Function(R) ifRight) {
    return isLeft ? ifLeft(left as L) : ifRight(right as R);
  }
}
