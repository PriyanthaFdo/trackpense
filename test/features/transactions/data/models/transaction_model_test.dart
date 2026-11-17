import 'package:flutter_test/flutter_test.dart';
import 'package:trackpense/core/database/database.dart';
import 'package:trackpense/features/transactions/data/models/transaction_model.dart';

import '../../../../helpers/transaction_fixtures.dart';

void main() {
  group('TransactionModel', () {
    test('maps an entity to a companion with every column present', () {
      final entity = buildTransaction(notes: 'note');
      final companion = TransactionModel.fromEntity(entity).toPaymentCompanion();

      expect(companion.uuid.value, entity.uuid);
      expect(companion.description.value, entity.description);
      expect(companion.amount.value, entity.amount);
      expect(companion.isExpense.value, entity.isExpense);
      expect(companion.date.value, entity.dateTime);
      expect(companion.notes.value, 'note');
    });

    // Regression: the refactor used Value.absent() for null notes, so clearing
    // the notes field on edit left the old notes in the database.
    test('writes null notes explicitly so updates can clear them', () {
      final companion = TransactionModel.fromEntity(buildTransaction()).toPaymentCompanion();

      expect(companion.notes.present, isTrue);
      expect(companion.notes.value, isNull);
    });

    test('maps a database row to an entity', () {
      final row = PaymentData(
        uuid: 'tx-9',
        date: DateTime(2026, 1, 2, 3, 4),
        description: 'Salary',
        amount: 5000,
        isExpense: false,
        notes: 'January',
      );

      expect(
        TransactionModel.fromPaymentData(row).toEntity(),
        buildTransaction(
          uuid: 'tx-9',
          dateTime: DateTime(2026, 1, 2, 3, 4),
          description: 'Salary',
          amount: 5000,
          isExpense: false,
          notes: 'January',
        ),
      );
    });

    test('an entity survives entity -> model -> entity unchanged', () {
      final entity = buildTransaction(notes: 'note');

      expect(TransactionModel.fromEntity(entity).toEntity(), entity);
    });
  });
}
