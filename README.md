# MLKit Scanner Component

A reusable Flutter component for Barcode/QR code scanning and OCR (Text Recognition) using Google ML Kit.

## Features

- **Barcode/QR Scanning**: Live camera preview with automatic detection.
- **OCR (Text Recognition)**: Capture an image and extract text.
- **Chooser Mode**: A built-in bottom sheet to let users choose between Barcode and OCR.
- **Customizable**: Configure timeouts, max value lengths, and UI titles.

## Installation

Ensure you have the following dependencies in your `pubspec.yaml`:

```yaml
dependencies:
  mobile_scanner: ^7.1.4
  google_mlkit_barcode_scanning: ^0.13.0
  google_mlkit_text_recognition: ^0.14.0
  image_picker: ^1.1.2
```

<!-- ## Usage

Import the component:

```dart
import 'package:google_mlkit/components/mlkit_scanner/mlkit_scanner.dart';
``` -->

### Basic Usage (Chooser Mode)

```dart
MlkitScannerButton(
  onResult: (ScanResult result) {
    if (result.status == "pass") {
      print("Scanned: ${result.value}");
    } else {
      print("Error: ${result.message}");
    }
  },
)
```

### Specific Mode (Barcode only)

```dart
MlkitScannerButton(
  mode: "barcode",
  onResult: (ScanResult result) {
    // ...
  },
)
```

### Specific Mode (OCR only)

```dart
MlkitScannerButton(
  mode: "ocr",
  onResult: (ScanResult result) {
    // ...
  },
)
```

## Models

### ScanResult

| Field | Type | Description |
|-------|------|-------------|
| `status` | `String` | "pass" or "fail" |
| `code` | `String` | Machine-readable code (e.g., "OK", "CANCELLED", "EMPTY") |
| `value` | `String` | The scanned/recognized text |
| `message` | `String` | Human-readable message (mainly for errors) |
| `type` | `String` | "barcode" or "ocr" |
| `meta` | `Map?` | Optional extra data |


#Permissions 
Permissions
Android: android/app/src/main/AndroidManifest.xml
<uses-permission android:name="android.permission.CAMERA" />

iOS: ios/Runner/Info.plist
<key>NSCameraUsageDescription</key>
<string>Camera access is required to scan QR/Barcodes.</string>