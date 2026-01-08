camera (camera frames)

google_mlkit_barcode_scanning (ML Kit decoding)

10s timeout

empty/too-long validation

returns ScanResult(status, code, value, message)

1) Dependencies (pubspec.yaml)
dependencies:
  flutter:
    sdk: flutter
  camera: ^0.11.0+2
  google_mlkit_barcode_scanning: ^0.13.0


Run:

flutter pub get

2) Permissions
Android: android/app/src/main/AndroidManifest.xml
<uses-permission android:name="android.permission.CAMERA" />

iOS: ios/Runner/Info.plist
<key>NSCameraUsageDescription</key>
<string>Camera access is required to scan QR/Barcodes.</string>


3) Professional component structure
lib/
  components/
    mlkit_scanner/
      mlkit_scanner.dart                 # public export (single import)
      models/
        scan_result.dart
      widgets/
        mlkit_scanner_button.dart
      pages/
        mlkit_scanner_page.dart

4) Public export file
lib/components/mlkit_scanner/mlkit_scanner.dart

5) Return model
lib/components/mlkit_scanner/models/scan_result.dart

6) Scanner page (Camera + ML Kit)
lib/components/mlkit_scanner/pages/mlkit_scanner_page.dart

7) Scanner button widget (component API)
lib/components/mlkit_scanner/widgets/mlkit_scanner_button.dart

8) Use it anywhere in your frontend
import 'package:your_app/components/mlkit_scanner/mlkit_scanner.dart';

MlkitScannerButton(
  onResult: (r) {
    if (r.status == "pass") {
      // r.value is your QR/barcode value
    } else {
      // show r.message to user
    }
  },
)
