import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CommaSeparatedInputFormatter extends TextInputFormatter {
  CommaSeparatedInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Handle backspace (empty input)
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digits except dot
    final String raw = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');

    // Split into integer and decimal
    final List<String> parts = raw.split('.');

    String integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';

    // Format integer part with commas
    final formatter = NumberFormat('#,###');
    integerPart = formatter.format(int.tryParse(integerPart) ?? 0);

    // Rebuild formatted text
    String newText = integerPart;
    if (raw.contains('.')) {
      newText += '.$decimalPart';
    }

    // Calculate new cursor position (keep it near where user typed)
    final selectionIndex = newText.length - (raw.length - newValue.selection.end);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selectionIndex.clamp(0, newText.length),
      ),
    );
  }
}
