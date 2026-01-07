import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

class ScannerMLKit {
  final BarcodeScanner _scanner = BarcodeScanner(
    formats: [
      BarcodeFormat.qrCode,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upca,
      BarcodeFormat.upce,
      BarcodeFormat.dataMatrix,
      BarcodeFormat.pdf417,
      BarcodeFormat.aztec,
    ],
  );

  Future<String?> scan(InputImage image) async {
    final barcodes = await _scanner.processImage(image);
    if (barcodes.isEmpty) return null;

    for (final b in barcodes) {
      final v = b.rawValue?.trim();
      if (v != null && v.isNotEmpty) return v;
    }
    return null;
  }

  void dispose() {
    _scanner.close();
  }
}
