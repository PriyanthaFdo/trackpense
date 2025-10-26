import 'package:drift/drift.dart';
import 'package:trackpense/data/database/database.dart';
import 'package:trackpense/data/models/payment_model.dart';

class PaymentRepo {
  PaymentRepo(this._db);

  final AppDatabase _db;

  Future<int> createPayment(PaymentModel payment) async {
    return await _db
        .into(_db.payment)
        .insert(
          PaymentCompanion.insert(
            description: payment.description,
            amount: payment.amount,
            isExpense: payment.isExpense,
            date: payment.dateTime,
            notes: Value(payment.notes),
          ),
        );
  }

  Future<void> updatePayment(PaymentModel payment) async {
    assert(payment.uuid != null);

    await _db
        .update(_db.payment)
        .replace(
          PaymentCompanion(
            uuid: Value(payment.uuid!),
            description: Value(payment.description),
            amount: Value(payment.amount),
            isExpense: Value(payment.isExpense),
            date: Value(payment.dateTime),
            notes: Value(payment.notes),
          ),
        );
  }

  Stream<List<PaymentData>> watchAllPayments() {
    return (_db.select(_db.payment)..orderBy([(p) => OrderingTerm.desc(p.date)])).watch();
  }
}
