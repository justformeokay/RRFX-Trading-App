import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/views/authentications/verification_account_page.dart';

class SuccessVerifiedOtpPage extends StatefulWidget {
  const SuccessVerifiedOtpPage({super.key});

  @override
  State<SuccessVerifiedOtpPage> createState() => _SuccessVerifiedOtpPageState();
}

class _SuccessVerifiedOtpPageState extends State<SuccessVerifiedOtpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF26D0A4), width: 2.0),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Checkmark Circle Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF26D0A4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 60,
                    ),
                ),
                const SizedBox(height: 24.0),

                // Success Title
                const Text(
                  'Registrasi Berhasil!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF26D0A4),
                  ),
                ),
                const SizedBox(height: 12.0),

                // Subtitle
                const Text(
                  'Akun Anda telah berhasil dibuat.\nTim kami akan segera memproses informasi Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF999999),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32.0),

                // Dashboard Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.offAll(() => const VerificationAccountPage());
                    },
                    icon: const Icon(Icons.home, size: 20, color: Colors.white,),
                    label: const Text(
                      'Lanjut Ke Dashboard',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF26D0A4),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
