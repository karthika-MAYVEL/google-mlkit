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
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
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
    this.defaultOcrScript = TextRecognitionScript.latin,
  });

  final void Function(ScanResult result) onResult;

  final int timeoutSeconds;
  final int maxValueLength;

  final IconData icon;
  final String tooltip;

  final String title;
  final String mode;
  final TextRecognitionScript defaultOcrScript;

  @override
  State<MlkitScannerButton> createState() => _MlkitScannerButtonState();
}

class _MlkitScannerButtonState extends State<MlkitScannerButton> {
  bool _opening = false;

  Future<void> _openScanner() async {
    if (_opening) return;
    _opening = true;

    try {
      // 1. Check/Request Camera Permission
      PermissionStatus status = await Permission.camera.status;

      if (!status.isGranted) {
        if (status.isPermanentlyDenied) {
          final bool? openSettings = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Camera Permission Required"),
              content: const Text(
                  "Camera permission is permanently denied. Please enable it in system settings to use the scanner."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Open Settings"),
                ),
              ],
            ),
          );

          if (openSettings == true) {
            await openAppSettings();
          }
          
          widget.onResult(const ScanResult(
            status: "fail",
            code: "CANCELLED",
            value: "",
            message: "Camera permission required.",
          ));
          return;
        }

        // Ask user to allow (Pre-request dialog)
        final bool? proceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Camera Access"),
            content: const Text("This app needs camera access to scan QR codes and read text."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Allow"),
              ),
            ],
          ),
        );

        if (proceed != true) {
          widget.onResult(const ScanResult(
            status: "fail",
            code: "CANCELLED",
            value: "",
            message: "Permission request cancelled.",
          ));
          return;
        }

        status = await Permission.camera.request();
        if (!status.isGranted) {
          widget.onResult(const ScanResult(
            status: "fail",
            code: "CANCELLED",
            value: "",
            message: "Camera permission denied.",
          ));
          return;
        }
      }

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

        if (choice == null) {
          widget.onResult(const ScanResult(
            status: "fail",
            code: "CANCELLED",
            value: "",
            message: "Selection cancelled.",
          ));
          return;
        }
        selectedMode = choice;
      }

      final ScanResult? result = await Navigator.of(context).push<ScanResult>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => selectedMode == "ocr"
              ? MlkitOcrPage(
                  title: "OCR Scanner",
                  maxValueLength: widget.maxValueLength,
                  initialScript: widget.defaultOcrScript,
                )
              : MlkitScannerPage(
                  timeoutSeconds: widget.timeoutSeconds,
                  maxValueLength: widget.maxValueLength,
                  title: widget.title,
                ),
        ),
      );

      if (result != null) {
        widget.onResult(result);
      } else {
        widget.onResult(
          const ScanResult(
            status: "fail",
            code: "CANCELLED",
            value: "",
            message: "Scan cancelled.",
          ),
        );
      }
    } catch (e) {
      widget.onResult(ScanResult(
        status: "fail",
        code: "CAMERA_ERROR",
        value: "",
        message: "Error opening scanner: $e",
      ));
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
