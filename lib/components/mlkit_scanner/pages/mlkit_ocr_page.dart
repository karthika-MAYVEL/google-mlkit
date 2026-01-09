import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../models/scan_result.dart';

class MlkitOcrPage extends StatefulWidget {
  const MlkitOcrPage({
    super.key,
    required this.title,
    required this.maxValueLength,
    this.initialScript = TextRecognitionScript.latin,
  });

  final String title;
  final int maxValueLength;
  final TextRecognitionScript initialScript;

  @override
  State<MlkitOcrPage> createState() => _MlkitOcrPageState();
}

class _MlkitOcrPageState extends State<MlkitOcrPage> {
  final ImagePicker _picker = ImagePicker();
  late TextRecognizer _recognizer;
  late TextRecognitionScript _currentScript;

  bool _busy = false;
  bool _returned = false;

  @override
  void initState() {
    super.initState();
    _currentScript = widget.initialScript;
    _recognizer = TextRecognizer(script: _currentScript);

    // Optional UX: open camera immediately when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _captureAndRead();
    });
  }

  @override
  void dispose() {
    _recognizer.close();
    super.dispose();
  }

  void _updateScript(TextRecognitionScript? newScript) {
    if (newScript == null || newScript == _currentScript) return;
    setState(() {
      _busy = true;
      _currentScript = newScript;
    });
    _recognizer.close();
    _recognizer = TextRecognizer(script: _currentScript);
    setState(() {
      _busy = false;
    });
  }

  void _returnOnce(ScanResult r) {
    if (_returned) return;
    _returned = true;
    if (!mounted) return;
    Navigator.of(context).pop(r);
  }

  Future<void> _captureAndRead() async {
    if (_busy) return;

    setState(() => _busy = true);

    try {
      final XFile? xfile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 95,
      );

      if (xfile == null) {
        // Don't pop if they just cancelled the image picker, 
        // let them try again or use the manual button.
        setState(() => _busy = false);
        return;
      }

      final inputImage = InputImage.fromFile(File(xfile.path));
      final RecognizedText recognized = await _recognizer.processImage(inputImage);

      final String text = recognized.text.trim();

      if (text.isEmpty) {
        _returnOnce(const ScanResult(
          status: "fail",
          code: "EMPTY",
          value: "",
          message: "No text detected. Hold steady, improve lighting, and try again.",
        ));
        return;
      }

      if (text.length > widget.maxValueLength) {
        _returnOnce(const ScanResult(
          status: "fail",
          code: "TOO_LONG",
          value: "",
          message: "Recognized text is too large to process.",
        ));
        return;
      }

      _returnOnce(ScanResult(
        status: "pass",
        code: "OK",
        value: text,
        message: "",
      ));
    } catch (e) {
      _returnOnce(ScanResult(
        status: "fail",
        code: "ERROR",
        value: "",
        message: e.toString(),
      ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _cancel() {
    _returnOnce(const ScanResult(
      status: "fail",
      code: "CANCELLED",
      value: "",
      message: "Scan cancelled.",
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _cancel,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Language Script:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButton<TextRecognitionScript>(
                value: _currentScript,
                isExpanded: true,
                onChanged: _updateScript,
                items: TextRecognitionScript.values.map((script) {
                  return DropdownMenuItem(
                    value: script,
                    child: Text(script.name.toUpperCase()),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              if (_busy)
                const CircularProgressIndicator()
              else ...[
                const Text(
                  'Capture an image to read text',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _captureAndRead,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Capture & Read Text'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const Text(
                'Note: Tamil is not yet supported by ML Kit OCR. Use Devanagari for Hindi/Marathi.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
