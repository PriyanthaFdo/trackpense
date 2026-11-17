import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trackpense/core/utils/formatters/currency_formatter.dart';
import 'package:trackpense/core/utils/formatters/decimal_input_formatter.dart';

/// Simulates the user ending up with [text] (cursor at the end) and returns
/// what the formatters turn it into.
TextEditingValue _type(List<TextInputFormatter> formatters, String text, {String previous = ''}) {
  var value = TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: text.length),
  );
  final oldValue = TextEditingValue(
    text: previous,
    selection: TextSelection.collapsed(offset: previous.length),
  );
  for (final formatter in formatters) {
    value = formatter.formatEditUpdate(oldValue, value);
  }
  return value;
}

void main() {
  group('DecimalTextInputFormatter', () {
    final formatter = DecimalTextInputFormatter(decimalDigits: 2);

    test('keeps at most the configured number of decimals', () {
      expect(_type([formatter], '12.345').text, '12.34');
    });

    test('keeps only the first decimal point', () {
      expect(_type([formatter], '1.2.3').text, '1.2');
    });

    test('strips characters other than digits and the decimal point', () {
      expect(_type([formatter], 'a1b2').text, '12');
    });

    test('lets the field be cleared', () {
      expect(_type([formatter], '', previous: '5').text, '');
    });

    test('allows any number of decimals when decimalDigits is null', () {
      expect(_type([DecimalTextInputFormatter()], '12.3456').text, '12.3456');
    });

    test('keeps the cursor within the text', () {
      final value = _type([formatter], '12.345');
      expect(value.selection.baseOffset, lessThanOrEqualTo(value.text.length));
    });
  });

  group('CommaSeparatedInputFormatter', () {
    final formatter = CommaSeparatedInputFormatter();

    test('groups the integer part with commas', () {
      expect(_type([formatter], '1234').text, '1,234');
      expect(_type([formatter], '1234567.5').text, '1,234,567.5');
    });

    test('regroups when typing into already formatted text', () {
      expect(_type([formatter], '1,2345', previous: '1,234').text, '12,345');
    });

    test('keeps a trailing decimal point while the user is typing', () {
      expect(_type([formatter], '12.').text, '12.');
    });

    test('adds a leading zero to a bare decimal', () {
      expect(_type([formatter], '.5').text, '0.5');
    });

    test('lets the field be cleared', () {
      expect(_type([formatter], '', previous: '1').text, '');
    });

    test('places the cursor at the end when typing at the end', () {
      final value = _type([formatter], '1234');
      expect(value.selection.baseOffset, value.text.length);
    });
  });

  group('amount field formatter chain (decimal, then comma)', () {
    final chain = [DecimalTextInputFormatter(decimalDigits: 2), CommaSeparatedInputFormatter()];

    test('produces a grouped amount with at most 2 decimals', () {
      expect(_type(chain, '1234.567').text, '1,234.56');
    });
  });
}
