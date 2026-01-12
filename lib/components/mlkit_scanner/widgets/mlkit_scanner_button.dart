// lib/components/mlkit_scanner/widgets/mlkit_scanner_button.dart
//
// REUSABLE COMPONENT WIDGET (the one you place anywhere)
// -----------------------------------------------------
// Responsibilities:
// 1) Render a scan IconButton
// 2) On tap, push MlkitScannerPage
// 3) Receive ScanResult and pass to onResult
// 4) Prevent multiple openings with `_opening`
// 5) Always reset `_opening` using try/finally
//

import 'package:flutter/material.dart';
import '../models/scan_result.dart';
import '../pages/mlkit_scanner_page.dart';
import '../pages/mlkit_ocr_page.dart';

class MlkitScannerButton extends StatefulWidget {
  const MlkitScannerButton({
    super.key,
    this.onResult,
    this.controller,
    this.timeoutSeconds = 10,
    this.maxValueLength = 512,
    this.icon = Icons.qr_code_scanner,
    this.tooltip = "Scan QR/Barcode/OCR",
    this.title = "Scan",
  });

  /// Optional callback for custom result handling
  final void Function(ScanResult result)? onResult;

  /// Optional controller to automatically update text
  final TextEditingController? controller;

  final int timeoutSeconds;
  final int maxValueLength;
  final IconData icon;
  final String tooltip;
  final String title;

  @override
  State<MlkitScannerButton> createState() => _MlkitScannerButtonState();
}

class _MlkitScannerButtonState extends State<MlkitScannerButton> {
  bool _opening = false;

  Future<void> _handleResult(ScanResult result) async {
    if (result.status == 'pass' && widget.controller != null) {
      widget.controller!.text = result.value;
    }
    if (widget.onResult != null) {
      widget.onResult!(result);
    }
  }

  Future<void> _openScanner() async {
    if (_opening) return;
    _opening = true;

    try {
      final String? choice = await showModalBottomSheet<String>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Choose Scan Mode',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_scanner, color: Colors.deepPurple),
                title: const Text('Scan QR / Barcode'),
                onTap: () => Navigator.pop(context, 'barcode'),
              ),
              ListTile(
                leading: const Icon(Icons.text_fields, color: Colors.deepPurple),
                title: const Text('Scan Text (OCR)'),
                onTap: () => Navigator.pop(context, 'ocr'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );

      if (choice == 'barcode') {
        await _scanBarcode();
      } else if (choice == 'ocr') {
        await _scanOcr();
      }
    } finally {
      _opening = false;
    }
  }

  Future<void> _scanBarcode() async {
    final ScanResult? result = await Navigator.of(context).push<ScanResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => MlkitScannerPage(
          timeoutSeconds: widget.timeoutSeconds,
          maxValueLength: widget.maxValueLength,
          title: widget.title,
        ),
      ),
    );
    if (result != null) await _handleResult(result);
  }

  Future<void> _scanOcr() async {
    final ScanResult? result = await Navigator.of(context).push<ScanResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => MlkitOcrPage(
          title: "Scan Text",
          maxValueLength: widget.maxValueLength,
        ),
      ),
    );
    if (result != null) await _handleResult(result);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _openScanner,
      icon: Icon(widget.icon, color: Colors.deepPurple),
      tooltip: widget.tooltip,
    );
  }
}
