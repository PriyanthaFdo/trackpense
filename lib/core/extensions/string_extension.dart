extension StringExtensions on String {
  double toCleanDouble() {
    final clean = replaceAll(',', '').trim();
    return double.tryParse(clean) ?? 0.0;
  }
}
