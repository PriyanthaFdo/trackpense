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
    emit(PaymentLoadingState());

    await emit.forEach<List<PaymentData>>(
      _repo.watchAllPayments(),
      onData: (payments) => PaymentLoadedState(payments: payments),
      onError: (error, stackTrace) => PaymentErrorState(error: error, stackTrace: stackTrace),
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
      emit(PaymentErrorState(error: e, stackTrace: s));
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
      emit(PaymentErrorState(error: e, stackTrace: s));
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
sealed class PaymentState {}

class PaymentLoadingState extends PaymentState {}

class PaymentLoadedState extends PaymentState {
  PaymentLoadedState({required this.payments});

  final List<PaymentData> payments;
}

class PaymentErrorState extends PaymentState {
  PaymentErrorState({
    required this.error,
    this.stackTrace,
    this.message,
  });

  final Object error;
  final StackTrace? stackTrace;
  final String? message;
}
