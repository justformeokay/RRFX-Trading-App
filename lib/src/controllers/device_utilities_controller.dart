import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceUtilitiesController {
  static Future<Map<String, String>> getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        "device": androidInfo.model, // Nama device
        "brand": androidInfo.brand, // Brand (Samsung, Xiaomi, dst)
        "version": androidInfo.version.release, // Android version (misal 13)
      };
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return {
        "device": iosInfo.utsname.machine, // Model device (iPhone14,7)
        "brand": "Apple",
        "version": iosInfo.systemVersion, // iOS version
      };
    }

    return {
      "device": "Unsupported",
      "brand": "Unsupported",
      "version": "Unsupported",
    };
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
