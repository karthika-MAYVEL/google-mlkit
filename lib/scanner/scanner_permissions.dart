// import 'package:permission_handler/permission_handler.dart';

// class ScannerPermissions {
//   static Future<bool> requestCamera() async {
//     final status = await Permission.camera.request();
//     return status.isGranted;
//   }

//   static Future<bool> hasCameraPermission() async {
//     final status = await Permission.camera.status;
//     return status.isGranted;
//   }
// }
import 'package:permission_handler/permission_handler.dart';

class ScannerPermissions {
  static Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }
}
