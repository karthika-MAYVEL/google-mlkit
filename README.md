# ML Kit Global Scanner Component

A professional, reusable Flutter component for QR/Barcode scanning and OCR (Text Recognition) using Google ML Kit and `mobile_scanner`.

## Features

- **Global Reusability**: Easily trigger the scanner from anywhere in your app using a static method.
- **Professional UI**: Polished selection screens, scanning overlays, and animations.
- **QR / Barcode Scanning**: High-performance scanning using `mobile_scanner`.
- **OCR (Text Recognition)**: Extract text from images or camera captures using Google ML Kit.
- **Structured Output**: Returns a consistent data format for easy integration.

## Getting Started

### Installation

1.  **Add dependencies** to your `pubspec.yaml`:
    ```yaml
    dependencies:
      mobile_scanner: ^6.0.0
      google_mlkit_text_recognition: ^0.14.0
      image_picker: ^1.1.2
      permission_handler: ^11.3.1
    ```

2.  **Configure Permissions**:
    - **Android**: Add `CAMERA` and storage permissions to `AndroidManifest.xml`.
    - **iOS**: Add `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` to `Info.plist`.

## Usage

### Global Trigger

You can open the scanner from any `BuildContext` using the static `scan` method:

```dart
import 'package:google_mlkit/widgets/mlkit_scanner_widget.dart';

void _onScanPressed() async {
  final result = await MlkitScanner.scan(context);
  
  if (result != null && result['success'] == true) {
    print("Scanned value: ${result['value']}");
    print("Scan type: ${result['scanType']}");
  }
}
```

### Structured Output Format

The scanner returns a `Map<String, dynamic>`:

```json
{
  "success": true,
  "scanType": "ocr | qr",
  "value": "scanned text or code value",
  "message": "Successful scan"
}
```

## Project Structure

- `lib/widgets/mlkit_scanner_widget.dart`: The core `MlkitScanner` component.
- `lib/services/scanner_service.dart`: OCR processing logic.
- `lib/main.dart`: Demo application showing global integration.

## Customization

The `MlkitScanner` is designed to be self-contained. You can customize the `ScannerOverlayShape` or the selection cards within `mlkit_scanner_widget.dart` to match your app's branding.
