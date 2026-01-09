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

  // Selection state
  List<TextBlock>? _recognizedBlocks;
  final Set<int> _selectedBlockIndices = {};

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
      _recognizedBlocks = null;
      _selectedBlockIndices.clear();
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
      _recognizedBlocks = null;
      _selectedBlockIndices.clear();
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

      // 2. Crop Image
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

      // 3. Recognize Text
      final inputImage = InputImage.fromFile(File(croppedFile.path));
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
        _recognizedBlocks = recognized.blocks;
        // Default select all
        for (int i = 0; i < recognized.blocks.length; i++) {
          _selectedBlockIndices.add(i);
        }
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
      if (mounted && _recognizedBlocks == null) {
        setState(() => _busy = false);
      }
    }
  }

  void _confirmSelection() {
    if (_recognizedBlocks == null || _selectedBlockIndices.isEmpty) return;

    final List<String> selectedTexts = [];
    final List<int> sortedIndices = _selectedBlockIndices.toList()..sort();
    
    for (final index in sortedIndices) {
      selectedTexts.add(_recognizedBlocks![index].text);
    }

    final String finalValue = selectedTexts.join("\n").trim();

    if (finalValue.length > widget.maxValueLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selected text is too large to process.")),
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
      body: _recognizedBlocks != null ? _buildSelectionUI() : _buildCaptureUI(),
      bottomNavigationBar: _recognizedBlocks != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _selectedBlockIndices.isEmpty ? null : _confirmSelection,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: Text('Confirm Selection (${_selectedBlockIndices.length})'),
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

  Widget _buildSelectionUI() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select text to keep:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        for (int i = 0; i < _recognizedBlocks!.length; i++) {
                          _selectedBlockIndices.add(i);
                        }
                      });
                    },
                    child: const Text('Select All'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedBlockIndices.clear();
                      });
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: _recognizedBlocks!.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final block = _recognizedBlocks![index];
              final isSelected = _selectedBlockIndices.contains(index);
              return CheckboxListTile(
                value: isSelected,
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _selectedBlockIndices.add(index);
                    } else {
                      _selectedBlockIndices.remove(index);
                    }
                  });
                },
                title: Text(block.text),
                controlAffinity: ListTileControlAffinity.leading,
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                _recognizedBlocks = null;
                _selectedBlockIndices.clear();
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
