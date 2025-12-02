import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/buttons/outlined_button.dart';
import 'package:rrfx/src/components/containers/utilities.dart';

class AboutApp extends StatefulWidget {
  const AboutApp({super.key});

  @override
  State<AboutApp> createState() => _AboutAppState();
}

class _AboutAppState extends State<AboutApp> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppBar.defaultAppBar(
        title: "About App",
        autoImplyLeading: true
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            Image.asset('assets/images/logo-rrfx-3.png', width: size.width / 4),
            const SizedBox(height: 20.0),
            UtilitiesWidget.titleContent(
              title: "Tentang Aplikasi",
              textAlign: TextAlign.justify,
              subtitle: "Selamat datang di aplikasi resmi PT. RRFX Investasi Berjangka. Solusi trading modern yang dirancang khusus untuk memberikan pengalaman trading forex yang aman, cepat, dan andal di genggaman tangan Anda. Aplikasi ini memungkinkan pengguna untuk",
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Bootstrap.dot, color: Colors.black54),
                    Flexible(child: Text("Membuka akun trading forex dengan mudah dan cepat", style: GoogleFonts.inter(fontSize: 16), textAlign: TextAlign.justify)),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Bootstrap.dot, color: Colors.black54),
                    Flexible(child: Text("Melakukan trading secara real-time dengan akses langsung ke pasar global", style: GoogleFonts.inter(fontSize: 16), textAlign: TextAlign.justify)),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Bootstrap.dot, color: Colors.black54),
                    Flexible(child: Text("Memantau pergerakan pasar, grafik harga, dan analisis terkini", style: GoogleFonts.inter(fontSize: 16), textAlign: TextAlign.justify)),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Bootstrap.dot, color: Colors.black54),
                    Flexible(child: Text("Mengelola akun, deposit, dan penarikan dana dengan praktis", style: GoogleFonts.inter(fontSize: 16), textAlign: TextAlign.justify)),
                  ],
                ),
                const SizedBox(height: 20),
                Text("""
Dengan dukungan sistem keamanan berlapis dan antarmuka pengguna yang intuitif, aplikasi ini menjadi mitra terbaik Anda dalam memulai atau mengembangkan karier trading di dunia forex.
PT. RRFX Investasi Berjangka berkomitmen untuk menyediakan layanan keuangan yang transparan, profesional, dan sesuai regulasi. Unduh aplikasinya sekarang dan mulai perjalanan Anda dalam dunia trading bersama kami.
                """, textAlign: TextAlign.justify, style: GoogleFonts.inter(fontSize: 16)),
                Text("Versi Aplikasi: 1.0.0", style: GoogleFonts.inter(fontSize: 16)),
              ]
            ),
            SizedBox(
              height: 35,
              width: double.infinity,
              child: CustomOutlinedButton.defaultOutlinedButton(
                onPressed: (){
                  CustomScaffoldMessanger.showAppSnackBar(context, message: "Fitur ini akan segera hadir");
                },
                title: "Beri Nilai Aplikasi"
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
