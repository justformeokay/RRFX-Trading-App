import 'package:flutter/material.dart';
import 'package:rrfx/src/controllers/authentication.dart';
import 'package:rrfx/src/views/authentications/failed_version_app.dart';
import 'package:rrfx/src/views/no_auth_view/mainpage_no_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rrfx/src/components/alerts/default.dart';
import 'package:rrfx/src/controllers/two_factory_auth.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/controllers/home.dart';
import 'package:rrfx/src/service/auth_service.dart';
import 'package:rrfx/src/views/mainpage.dart';

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
    bool isValidVersion = await authController.getVersionApp();

    if (!isValidVersion) {
      _finishTransition(() {
        Get.offAll(() => const FailedVersionPage(updateUrl: "https://rrfx.co.id/"));
      });
      return;
    }

    bool loggedIn = await getLoggedIn();
    if (loggedIn) {
      Map<String, dynamic> result = await authService.get("profile/info");
      if (result['statusCode'] == 200) {
        bool resultProfile = await homeController.profile();
        if (!resultProfile) {
          _finishTransition(() {
            CustomAlert.alertError(
              context,
              message: homeController.responseMessage.value,
              onTap: () {
                Get.offAll(() => const MainpageWithoutLogin());
              },
            );
          });
          return;
        }
        _finishTransition(() {
          Get.offAll(() => const Mainpage());
        });
        return;
      }

      _finishTransition(() {
        Get.offAll(() => const MainpageWithoutLogin());
      });
    } else {
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
