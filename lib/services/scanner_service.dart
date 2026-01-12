import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ScannerService {
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<Map<String, dynamic>> scanBarcode(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final List<Barcode> barcodes = await _barcodeScanner.processImage(inputImage);

      if (barcodes.isNotEmpty) {
        return {
          "success": true,
          "scanType": "qr",
          "value": barcodes.first.displayValue ?? "",
          "message": "Successful scan"
        };
      }
      return {
        "success": false,
        "scanType": "qr",
        "value": "",
        "message": "No barcode/QR code detected"
      };
    } catch (e) {
      return {
        "success": false,
        "scanType": "qr",
        "value": "",
        "message": "Error scanning barcode: $e"
      };
    }
  }

  Future<Map<String, dynamic>> recognizeText(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      if (recognizedText.text.isNotEmpty) {
        return {
          "success": true,
          "scanType": "ocr",
          "value": recognizedText.text,
          "message": "Successful scan"
        };
      }
      return {
        "success": false,
        "scanType": "ocr",
        "value": "",
        "message": "No text detected"
      };
    } catch (e) {
      return {
        "success": false,
        "scanType": "ocr",
        "value": "",
        "message": "Error recognizing text: $e"
      };
    }
  }

  void dispose() {
    _barcodeScanner.close();
    _textRecognizer.close();
  }
}
