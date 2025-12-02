import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

void setupFirebaseMessaging() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // ✅ Minta izin untuk iOS
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // ✅ Dapatkan token device (Device ID unik untuk FCM)
  String? token = await messaging.getToken();
  debugPrint('FCM Device Token: $token');

  // ✅ (Opsional) Listen on token refresh
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    // print('FCM Token refreshed: $newToken');
  });

  // ✅ Handle pesan ketika aplikasi foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // print('Received message in foreground: ${message.notification?.title}');
  });

  // ✅ Handle saat user membuka pesan dari background/terminated
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    // print('Opened message: ${message.data}');
  });
}
