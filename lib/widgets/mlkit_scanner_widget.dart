import 'package:flutter/material.dart';
import 'package:google_mlkit/services/scanner_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

enum ScannerView { selection, ocrOptions, qrScanner }

class MlkitScannerWidget extends StatefulWidget {
  final Function(Map<String, dynamic> result) onResult;

  const MlkitScannerWidget({super.key, required this.onResult});

  @override
  State<MlkitScannerWidget> createState() => _MlkitScannerWidgetState();
}

class _MlkitScannerWidgetState extends State<MlkitScannerWidget> {
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
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return AppBar(
      title: const Text('Scanner'),
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.pop(context),
      ),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    );
  }

  Widget _buildBody() {
    if (_isProcessing) {
      return const Center(child: CircularProgressIndicator());
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _largeButton(
            icon: Icons.text_fields,
            label: 'OCR (Text Recognition)',
            onPressed: () => setState(() => _currentView = ScannerView.ocrOptions),
          ),
          const SizedBox(height: 30),
          _largeButton(
            icon: Icons.qr_code_scanner,
            label: 'QR / Barcode',
            onPressed: () => setState(() => _currentView = ScannerView.qrScanner),
          ),
        ],
      ),
    );
  }

  Widget _buildOCROptionsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'OCR Options',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          _largeButton(
            icon: Icons.photo_library,
            label: 'Upload from Gallery',
            onPressed: () => _processOCR(ImageSource.gallery),
          ),
          const SizedBox(height: 20),
          _largeButton(
            icon: Icons.camera_alt,
            label: 'Capture from Camera',
            onPressed: () => _processOCR(ImageSource.camera),
          ),
          const SizedBox(height: 40),
          TextButton(
            onPressed: () => setState(() => _currentView = ScannerView.selection),
            child: const Text('Back'),
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
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: TextButton(
              onPressed: () => setState(() => _currentView = ScannerView.selection),
              style: TextButton.styleFrom(backgroundColor: Colors.black54, foregroundColor: Colors.white),
              child: const Text('Back'),
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
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 250,
        ),
      ),
    );
  }

  Widget _largeButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 250,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
      ..strokeWidth = borderWidth;

    final path = Path();
    path.moveTo(cutOutRect.left, cutOutRect.top + borderLength);
    path.lineTo(cutOutRect.left, cutOutRect.top);
    path.lineTo(cutOutRect.left + borderLength, cutOutRect.top);
    path.moveTo(cutOutRect.right - borderLength, cutOutRect.top);
    path.lineTo(cutOutRect.right, cutOutRect.top);
    path.lineTo(cutOutRect.right, cutOutRect.top + borderLength);
    path.moveTo(cutOutRect.right, cutOutRect.bottom - borderLength);
    path.lineTo(cutOutRect.right, cutOutRect.bottom);
    path.lineTo(cutOutRect.right - borderLength, cutOutRect.bottom);
    path.moveTo(cutOutRect.left + borderLength, cutOutRect.bottom);
    path.lineTo(cutOutRect.left, cutOutRect.bottom);
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
