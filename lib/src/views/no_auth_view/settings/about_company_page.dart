import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutCompanyPage extends StatelessWidget {
  const AboutCompanyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D0D) : const Color(0xFFFDFDFD),
      appBar: AppBar(
        elevation: 0,
        forceMaterialTransparency: true,
        title: Text(
          "Tentang Perusahaan",
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
            _title("PT RRFX Investasi Berjangka", isDark),
            _body(
              "PT RRFX Investasi Berjangka merupakan Perusahaan pialang berjangka yang mengkhususkan diri pada "
              "perdagangan Indeks Saham, Komoditi, Forex dengan spread dan biaya yang kompetitif. Perusahaan kami "
              "memiliki Visi, misi dan moto yang sangat jelas serta memastikan semua aktivitas di bawah pengawasan BAPPEBTI, JFX, KBI dan diawasi oleh OJK.",
              isDark,
            ),

            const SizedBox(height: 20),
            _title("Visi", isDark),
            _body(
              "Visi kami adalah menjadi pilihan utama nasabah di bidang Perdagangan Berjangka Komoditi "
              "dengan menawarkan pengalaman transaksi yang unik, nyaman dan memberikan pelayanan holistik yang unggul bagi nasabah.",
              isDark,
            ),

            const SizedBox(height: 20),
            _title("Misi", isDark),
            _bullet([
              "Membangun hubungan melalui pendekatan holistik dengan memberikan solusi transaksi yang komprehensif untuk mengembalikan kepercayaan nasabah pada industri Perdagangan Berjangka Komoditi.",
              "Menerapkan manajemen dalam memberikan layanan Perdagangan Berjangka Komoditi yang terpercaya, unggul dan juga inovatif.",
              "Menghadirkan konten digital interaktif yang komprehensif untuk memberikan kemudahan bagi nasabah, serta sistem yang terintegrasi dan teknologi terkini untuk menciptakan lagi rasa aman dan nyaman untuk bertransaksi.",
              "Memberikan edukasi secara komprehensif dan berkelanjutan berkaitan dengan produk dan peraturan serta perundangan di bidang Perdagangan Berjangka Komoditi.",
            ], isDark),

            const SizedBox(height: 20),
            _title("Nilai-Nilai Perusahaan", isDark),
            _bullet([
              "Integritas dalam menjalankan bisnis.",
              "Inovasi berkelanjutan untuk kemudahan nasabah.",
              "Kualitas layanan prima.",
              "Kepercayaan dan transparansi.",
            ], isDark),

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
