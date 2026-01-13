enum ScanType { qr, ocr }

class ScanResult {
  final bool success;
  final ScanType scanType;
  final String value;
  final String message;

  ScanResult({
    required this.success,
    required this.scanType,
    required this.value,
    this.message = '',
  });

  Map<String, dynamic> toJson() => {
        'success': success,
        'scanType': scanType == ScanType.qr ? 'qr' : 'ocr',
        'value': value,
        'message': message,
      };

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      success: json['success'] ?? false,
      scanType: json['scanType'] == 'qr' ? ScanType.qr : ScanType.ocr,
      value: json['value'] ?? '',
      message: json['message'] ?? '',
    );
  }
}
