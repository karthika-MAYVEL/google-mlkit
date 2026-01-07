import 'package:flutter/material.dart';
import 'scanner_result.dart';
import 'scanner_state.dart';


class ScannerButton extends StatefulWidget {
  final ValueChanged<ScanResult> onResult;

  /// Optional: customize icon
  final IconData icon;

  /// Optional: timeout seconds (default 6)
  final int timeoutSeconds;

  final String? tooltip;

  const ScannerButton({
    super.key,
    required this.onResult,
    this.icon = Icons.qr_code_scanner,
    this.timeoutSeconds = 10,
    this.tooltip,
  });


  @override
  State<ScannerButton> createState() => ScannerButtonState();
}
