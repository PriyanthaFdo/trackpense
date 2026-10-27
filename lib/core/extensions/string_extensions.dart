extension StringExtensions on String {
  double toCleanDouble() {
    final clean = replaceAll(',', '').trim();
    return double.tryParse(clean) ?? 0.0;
  }

  String toSentenceCase() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}
