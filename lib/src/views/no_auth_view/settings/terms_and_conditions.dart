import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D0D) : const Color(0xFFFDFDFD),
      appBar: AppBar(
        elevation: 0,
        forceMaterialTransparency: true,
        title: Text(
          "Terms & Conditions",
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title("1. Penerimaan Syarat", isDark),
            _body(
              "Dengan mengakses dan menggunakan aplikasi RRFX, Anda menyetujui seluruh "
              "syarat dan ketentuan yang berlaku. Jika Anda tidak setuju, mohon untuk "
              "tidak menggunakan aplikasi kami.",
              isDark,
            ),

            const SizedBox(height: 20),
            _title("2. Penggunaan Layanan", isDark),
            _bullet([
              "Anda wajib menggunakan aplikasi sesuai hukum yang berlaku.",
              "Anda bertanggung jawab menjaga kerahasiaan akun Anda.",
              "RRFX berhak melakukan pembatasan atau penghentian layanan jika ditemukan pelanggaran.",
            ], isDark),

            const SizedBox(height: 20),
            _title("3. Aktivitas Trading", isDark),
            _body(
              "Semua aktivitas trading yang dilakukan melalui RRFX merupakan keputusan "
              "pengguna sepenuhnya. RRFX tidak menjamin keuntungan tertentu.",
              isDark,
            ),

            const SizedBox(height: 20),
            _title("4. Pembaruan Layanan", isDark),
            _body(
              "RRFX berhak memperbarui, menambah, atau mengubah fitur kapan pun demi "
              "meningkatkan kualitas layanan.",
              isDark,
            ),

            const SizedBox(height: 20),
            _title("5. Pembatasan Tanggung Jawab", isDark),
            _body(
              "RRFX tidak bertanggung jawab atas kerugian finansial, kesalahan teknis, "
              "atau tindakan pihak ketiga yang berada di luar kendali kami.",
              isDark,
            ),

            const SizedBox(height: 20),
            _title("6. Hukum yang Berlaku", isDark),
            _body(
              "Syarat dan ketentuan ini tunduk pada hukum Republik Indonesia.",
              isDark,
            ),

            const SizedBox(height: 35),
          ],
        ),
      ),
    );
  }

  // Helpers
  Widget _title(String text, bool isDark) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _body(String text, bool isDark) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 15,
        height: 1.5,
        color: isDark ? Colors.white70 : Colors.black87,
      ),
    );
  }

  Widget _bullet(List<String> items, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("•  ",
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: isDark ? Colors.white70 : Colors.black87,
                  )),
              Expanded(
                child: Text(
                  item,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    height: 1.5,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              )
            ],
          ),
        );
      }).toList(),
    );
  }
}
