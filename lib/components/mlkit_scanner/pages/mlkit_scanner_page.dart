// lib/components/mlkit_scanner/pages/mlkit_scanner_page.dart
//
// FULL SCREEN SCANNER PAGE (mobile_scanner -> ML Kit under the hood)
// -----------------------------------------------------------------
// Responsibilities:
// 1) Open camera scanner
// 2) Detect QR/Barcode
// 3) Enforce timeout (default 10s)
// 4) Validate scanned value:
//    - empty -> FAIL/EMPTY
//    - too long -> FAIL/TOO_LONG
// 5) Return ScanResult exactly once and pop()
// 6) Handle camera/scanner error -> FAIL/CAMERA_ERROR
//
// Notes:
// - Uses `_returned` guard to return only once.
// - Disposes controller in dispose() (single disposal place).
//

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/scan_result.dart';

class MlkitScannerPage extends StatefulWidget {
  const MlkitScannerPage({
    super.key,
    required this.timeoutSeconds,
    required this.maxValueLength,
    required this.title,
  });

  final int timeoutSeconds;
  final int maxValueLength;
  final String title;

  @override
  State<MlkitScannerPage> createState() => _MlkitScannerPageState();
}

class _MlkitScannerPageState extends State<MlkitScannerPage> {
  // STEP 1: Scanner controller (camera + MLKit scanning handled internally)
  final MobileScannerController _controller = MobileScannerController();

  // STEP 2: Timeout timer
  Timer? _timeoutTimer;

  // STEP 3: Ensure we return only once
  bool _returned = false;

  // STEP 3.1: Scanned result to display
  String? _scannedData;

  // STEP 4: Return result + close screen (single exit)
  void _returnResult(ScanResult r) {
    if (_returned) return;
    _returned = true;

    _timeoutTimer?.cancel();
    Navigator.of(context).pop(r);
  }

  @override
  void initState() {
    super.initState();

    // STEP 5: Start timeout (if nothing is scanned within N seconds)
    _timeoutTimer = Timer(Duration(seconds: widget.timeoutSeconds), () {
      _returnResult(const ScanResult(
        status: "fail",
        code: "TIMEOUT",
        value: "",
        message: "No code detected. Hold steady, improve lighting, and try again.",
      ));
    });
  }

  @override
  void dispose() {
    // STEP 6: Cleanup resources
    _timeoutTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanWindow = Rect.fromCenter(
      center: Offset(
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 2,
      ),
      width: 250,
      height: 250,
    );

    // STEP 7: Render camera scanner UI
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _returnResult(const ScanResult(
              status: "fail",
              code: "CANCELLED",
              value: "",
              message: "Scan cancelled.",
            )),
          )
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            fit: BoxFit.cover,
            scanWindow: scanWindow,
            // STEP 8: When scanner detects a barcode
            onDetect: (capture) {
              if (capture.barcodes.isEmpty) return;

              final String raw = (capture.barcodes.first.rawValue ?? "").trim();

              // Validate: empty value
              if (raw.isEmpty) {
                _returnResult(const ScanResult(
                  status: "fail",
                  code: "EMPTY",
                  value: "",
                  message: "QR/Barcode contains no readable value.",
                ));
                return;
              }

              // Validate: too long value
              if (raw.length > widget.maxValueLength) {
                _returnResult(const ScanResult(
                  status: "fail",
                  code: "TOO_LONG",
                  value: "",
                  message: "Scanned value is too large to process.",
                ));
                return;
              }

              // Update UI to show result
              setState(() {
                _scannedData = raw;
              });

              // Success - Wait a bit to show the result before popping
              Future.delayed(const Duration(milliseconds: 1500), () {
                _returnResult(ScanResult(
                  status: "pass",
                  code: "OK",
                  value: raw,
                  message: "",
                ));
              });
            },
          ),
          // Viewfinder Overlay
          CustomPaint(
            painter: ScannerOverlayPainter(scanWindow: scanWindow),
          ),
          // Result Display
          if (_scannedData != null)
            Positioned(
              bottom: 50,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Data Scanned",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _scannedData!,
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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

class ScannerOverlayPainter extends CustomPainter {
  final Rect scanWindow;

  ScannerOverlayPainter({required this.scanWindow});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()..addRect(scanWindow);

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    // Draw background with cutout
    canvas.drawPath(
      Path.combine(PathOperation.difference, backgroundPath, cutoutPath),
      backgroundPaint,
    );

    // Draw border around scan window
    canvas.drawRect(scanWindow, borderPaint);

    // Add corners highlighting
    final cornerPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

    const cornerLength = 30.0;

    // Top Left
    canvas.drawLine(scanWindow.topLeft, scanWindow.topLeft + const Offset(cornerLength, 0), cornerPaint);
    canvas.drawLine(scanWindow.topLeft, scanWindow.topLeft + const Offset(0, cornerLength), cornerPaint);

    // Top Right
    canvas.drawLine(scanWindow.topRight, scanWindow.topRight + const Offset(-cornerLength, 0), cornerPaint);
    canvas.drawLine(scanWindow.topRight, scanWindow.topRight + const Offset(0, cornerLength), cornerPaint);

    // Bottom Left
    canvas.drawLine(scanWindow.bottomLeft, scanWindow.bottomLeft + const Offset(cornerLength, 0), cornerPaint);
    canvas.drawLine(scanWindow.bottomLeft, scanWindow.bottomLeft + const Offset(0, -cornerLength), cornerPaint);

    // Bottom Right
    canvas.drawLine(scanWindow.bottomRight, scanWindow.bottomRight + const Offset(-cornerLength, 0), cornerPaint);
    canvas.drawLine(scanWindow.bottomRight, scanWindow.bottomRight + const Offset(0, -cornerLength), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
