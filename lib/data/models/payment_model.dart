import 'package:trackpense/data/database/database.dart';

class PaymentModel {
  const PaymentModel({
    this.uuid,
    required this.description,
    required this.amount,
    this.isExpense = true,
    required this.dateTime,
    this.notes,
  });

  PaymentModel.fromPaymentData(PaymentData paymentData)
    : this(
        uuid: paymentData.uuid,
        description: paymentData.description,
        amount: paymentData.amount,
        isExpense: paymentData.isExpense,
        dateTime: paymentData.date,
        notes: paymentData.notes,
      );

  final String? uuid;
  final String description;
  final double amount;
  final bool isExpense;
  final DateTime dateTime;
  final String? notes;
}
