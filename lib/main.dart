import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import ini dibutuhkan untuk SystemChrome
import 'package:flutter/foundation.dart' show kIsWeb;
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
import 'src/controllers/authentication.dart';
import 'src/helpers/get_utilities/routes.dart';
import 'src/views/authentications/splashscreen.dart';
import 'src/helpers/http/http_overrides_stub.dart'
    if (dart.library.io) 'src/helpers/http/http_overrides_mobile.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  // Wajib pertama
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Storage
  try { await GetStorage.init(); } catch (e) { print(e); }
  
  // Custom HTTP - hanya untuk mobile (tidak didukung di Web)
  setupHttpOverrides();
  
  // Firebase
  try { 
    print('🔥 Initializing Firebase and Notifications...');
    await initFirebaseAndNotifications(); 
    print('✅ Firebase initialization completed');
  } catch (e) { 
    print('❌ Firebase initialization failed: $e'); 
  }
  
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
  final authController = Get.put(AuthController());

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
      
      // Widget utama GetMaterialApp
      final mainApp = GetMaterialApp(
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
        home: networkController.hasConnection.value ? const Splashscreen() : const NoNetworkPage(),
      );

      // Jika Web, bungkus dengan mobile frame wrapper
      if (kIsWeb) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: Scaffold(
            backgroundColor: isDark ? const Color(0xFF0d0d1a) : const Color(0xFFe8e8f0),
            body: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 430), // iPhone 14 Pro Max width
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 40,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  child: mainApp,
                ),
              ),
            ),
          ),
        );
      }

      // Untuk Mobile, gunakan langsung tanpa wrapper
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle,
        child: mainApp,
      );
    });
  }
}


