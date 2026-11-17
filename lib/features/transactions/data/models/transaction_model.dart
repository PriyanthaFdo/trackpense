import 'package:drift/drift.dart';
import 'package:trackpense/core/database/database.dart';
import 'package:trackpense/features/transactions/domain/entities/transaction.dart';

/// Data model for transaction (maps to database).
class TransactionModel {
  TransactionModel({
    required this.uuid,
    required this.description,
    required this.amount,
    required this.isExpense,
    required this.dateTime,
    this.notes,
  });

  /// Creates a TransactionModel from PaymentData (Drift).
  TransactionModel.fromPaymentData(PaymentData data) : uuid = data.uuid, description = data.description, amount = data.amount, isExpense = data.isExpense, dateTime = data.date, notes = data.notes;

  /// Creates a TransactionModel from domain entity.
  TransactionModel.fromEntity(Transaction entity)
    : uuid = entity.uuid,
      description = entity.description,
      amount = entity.amount,
      isExpense = entity.isExpense,
      dateTime = entity.dateTime,
      notes = entity.notes;

  final String uuid;
  final String description;
  final double amount;
  final bool isExpense;
  final DateTime dateTime;
  final String? notes;

  /// Converts to PaymentCompanion for database operations.
  PaymentCompanion toPaymentCompanion() {
    return PaymentCompanion(
      uuid: Value(uuid),
      description: Value(description),
      amount: Value(amount),
      isExpense: Value(isExpense),
      date: Value(dateTime),
      notes: Value(notes),
    );
  }

  /// Converts to domain entity.
  Transaction toEntity() {
    return Transaction(
      uuid: uuid,
      description: description,
      amount: amount,
      isExpense: isExpense,
      dateTime: dateTime,
      notes: notes,
    );
  }
}
