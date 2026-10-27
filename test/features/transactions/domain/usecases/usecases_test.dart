import 'package:flutter_test/flutter_test.dart';
import 'package:trackpense/features/transactions/domain/usecases/create_transaction.dart';
import 'package:trackpense/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:trackpense/features/transactions/domain/usecases/update_transaction.dart';
import 'package:trackpense/features/transactions/domain/usecases/watch_transactions.dart';

import '../../../../helpers/fake_transaction_repository.dart';
import '../../../../helpers/transaction_fixtures.dart';

// The use cases are thin pass-throughs today. These tests pin that each one
// delegates to the right repository method, so business rules can be added
// to them later with a safety net.
void main() {
  late FakeTransactionRepository repository;

  setUp(() => repository = FakeTransactionRepository());
  tearDown(() => repository.dispose());

  test('CreateTransaction delegates to createTransaction', () async {
    final result = await CreateTransaction(repository)(buildTransaction());

    expect(result.isRight, isTrue);
    expect(repository.calls, ['create:tx-1']);
  });

  test('UpdateTransaction delegates to updateTransaction', () async {
    await UpdateTransaction(repository)(buildTransaction());

    expect(repository.calls, ['update:tx-1']);
  });

  test('DeleteTransaction delegates to deleteTransaction', () async {
    await DeleteTransaction(repository)('tx-1');

    expect(repository.calls, ['delete:tx-1']);
  });

  test('WatchTransactions streams the repository contents', () async {
    repository = FakeTransactionRepository([buildTransaction()]);

    expect(await WatchTransactions(repository)().first, [buildTransaction()]);
  });
}
