import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAPI {
  static Future<void> getToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = await FirebaseMessaging.instance.getToken();
    preferences.setString('deviceID', token ?? '0');
  }
}