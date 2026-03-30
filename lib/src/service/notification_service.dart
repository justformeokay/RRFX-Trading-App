import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
  if (kIsWeb) {
    print('⚠️ Firebase not configured for web, skipping initialization.');
    return;
  }

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
  
  // ✅ Setup message listeners immediately
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('deviceID', newToken);
    print('🔄 FCM Token refreshed: $newToken');
  });
  
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('💬 Foreground message received: ${message.notification?.title}');
    _showNotification(message);
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('👆 User tapped notification: ${message.notification?.title}');
  });
  
  // ✅ Run APNS/FCM initialization in background (non-blocking)
  print('🔥 Starting background FCM token initialization...');
  _initializeTokensInBackground();
}

/// Initialize FCM tokens in background without blocking app startup
Future<void> _initializeTokensInBackground() async {
  try {
    // For iOS: Initialize APNS first (in background)
    if (Platform.isIOS) {
      await _initializeAPNS();
    }
    
    // Get FCM Token and save to SharedPreferences
    await getAndSaveFCMToken();
  } catch (e) {
    print('❌ Background token initialization error: $e');
  }
}

/// Initialize APNS for iOS (with reduced wait time for better UX)
Future<void> _initializeAPNS() async {
  try {
    print('🍎 Initializing APNS for iOS...');
    
    // Quick check first (non-blocking)
    String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    if (apnsToken != null) {
      print('✅ APNS Token obtained immediately: ${apnsToken.substring(0, 20)}...');
      return;
    }
    
    // If not available, do minimal retries with shorter delays
    int retryCount = 0;
    const maxRetries = 3; // Reduced from 6 to 3
    const delayMs = 1000; // Fixed 1 second delay
    
    while (retryCount < maxRetries) {
      retryCount++;
      print('⚠️ APNS Token not available, attempt $retryCount/$maxRetries (waiting 1s)');
      await Future.delayed(Duration(milliseconds: delayMs));
      
      apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken != null) {
        print('✅ APNS Token obtained: ${apnsToken.substring(0, 20)}...');
        return;
      }
    }
    
    print('⚠️ APNS Token not available after $maxRetries attempts (likely running on simulator)');
    print('💡 Note: APNS tokens are only available on physical iOS devices');
  } catch (e) {
    print('❌ Error initializing APNS: $e');
  }
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

/// Get FCM Token and save to SharedPreferences with retry (reduced attempts)
Future<String?> getAndSaveFCMToken() async {
  const maxAttempts = 2; // Reduced from 3 to 2
  
  for (int attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      // Request permission for iOS (Alert, Badge, Sound)
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      
      print('📱 Notification permission status: ${settings.authorizationStatus}');
      
      // Check if permission is granted
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print('❌ Notification permission denied by user');
        return null;
      }
      
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('deviceID', token);
        print('✅ FCM Token saved (attempt $attempt): ${token.substring(0, 20)}...');
        return token;
      } else {
        print('⚠️ Failed to get FCM token (attempt $attempt/$maxAttempts)');
        
        if (attempt < maxAttempts) {
          await Future.delayed(Duration(seconds: 1)); // Fixed 1s delay
        }
      }
    } catch (e) {
      print('❌ Error getting FCM token (attempt $attempt/$maxAttempts): $e');
      
      if (attempt < maxAttempts) {
        await Future.delayed(Duration(seconds: 1)); // Fixed 1s delay
      }
    }
  }
  
  print('⚠️ FCM token not available (likely iOS simulator)');
  return null;
}

/// Utility function to check current FCM token status
Future<void> debugFCMTokenStatus() async {
  try {
    print('🔍 Debug: Checking FCM Token Status...');
    
    if (Platform.isIOS) {
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken != null) {
        print('✅ APNS Token: Available');
      } else {
        print('❌ APNS Token: Not Available');
      }
    }
    
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      print('✅ FCM Token: Available');
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedToken = prefs.getString('deviceID');
      if (savedToken == fcmToken) {
        print('✅ Saved token matches current token');
      } else {
        print('⚠️ Saved token differs from current token, updating...');
        await prefs.setString('deviceID', fcmToken);
      }
    } else {
      print('❌ FCM Token: Not Available');
    }
    
    NotificationSettings settings = await FirebaseMessaging.instance.getNotificationSettings();
    print('📱 Permission Status: ${settings.authorizationStatus}');
  } catch (e) {
    print('❌ Error during FCM debug: $e');
  }
}
