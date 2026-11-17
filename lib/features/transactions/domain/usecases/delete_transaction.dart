import 'package:trackpense/core/error/failures.dart';
import 'package:trackpense/features/transactions/domain/repositories/transaction_repository.dart';

/// Use case for deleting a transaction.
class DeleteTransaction {
  const DeleteTransaction(this.repository);

  final TransactionRepository repository;

  Future<Either<Failure, void>> call(String uuid) {
    return repository.deleteTransaction(uuid);
  }
}
