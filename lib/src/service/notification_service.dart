import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rrfx/firebase_options.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> initFirebaseAndNotifications() async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
  } catch (e) {
    print('❌ Firebase initialization error: $e');
    return;
  }

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  final settings = InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(settings);
  
  // ✅ Get FCM Token and save to SharedPreferences
  await getAndSaveFCMToken();
  
  // ✅ Listen to token refresh
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('deviceID', newToken);
    print('🔄 FCM Token refreshed: $newToken');
  });
}

/// Get FCM Token and save to SharedPreferences
Future<String?> getAndSaveFCMToken() async {
  try {
    // Request permission for iOS
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('deviceID', token);
      print('✅ FCM Token saved: $token');
      return token;
    }
    return null;
  } catch (e) {
    print('❌ Error getting FCM token: $e');
    return null;
  }
}
