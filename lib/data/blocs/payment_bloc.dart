import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackpense/data/database/database.dart';
import 'package:trackpense/data/repositories/payment_repo.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc(AppDatabase database) //
    : _repo = PaymentRepo(database),
      super(PaymentLoadingState()) {
    on<GetAllPaymentsEvent>(_handleGetAllPaymentsEvent);
    on<CreatePaymentEvent>(_handleCreatePaymentEvent);
    on<UpdatePaymentEvent>(_handleUpdatePaymentEvent);
  }

  final PaymentRepo _repo;

  Future<void> _handleGetAllPaymentsEvent(GetAllPaymentsEvent event, Emitter<PaymentState> emit) async {
    emit(state.loadingState());

    await emit.forEach<List<PaymentData>>(
      _repo.watchAllPayments(),
      onData: (payments) => state.loadedState(payments),
      onError: (error, stackTrace) => state.errorState(error: error, stackTrace: stackTrace),
    );
  }

  Future<void> _handleCreatePaymentEvent(CreatePaymentEvent event, Emitter<PaymentState> emit) async {
    try {
      await _repo.createPayment(
        description: event.description,
        amount: event.amount,
        isExpense: event.isExpense,
        dateTime: event.dateTime,
        notes: event.notes,
      );
    } catch (e, s) {
      emit(state.errorState(error: e, stackTrace: s));
    }
  }


  Future<void> _handleUpdatePaymentEvent(UpdatePaymentEvent event, Emitter<PaymentState> emit) async {
    try {
      await _repo.updatePayment(
        uuid: event.uuid,
        description: event.description,
        amount: event.amount,
        isExpense: event.isExpense,
        dateTime: event.dateTime,
        notes: event.notes,
      );
    } catch (e, s) {
      emit(state.errorState(error: e, stackTrace: s));
    }
  }
}

// ======== EVENTS ========
sealed class PaymentEvent {}

class GetAllPaymentsEvent extends PaymentEvent {}

class CreatePaymentEvent extends PaymentEvent {
  CreatePaymentEvent({
    required this.description,
    required this.amount,
    required this.isExpense,
    required this.dateTime,
    this.notes,
  });

  final String description;
  final double amount;
  final bool isExpense;
  final DateTime dateTime;
  final String? notes;
}

class UpdatePaymentEvent extends PaymentEvent {
  UpdatePaymentEvent({
    required this.uuid,
    required this.description,
    required this.amount,
    required this.isExpense,
    required this.dateTime,
    this.notes,
  });

  final String uuid;
  final String description;
  final double amount;
  final bool isExpense;
  final DateTime dateTime;
  final String? notes;
}

// ======== STATES ========
sealed class PaymentState {
  PaymentState({required this.payments});

  final List<PaymentData> payments;

  PaymentLoadingState loadingState() => PaymentLoadingState(payments: payments);
  PaymentLoadedState loadedState(List<PaymentData>? payments) => PaymentLoadedState(payments: payments ?? this.payments);
  PaymentErrorState errorState({
    required Object error,
    required StackTrace stackTrace,
    String? message,
  }) => PaymentErrorState(
    payments: payments,
    error: error,
    stackTrace: stackTrace,
    message: message,
  );
}

class PaymentLoadingState extends PaymentState {
  PaymentLoadingState({super.payments = const []});
}

class PaymentLoadedState extends PaymentState {
  PaymentLoadedState({required super.payments});
}

class PaymentErrorState extends PaymentState {
  PaymentErrorState({
    required super.payments,
    required this.error,
    required this.stackTrace,
    this.message,
  });

  final Object error;
  final StackTrace stackTrace;
  final String? message;
}
