# ML Kit Scanner Demo

A Flutter application demonstrating a simplified and robust integration of Google ML Kit for OCR (Text Recognition) and `mobile_scanner` for QR/Barcode scanning.

## Features

- **QR / Barcode Scanning**: High-performance scanning using the `mobile_scanner` package.
- **OCR (Text Recognition)**: Extract text from images using Google ML Kit.
- **Gallery & Camera Support**: Process images directly from the camera or pick them from the device gallery.
- **Structured Output**: Consistent response format for easy integration into any UI.
- **Simple UI**: Integrated scanner button within a text field for a seamless user experience.

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version recommended)
- Android Studio / VS Code with Flutter extension
- A physical device (recommended for camera features)

### Installation

1.  **Clone the repository**:
    ```bash
    git clone <repository-url>
    cd google-mlkit
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run the app**:
    ```bash
    flutter run
    ```

## Project Structure

- `lib/main.dart`: Entry point and main UI with the integrated scanner field.
- `lib/widgets/mlkit_scanner_widget.dart`: Reusable scanner component with OCR and QR flows.
- `lib/services/scanner_service.dart`: Encapsulates ML Kit OCR logic.

## Configuration

### Android
Permissions are already configured in `android/app/src/main/AndroidManifest.xml`:
- `android.permission.CAMERA`
- `android.permission.READ_EXTERNAL_STORAGE`
- `android.permission.WRITE_EXTERNAL_STORAGE`

### iOS
Permissions are configured in `ios/Runner/Info.plist`:
- `NSCameraUsageDescription`: Required for scanning.
- `NSPhotoLibraryUsageDescription`: Required for gallery uploads.

## Usage

The scanner returns a structured JSON-like response:

```json
{
  "success": true,
  "scanType": "ocr | qr",
  "value": "scanned text or code value",
  "message": "Successful scan"
}
```

This response is used to automatically populate the `TextField` on the home screen.

## Dependencies

- `mobile_scanner`: High-performance QR/Barcode scanning.
- `google_mlkit_text_recognition`: Google ML Kit OCR.
- `image_picker`: Camera and gallery image selection.
- `permission_handler`: Permission management.
