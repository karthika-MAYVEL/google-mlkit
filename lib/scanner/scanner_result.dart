class ScanResult {
  final bool isSuccess;
  final String value;
  final String message;

  const ScanResult._({
    required this.isSuccess,
    required this.value,
    required this.message,
  });

  factory ScanResult.success(String value) {
    return ScanResult._(
      isSuccess: true,
      value: value,
      message: "",
    );
  }

  factory ScanResult.error(String message) {
    return ScanResult._(
      isSuccess: false,
      value: "",
      message: message,
    );
  }
}
