import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rrfx/firebase_options.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('📨 Background message received: ${message.notification?.title}');
}

Future<void> initFirebaseAndNotifications() async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
  } catch (e) {
    print('❌ Firebase initialization error: $e');
    return;
  }

  // Setup local notifications untuk Android & iOS
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  
  final settings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(settings);
  
  // ✅ Get FCM Token and save to SharedPreferences
  await getAndSaveFCMToken();
  
  // ✅ Listen to token refresh
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('deviceID', newToken);
    print('🔄 FCM Token refreshed: $newToken');
  });
  
  // ✅ Handle pesan saat app di foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('💬 Foreground message received: ${message.notification?.title}');
    _showNotification(message);
  });

  // ✅ Handle saat user tap notification
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('👆 User tapped notification: ${message.notification?.title}');
    // Handle navigation atau aksi lainnya
  });
}

/// Show local notification (untuk iOS)
Future<void> _showNotification(RemoteMessage message) async {
  final notification = message.notification;
  
  if (notification != null) {
    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'This channel is used for important notifications.',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data.isEmpty ? null : message.data.toString(),
    );
  }
}

/// Get FCM Token and save to SharedPreferences
Future<String?> getAndSaveFCMToken() async {
  try {
    // Request permission for iOS (Alert, Badge, Sound)
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    print('📱 Notification permission status: ${settings.authorizationStatus}');
    
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('deviceID', token);
      print('✅ FCM Token saved: $token');
      return token;
    } else {
      print('⚠️ Failed to get FCM token');
      return null;
    }
  } catch (e) {
    print('❌ Error getting FCM token: $e');
    return null;
  }
}
