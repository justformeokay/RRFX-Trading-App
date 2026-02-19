import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/colors/default.dart';

class AboutApp extends StatefulWidget {
  const AboutApp({super.key});

  @override
  State<AboutApp> createState() => _AboutAppState();
}

class _AboutAppState extends State<AboutApp> {
  late Future<PackageInfo> _packageInfo;

  @override
  void initState() {
    super.initState();
    _packageInfo = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar.defaultAppBar(
        title: "About App",
        autoImplyLeading: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Hero Section with Logo
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    CustomColor.secondaryColor.withOpacity(0.1),
                    CustomColor.secondaryColor.withOpacity(0.05),
                  ],
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CustomColor.secondaryColor.withOpacity(0.1),
                    ),
                    child: Image.asset(
                      'assets/images/logo-rrfx-3.png',
                      width: 80,
                      height: 80,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "PT. RRFX Investasi Berjangka",
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<PackageInfo>(
                    future: _packageInfo,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final version = snapshot.data!.version;
                        return Text(
                          "Versi $version",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Theme.of(
                              context,
                            ).textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                        );
                      }
                      return Text(
                        "Versi 1.8.35",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Main Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // About Section
                  Text(
                    "Tentang Aplikasi",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Selamat datang di aplikasi resmi PT. RRFX Investasi Berjangka. Platform trading modern yang dirancang untuk memberikan pengalaman trading forex yang aman, cepat, dan terpercaya di genggaman Anda.",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.6,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.justify,
                  ),

                  const SizedBox(height: 28),

                  // Features Grid
                  Text(
                    "Fitur Unggulan",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildFeatureGrid(context),

                  const SizedBox(height: 28),

                  // Company Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color:
                          isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: CustomColor.secondaryColor.withOpacity(
                                  0.15,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Iconsax.bank_outline,
                                size: 24,
                                color: CustomColor.secondaryColor,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              "Profil Perusahaan",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _buildInfoRow(
                          context,
                          label: "Nama Perusahaan",
                          value: "PT. RRFX Investasi Berjangka",
                        ),
                        const SizedBox(height: 14),
                        _buildInfoRow(
                          context,
                          label: "Tujuan",
                          value:
                              "Menyediakan layanan trading forex yang transparan dan profesional",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Contact Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color:
                          isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Iconsax.call_outline,
                                size: 24,
                                color: Colors.amber,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              "Hubungi Kami",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _buildContactItem(
                          context,
                          icon: Iconsax.location_outline,
                          label: "Alamat",
                          value:
                              "Ruko Soho Rodeo Drive Blok. A No. 20 (SRD-020), Desa/Kelurahan Kamal Muara, Kec. Penjaringan, Kota Adm. Jakarta Utara, Provinsi DKI Jakarta, Kode Pos: 14470",
                        ),
                        const SizedBox(height: 16),
                        _buildContactItem(
                          context,
                          icon: Iconsax.sms_outline,
                          label: "Email",
                          value: "cs@rrfx.co.id",
                          isClickable: true,
                          onTap: () {
                            Clipboard.setData(const ClipboardData(text: "cs@rrfx.co.id"));
                            CustomScaffoldMessanger.showAppSnackBar(
                              context,
                              message: "Email disalin: cs@rrfx.co.id",
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildContactItem(
                          context,
                          icon: Iconsax.call_outline,
                          label: "Telepon",
                          value: "021-50322008",
                          isClickable: true,
                          onTap: () {
                            Clipboard.setData(const ClipboardData(text: "021-50322008"));
                            CustomScaffoldMessanger.showAppSnackBar(
                              context,
                              message: "Nomor disalin: 021-50322008",
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Commitment Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          CustomColor.secondaryColor.withOpacity(0.1),
                          CustomColor.secondaryColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: CustomColor.secondaryColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Iconsax.shield_tick_outline,
                              size: 24,
                              color: CustomColor.secondaryColor,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Komitmen Kami",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          "PT. RRFX Investasi Berjangka berkomitmen untuk menyediakan layanan keuangan yang transparan, profesional, dan sesuai dengan regulasi yang berlaku. Kepercayaan Anda adalah prioritas utama kami.",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            height: 1.6,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color?.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    final features = [
      {
        'icon': Iconsax.wallet_outline,
        'title': 'Akun Mudah',
        'desc': 'Buka akun dengan cepat',
      },
      {
        'icon': Iconsax.trend_up_outline,
        'title': 'Trading Real-time',
        'desc': 'Akses pasar global 24/7',
      },
      {
        'icon': Iconsax.chart_outline,
        'title': 'Analisis Lengkap',
        'desc': 'Grafik & tools profesional',
      },
      {
        'icon': Iconsax.security_outline,
        'title': 'Aman Terpercaya',
        'desc': 'Sistem keamanan berlapis',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CustomColor.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  size: 28,
                  color: CustomColor.secondaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                feature['title'] as String,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                feature['desc'] as String,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(
              context,
            ).textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isClickable = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: isClickable ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: Colors.amber),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
            if (isClickable)
              Icon(
                Iconsax.copy_outline,
                size: 16,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.5),
              ),
          ],
        ),
      ),
    );
  }
}
