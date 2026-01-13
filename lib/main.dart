import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import ini dibutuhkan untuk SystemChrome
import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rrfx/src/controllers/network_controller.dart';
import 'package:rrfx/src/controllers/theme_controller.dart';
import 'package:rrfx/src/service/auth_service.dart';
import 'package:rrfx/src/service/deeplink_service.dart';
import 'package:rrfx/src/service/notification_service.dart';
import 'package:rrfx/src/views/no_network_page.dart';
import 'src/components/languages/languages.dart';
import 'src/components/themes/default.dart';
import 'src/helpers/get_utilities/routes.dart';
import 'src/views/authentications/splashscreen.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  // Wajib pertama
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Storage
  try { await GetStorage.init(); } catch (e) { print(e); }
  
  // Custom HTTP
  HttpOverrides.global = _MyHttpOverrides();
  
  // Firebase
  try { await initFirebaseAndNotifications(); } catch (e) { print(e); }
  
  final themeController = Get.put(ThemeController());

  // Inisialisasi DeepLink secara async
  final deepLinkService = DeepLinkService();
  try {
    await deepLinkService.init(); // Sekarang tidak akan error 'type void' lagi
  } catch (e) {
    print('DeepLink init warning: $e');
  }

  runApp(MyApp(
    themeController: themeController,
    deepLinkService: deepLinkService,
  ));
}

class MyApp extends StatefulWidget {
  final ThemeController themeController;
  final DeepLinkService deepLinkService;
  const MyApp({super.key, required this.themeController, required this.deepLinkService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final networkController = Get.put(NetworkController());
  final authService = Get.put(AuthService());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setSystemUIOverlayStyle();
      // Trigger network speed check saat app pertama kali di-launch
      networkController.checkNetworkSpeed();
    });
    ever(widget.themeController.isDark, (_) {
      _setSystemUIOverlayStyle();
    });
  }
  void _setSystemUIOverlayStyle() {
    final bool isDark = widget.themeController.isDark.value;
    final Color systemNavBarColor = isDark ? Colors.black : Colors.white; // Warna hitam untuk Dark Mode, putih untuk Light Mode
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: systemNavBarColor,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark, 
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark, 
      statusBarColor: Colors.transparent, // Biasanya dibuat transparan
    ));
  }

  @override
  void dispose() {
    widget.deepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isDark = widget.themeController.isDark.value;
      final SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Biarkan transparan
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark, // Icon Status Bar (jam, sinyal, baterai)
        systemNavigationBarColor: isDark ? Colors.black : Colors.white, // Inilah yang mengatasi warna putih
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark, // Icon Navigation Bar (Home, Back)
      );
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle,
        child: GetMaterialApp(
          scaffoldMessengerKey: scaffoldMessengerKey,
          title: 'RRFX',
          getPages: GetUtilities.routes,
          defaultTransition: Transition.cupertino,
          debugShowCheckedModeBanner: false,
          translations: Languages(),
          locale: Get.deviceLocale,
          theme: CustomTheme.defaultLightTheme(),
          darkTheme: CustomTheme.defaultDarkTheme(),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', '')],
          home: networkController.hasConnection.value ? const Splashscreen() : const NoNetworkPage(), // ⬅️ redirect otomatis
        ),
      );
    });
  }
}

/// Custom HTTP overrides untuk handle image loading dengan status code 300
class _MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}