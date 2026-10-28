// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trackpense/core/database/database.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  // Installs from before notes existed (v1.0.x) hold real user data, so check
  // that upgrading keeps every row intact. See
  // https://drift.simonbinder.eu/migrations/tests/#verifying-data-integrity
  test('migration from v1 to v2 keeps existing transactions', () async {
    // Snapshot classes hold raw SQL values: dates as Unix seconds, booleans as 0/1.
    final oldPaymentData = <v1.PaymentData>[
      v1.PaymentData(
        uuid: 'expense-1',
        date: _unixSeconds(DateTime(2025, 8, 30, 12, 15)),
        description: 'Groceries',
        amount: 1234.5,
        isExpense: 1,
      ),
      v1.PaymentData(
        uuid: 'income-1',
        date: _unixSeconds(DateTime(2025, 9, 1, 9)),
        description: 'Salary',
        amount: 150000,
        isExpense: 0,
      ),
      // v1 allowed descriptions up to 255 characters; v2 limits new ones to 200.
      v1.PaymentData(
        uuid: 'long-description',
        date: _unixSeconds(DateTime(2025, 9, 2, 18, 45, 30)),
        description: 'x' * 255,
        amount: 0.01,
        isExpense: 1,
      ),
    ];
    final expectedNewPaymentData = <v2.PaymentData>[
      for (final old in oldPaymentData)
        v2.PaymentData(
          uuid: old.uuid,
          date: old.date,
          description: old.description,
          amount: old.amount,
          isExpense: old.isExpense,
        ),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.payment, oldPaymentData);
      },
      validateItems: (newDb) async {
        expect(expectedNewPaymentData, await newDb.select(newDb.payment).get());
      },
    );
  });
}

/// Drift stores DateTime columns as Unix timestamps in seconds.
int _unixSeconds(DateTime dateTime) => dateTime.millisecondsSinceEpoch ~/ 1000;
