import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trackpense/core/error/failures.dart';
import 'package:trackpense/features/transactions/presentation/blocs/transaction_bloc.dart';

import '../../../../helpers/fake_transaction_repository.dart';
import '../../../../helpers/transaction_bloc_factory.dart';
import '../../../../helpers/transaction_fixtures.dart';

Matcher _loadedWith(int count) {
  return isA<TransactionLoadedState>().having((s) => s.transactions.length, 'transactions.length', count);
}

Matcher _errorWith(String message) {
  return isA<TransactionErrorState>().having((s) => s.message, 'message', message);
}

void main() {
  late FakeTransactionRepository repository;

  setUp(() => repository = FakeTransactionRepository());
  tearDown(() => repository.dispose());

  test('starts in TransactionReadyState', () {
    expect(buildTransactionBloc(repository).state, isA<TransactionReadyState>());
  });

  group('TransactionLoadEvent', () {
    blocTest<TransactionBloc, TransactionState>(
      'emits Loading, then Loaded with the current transactions',
      setUp: () => repository = FakeTransactionRepository([buildTransaction()]),
      build: () => buildTransactionBloc(repository),
      act: (bloc) => bloc.add(TransactionLoadEvent()),
      expect: () => [isA<TransactionLoadingState>(), _loadedWith(1)],
    );

    blocTest<TransactionBloc, TransactionState>(
      'keeps emitting Loaded as the data changes',
      build: () => buildTransactionBloc(repository),
      act: (bloc) async {
        bloc.add(TransactionLoadEvent());
        await pumpEventQueue();
        await repository.createTransaction(buildTransaction());
      },
      expect: () => [isA<TransactionLoadingState>(), _loadedWith(0), _loadedWith(1)],
    );

    blocTest<TransactionBloc, TransactionState>(
      'emits an error state when the stream fails',
      build: () => buildTransactionBloc(repository),
      act: (bloc) async {
        bloc.add(TransactionLoadEvent());
        await pumpEventQueue();
        repository.emitStreamError(Exception('disk error'));
      },
      expect: () => [isA<TransactionLoadingState>(), _loadedWith(0), _errorWith('An unexpected error occurred')],
    );
  });

  group('write events', () {
    blocTest<TransactionBloc, TransactionState>(
      'create emits Ready on success',
      build: () => buildTransactionBloc(repository),
      act: (bloc) => bloc.add(TransactionCreateEvent(buildTransaction())),
      expect: () => [isA<TransactionReadyState>()],
      verify: (_) => expect(repository.items, [buildTransaction()]),
    );

    blocTest<TransactionBloc, TransactionState>(
      'create emits Error with the failure message on failure',
      setUp: () => repository.failure = const DatabaseFailure('Failed to create transaction'),
      build: () => buildTransactionBloc(repository),
      act: (bloc) => bloc.add(TransactionCreateEvent(buildTransaction())),
      expect: () => [_errorWith('Failed to create transaction')],
    );

    blocTest<TransactionBloc, TransactionState>(
      'update emits Ready on success',
      setUp: () => repository = FakeTransactionRepository([buildTransaction()]),
      build: () => buildTransactionBloc(repository),
      act: (bloc) => bloc.add(TransactionUpdateEvent(buildTransaction(description: 'Rent'))),
      expect: () => [isA<TransactionReadyState>()],
      verify: (_) => expect(repository.items.single.description, 'Rent'),
    );

    blocTest<TransactionBloc, TransactionState>(
      'update emits Error on failure',
      setUp: () => repository.failure = const DatabaseFailure('Failed to update transaction'),
      build: () => buildTransactionBloc(repository),
      act: (bloc) => bloc.add(TransactionUpdateEvent(buildTransaction())),
      expect: () => [_errorWith('Failed to update transaction')],
    );

    blocTest<TransactionBloc, TransactionState>(
      'delete emits Ready on success',
      setUp: () => repository = FakeTransactionRepository([buildTransaction()]),
      build: () => buildTransactionBloc(repository),
      act: (bloc) => bloc.add(TransactionDeleteEvent('tx-1')),
      expect: () => [isA<TransactionReadyState>()],
      verify: (_) => expect(repository.items, isEmpty),
    );

    blocTest<TransactionBloc, TransactionState>(
      'delete emits Error on failure',
      setUp: () => repository.failure = const DatabaseFailure('Failed to delete transaction'),
      build: () => buildTransactionBloc(repository),
      act: (bloc) => bloc.add(TransactionDeleteEvent('tx-1')),
      expect: () => [_errorWith('Failed to delete transaction')],
    );

    blocTest<TransactionBloc, TransactionState>(
      'a write while loading is followed by a fresh Loaded state',
      build: () => buildTransactionBloc(repository),
      act: (bloc) async {
        bloc.add(TransactionLoadEvent());
        await pumpEventQueue();
        bloc.add(TransactionCreateEvent(buildTransaction()));
      },
      expect: () => [isA<TransactionLoadingState>(), _loadedWith(0), _loadedWith(1), isA<TransactionReadyState>()],
    );
  });
}
