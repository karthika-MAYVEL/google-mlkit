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
    required this.onResult,
    this.timeoutSeconds = 10,
    this.maxValueLength = 512,
    this.icon = Icons.qr_code_scanner,
    this.tooltip = "Scan QR/Barcode",
    this.title = "Scan",
    this.mode = "chooser", // "barcode" | "ocr" | "chooser"
  });

  final void Function(ScanResult result) onResult;

  final int timeoutSeconds;
  final int maxValueLength;

  final IconData icon;
  final String tooltip;

  final String title;
  final String mode;

  @override
  State<MlkitScannerButton> createState() => _MlkitScannerButtonState();
}

class _MlkitScannerButtonState extends State<MlkitScannerButton> {
  bool _opening = false;

  Future<void> _openScanner() async {
    if (_opening) return;
    _opening = true;

    try {
      String selectedMode = widget.mode;

      if (widget.mode == "chooser") {
        final String? choice = await showModalBottomSheet<String>(
          context: context,
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.qr_code_scanner),
                  title: const Text("Scan QR/Barcode"),
                  onTap: () => Navigator.pop(context, "barcode"),
                ),
                ListTile(
                  leading: const Icon(Icons.text_fields),
                  title: const Text("Capture & Read Text (OCR)"),
                  onTap: () => Navigator.pop(context, "ocr"),
                ),
              ],
            ),
          ),
        );

        if (choice == null) return;
        selectedMode = choice;
      }

      final ScanResult? result = await Navigator.of(context).push<ScanResult>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => selectedMode == "ocr"
              ? MlkitOcrPage(
                  title: "OCR Scanner",
                  maxValueLength: widget.maxValueLength,
                )
              : MlkitScannerPage(
                  timeoutSeconds: widget.timeoutSeconds,
                  maxValueLength: widget.maxValueLength,
                  title: widget.title,
                ),
        ),
      );

      widget.onResult(
        result ??
            const ScanResult(
              status: "fail",
              code: "CANCELLED",
              value: "",
              message: "Scan cancelled.",
            ),
      );
    } finally {
      _opening = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _openScanner,
      icon: Icon(widget.icon),
      tooltip: widget.tooltip,
    );
  }
}
