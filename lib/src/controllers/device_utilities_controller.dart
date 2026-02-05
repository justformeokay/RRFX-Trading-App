import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceUtilitiesController {
  static Future<Map<String, String>> getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    // Handle Web platform
    if (kIsWeb) {
      final webInfo = await deviceInfo.webBrowserInfo;
      return {
        "device": webInfo.browserName.name,
        "brand": "Web Browser",
        "version": webInfo.appVersion ?? "Unknown",
      };
    }

    // Handle mobile platforms using conditional import
    return await _getMobileDeviceInfo(deviceInfo);
  }

  static Future<Map<String, String>> _getMobileDeviceInfo(DeviceInfoPlugin deviceInfo) async {
    try {
      // Try Android first
      final androidInfo = await deviceInfo.androidInfo;
      return {
        "device": androidInfo.model,
        "brand": androidInfo.brand,
        "version": androidInfo.version.release,
      };
    } catch (_) {
      try {
        // Try iOS
        final iosInfo = await deviceInfo.iosInfo;
        return {
          "device": iosInfo.utsname.machine,
          "brand": "Apple",
          "version": iosInfo.systemVersion,
        };
      } catch (_) {
        return {
          "device": "Unsupported",
          "brand": "Unsupported",
          "version": "Unsupported",
        };
      }
    }
  }

  static Future<String> getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    final version = info.version; // contoh: "1.0.0"
    
    // pisahkan berdasarkan titik
    final parts = version.split(".");
    if (parts.length >= 2) {
      return "${parts[0]}.${parts[1]}"; // hasil "1.0"
    }
    return version; // fallback kalau format aneh
  }
}
