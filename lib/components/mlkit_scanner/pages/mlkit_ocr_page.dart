import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

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

  // Editing state
  TextEditingController? _editingController;

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
    _editingController?.dispose();
    super.dispose();
  }

  void _updateScript(TextRecognitionScript? newScript) {
    if (newScript == null || newScript == _currentScript) return;
    setState(() {
      _busy = true;
      _currentScript = newScript;
      _editingController?.dispose();
      _editingController = null;
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

    setState(() {
      _busy = true;
      _editingController?.dispose();
      _editingController = null;
    });

    try {
      // 1. Pick Image
      final XFile? xfile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 95,
      );

      if (xfile == null) {
        setState(() => _busy = false);
        return;
      }

      // 2. Provide Choice: Crop or Use Image
      final String? choice = await showModalBottomSheet<String>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Image Captured',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.crop),
                title: const Text('Crop Image'),
                subtitle: const Text('Refine the area for better accuracy'),
                onTap: () => Navigator.pop(context, 'crop'),
              ),
              ListTile(
                leading: const Icon(Icons.check),
                title: const Text('Use Image Directly'),
                subtitle: const Text('Scan the entire photo'),
                onTap: () => Navigator.pop(context, 'use'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );

      if (choice == null) {
        setState(() => _busy = false);
        return;
      }

      File finalFile = File(xfile.path);

      if (choice == 'crop') {
        // 3. Crop Image
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: xfile.path,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: Theme.of(context).colorScheme.primary,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
            ),
            IOSUiSettings(
              title: 'Crop Image',
            ),
          ],
        );

        if (croppedFile == null) {
          setState(() => _busy = false);
          return;
        }
        finalFile = File(croppedFile.path);
      }

      // 4. Recognize Text
      final inputImage = InputImage.fromFile(finalFile);
      final RecognizedText recognized = await _recognizer.processImage(inputImage);

      if (recognized.blocks.isEmpty) {
        _returnOnce(const ScanResult(
          status: "fail",
          code: "EMPTY",
          value: "",
          message: "No text detected. Try again with better lighting or focus.",
        ));
        return;
      }

      setState(() {
        final String fullText = recognized.blocks.map((b) => b.text).join("\n");
        _editingController = TextEditingController(text: fullText);
        _busy = false;
      });
    } catch (e) {
      _returnOnce(ScanResult(
        status: "fail",
        code: "ERROR",
        value: "",
        message: e.toString(),
      ));
    } finally {
      if (mounted && _editingController == null) {
        setState(() => _busy = false);
      }
    }
  }

  void _confirmResult() {
    if (_editingController == null) return;

    final String finalValue = _editingController!.text.trim();

    if (finalValue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Text cannot be empty.")),
      );
      return;
    }

    if (finalValue.length > widget.maxValueLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Text is too large to process.")),
      );
      return;
    }

    _returnOnce(ScanResult(
      status: "pass",
      code: "OK",
      value: finalValue,
      message: "",
    ));
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
      body: _editingController != null ? _buildEditUI() : _buildCaptureUI(),
      bottomNavigationBar: _editingController != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _confirmResult,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text('Confirm & Save Text'),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildCaptureUI() {
    return Center(
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
    );
  }

  Widget _buildEditUI() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Review and edit recognized text:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _editingController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Recognized text will appear here...',
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                _editingController?.dispose();
                _editingController = null;
              });
              _captureAndRead();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retake Photo'),
          ),
        ),
      ],
    );
  }
}
