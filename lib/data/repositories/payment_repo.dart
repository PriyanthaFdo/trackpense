import 'package:trackpense/data/database/database.dart';

class PaymentRepo {
  PaymentRepo({required this.database});

  final AppDatabase database;

  Future<int> createPayment({
    required DateTime dateTime,
    required String description,
    required double amount,
    required bool isExpense,
  }) async {
    return await database
        .into(database.payment)
        .insert(
          PaymentCompanion.insert(
            date: dateTime,
            description: description,
            amount: amount,
            isExpense: isExpense,
          ),
        );
  }

  Future<List<PaymentData>> getAllPayments() async {
    return await database.select(database.payment).get();
  }
}
