import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  int openedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF9F9F9),

      appBar: AppBar(
        elevation: 0,
        forceMaterialTransparency: true,
        title: Text(
          "FAQ",
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          _faqItem(0, "Apa itu RRFX?", 
              "RRFX adalah aplikasi finansial untuk mengelola akun trading, melihat saldo, "
              "melakukan deposit, penarikan, dan aktivitas lainnya.",
              isDark),
          _faqItem(1, "Apakah aplikasi ini aman?", 
              "Ya. RRFX menggunakan sistem keamanan berlapis, enkripsi data, dan otentikasi "
              "yang mengikuti standar industri.",
              isDark),
          _faqItem(2, "Bagaimana cara menghubungi support?", 
              "Anda dapat menghubungi tim dukungan kami melalui website resmi: rrfx.co.id.",
              isDark),
          _faqItem(3, "Apakah ada biaya penggunaan?", 
              "Tidak ada biaya untuk penggunaan aplikasi. Namun layanan tertentu di dalam "
              "platform trading dapat memiliki biaya sesuai ketentuan broker.",
              isDark),
          _faqItem(4, "Bagaimana jika lupa password?", 
              "Gunakan menu 'Forgot Password' untuk melakukan reset dengan email terdaftar.",
              isDark),
        ],
      ),
    );
  }

  Widget _faqItem(int index, String title, String desc, bool isDark) {
    final isOpen = index == openedIndex;
    final cardColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
        ],
      ),

      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                openedIndex = isOpen ? -1 : index;
              });
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),

                AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: isOpen ? 0.5 : 0,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 26,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            firstChild: Container(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                desc,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  height: 1.55,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
            crossFadeState: isOpen
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          )
        ],
      ),
    );
  }
}
