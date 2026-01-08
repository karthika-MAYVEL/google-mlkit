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
  });

  final String title;
  final int maxValueLength;

  @override
  State<MlkitOcrPage> createState() => _MlkitOcrPageState();
}

class _MlkitOcrPageState extends State<MlkitOcrPage> {
  final ImagePicker _picker = ImagePicker();
  late final TextRecognizer _recognizer;

  bool _busy = false;
  bool _returned = false;

  @override
  void initState() {
    super.initState();
    _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

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
        _returnOnce(const ScanResult(
          status: "fail",
          code: "CANCELLED",
          value: "",
          message: "Scan cancelled.",
        ));
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
        child: _busy
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Capture an image to read text'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _captureAndRead,
                    child: const Text('Capture & Read Text'),
                  ),
                ],
              ),
      ),
    );
  }
}
