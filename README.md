```md
# google_mlkit

A Flutter project demonstrating a **production-ready scanner widget skeleton** using Google ML Kit for QR / barcode scanning.

---

# Scanner Widget (Production-Ready Skeleton)

A clean, modular scanner widget structure designed for real-world production use.

**Key goals**
- On-device ML Kit scanning (offline)
- Safe result handling (no raw strings)
- Validation & timeout handling
- Explicit permission ownership (Play Store compliant)
- Reusable inside app or extractable as a package

---

## Folder Structure

```

lib/
│
├── scanner/
│   ├── scanner_button.dart        # Public widget (icon button)
│   ├── scanner_state.dart         # State & core flow (timeout, scan lifecycle)
│   ├── scanner_result.dart        # Typed result model (success / error)
│   ├── scanner_validator.dart     # Input validation rules
│   ├── scanner_permissions.dart  # Camera permission handling
│   ├── scanner_mlkit.dart         # ML Kit barcode scanning logic
│   └── scanner_overlay.dart       # UX strings (align, hold steady, timeout)
│
├── keyboard/
│   ├── keyboard_view.dart         # Keyboard UI
│   └── keyboard_controller.dart   # Insert text logic
│
├── main.dart

````

---

## What This Provides

- **Separation of concerns**
  - UI, permissions, ML, validation, and state are isolated
- **Safe result contract**
  - Uses `ScanResult` instead of raw strings
- **Security & correctness**
  - Validation layer prevents malformed or malicious input
- **Play Store readiness**
  - App-level permission ownership
- **Scalable**
  - Can be extracted into a reusable scanner package later

---

## Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  permission_handler: ^11.3.1
  google_mlkit_barcode_scanning: ^0.14.1
````

Then run:

```bash
flutter pub get
```

---

## Usage Import

```dart
import 'package:google_mlkit/google_mlkit.dart';
```

---

## Android Permission Setup

### 1) AndroidManifest.xml

Add camera permission:

`android/app/src/main/AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.CAMERA" />
```

Notes:

* Android 13+ does **not** require storage permissions unless images/videos are saved.
* Permission must be justified in Play Console.

---

### 2) Runtime Permission (In Code)

Camera permission is requested **only when the user taps scan**:

```dart
ScannerPermissions.requestCamera();
```

**Rules**

* ❌ Do NOT request permission on app launch
* ✅ Request only on explicit user action (scan button)

---

## iOS Permission Setup

Add to:

`ios/Runner/Info.plist`

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required to scan QR and barcodes for text input.</string>
```

Rebuild:

```bash
flutter clean
flutter pub get
flutter run
```

---

## File Responsibilities

### scanner_result.dart

**Purpose:** Typed result contract.

```dart
ScanResult.success(value)
ScanResult.error(message)
```

Prevents:

* Returning raw strings
* Mixing success & error states incorrectly

---

### scanner_validator.dart

**Purpose:** Security + correctness.

Validations:

* Non-empty value
* Length limit (e.g., 500 chars)
* Blocks script-like patterns

Protects:

* Keyboard input
* Downstream apps

---

### scanner_permissions.dart

**Purpose:** Camera permission handling.

Key points:

* Permission is app-level
* Widget only *triggers* the request
* Fully Play Store compliant

---

### scanner_mlkit.dart

**Purpose:** ML Kit scanning logic.

Responsibilities:

* Configure supported formats (QR, Code128)
* Process `InputImage`
* Return `rawValue` when detected
* Dispose scanner properly

Runs:

* Fully offline
* On device
* Fast & lightweight

---

### scanner_overlay.dart

**Purpose:** UX guidance strings.

Examples:

* “Align QR within frame”
* “Hold camera steady”
* “Camera not clear. Try again”

---

### scanner_button.dart + scanner_state.dart

**Purpose:** Public widget + core scan flow.

**Flow**

1. User taps scan button
2. Camera permission requested
3. Scan session starts
4. 6-second timeout timer starts
5. On scan detection:

   * Stop scan
   * Validate value
   * Return `ScanResult.success(value)`
6. On timeout / failure:

   * Stop scan
   * Return `ScanResult.error(message)`

---

## Usage Example (Keyboard / Text Input)

In `keyboard_view.dart`:

```dart
ScannerButton(
  onResult: (result) {
    if (result.isSuccess) {
      insertText(result.value);
    } else {
      showToast(result.message);
    }
  },
)
```

**Rules**

* Insert text **only** when `isSuccess == true`
* Validation must happen before returning success

---

## Notes on Scanner UI / Camera Capture

This skeleton focuses on **architecture**.

You can plug in any capture strategy:

1. Full-screen Flutter camera page
2. Native Android Activity bridged to Flutter
3. IME (keyboard) → Activity → result callback

The scanner module remains unchanged.

---

## Common Mistakes to Avoid

* Requesting camera permission at app startup
* Returning raw scan values without validation
* No timeout handling (infinite scan)
* Missing iOS camera usage description
* No Play Store permission justification

---

## Summary

| Area               | Status                    |
| ------------------ | ------------------------- |
| Architecture       | Modular & scalable        |
| ML scanning        | Offline (ML Kit)          |
| Security           | Validation enforced       |
| Permissions        | Play Store compliant      |
| Keyboard auto-fill | Allowed (post-validation) |

---


