import 'package:trackpense/features/transactions/domain/entities/transaction.dart';
import 'package:trackpense/features/transactions/domain/repositories/transaction_repository.dart';

/// Use case for watching all transactions.
class WatchTransactions {
  const WatchTransactions(this.repository);

  final TransactionRepository repository;

  Stream<List<Transaction>> call() {
    return repository.watchAllTransactions();
  }
}
