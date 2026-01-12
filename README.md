# ML Kit Structured Scanner Component

A self-contained, importable Flutter component for QR/Barcode scanning and OCR (Text Recognition) using Google ML Kit and `mobile_scanner`.

## Features

- **Structured Flow**: A professional selection pop-up to choose between QR and OCR modes.
- **QR / Barcode Scanning**: High-performance scanning with both camera and gallery support.
- **OCR (Text Recognition)**: Extract text from camera captures or gallery images.
- **Importable Widget**: Designed to be easily integrated into any Flutter project.
- **Consistent Output**: Returns a structured JSON-like map for easy data handling.

## Getting Started

### Installation

1.  **Add dependencies** to your `pubspec.yaml`:
    ```yaml
    dependencies:
      mobile_scanner: ^6.0.0
      google_mlkit_barcode_scanning: ^0.13.0
      google_mlkit_text_recognition: ^0.14.0
      image_picker: ^1.1.2
      permission_handler: ^11.3.1
    ```

2.  **Configure Permissions**:
    - **Android**: Add `CAMERA` and storage permissions to `AndroidManifest.xml`.
    - **iOS**: Add `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` to `Info.plist`.

## Usage

### Integration

You can use the `MlkitScanner` widget directly as a component (e.g., in a `TextField`'s `suffixIcon`):

```dart
import 'package:google_mlkit/widgets/mlkit_scanner_widget.dart';

TextField(
  decoration: InputDecoration(
    suffixIcon: MlkitScanner(
      onResult: (result) {
        if (result['success']) {
          print("Scanned: ${result['value']}");
        }
      },
    ),
  ),
)
```

### Manual Trigger

You can also trigger the selection flow manually using the static `start` method:

```dart
MlkitScanner.start(context, onResult: (result) {
  // Handle result
});
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
- `lib/services/scanner_service.dart`: OCR and Barcode processing logic for images.
- `lib/main.dart`: Demo application showing the structured integration.
