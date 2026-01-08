// lib/components/mlkit_scanner/widgets/mlkit_scanner_button.dart
//
// STEP 3 (REUSABLE FRONTEND WIDGET)
// ---------------------------------
// This is the component you place in any screen (AppBar, form, etc.).
//
// What it does:
// 1) Renders a scan IconButton
// 2) On tap, opens the full-screen ML Kit scanner page
// 3) Receives ScanResult and returns it via onResult callback
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

  /// Caller receives pass/fail + value + code + message
  final void Function(ScanResult result) onResult;

  /// Requirement: fail if nothing read within 10 seconds (configurable)
  final int timeoutSeconds;

  /// Requirement: validator to reject huge scanned values (configurable)
  final int maxValueLength;

  /// Button icon
  final IconData icon;

  /// Tooltip for the button
  final String tooltip;

  /// Title displayed in scanner screen AppBar
  final String title;

  @override
  State<MlkitScannerButton> createState() => _MlkitScannerButtonState();
}

class _MlkitScannerButtonState extends State<MlkitScannerButton> {
  // Prevent double-taps opening multiple scanner routes.
  bool _opening = false;

  Future<void> _openScanner() async {
    // STEP 1: Ignore if already opening
    if (_opening) return;
    _opening = true;

    try {
      // STEP 2: Open the scanner page
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
          // STEP 3: If user backs out without result, return CANCELLED
          .then(
            (v) => v ??
                const ScanResult(
                  status: "fail",
                  code: "CANCELLED",
                  value: "",
                  message: "Scan cancelled.",
                ),
          );

      // STEP 4: Return result to caller
      widget.onResult(result);
    } finally {
      // STEP 5: Always reset, even if errors happen
      _opening = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI: simple icon button
    return IconButton(
      onPressed: _openScanner,
      icon: Icon(widget.icon),
      tooltip: widget.tooltip,
    );
  }
}
