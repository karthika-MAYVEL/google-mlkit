// lib/components/mlkit_scanner/models/scan_result.dart
//
// STEP 2 (RETURN CONTRACT / MODEL)
// --------------------------------
// This defines the consistent result returned by the scanner component.
// Keep this stable so other screens can rely on it.
//

class ScanResult {
  /// "pass" or "fail"
  final String status;

  /// Machine-readable code:
  /// OK | TIMEOUT | EMPTY | TOO_LONG | CANCELLED | CAMERA_ERROR
  final String code;

  /// Scanned QR/barcode value (empty on failure)
  final String value;

  /// Human-readable message (mainly for failure)
  final String message;

  const ScanResult({
    required this.status,
    required this.code,
    required this.value,
    this.message = "",
  });

  bool get isPass => status == "pass";
}
