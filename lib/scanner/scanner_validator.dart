class ScannerValidator {
  static bool isValid(String value) {
    final v = value.trim();
    if (v.isEmpty) return false;
    if (v.length > 1000) return false;
    return true;
  }
}
