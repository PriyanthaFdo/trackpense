import 'package:trackpense/core/error/failures.dart';
import 'package:trackpense/features/transactions/domain/entities/transaction.dart';
import 'package:trackpense/features/transactions/domain/repositories/transaction_repository.dart';

/// Use case for creating a new transaction.
class CreateTransaction {
  const CreateTransaction(this.repository);

  final TransactionRepository repository;

  Future<Either<Failure, void>> call(Transaction transaction) {
    return repository.createTransaction(transaction);
  }
}
