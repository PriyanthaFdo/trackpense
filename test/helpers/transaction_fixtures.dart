import 'package:trackpense/features/transactions/domain/entities/transaction.dart';

/// Builds a [Transaction] with sensible defaults; override only what a test cares about.
///
/// The default date has whole seconds because Drift stores DateTime values with
/// second precision, so values survive a database round trip unchanged.
Transaction buildTransaction({
  String uuid = 'tx-1',
  String description = 'Groceries',
  double amount = 1234.5,
  bool isExpense = true,
  DateTime? dateTime,
  String? notes,
}) {
  return Transaction(
    uuid: uuid,
    description: description,
    amount: amount,
    isExpense: isExpense,
    dateTime: dateTime ?? DateTime(2026, 10, 20, 9, 30),
    notes: notes,
  );
}
