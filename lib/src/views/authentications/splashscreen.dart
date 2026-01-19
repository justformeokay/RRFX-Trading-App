import 'package:flutter/material.dart';
import 'package:rrfx/src/controllers/authentication.dart';
import 'package:rrfx/src/service/in_app_update_service.dart';
import 'package:rrfx/src/views/authentications/locked_page.dart';
import 'package:rrfx/src/views/authentications/setup_passcode_page.dart';
import 'package:rrfx/src/views/authentications/verify_passcode_page.dart';
import 'package:rrfx/src/views/no_auth_view/mainpage_no_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rrfx/src/controllers/two_factory_auth.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/controllers/home.dart';
import 'package:rrfx/src/service/auth_service.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> with TickerProviderStateMixin {
  TwoFactoryAuth twoFactoryAuth = Get.put(TwoFactoryAuth());
  HomeController homeController = Get.put(HomeController());
  AuthService authService = Get.put(AuthService());
  AuthController authController = Get.put(AuthController());

  late AnimationController _pulseController;
  late AnimationController _exitController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.9,
      upperBound: 1.1,
    )..repeat(reverse: true);

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _startAppFlow();
  }

  Future<void> _startAppFlow() async {
    try {
      print('🚀 [SPLASH] Starting app flow...');
      
      // ✅ Check for in-app updates from Play Store (no timeout needed)
      print('📱 [SPLASH] Checking for app updates...');
      await InAppUpdateService().checkForUpdate();
      
      print('✅ [SPLASH] Update check completed, proceeding with app flow...');

      bool loggedIn = await getLoggedIn();
    
    // ✅ If user is logged in, fetch profile and check passcode from API response
    if (loggedIn) {
      Get.log("📡 [SPLASH] User logged in - Fetching profile from API...");
      
      // Fetch profile dari API
      bool resultProfile = await homeController.profile();
      
      print("Result Profile: $resultProfile");
      
      // ✅ Check if account is locked
      if (homeController.responseMessage.value == "Account Locked") {
        Get.log("🔒 [SPLASH] Account is locked");
        _finishTransition(() {
          Get.offAll(() => const LockedPage());
        });
        return;
      }
      
      if (!resultProfile) {
        Get.log("❌ [SPLASH] Failed to fetch profile");
        _finishTransition(() {
          Get.offAll(() => const MainpageWithoutLogin());
        });
        return;
      }

      // ✅ Check passcode dari API response
      final profileData = homeController.profileModel.value;
      if (profileData == null) {
        Get.log("❌ [SPLASH] Profile data is NULL");
        _finishTransition(() {
          Get.offAll(() => const MainpageWithoutLogin());
        });
        return;
      }

      Get.log("✅ [SPLASH] Profile fetched successfully");

      
      // ✅ Cek passcode dari API response (bukan dari local storage)
      final hasPasscode = profileData.passcode ?? true;
      
      Get.log("🔐 [SPLASH] Passcode status from API: $hasPasscode");
      
      if (hasPasscode) {
        // ✅ Passcode sudah setup, HARUS verifikasi passcode
        Get.log("✅ [SPLASH] Passcode already setup (from API) - Redirecting to VerifyPasscodePage");
        _finishTransition(() {
          Get.offAll(() => const VerifyPasscodePage());
        });
        return;
      } else {
        // ✅ Passcode belum setup, arahkan ke SetupPasscodePage
        Get.log("🔐 [SPLASH] Passcode not setup yet (from API) - Redirecting to SetupPasscodePage");
        _finishTransition(() {
          Get.offAll(() => const SetupPasscodePage());
        });
        return;
      }
    } else {
      // ✅ User belum login
      Get.log("📱 [SPLASH] User not logged in - Going to MainpageWithoutLogin");
      _finishTransition(() {
        Get.offAll(() => const MainpageWithoutLogin());
      });
    }
    } catch (e, stacktrace) {
      print('❌ [SPLASH] Error in _startAppFlow: $e');
      print('Stack: $stacktrace');
      // Default fallback ke login page
      _finishTransition(() {
        Get.offAll(() => const MainpageWithoutLogin());
      });
    }
  }

  Future<bool> getLoggedIn() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool('loggedIn') ?? false;
  }

  Future<void> _finishTransition(VoidCallback onComplete) async {
    _pulseController.stop();
    await _exitController.forward();
    onComplete();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final theme = Theme.of(context);
    final scaffoldBg = theme.scaffoldBackgroundColor;   // <==== WARNA TEMA

    return Scaffold(
      backgroundColor: scaffoldBg, // <==== EDIT DI SINI
      body: AnimatedBuilder(
        animation: Listenable.merge([_pulseController, _exitController]),
        builder: (context, child) {
          final scale = _exitController.isAnimating
              ? 1 + (_exitController.value * 5)
              : _pulseController.value;

          final bgColor = Color.lerp(
            scaffoldBg,
            scaffoldBg,
            _exitController.value,
          );

          return Container(
            width: size.width,
            height: size.height,
            color: bgColor, // <==== BACKGROUND MENGIKUTI TEMA
            alignment: Alignment.center,
            child: Transform.scale(
              scale: scale,
              child: Image.asset(
                'assets/images/logo-rrfx-3.png',
                width: size.width / 2,
              ),
            ),
          );
        },
      ),
    );
  }
}
