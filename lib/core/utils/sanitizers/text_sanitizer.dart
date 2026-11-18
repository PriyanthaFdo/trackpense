class TextSanitizer {
  static String? sanitize(String? input) {
    // remove null
    if (input == null) return null;

    // Extract initial whitespace.
    final leadingWhitespace = RegExp(r'^\s*').firstMatch(input)!.group(0)!;

    // Remove initial whitespace.
    var result = input.substring(leadingWhitespace.length);

    // Preserve a single newline if the initial whitespace contained one.
    final prefix = leadingWhitespace.contains('\n') ? '\n' : '';

    // Discard ending whitespace.
    result = result.replaceFirst(RegExp(r'\s+$'), '');

    return prefix + result;
  }
}
