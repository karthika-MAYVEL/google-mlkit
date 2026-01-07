import 'dart:async';
import 'package:flutter/material.dart';

import 'scanner_button.dart';
import 'scanner_overlay.dart';
import 'scanner_permissions.dart';
import 'scanner_result.dart';
import 'scanner_validator.dart';
import 'scanner_view.dart';

class ScannerButtonState extends State<ScannerButton> {
  bool isScanning = false;
  Timer? _timeoutTimer;
  bool _scannerRouteOpen = false;

  Future<void> startScan() async {
    if (isScanning) return;

    final hasPermission = await ScannerPermissions.requestCamera();
    if (!hasPermission) {
      widget.onResult(ScanResult.error(ScannerOverlayText.denied));
      return;
    }

    setState(() => isScanning = true);

    _timeoutTimer = Timer(
      Duration(seconds: widget.timeoutSeconds),
      () {
        // If the scanner screen is open, close it.
        if (_scannerRouteOpen && mounted) {
          Navigator.of(context).maybePop<String?>(null);
        }

        stopScan();
        widget.onResult(ScanResult.error(ScannerOverlayText.timeout));
      },
    );

    _scannerRouteOpen = true;

    // Open full-screen scanner screen and wait for scanned value
    final String? value = await Navigator.of(context).push<String?>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const ScannerView(),
      ),
    );

    _scannerRouteOpen = false;

    // If timeout already fired, ignore result.
    if (!mounted || !isScanning) return;

    onScanDetected(value);
  }

  void onScanDetected(String? value) {
    stopScan();

    final v = value?.trim() ?? "";
    if (v.isEmpty) {
      widget.onResult(ScanResult.error(ScannerOverlayText.timeout));
      return;
    }

    if (!ScannerValidator.isValid(v)) {
      widget.onResult(ScanResult.error(ScannerOverlayText.unreadable));
      return;
    }

    widget.onResult(ScanResult.success(v));
  }

  void stopScan() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;

    if (mounted) {
      setState(() => isScanning = false);
    }
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }
}
