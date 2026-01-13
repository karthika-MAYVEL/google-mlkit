import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'models.dart';

class ScannerService {
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<ScanResult> scanBarcode(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final List<Barcode> barcodes = await _barcodeScanner.processImage(inputImage);

      if (barcodes.isNotEmpty) {
        return ScanResult(
          success: true,
          scanType: ScanType.qr,
          value: barcodes.first.displayValue ?? barcodes.first.rawValue ?? "",
          message: "Successful scan",
        );
      }
      return ScanResult(
        success: false,
        scanType: ScanType.qr,
        value: "",
        message: "No barcode/QR code detected",
      );
    } catch (e) {
      return ScanResult(
        success: false,
        scanType: ScanType.qr,
        value: "",
        message: "Error scanning barcode: $e",
      );
    }
  }

  Future<ScanResult> recognizeText(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      if (recognizedText.text.isNotEmpty) {
        return ScanResult(
          success: true,
          scanType: ScanType.ocr,
          value: recognizedText.text,
          message: "Successful scan",
        );
      }
      return ScanResult(
        success: false,
        scanType: ScanType.ocr,
        value: "",
        message: "No text detected",
      );
    } catch (e) {
      return ScanResult(
        success: false,
        scanType: ScanType.ocr,
        value: "",
        message: "Error recognizing text: $e",
      );
    }
  }

  void dispose() {
    _barcodeScanner.close();
    _textRecognizer.close();
  }
}
