import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'scanner_service.dart';
import 'models.dart';

class MlkitScanner extends StatefulWidget {
  final Function(ScanResult result) onResult;

  const MlkitScanner({super.key, required this.onResult});

  /// Static method to trigger the scanner flow.
  /// It first shows a selection pop-up, then proceeds to the chosen scanning mode.
  static Future<ScanResult?> show(BuildContext context) async {
    final ScanType? type = await showDialog<ScanType>(
      context: context,
      builder: (context) => _ScannerSelectionDialog(
        onSelect: (type) => Navigator.pop(context, type),
      ),
    );

    if (type == null) return null;

    if (!context.mounted) return null;

    return await Navigator.push<ScanResult>(
      context,
      MaterialPageRoute(
        builder: (context) => MlkitScannerScreen(
          type: type,
          onResult: (result) => Navigator.pop(context, result),
        ),
      ),
    );
  }

  @override
  State<MlkitScanner> createState() => _MlkitScannerState();
}

class _MlkitScannerState extends State<MlkitScanner> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.qr_code_scanner, color: Colors.blue),
      onPressed: () async {
        final result = await MlkitScanner.show(context);
        if (result != null) {
          widget.onResult(result);
        }
      },
      tooltip: 'Open Scanner',
    );
  }
}

class _ScannerSelectionDialog extends StatelessWidget {
  final Function(ScanType type) onSelect;

  const _ScannerSelectionDialog({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Scanning Mode',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _selectionButton(
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'QR / Barcode',
                  onTap: () => onSelect(ScanType.qr),
                ),
                _selectionButton(
                  icon: Icons.text_snippet_rounded,
                  label: 'OCR',
                  onTap: () => onSelect(ScanType.ocr),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class MlkitScannerScreen extends StatefulWidget {
  final ScanType type;
  final Function(ScanResult result) onResult;

  const MlkitScannerScreen({super.key, required this.type, required this.onResult});

  @override
  State<MlkitScannerScreen> createState() => _MlkitScannerScreenState();
}

class _MlkitScannerScreenState extends State<MlkitScannerScreen> {
  final ScannerService _scannerService = ScannerService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerService.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    setState(() => _isProcessing = true);
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final result = widget.type == ScanType.qr
            ? await _scannerService.scanBarcode(image.path)
            : await _scannerService.recognizeText(image.path);
        widget.onResult(result);
      }
    } catch (e) {
      widget.onResult(ScanResult(
        success: false,
        scanType: widget.type,
        value: "",
        message: "Error: $e",
      ));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _captureOCR() async {
    setState(() => _isProcessing = true);
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
      if (image != null) {
        final result = await _scannerService.recognizeText(image.path);
        widget.onResult(result);
      }
    } catch (e) {
      widget.onResult(ScanResult(
        success: false,
        scanType: ScanType.ocr,
        value: "",
        message: "Error: $e",
      ));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.type == ScanType.qr ? 'Scan QR / Barcode' : 'Scan OCR'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: _pickFromGallery,
            tooltip: 'Pick from Gallery',
          ),
        ],
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : widget.type == ScanType.qr
              ? _buildQRScanner()
              : _buildOCRScanner(),
    );
  }

  Widget _buildQRScanner() {
    return Stack(
      children: [
        MobileScanner(
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              final String code = barcodes.first.displayValue ?? barcodes.first.rawValue ?? "";
              if (code.isNotEmpty) {
                widget.onResult(ScanResult(
                  success: true,
                  scanType: ScanType.qr,
                  value: code,
                  message: "Successful scan",
                ));
              }
            }
          },
        ),
        _buildOverlay(),
      ],
    );
  }

  Widget _buildOCRScanner() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.text_fields_rounded, size: 100, color: Colors.white54),
          const SizedBox(height: 32),
          const Text(
            'Point camera at text and capture',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 48),
          GestureDetector(
            onTap: _captureOCR,
            child: Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: const Icon(Icons.camera_alt, size: 40, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: ShapeDecoration(
        shape: ScannerOverlayShape(
          borderColor: Colors.blue,
          borderRadius: 20,
          borderLength: 40,
          borderWidth: 8,
          cutOutSize: 280,
        ),
      ),
    );
  }
}

class ScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const ScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 1.0,
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(center: rect.center, width: cutOutSize, height: cutOutSize),
          Radius.circular(borderRadius)))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final backgroundPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final cutOutRect = Rect.fromCenter(
      center: rect.center,
      width: cutOutSize,
      height: cutOutSize,
    );

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(rect),
        Path()
          ..addRRect(RRect.fromRectAndRadius(
            cutOutRect,
            Radius.circular(borderRadius),
          )),
      ),
      backgroundPaint,
    );

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // Top left
    path.moveTo(cutOutRect.left, cutOutRect.top + borderLength);
    path.lineTo(cutOutRect.left, cutOutRect.top + borderRadius);
    path.arcToPoint(Offset(cutOutRect.left + borderRadius, cutOutRect.top), radius: Radius.circular(borderRadius), clockwise: true);
    path.lineTo(cutOutRect.left + borderLength, cutOutRect.top);

    // Top right
    path.moveTo(cutOutRect.right - borderLength, cutOutRect.top);
    path.lineTo(cutOutRect.right - borderRadius, cutOutRect.top);
    path.arcToPoint(Offset(cutOutRect.right, cutOutRect.top + borderRadius), radius: Radius.circular(borderRadius), clockwise: true);
    path.lineTo(cutOutRect.right, cutOutRect.top + borderLength);

    // Bottom right
    path.moveTo(cutOutRect.right, cutOutRect.bottom - borderLength);
    path.lineTo(cutOutRect.right, cutOutRect.bottom - borderRadius);
    path.arcToPoint(Offset(cutOutRect.right - borderRadius, cutOutRect.bottom), radius: Radius.circular(borderRadius), clockwise: true);
    path.lineTo(cutOutRect.right - borderLength, cutOutRect.bottom);

    // Bottom left
    path.moveTo(cutOutRect.left + borderLength, cutOutRect.bottom);
    path.lineTo(cutOutRect.left + borderRadius, cutOutRect.bottom);
    path.arcToPoint(Offset(cutOutRect.left, cutOutRect.bottom - borderRadius), radius: Radius.circular(borderRadius), clockwise: true);
    path.lineTo(cutOutRect.left, cutOutRect.bottom - borderLength);

    canvas.drawPath(path, borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return ScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      borderRadius: borderRadius,
      borderLength: borderLength,
      cutOutSize: cutOutSize,
    );
  }
}
