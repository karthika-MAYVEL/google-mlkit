// lib/components/mlkit_scanner/models/scan_result.dart

class ScanResult {
  /// "pass" | "fail"
  final String status;

  /// OK | TIMEOUT | EMPTY | TOO_LONG | CANCELLED | CAMERA_ERROR
  final String code;

  /// scanned value (empty on failure)
  final String value;

  /// optional human-readable message
  final String message;

  /// "barcode" | "ocr"
  final String type;

  /// extra data (e.g. OCR blocks)
  final Map<String, dynamic>? meta;

  const ScanResult({
    required this.status,
    required this.code,
    required this.value,
    this.message = "",
    this.type = "barcode",
    this.meta,
  });
}
