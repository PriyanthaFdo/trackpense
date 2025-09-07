import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trackpense/data/constants/kjp_miscellaneous.dart';
import 'package:trackpense/data/database/tables/payment.dart';

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

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: KjpMiscellaneous.databaseName,
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
