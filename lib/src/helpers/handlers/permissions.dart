import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';

class PermissionHandlers {
  static Future<void> requestPermissions() async {
    // Skip permissions on Web platform - not supported
    if (kIsWeb) {
      print('🌐 [Permissions] Skipping permission requests on Web platform');
      return;
    }
    
    // Minta semua izin yang relevan dalam 1 call (hanya untuk mobile)
    await [
      Permission.photos,
      Permission.camera,
      Permission.storage,
      Permission.notification,
    ].request();
  }
}

