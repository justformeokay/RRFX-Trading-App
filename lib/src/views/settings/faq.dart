import 'package:flutter/material.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/containers/utilities.dart';

class FaqItem {
  final String question;
  final String answer;

  const FaqItem({required this.question, required this.answer});
}

class Faq extends StatefulWidget {
  const Faq({super.key});

  @override
  State<Faq> createState() => _FaqState();
}

class _FaqState extends State<Faq> {
  final List<FaqItem> faqs = const [
    FaqItem(
      question: 'Apa itu trading forex?',
      answer:
          'Trading forex adalah aktivitas jual beli mata uang asing di pasar global. Tujuannya adalah memperoleh keuntungan dari pergerakan nilai tukar antar mata uang.',
    ),
    FaqItem(
      question: 'Bagaimana cara membuka akun trading di aplikasi ini?',
      answer:
          'Anda dapat membuka akun langsung melalui aplikasi dengan mengisi formulir pendaftaran, mengunggah dokumen KYC, dan menunggu proses verifikasi dari tim kami.',
    ),
    FaqItem(
      question: 'Apakah dana saya aman di PT. RRFX Investasi Berjangka?',
      answer:
          'Ya, PT. RRFX Investasi Berjangka terdaftar dan diawasi oleh BAPPEBTI serta merupakan anggota resmi dari Bursa Berjangka Jakarta (BBJ) dan Kliring Berjangka Indonesia (KBI). Dana nasabah disimpan di rekening terpisah (segregated account).',
    ),
    FaqItem(
      question: 'Apakah aplikasi ini menyediakan akun demo?',
      answer:
          'Ya, kami menyediakan akun demo untuk pengguna baru agar dapat belajar dan membiasakan diri dengan platform sebelum melakukan trading riil.',
    ),
    // 👉 Tambahkan FAQ lainnya di sini
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: CustomAppBar.defaultAppBar(
        title: "FAQ",
        autoImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            UtilitiesWidget.titleContent(
              title: "Frequently Asked Questions",
              subtitle: "Pertanyaan yang sering ditanyakan oleh Nasabah Kami",
              children: List.generate(
                faqs.length,
                (i) {
                  final faq = faqs[i];
                  return Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      shape: const RoundedRectangleBorder(),
                      title: Text(
                        faq.question,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textTheme.bodyLarge?.color?.withOpacity(0.8),
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 8, right: 8, bottom: 12),
                          child: Text(
                            faq.answer,
                            style: textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
