import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/controllers/home.dart';
import 'package:url_launcher/url_launcher.dart';

class SuspendedAccountPage extends StatelessWidget {
  const SuspendedAccountPage({super.key});

  Future<void> _contactSupport() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'cs@rrfx.co.id',
      query: Uri.encodeFull(
        'subject=Permintaan Aktivasi Akun&body=Halo tim CS RRFX,\n\nAkun saya telah ditangguhkan. Mohon bantuan untuk mengaktifkan kembali.\n\nTerima kasih.',
      ),
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      Get.snackbar("Error", "Tidak dapat membuka aplikasi email",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    HomeController homeController = Get.find();
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, color: theme.colorScheme.error, size: 80),
              const SizedBox(height: 20),
              Text(
                "Akun Anda Ditangguhkan",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Akun Anda ${homeController.profileModel.value?.email ?? 'example@email.com'} saat ini tidak dapat digunakan.\n"
                "Silakan hubungi tim Customer Support kami untuk bantuan lebih lanjut.",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _contactSupport,
                  icon: const Icon(Icons.email, color: Colors.white,),
                  label: const Text("Hubungi CS", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
