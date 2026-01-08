// lib/components/mlkit_scanner/models/scan_result.dart
//
// STEP 2 (RETURN CONTRACT / MODEL)
// --------------------------------
// This defines the consistent result returned by the scanner component.
// Keep this stable so other screens can rely on it.
//
// STEP 1: Result contract returned by the scanner component
class ScanResult {
  // "pass" | "fail"
  final String status;

  // OK | TIMEOUT | EMPTY | TOO_LONG | CANCELLED | CAMERA_ERROR
  final String code;

  // scanned value (empty on failure)
  final String value;

  // human-readable message (mainly for failure)
  final String message;

  // "barcode" | "ocr"
  final String type;

  // extra data (e.g. OCR blocks, confidence)
  final Map<String, dynamic>? meta;

  const ScanResult({
    required this.status,
    required this.code,
    required this.value,
    this.type = "barcode",
    this.meta,
    this.message = "",
  });
}
