import 'package:drift/drift.dart';
import 'package:trackpense/data/database/database.dart';

class PaymentRepo {
  PaymentRepo(this._db);

  final AppDatabase _db;

  Future<int> createPayment({
    required DateTime dateTime,
    required String description,
    required double amount,
    required bool isExpense,
  }) async {
    return await _db
        .into(_db.payment)
        .insert(
          PaymentCompanion.insert(
            date: dateTime,
            description: description,
            amount: amount,
            isExpense: isExpense,
          ),
        );
  }

  Stream<List<PaymentData>> watchAllPayments() {
    return (_db.select(_db.payment)..orderBy([(p) => OrderingTerm.desc(p.date)])).watch();
  }
}
