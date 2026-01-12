import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ScannerService {
  final TextRecognizer _textRecognizer = TextRecognizer();

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
    _textRecognizer.close();
  }
}
