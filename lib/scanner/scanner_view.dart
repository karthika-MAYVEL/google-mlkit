import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

import 'scanner_mlkit.dart';
import 'scanner_overlay.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({super.key});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  CameraController? _controller;
  final ScannerMLKit _mlkit = ScannerMLKit();

  bool _busy = false;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cams = await availableCameras();
      final back = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cams.first,
      );

      final c = CameraController(
        back,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup:
            Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.yuv420,
      );

      await c.initialize();
      await c.startImageStream(_onFrame);

      if (!mounted) return;
      setState(() {
        _controller = c;
        _ready = true;
      });
    } catch (_) {
      if (mounted) Navigator.of(context).pop<String?>(null);
    }
  }

  Future<void> _onFrame(CameraImage image) async {
    if (_busy || !_ready) return;
    _busy = true;

    try {
      final input = _toInputImage(image);
      if (input == null) return;

      final value = await _mlkit.scan(input);
      if (value != null && value.trim().isNotEmpty && mounted) {
        Navigator.of(context).pop<String?>(value.trim());
      }
    } finally {
      _busy = false;
    }
  }

  InputImage? _toInputImage(CameraImage image) {
    final controller = _controller;
    if (controller == null) return null;

    final rotation =
        InputImageRotationValue.fromRawValue(controller.description.sensorOrientation) ??
            InputImageRotation.rotation0deg;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    final bytes = _concatenatePlanes(image.planes);

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  List<int> _concatenatePlanes(List<Plane> planes) {
    final all = <int>[];
    for (final p in planes) {
      all.addAll(p.bytes);
    }
    return all;
  }

  @override
  void dispose() {
    _mlkit.dispose();
    final c = _controller;
    if (c != null) {
      c.stopImageStream().catchError((_) {});
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;

    return Scaffold(
      appBar: AppBar(title: const Text(ScannerOverlayText.title)),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (c != null && c.value.isInitialized) CameraPreview(c) else const Center(child: CircularProgressIndicator()),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ScannerOverlayText.align,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6),
                  Text(
                    ScannerOverlayText.holdSteady,
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
