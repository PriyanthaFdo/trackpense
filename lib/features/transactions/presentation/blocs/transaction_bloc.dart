import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackpense/core/error/failures.dart';
import 'package:trackpense/features/transactions/domain/entities/transaction.dart';
import 'package:trackpense/features/transactions/domain/usecases/create_transaction.dart';
import 'package:trackpense/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:trackpense/features/transactions/domain/usecases/update_transaction.dart';
import 'package:trackpense/features/transactions/domain/usecases/watch_transactions.dart';

/// Transaction BLoC events.
abstract class TransactionEvent {}

class TransactionLoadEvent extends TransactionEvent {}

class TransactionCreateEvent extends TransactionEvent {
  TransactionCreateEvent(this.transaction);

  final Transaction transaction;
}

class TransactionUpdateEvent extends TransactionEvent {
  TransactionUpdateEvent(this.transaction);

  final Transaction transaction;
}

class TransactionDeleteEvent extends TransactionEvent {
  TransactionDeleteEvent(this.uuid);

  final String uuid;
}

/// Transaction BLoC states.
abstract class TransactionState {}

class TransactionLoadingState extends TransactionState {}

class TransactionLoadedState extends TransactionState {
  TransactionLoadedState(this.transactions);

  final List<Transaction> transactions;
}

class TransactionErrorState extends TransactionState {
  TransactionErrorState(this.message);

  final String message;
}

class TransactionReadyState extends TransactionState {}

/// Transaction BLoC.
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc({
    required CreateTransaction createTransaction,
    required UpdateTransaction updateTransaction,
    required DeleteTransaction deleteTransaction,
    required WatchTransactions watchTransactions,
  })  : _createTransaction = createTransaction,
        _updateTransaction = updateTransaction,
        _deleteTransaction = deleteTransaction,
        _watchTransactions = watchTransactions,
        super(TransactionReadyState()) {
    on<TransactionLoadEvent>(_onLoad);
    on<TransactionCreateEvent>(_onCreate);
    on<TransactionUpdateEvent>(_onUpdate);
    on<TransactionDeleteEvent>(_onDelete);
  }

  final CreateTransaction _createTransaction;
  final UpdateTransaction _updateTransaction;
  final DeleteTransaction _deleteTransaction;
  final WatchTransactions _watchTransactions;

  Future<void> _onLoad(
    TransactionLoadEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoadingState());
    try {
      await emit.forEach(
        _watchTransactions(),
        onData: (transactions) => TransactionLoadedState(transactions),
        onError: (error, stackTrace) {
          return TransactionErrorState(
            _getErrorMessage(error),
          );
        },
      );
    } catch (e) {
      emit(TransactionErrorState(_getErrorMessage(e)));
    }
  }

  Future<void> _onCreate(
    TransactionCreateEvent event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await _createTransaction(event.transaction);
    result.fold(
      (failure) => emit(TransactionErrorState(failure.message)),
      (_) => emit(TransactionReadyState()),
    );
  }

  Future<void> _onUpdate(
    TransactionUpdateEvent event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await _updateTransaction(event.transaction);
    result.fold(
      (failure) => emit(TransactionErrorState(failure.message)),
      (_) => emit(TransactionReadyState()),
    );
  }

  Future<void> _onDelete(
    TransactionDeleteEvent event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await _deleteTransaction(event.uuid);
    result.fold(
      (failure) => emit(TransactionErrorState(failure.message)),
      (_) => emit(TransactionReadyState()),
    );
  }

  String _getErrorMessage(dynamic error) {
    if (error is Failure) {
      return error.message;
    }
    return 'An unexpected error occurred';
  }
}
