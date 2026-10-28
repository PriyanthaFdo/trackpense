import 'dart:async';

import 'package:trackpense/core/error/failures.dart';
import 'package:trackpense/features/transactions/domain/entities/transaction.dart';
import 'package:trackpense/features/transactions/domain/repositories/transaction_repository.dart';

/// In-memory [TransactionRepository] for BLoC and widget tests.
///
/// Set [failure] to make every write return `Either.left(failure)`.
/// Call [dispose] in `tearDown`.
class FakeTransactionRepository implements TransactionRepository {
  FakeTransactionRepository([List<Transaction> initial = const []]) {
    _items.addAll(initial);
  }

  final List<Transaction> _items = [];
  final StreamController<List<Transaction>> _changes = StreamController<List<Transaction>>.broadcast();

  /// When non-null, create/update/delete fail with this failure.
  Failure? failure;

  /// Every write call received, in order, e.g. `create:<uuid>`.
  final List<String> calls = [];

  List<Transaction> get items => List.unmodifiable(_items);

  @override
  Future<Either<Failure, void>> createTransaction(Transaction transaction) async {
    calls.add('create:${transaction.uuid}');
    if (failure != null) return Either.left(failure!);
    _items.add(transaction);
    _notify();
    return Either.right(null);
  }

  @override
  Future<Either<Failure, void>> updateTransaction(Transaction transaction) async {
    calls.add('update:${transaction.uuid}');
    if (failure != null) return Either.left(failure!);
    final index = _items.indexWhere((t) => t.uuid == transaction.uuid);
    if (index >= 0) _items[index] = transaction;
    _notify();
    return Either.right(null);
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String uuid) async {
    calls.add('delete:$uuid');
    if (failure != null) return Either.left(failure!);
    _items.removeWhere((t) => t.uuid == uuid);
    _notify();
    return Either.right(null);
  }

  @override
  Future<Either<Failure, Transaction?>> getTransaction(String uuid) async {
    final matches = _items.where((t) => t.uuid == uuid);
    return Either.right(matches.isEmpty ? null : matches.first);
  }

  /// Emits the current items immediately, then again after every change.
  @override
  Stream<List<Transaction>> watchAllTransactions() async* {
    yield items;
    yield* _changes.stream;
  }

  /// Pushes an error into active [watchAllTransactions] streams.
  void emitStreamError(Object error) => _changes.addError(error);

  Future<void> dispose() => _changes.close();

  void _notify() => _changes.add(items);
}
