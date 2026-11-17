import 'package:flutter_test/flutter_test.dart';
import 'package:trackpense/core/config/app_config.dart';
import 'package:trackpense/core/utils/validators/description_validator.dart';

void main() {
  const maxLength = AppConfig.maxDescriptionLength;

  group('DescriptionValidator.validate', () {
    test('requires a value', () {
      expect(DescriptionValidator.validate(null), 'Description is required');
      expect(DescriptionValidator.validate(''), 'Description is required');
    });

    test('rejects whitespace-only descriptions', () {
      expect(DescriptionValidator.validate('   '), 'Description cannot be empty');
    });

    test('accepts up to the maximum length', () {
      expect(DescriptionValidator.validate('a' * maxLength), isNull);
    });

    test('rejects descriptions over the maximum length', () {
      expect(DescriptionValidator.validate('a' * (maxLength + 1)), 'Description cannot exceed $maxLength characters');
    });
  });

  group('DescriptionValidator.validateOptional', () {
    test('allows an empty value', () {
      expect(DescriptionValidator.validateOptional(null), isNull);
      expect(DescriptionValidator.validateOptional(''), isNull);
    });

    test('still rejects whitespace-only and over-long values', () {
      expect(DescriptionValidator.validateOptional('  '), 'Description cannot be empty');
      expect(DescriptionValidator.validateOptional('a' * (maxLength + 1)), isNotNull);
    });
  });
}
