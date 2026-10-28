import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/transaction_fixtures.dart';

void main() {
  group('Transaction', () {
    test('instances with the same fields are equal and share a hash code', () {
      final a = buildTransaction(notes: 'note');
      final b = buildTransaction(notes: 'note');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('instances differing in any field are not equal', () {
      final base = buildTransaction();

      expect(base, isNot(buildTransaction(uuid: 'other')));
      expect(base, isNot(buildTransaction(description: 'Other')));
      expect(base, isNot(buildTransaction(amount: 1)));
      expect(base, isNot(buildTransaction(isExpense: false)));
      expect(base, isNot(buildTransaction(dateTime: DateTime(2020))));
      expect(base, isNot(buildTransaction(notes: 'note')));
    });

    test('copyWith replaces only the given fields', () {
      final original = buildTransaction(notes: 'note');
      final copy = original.copyWith(description: 'Rent', amount: 500);

      expect(copy.description, 'Rent');
      expect(copy.amount, 500);
      expect(copy.uuid, original.uuid);
      expect(copy.isExpense, original.isExpense);
      expect(copy.dateTime, original.dateTime);
      expect(copy.notes, original.notes);
    });
  });
}
