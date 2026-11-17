/// Domain entity representing a transaction.
class Transaction {
  const Transaction({
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

  /// Creates a copy of this transaction with the given fields replaced.
  Transaction copyWith({
    String? uuid,
    String? description,
    double? amount,
    bool? isExpense,
    DateTime? dateTime,
    String? notes,
  }) {
    return Transaction(
      uuid: uuid ?? this.uuid,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      isExpense: isExpense ?? this.isExpense,
      dateTime: dateTime ?? this.dateTime,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Transaction &&
        other.uuid == uuid &&
        other.description == description &&
        other.amount == amount &&
        other.isExpense == isExpense &&
        other.dateTime == dateTime &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return uuid.hashCode ^
        description.hashCode ^
        amount.hashCode ^
        isExpense.hashCode ^
        dateTime.hashCode ^
        notes.hashCode;
  }

  @override
  String toString() {
    return 'Transaction(uuid: $uuid, description: $description, amount: $amount, isExpense: $isExpense, dateTime: $dateTime, notes: $notes)';
  }
}
