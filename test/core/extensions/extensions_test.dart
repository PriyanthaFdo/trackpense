import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trackpense/core/extensions/color_extensions.dart';
import 'package:trackpense/core/extensions/datetime_extensions.dart';
import 'package:trackpense/core/extensions/double_extensions.dart';
import 'package:trackpense/core/extensions/string_extensions.dart';

void main() {
  group('StringExtensions.toCleanDouble', () {
    test('parses comma-grouped numbers', () {
      expect('1,234.56'.toCleanDouble(), 1234.56);
      expect('1,234,567'.toCleanDouble(), 1234567);
    });

    test('trims whitespace', () {
      expect(' 12.5 '.toCleanDouble(), 12.5);
    });

    test('falls back to 0.0 for empty or invalid input', () {
      expect(''.toCleanDouble(), 0.0);
      expect('abc'.toCleanDouble(), 0.0);
    });
  });

  group('StringExtensions.toSentenceCase', () {
    test('capitalises the first letter and lowercases the rest', () {
      expect('hELLO wORLD'.toSentenceCase(), 'Hello world');
    });

    test('leaves an empty string unchanged', () {
      expect(''.toSentenceCase(), '');
    });
  });

  group('DoubleExtensions.toCommaString', () {
    test('formats with thousands separators and 2 decimals', () {
      expect(1234.5.toCommaString(), '1,234.50');
      expect(1234567.891.toCommaString(), '1,234,567.89');
      expect(0.0.toCommaString(), '0.00');
    });

    test('supports a custom number of decimals', () {
      expect(1.5.toCommaString(decimalDigits: 3), '1.500');
    });

    test('keeps the sign of negative numbers', () {
      expect((-1234.5).toCommaString(), '-1,234.50');
    });
  });

  group('KbDateTimeFormatting.format', () {
    final date = DateTime(2026, 10, 27, 14, 5);

    test('uses the given pattern', () {
      expect(date.format(format: 'dd/MMM/yyyy'), '27/Oct/2026');
      expect(date.format(format: 'hh:mm a'), '02:05 PM');
    });

    test('has a default pattern', () {
      expect(date.format(), '27/Oct/2026 14:05:00');
    });
  });

  group('ColorExtensions', () {
    const color = Color(0xFF0C4776);

    test('darken(0) and lighten(0) leave the color unchanged', () {
      expect(color.darken(0), isSameColorAs(color));
      expect(color.lighten(0), isSameColorAs(color));
    });

    test('darken(1) is black and lighten(1) is white', () {
      expect(color.darken(1), isSameColorAs(Colors.black));
      expect(color.lighten(1), isSameColorAs(Colors.white));
    });

    test('rejects percentages outside 0..1', () {
      expect(() => color.darken(1.5), throwsAssertionError);
      expect(() => color.lighten(-0.1), throwsAssertionError);
    });
  });
}
