import 'package:flutter_test/flutter_test.dart';
import 'package:trackpense/core/utils/validators/amount_validator.dart';

void main() {
  group('AmountValidator.validate', () {
    test('requires a value', () {
      expect(AmountValidator.validate(null), 'Amount is required');
      expect(AmountValidator.validate(''), 'Amount is required');
    });

    test('rejects text that is not a number', () {
      expect(AmountValidator.validate('abc'), 'Please enter a valid amount');
    });

    test('rejects zero and negative amounts', () {
      expect(AmountValidator.validate('0'), 'Amount must be greater than 0');
      expect(AmountValidator.validate('0.00'), 'Amount must be greater than 0');
      expect(AmountValidator.validate('-5'), 'Amount must be greater than 0');
    });

    test('rejects more than 2 decimal places', () {
      expect(AmountValidator.validate('1.234'), 'Amount cannot have more than 2 decimal places');
    });

    test('accepts comma-grouped amounts as produced by the amount field', () {
      expect(AmountValidator.validate('1,234.50'), isNull);
      expect(AmountValidator.validate('1,234,567'), isNull);
    });

    test('ignores surrounding whitespace', () {
      expect(AmountValidator.validate(' 12.5 '), isNull);
    });
  });

  group('AmountValidator.validateDouble', () {
    test('requires a value greater than 0', () {
      expect(AmountValidator.validateDouble(null), 'Amount is required');
      expect(AmountValidator.validateDouble(0), 'Amount must be greater than 0');
      expect(AmountValidator.validateDouble(0.01), isNull);
    });
  });
}
