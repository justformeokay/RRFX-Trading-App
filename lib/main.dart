import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import ini dibutuhkan untuk SystemChrome
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:deriv_chart/generated/l10n.dart' as chart_l10n;
import 'package:get_storage/get_storage.dart';
import 'package:rrfx/src/controllers/network_controller.dart';
import 'package:rrfx/src/controllers/theme_controller.dart';
import 'package:rrfx/src/service/auth_service.dart';
import 'package:rrfx/src/service/deeplink_service.dart';
import 'package:rrfx/src/views/no_network_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'src/components/languages/languages.dart';
import 'src/components/themes/default.dart';
import 'src/helpers/get_utilities/routes.dart';
import 'src/views/authentications/splashscreen.dart';


final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(); 
  await Supabase.initialize(
    url: 'https://epptafokbdelrxfpiiqu.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVwcHRhZm9rYmRlbHJ4ZnBpaXF1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3NjQzMTgsImV4cCI6MjA3ODM0MDMxOH0.HGlmriIkdCUsnEc8oWavzA0DD6aVRKTVvje4M1rZk9g',
  );
  final themeController = Get.put(ThemeController());

  final deepLinkService = DeepLinkService();
  deepLinkService.init();

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
    // Panggil pengaturan UI setelah build awal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setSystemUIOverlayStyle();
    });
    // Tambahkan listener untuk mendengarkan perubahan tema
    ever(widget.themeController.isDark, (_) {
      _setSystemUIOverlayStyle();
    });
  }

  // Fungsi untuk menentukan dan menerapkan SystemUiOverlayStyle
  void _setSystemUIOverlayStyle() {
    final bool isDark = widget.themeController.isDark.value;
    final Color systemNavBarColor = isDark ? Colors.black : Colors.white; // Warna hitam untuk Dark Mode, putih untuk Light Mode

    // Menggunakan SystemChrome untuk mengatur warna Navigation Bar (bilah bawah di Android)
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
      // 1. Dapatkan tema saat ini (Light atau Dark)
      final bool isDark = widget.themeController.isDark.value;
      
      // 2. Tentukan SystemUiOverlayStyle berdasarkan tema
      // Gunakan warna latar belakang Scaffold/AppBar untuk StatusBar dan NavigationBar
      final SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle(
        // Untuk Bilah Status (atas)
        statusBarColor: Colors.transparent, // Biarkan transparan
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark, // Icon Status Bar (jam, sinyal, baterai)
        
        // Untuk Bilah Navigasi (bawah)
        systemNavigationBarColor: isDark ? Colors.black : Colors.white, // Inilah yang mengatasi warna putih
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark, // Icon Navigation Bar (Home, Back)
      );

      // 3. Bungkus GetMaterialApp dengan AnnotatedRegion
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
            chart_l10n.ChartLocalization.delegate,
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