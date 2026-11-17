import 'package:trackpense/features/transactions/domain/usecases/create_transaction.dart';
import 'package:trackpense/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:trackpense/features/transactions/domain/usecases/update_transaction.dart';
import 'package:trackpense/features/transactions/domain/usecases/watch_transactions.dart';
import 'package:trackpense/features/transactions/presentation/blocs/transaction_bloc.dart';

import 'fake_transaction_repository.dart';

/// A [TransactionBloc] wired to real use cases over [repository].
TransactionBloc buildTransactionBloc(FakeTransactionRepository repository) {
  return TransactionBloc(
    createTransaction: CreateTransaction(repository),
    updateTransaction: UpdateTransaction(repository),
    deleteTransaction: DeleteTransaction(repository),
    watchTransactions: WatchTransactions(repository),
  );
}
