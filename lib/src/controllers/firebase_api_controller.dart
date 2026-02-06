import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
class FirebaseAPI {
  static Future<void> getToken() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? token = await FirebaseMessaging.instance.getToken();
      preferences.setString('deviceID', token ?? '0');
    } catch (e) {
      Get.log('⚠️ Error getting Firebase token: $e');
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString('deviceID', '0');
    }
  }
}