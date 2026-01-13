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

class MlkitScannerButton extends StatefulWidget {
  const MlkitScannerButton({
    super.key,
    required this.onResult,
    this.timeoutSeconds = 10,
    this.maxValueLength = 512,
    this.icon = Icons.qr_code_scanner,
    this.tooltip = "Scan QR/Barcode",
    this.title = "Scan",
  });

  final void Function(ScanResult result) onResult;

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

  Future<void> _openScanner() async {
    if (_opening) return;
    _opening = true;

    try {
      final ScanResult result = await Navigator.of(context)
          .push<ScanResult>(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => MlkitScannerPage(
                timeoutSeconds: widget.timeoutSeconds,
                maxValueLength: widget.maxValueLength,
                title: widget.title,
              ),
            ),
          )
          .then(
            (v) => v ??
                const ScanResult(
                  status: "fail",
                  code: "CANCELLED",
                  value: "",
                  message: "Scan cancelled.",
                ),
          );

      widget.onResult(result);
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
