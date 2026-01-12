import 'package:flutter/material.dart';
import 'package:google_mlkit/services/scanner_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

enum ScannerView { selection, ocrOptions, qrScanner }

class MlkitScanner extends StatefulWidget {
  final Function(Map<String, dynamic> result) onResult;

  const MlkitScanner({super.key, required this.onResult});

  /// Static method to open the scanner globally.
  /// Returns the structured result map or null if dismissed.
  static Future<Map<String, dynamic>?> scan(BuildContext context) async {
    return await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.95,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: MlkitScanner(
            onResult: (result) => Navigator.pop(context, result),
          ),
        ),
      ),
    );
  }

  @override
  State<MlkitScanner> createState() => _MlkitScannerState();
}

class _MlkitScannerState extends State<MlkitScanner> {
  final ScannerService _scannerService = ScannerService();
  final ImagePicker _imagePicker = ImagePicker();
  
  ScannerView _currentView = ScannerView.selection;
  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerService.dispose();
    super.dispose();
  }

  Future<void> _processOCR(ImageSource source) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        final result = await _scannerService.recognizeText(image.path);
        widget.onResult(result);
      } else {
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      widget.onResult({
        "success": false,
        "scanType": "ocr",
        "value": "",
        "message": "Error: $e"
      });
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _onQRDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String code = barcodes.first.displayValue ?? barcodes.first.rawValue ?? "";
      if (code.isNotEmpty) {
        widget.onResult({
          "success": true,
          "scanType": "qr",
          "value": code,
          "message": "Successful scan"
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    String title = 'Scanner';
    if (_currentView == ScannerView.ocrOptions) title = 'OCR Options';
    if (_currentView == ScannerView.qrScanner) title = 'QR / Barcode';

    return AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(_currentView == ScannerView.selection ? Icons.close : Icons.arrow_back),
        onPressed: () {
          if (_currentView == ScannerView.selection) {
            Navigator.pop(context);
          } else {
            setState(() => _currentView = ScannerView.selection);
          }
        },
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: Colors.black,
    );
  }

  Widget _buildBody() {
    if (_isProcessing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing image...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    switch (_currentView) {
      case ScannerView.selection:
        return _buildSelectionView();
      case ScannerView.ocrOptions:
        return _buildOCROptionsView();
      case ScannerView.qrScanner:
        return _buildQRScannerView();
    }
  }

  Widget _buildSelectionView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Choose Scanning Mode',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Select the type of data you want to capture',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          _selectionCard(
            icon: Icons.qr_code_scanner_rounded,
            title: 'QR / Barcode',
            description: 'Scan any standard QR or Barcode instantly.',
            color: Colors.blue,
            onTap: () => setState(() => _currentView = ScannerView.qrScanner),
          ),
          const SizedBox(height: 20),
          _selectionCard(
            icon: Icons.text_snippet_rounded,
            title: 'OCR Text Recognition',
            description: 'Extract text from documents or images.',
            color: Colors.orange,
            onTap: () => setState(() => _currentView = ScannerView.ocrOptions),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _selectionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
          color: color.withValues(alpha: 0.05),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildOCROptionsView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _selectionCard(
            icon: Icons.camera_alt_rounded,
            title: 'Capture with Camera',
            description: 'Take a photo of the text you want to scan.',
            color: Colors.green,
            onTap: () => _processOCR(ImageSource.camera),
          ),
          const SizedBox(height: 20),
          _selectionCard(
            icon: Icons.photo_library_rounded,
            title: 'Upload from Gallery',
            description: 'Pick an existing image from your device.',
            color: Colors.purple,
            onTap: () => _processOCR(ImageSource.gallery),
          ),
        ],
      ),
    );
  }

  Widget _buildQRScannerView() {
    return Stack(
      children: [
        MobileScanner(
          onDetect: _onQRDetect,
        ),
        _buildOverlay(),
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Align QR code within the frame',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),
      ],
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
