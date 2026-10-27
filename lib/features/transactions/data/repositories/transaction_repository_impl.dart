import 'package:trackpense/core/database/database.dart';
import 'package:trackpense/core/error/failures.dart';
import 'package:trackpense/features/transactions/data/models/transaction_model.dart';
import 'package:trackpense/features/transactions/domain/entities/transaction.dart';
import 'package:trackpense/features/transactions/domain/repositories/transaction_repository.dart';

/// Implementation of TransactionRepository.
class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl(this.database);

  final AppDatabase database;

  @override
  Future<Either<Failure, void>> createTransaction(Transaction transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await database.createPayment(model.toPaymentCompanion());
      return Either.right(null);
    } catch (e, stackTrace) {
      return Either.left(
        DatabaseFailure('Failed to create transaction', e, stackTrace),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateTransaction(Transaction transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await database.updatePayment(model.toPaymentCompanion());
      return Either.right(null);
    } catch (e, stackTrace) {
      return Either.left(
        DatabaseFailure('Failed to update transaction', e, stackTrace),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String uuid) async {
    try {
      await database.deletePayment(uuid);
      return Either.right(null);
    } catch (e, stackTrace) {
      return Either.left(
        DatabaseFailure('Failed to delete transaction', e, stackTrace),
      );
    }
  }

  @override
  Future<Either<Failure, Transaction?>> getTransaction(String uuid) async {
    try {
      final payment = await database.getPayment(uuid);
      if (payment == null) {
        return Either.right(null);
      }
      final model = TransactionModel.fromPaymentData(payment);
      return Either.right(model.toEntity());
    } catch (e, stackTrace) {
      return Either.left(
        DatabaseFailure('Failed to get transaction', e, stackTrace),
      );
    }
  }

  @override
  Stream<List<Transaction>> watchAllTransactions() {
    return database.watchAllPayments().map((payments) {
      return payments
          .map((payment) => TransactionModel.fromPaymentData(payment).toEntity())
          .toList();
    });
  }
}
