import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ScannerService {
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<String?> scanBarcode(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final List<Barcode> barcodes = await _barcodeScanner.processImage(inputImage);

    if (barcodes.isNotEmpty) {
      return barcodes.first.displayValue;
    }
    return null;
  }

  Future<String?> recognizeText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

    if (recognizedText.text.isNotEmpty) {
      return recognizedText.text;
    }
    return null;
  }

  void dispose() {
    _barcodeScanner.close();
    _textRecognizer.close();
  }
}
