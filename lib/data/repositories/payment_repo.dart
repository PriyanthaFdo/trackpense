import 'package:drift/drift.dart';
import 'package:trackpense/data/database/database.dart';

class PaymentRepo {
  PaymentRepo(this._db);

  final AppDatabase _db;

  Future<int> createPayment({
    required String description,
    required double amount,
    required bool isExpense,
  }) async {
    return await _db
        .into(_db.payment)
        .insert(
          PaymentCompanion.insert(
            description: description,
            amount: amount,
            isExpense: isExpense,
          ),
        );
  }

  Future<void> updatePayment({
    required String uuid,
    required String description,
    required double amount,
    required bool isExpense,
  }) async {
    await _db.update(_db.payment).replace(
      PaymentCompanion(
        uuid: Value(uuid),
        description: Value(description),
        amount: Value(amount),
        isExpense: Value(isExpense),
      ),
    );
  }

  Stream<List<PaymentData>> watchAllPayments() {
    return (_db.select(_db.payment)..orderBy([(p) => OrderingTerm.desc(p.date)])).watch();
  }
}
