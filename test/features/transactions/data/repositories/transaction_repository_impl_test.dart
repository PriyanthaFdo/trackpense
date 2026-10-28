import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trackpense/core/database/database.dart';
import 'package:trackpense/core/error/failures.dart';
import 'package:trackpense/features/transactions/data/repositories/transaction_repository_impl.dart';

import '../../../../helpers/transaction_fixtures.dart';

void main() {
  late AppDatabase database;
  late TransactionRepositoryImpl repository;

  setUp(() {
    // A real SQLite database in memory: exercises the actual SQL, constraints and mapping.
    database = AppDatabase(NativeDatabase.memory());
    repository = TransactionRepositoryImpl(database);
  });

  tearDown(() => database.close());

  group('createTransaction', () {
    test('stores the transaction', () async {
      final transaction = buildTransaction(notes: 'note');

      final result = await repository.createTransaction(transaction);

      expect(result.isRight, isTrue);
      expect((await repository.getTransaction(transaction.uuid)).right, transaction);
    });

    test('returns a DatabaseFailure when the description is empty', () async {
      final result = await repository.createTransaction(buildTransaction(description: ''));

      expect(result.isLeft, isTrue);
      expect(result.left, isA<DatabaseFailure>());
    });

    test('returns a DatabaseFailure for a duplicate uuid', () async {
      await repository.createTransaction(buildTransaction());

      final result = await repository.createTransaction(buildTransaction(description: 'Duplicate'));

      expect(result.left, isA<DatabaseFailure>());
    });
  });

  group('updateTransaction', () {
    test('replaces the stored fields', () async {
      final original = buildTransaction(notes: 'note');
      await repository.createTransaction(original);
      final edited = original.copyWith(description: 'Rent', amount: 800, isExpense: false);

      final result = await repository.updateTransaction(edited);

      expect(result.isRight, isTrue);
      expect((await repository.getTransaction(original.uuid)).right, edited);
    });

    // Regression: clearing notes on edit used to leave the old notes stored.
    test('clears notes when the updated transaction has none', () async {
      await repository.createTransaction(buildTransaction(notes: 'old note'));

      await repository.updateTransaction(buildTransaction());

      expect((await repository.getTransaction('tx-1')).right!.notes, isNull);
    });

    test('changes only the transaction with the matching uuid', () async {
      await repository.createTransaction(buildTransaction(uuid: 'a'));
      await repository.createTransaction(buildTransaction(uuid: 'b'));

      await repository.updateTransaction(buildTransaction(uuid: 'a', description: 'Changed'));

      expect((await repository.getTransaction('b')).right!.description, 'Groceries');
    });
  });

  group('deleteTransaction', () {
    test('removes the transaction', () async {
      await repository.createTransaction(buildTransaction());

      final result = await repository.deleteTransaction('tx-1');

      expect(result.isRight, isTrue);
      expect((await repository.getTransaction('tx-1')).right, isNull);
    });

    test('succeeds when the uuid does not exist', () async {
      expect((await repository.deleteTransaction('missing')).isRight, isTrue);
    });
  });

  group('getTransaction', () {
    test('returns null for an unknown uuid', () async {
      final result = await repository.getTransaction('missing');

      expect(result.isRight, isTrue);
      expect(result.right, isNull);
    });
  });

  group('watchAllTransactions', () {
    test('emits an empty list for an empty database', () async {
      expect(await repository.watchAllTransactions().first, isEmpty);
    });

    // Regression: the refactor dropped the date-descending order.
    test('lists transactions newest first', () async {
      await repository.createTransaction(buildTransaction(uuid: 'old', dateTime: DateTime(2026, 1, 10)));
      await repository.createTransaction(buildTransaction(uuid: 'new', dateTime: DateTime(2026, 3, 10)));
      await repository.createTransaction(buildTransaction(uuid: 'mid', dateTime: DateTime(2026, 2, 10)));

      final transactions = await repository.watchAllTransactions().first;

      expect(transactions.map((t) => t.uuid), ['new', 'mid', 'old']);
    });

    test('emits again after every change', () async {
      final emissions = repository.watchAllTransactions().map((list) => list.length);
      final expectation = expectLater(emissions, emitsInOrder([0, 1, 0]));

      await pumpEventQueue();
      await repository.createTransaction(buildTransaction());
      await pumpEventQueue();
      await repository.deleteTransaction('tx-1');

      await expectation;
    });
  });
}
