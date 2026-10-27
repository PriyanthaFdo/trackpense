import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trackpense/core/config/app_config.dart';
import 'package:trackpense/core/database/tables/payment_table.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Payment])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from == 1) {
        // Add the new "notes" column
        await m.addColumn(payment, payment.notes);
      }
    },
  );

  /// Creates a new payment.
  Future<void> createPayment(PaymentCompanion companion) async {
    await into(payment).insert(companion);
  }

  /// Updates an existing payment.
  Future<void> updatePayment(PaymentCompanion companion) async {
    final uuidValue = companion.uuid.value;
    await (update(payment)..where((tbl) => tbl.uuid.equals(uuidValue))).write(companion);
  }

  /// Deletes a payment by UUID.
  Future<void> deletePayment(String uuid) async {
    await (delete(payment)..where((tbl) => tbl.uuid.equals(uuid))).go();
  }

  /// Gets a payment by UUID.
  Future<PaymentData?> getPayment(String uuid) async {
    return await (select(payment)..where((tbl) => tbl.uuid.equals(uuid))).getSingleOrNull();
  }

  /// Watches all payments.
  Stream<List<PaymentData>> watchAllPayments() {
    return select(payment).watch();
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: AppConfig.databaseName,
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
