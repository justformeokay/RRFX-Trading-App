import 'package:permission_handler/permission_handler.dart';

class PermissionHandlers {
  static Future<void> requestPermissions() async {
    // Minta semua izin yang relevan dalam 1 call
    await [
      Permission.photos,
      Permission.camera,
      Permission.storage,
      Permission.notification,
    ].request();
  }
}

