import 'package:flutter_test/flutter_test.dart';
import 'package:trackpense/core/utils/sanitizers/text_sanitizer.dart';

void main() {
  group('TextSanitizer.sanitize', () {
    test('returns null when input is null', () {
      expect(TextSanitizer.sanitize(null), isNull);
    });

    test('preserves normal text without whitespace', () {
      expect(TextSanitizer.sanitize('Hello World'), 'Hello World');
    });

    test('discards leading whitespace without newline', () {
      expect(TextSanitizer.sanitize('  Hello'), 'Hello');
      expect(TextSanitizer.sanitize('   Hello'), 'Hello');
      expect(TextSanitizer.sanitize('\tHello'), 'Hello');
    });

    test('preserves single newline when leading whitespace contains newline', () {
      expect(TextSanitizer.sanitize('\nHello'), '\nHello');
      expect(TextSanitizer.sanitize('  \nHello'), '\nHello');
      expect(TextSanitizer.sanitize('\n  Hello'), '\nHello');
      expect(TextSanitizer.sanitize('  \n  Hello'), '\nHello');
    });

    test('discards trailing whitespace', () {
      expect(TextSanitizer.sanitize('Hello  '), 'Hello');
      expect(TextSanitizer.sanitize('Hello   '), 'Hello');
      expect(TextSanitizer.sanitize('Hello\t'), 'Hello');
      expect(TextSanitizer.sanitize('Hello \t '), 'Hello');
    });

    test('handles leading whitespace with newline and trailing whitespace', () {
      expect(TextSanitizer.sanitize('\nHello  '), '\nHello');
      expect(TextSanitizer.sanitize('  \nHello  '), '\nHello');
    });

    test('handles empty string', () {
      expect(TextSanitizer.sanitize(''), '');
    });

    test('handles only whitespace', () {
      expect(TextSanitizer.sanitize('  '), '');
      expect(TextSanitizer.sanitize('\t'), '');
      expect(TextSanitizer.sanitize(' \t '), '');
    });

    test('handles only newlines', () {
      expect(TextSanitizer.sanitize('\n'), '\n');
      expect(TextSanitizer.sanitize('\n\n'), '\n');
      expect(TextSanitizer.sanitize('  \n  '), '\n');
    });

    test('handles multiline text with leading whitespace', () {
      expect(TextSanitizer.sanitize('\nLine1\nLine2'), '\nLine1\nLine2');
      expect(TextSanitizer.sanitize('  \nLine1\nLine2'), '\nLine1\nLine2');
    });

    test('handles multiline text with trailing whitespace', () {
      expect(TextSanitizer.sanitize('Line1\nLine2  '), 'Line1\nLine2');
      expect(TextSanitizer.sanitize('Line1\nLine2\t'), 'Line1\nLine2');
    });

    test('handles complex whitespace scenarios', () {
      expect(TextSanitizer.sanitize('  \n  Hello World  \t  '), '\nHello World');
      expect(TextSanitizer.sanitize('\t\n\tTest\n\t'), '\nTest');
    });
  });
}
