import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/views/mainpage.dart';

class RegistrationSuccessPage extends StatelessWidget {
  const RegistrationSuccessPage({super.key});

  Color _accent(BuildContext context) => CustomColor.secondaryColor;
  Color _surface(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? Colors.grey[850]! : Colors.white;
  Color _textPrimary(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87;
  Color _textSecondary(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54;

  @override
  Widget build(BuildContext context) {
    final accent = _accent(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('Pendaftaran Berhasil', style: TextStyle(color: _textPrimary(context))),
        iconTheme: IconThemeData(color: _textPrimary(context)),
      ),
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor, // respect system theme
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 720),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Card with subtle elevation and gradient accent
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _surface(context),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black26
                              : Colors.black12,
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        // Decorative circle with check
                        Container(
                          width: 104,
                          height: 104,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                accent,
                                accent.withOpacity(0.85),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withOpacity(0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.check_rounded,
                              size: 56,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Pendaftaran Berhasil!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary(context),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Terima kasih! Pengajuanmu telah kami terima.',
                          style: TextStyle(fontSize: 14, color: _textSecondary(context)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Divider(color: Theme.of(context).dividerColor),
                        const SizedBox(height: 12),

                        // Info box
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, color: accent, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(color: _textSecondary(context), fontSize: 14, height: 1.4),
                                  children: [
                                    const TextSpan(text: 'Proses verifikasi biasanya memakan waktu '),
                                    TextSpan(
                                      text: '1 - 2 hari kerja',
                                      style: TextStyle(fontWeight: FontWeight.w700, color: _textPrimary(context)),
                                    ),
                                    const TextSpan(
                                        text:
                                            '. Setelah diverifikasi, kami akan menginformasikan melalui email atau notifikasi di aplikasi.'),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Actions
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  // kembali ke halaman awal aplikasi (mis. dashboard) dan hilangkan stack
                                  Get.offAll(() => const Mainpage());
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Theme.of(context).dividerColor),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Text('Selesai', style: TextStyle(color: _textPrimary(context), fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // juga ke MainPage tapi dengan aksen
                                  Get.offAll(() => const Mainpage());
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accent,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Ke Beranda', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Small help text
                  Text(
                    'Butuh bantuan? Hubungi layanan pelanggan kami.',
                    style: TextStyle(color: _textSecondary(context), fontSize: 13),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // bisa diarahkan ke halaman bantuan / chat
                      // Get.to(() => SupportPage());
                    },
                    child: Text('Pusat Bantuan', style: TextStyle(color: accent, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
