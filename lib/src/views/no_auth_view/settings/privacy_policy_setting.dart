import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D0D0D) : const Color(0xFFFDFDFD),

      appBar: AppBar(
        elevation: 0,
        forceMaterialTransparency: true,
        title: Text(
          "Kebijakan Privasi",
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        iconTheme:
            IconThemeData(color: isDark ? Colors.white : Colors.black87),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title("1. Pendahuluan", isDark),
            _body(
              "Kebijakan Privasi ini menjelaskan bagaimana RRFX mengumpulkan, menggunakan, "
              "menyimpan, dan melindungi data pribadi Anda ketika menggunakan aplikasi dan "
              "layanan kami. Dengan menggunakan aplikasi RRFX, Anda dianggap telah membaca, "
              "memahami, dan menyetujui isi kebijakan privasi ini.",
              isDark,
            ),

            const SizedBox(height: 20),

            _title("2. Data yang Kami Kumpulkan", isDark),
            _body(
              "Kami dapat mengumpulkan beberapa jenis data, termasuk namun tidak terbatas pada:",
              isDark,
            ),
            _bullet([
              "Informasi Identitas: nama, email, nomor telepon.",
              "Informasi Akun: aktivitas trading, riwayat transaksi.",
              "Informasi Teknis: alamat IP, tipe perangkat, sistem operasi.",
              "Informasi Lokasi (jika diizinkan oleh Anda).",
            ], isDark),

            const SizedBox(height: 20),

            _title("3. Cara Kami Menggunakan Data Anda", isDark),
            _bullet([
              "Meningkatkan pengalaman penggunaan aplikasi.",
              "Mengoperasikan layanan trading dan fitur terkait.",
              "Menjaga keamanan akun dan verifikasi identitas.",
              "Memberikan notifikasi atau informasi yang relevan.",
              "Menganalisis performa, statistik, dan pengembangan fitur baru.",
            ], isDark),

            const SizedBox(height: 20),

            _title("4. Keamanan Data", isDark),
            _body(
              "RRFX berkomitmen melindungi data pribadi Anda dengan standar keamanan yang tinggi. "
              "Kami menggunakan enkripsi, pengamanan server, dan kontrol akses untuk menjaga "
              "datanya tetap aman. Namun, tidak ada sistem yang sepenuhnya aman, sehingga risiko "
              "keamanan digital tetap mungkin terjadi.",
              isDark,
            ),

            const SizedBox(height: 20),

            _title("5. Berbagi Data kepada Pihak Ketiga", isDark),
            _body(
              "Kami tidak menjual atau memperdagangkan data pribadi Anda. Namun, dalam kondisi "
              "tertentu, kami dapat membagikan data kepada:",
              isDark,
            ),
            _bullet([
              "Penyedia layanan pihak ketiga (seperti sistem keamanan & verifikasi).",
              "Regulator atau otoritas hukum jika diwajibkan oleh peraturan.",
            ], isDark),

            const SizedBox(height: 20),

            _title("6. Hak Pengguna", isDark),
            _bullet([
              "Mengakses data pribadi yang kami simpan.",
              "Memperbarui atau mengubah data.",
              "Meminta penghapusan data tertentu.",
              "Menolak pemrosesan data untuk tujuan pemasaran.",
            ], isDark),

            const SizedBox(height: 20),

            _title("7. Perubahan Kebijakan", isDark),
            _body(
              "RRFX dapat memperbarui kebijakan privasi ini sewaktu-waktu. Perubahan akan "
              "ditampilkan di halaman ini dan mulai berlaku sejak tanggal pembaruan.",
              isDark,
            ),

            const SizedBox(height: 20),

            _title("8. Kontak", isDark),
            _body(
              "Jika Anda memiliki pertanyaan atau keluhan terkait Kebijakan Privasi, Anda dapat "
              "menghubungi kami melalui halaman resmi RRFX: rrfx.co.id.",
              isDark,
            ),

            const SizedBox(height: 35),
          ],
        ),
      ),
    );
  }

  // ========= UI Helpers =========

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
              Text(
                "•  ",
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
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
