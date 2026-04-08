import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/controllers/home.dart';
import 'package:rrfx/src/views/authentications/signin.dart';
import 'package:rrfx/src/views/mainpage.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ganti dengan path MainPage kamu

class VerificationSuccessPage extends StatefulWidget {
  const VerificationSuccessPage({super.key});

  @override
  State<VerificationSuccessPage> createState() => _VerificationSuccessPageState();
}

class _VerificationSuccessPageState extends State<VerificationSuccessPage> {
  HomeController homeController = Get.find();
  @override
  void initState() {
    super.initState();
    homeController.profile(forceRefresh: true).then((resultProfile){
      if(!resultProfile){
        CustomScaffoldMessanger.showAppSnackBar(context, message: homeController.responseMessage.value, type: SnackBarType.error);
        Get.offAll(() => const SignIn());
        return;
      }
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('loggedIn', true);
      });
      Timer(const Duration(seconds: 5), () {
        Get.offAll(() => const Mainpage()); 
      });
    });
    // Timer untuk redirect otomatis
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animasi Lottie sukses
              SizedBox(
                height: size.height * 0.3,
                child: Lottie.asset(
                  'assets/json/success.json', // taruh file lottie di assets
                  repeat: false,
                ),
              ),
              const SizedBox(height: 24),

              // Teks ucapan
              Text(
                "Verifikasi Berhasil!",
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Selamat, akun Anda sudah berhasil diverifikasi.\nAnda akan diarahkan ke halaman utama.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 40),

              // Indicator loading ke MainPage
              const CircularProgressIndicator(
                color: Colors.green,
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
