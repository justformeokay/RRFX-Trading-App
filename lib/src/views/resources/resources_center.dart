import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/colors/default.dart';

class ResourcesCenter extends StatefulWidget {
  const ResourcesCenter({super.key});

  @override
  State<ResourcesCenter> createState() => _ResourcesCenterState();
}

class _ResourcesCenterState extends State<ResourcesCenter> {
  // Expanded section tracking
  Map<String, bool> expandedSections = {
    'trading': true,
    'produk': false,
    'edukasi': false,
    'perusahaan': false,
  };

  final Map<String, Map<String, dynamic>> resourcesData = {
    'trading': {
      'title': 'TRADING',
      'subtitle': 'Semua yang anda butuhkan untuk trading',
      'icon': Iconsax.trend_up_outline,
      'items': [
        {
          'label': 'Jenis Akun',
          'icon': Iconsax.wallet_outline,
          'color': Colors.blue,
        },
        {
          'label': 'Info Spread',
          'icon': Iconsax.chart_2_outline,
          'color': Colors.cyan,
        },
        {
          'label': 'Deposit & Withdrawal',
          'icon': Iconsax.arrow_swap_horizontal_outline,
          'color': Colors.purple,
        },
        {
          'label': 'Platform',
          'icon': Iconsax.monitor_outline,
          'color': Colors.orange,
        },
      ],
    },
    'produk': {
      'title': 'PRODUK',
      'subtitle': 'Instrumen trading yang tersedia',
      'icon': Iconsax.box_outline,
      'items': [
        {
          'label': 'Forex',
          'icon': Iconsax.global_outline,
          'color': Colors.green,
        },
        {
          'label': 'Komoditi',
          'icon': Iconsax.shopping_cart_outline,
          'color': Colors.amber,
        },
        {'label': 'Indeks', 'icon': Iconsax.chart_outline, 'color': Colors.red},
      ],
    },
    'edukasi': {
      'title': 'EDUKASI & BERITA',
      'subtitle': 'Pelajari dan update terkini',
      'icon': Iconsax.book_outline,
      'items': [
        {
          'label': 'Artikel',
          'icon': Iconsax.note_outline,
          'color': Colors.indigo,
        },
        {
          'label': 'Berita',
          'icon': Iconsax.notification_outline,
          'color': Colors.teal,
        },
        {
          'label': 'Market Analysis',
          'icon': Iconsax.chart_square_outline,
          'color': Colors.pink,
        },
      ],
    },
    'perusahaan': {
      'title': 'PERUSAHAAN',
      'subtitle': 'Informasi tentang RRFX',
      'icon': Iconsax.bank_outline,
      'items': [
        {
          'label': 'Hubungi Kami',
          'icon': Iconsax.call_outline,
          'color': Colors.deepOrange,
        },
        {
          'label': 'Legalitas',
          'icon': Iconsax.document_outline,
          'color': Colors.blueGrey,
        },
        {
          'label': 'Tentang Kami',
          'icon': Iconsax.info_circle_outline,
          'color': Colors.lightBlue,
        },
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar.defaultAppBar(
        title: "Resources Center",
        autoImplyLeading: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    CustomColor.secondaryColor.withOpacity(0.15),
                    CustomColor.secondaryColor.withOpacity(0.05),
                  ],
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CustomColor.secondaryColor.withOpacity(0.2),
                    ),
                    child: Icon(
                      Iconsax.book_1_outline,
                      size: 44,
                      color: CustomColor.secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Pusat Sumber Daya",
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Akses semua informasi penting untuk trading",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Resources Sections
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children:
                    resourcesData.entries.map((entry) {
                      final key = entry.key;
                      final data = entry.value;
                      final isExpanded = expandedSections[key] ?? false;

                      return Column(
                        children: [
                          _buildSectionHeader(
                            context,
                            key: key,
                            title: data['title'],
                            subtitle: data['subtitle'],
                            icon: data['icon'],
                            isExpanded: isExpanded,
                            isDark: isDark,
                            onTap: () {
                              setState(() {
                                expandedSections[key] = !isExpanded;
                              });
                            },
                          ),
                          AnimatedCrossFade(
                            firstChild: const SizedBox.shrink(),
                            secondChild: _buildSectionContent(
                              context,
                              items: data['items'],
                              isDark: isDark,
                            ),
                            crossFadeState:
                                isExpanded
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 300),
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }).toList(),
              ),
            ),

            // Quick Info Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Iconsax.info_circle_outline,
                          size: 24,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Tips Bermanfaat",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      "Jelajahi semua kategori resources kami untuk memaksimalkan pengalaman trading Anda. Dari jenis akun hingga analisis pasar, semua informasi tersedia di sini.",
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
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String key,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isExpanded,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CustomColor.secondaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: CustomColor.secondaryColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Iconsax.arrow_down_1_outline,
                size: 20,
                color: CustomColor.secondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContent(
    BuildContext context, {
    required List<dynamic> items,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children:
            items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;

              return Column(
                children: [
                  _buildResourceItem(
                    context,
                    label: item['label'],
                    icon: item['icon'],
                    color: item['color'],
                  ),
                  if (!isLast) ...[
                    const SizedBox(height: 8),
                    Divider(
                      height: 1,
                      color:
                          isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildResourceItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        // Akan diintegrasikan dengan navigasi actual nanti
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Buka: $label"),
            duration: const Duration(milliseconds: 1500),
          ),
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            Icon(
              Iconsax.arrow_right_3_outline,
              size: 18,
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Wave Painter untuk dekorasi
class WavePainter extends CustomPainter {
  final Color color;

  WavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final path = Path();
    const List<double> wavePoints = [
      0,
      15, // Start
      25,
      10,
      50,
      12,
      75,
      8,
      100,
      12,
    ];

    path.moveTo(0, 20);

    for (int i = 0; i < wavePoints.length; i += 2) {
      final x = (size.width / 100) * wavePoints[i];
      final y = wavePoints[i + 1].toDouble();
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
