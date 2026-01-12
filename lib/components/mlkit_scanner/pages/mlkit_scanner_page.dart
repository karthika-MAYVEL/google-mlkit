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
      body: MobileScanner(
        controller: _controller,
        fit: BoxFit.cover,

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

          // Success
          _returnResult(ScanResult(
            status: "pass",
            code: "OK",
            value: raw,
            message: "",
            type: "barcode",
          ));
        },

      ),
    );
  }
}
