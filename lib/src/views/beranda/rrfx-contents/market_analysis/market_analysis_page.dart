import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'market_analysis_controller.dart';
import 'market_analysis_card.dart';

class MarketAnalysisPage extends StatefulWidget {
  const MarketAnalysisPage({super.key});

  @override
  State<MarketAnalysisPage> createState() => _MarketAnalysisPageState();
}

class _MarketAnalysisPageState extends State<MarketAnalysisPage> {
  final controller = Get.put(MarketAnalysisController());
  final ScrollController scroll = ScrollController();

  @override
  void initState() {
    super.initState();

    scroll.addListener(() {
      if (scroll.position.pixels >= scroll.position.maxScrollExtent - 150) {
        controller.fetchMore();
      }
    });
  }

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text("Market Analysis"),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: CustomColor.secondaryColor));
        }

        // Show error state
        if (controller.errorType.value != MarketAnalysisErrorType.none) {
          return _buildErrorState(context, theme, controller);
        }

        if (controller.analysis.isEmpty) {
          return _noAvailableData();
        }

        return ListView.separated(
          controller: scroll,
          padding: const EdgeInsets.all(16),
          itemCount: controller.analysis.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (_, index) {
            if (index == controller.analysis.length) {
              return controller.isLoadMore.value
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : const SizedBox();
            }

            return MarketAnalysisCard(
              data: controller.analysis[index],
            );
          },
        );
      }),
    );
  }


  Widget _noAvailableData() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ICON
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.black.withOpacity(0.05),
              ),
              child: Icon(
                Icons.analytics_rounded,
                size: 48,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),

            const SizedBox(height: 20),

            // TITLE
            Text(
              "Belum Ada Market Analysis",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),

            const SizedBox(height: 10),

            // DESCRIPTION
            Text(
              "Konten market analysis akan muncul di halaman ini "
              "jika sudah tersedia dari platform RRFX.",
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1.45,
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    ThemeData theme,
    MarketAnalysisController controller,
  ) {
    IconData icon;
    String title;
    String description;

    switch (controller.errorType.value) {
      case MarketAnalysisErrorType.noConnection:
        icon = Iconsax.wifi_square_outline;
        title = 'Tidak Ada Koneksi';
        description =
            'Sepertinya Anda tidak terhubung ke internet. Periksa koneksi WiFi atau data seluler Anda.';
        break;
      case MarketAnalysisErrorType.timeout:
        icon = Iconsax.timer_1_outline;
        title = 'Koneksi Terlalu Lambat';
        description =
            'Proses memuat data memakan waktu lebih dari 15 detik. Coba periksa kecepatan internet Anda.';
        break;
      case MarketAnalysisErrorType.serverError:
        icon = Iconsax.danger_outline;
        title = 'Terjadi Kesalahan';
        description =
            controller.errorMessage.value.isNotEmpty
                ? controller.errorMessage.value
                : 'Server sedang mengalami gangguan. Silakan coba lagi nanti.';
        break;
      default:
        icon = Iconsax.information_outline;
        title = 'Terjadi Kesalahan';
        description =
            'Maaf, terjadi kesalahan yang tidak terduga. Silakan coba lagi.';
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        forceMaterialTransparency: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_outline),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Icon
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: CustomColor.secondaryColor.withOpacity(0.1),
                            ),
                            child: Icon(
                              icon,
                              size: 60,
                              color: CustomColor.secondaryColor,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // Description
                    Text(
                      description,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Tips for connection issues
                    if (controller.errorType.value == MarketAnalysisErrorType.noConnection ||
                        controller.errorType.value == MarketAnalysisErrorType.timeout) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: CustomColor.secondaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: CustomColor.secondaryColor.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Iconsax.lamp_charge_outline,
                                  size: 18,
                                  color: CustomColor.secondaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Tips',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              controller.errorType.value == MarketAnalysisErrorType.timeout
                                  ? '• Pastikan koneksi internet Anda stabil\n• Coba matikan dan nyalakan ulang perangkat\n• Periksa pengaturan jaringan Anda'
                                  : '• Pastikan WiFi atau data mobile Anda aktif\n• Coba matikan dan nyalakan ulang perangkat\n• Periksa pengaturan jaringan Anda',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Action buttons
                    Column(
                      children: [
                        // Retry button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              controller.retryFetch();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CustomColor.secondaryColor,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Iconsax.refresh_outline, size: 20),
                            label: Text(
                              'Coba Lagi',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Back button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Get.back();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.colorScheme.onSurface,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(
                                color: theme.dividerColor.withOpacity(0.5),
                              ),
                            ),
                            icon: const Icon(Iconsax.arrow_left_outline, size: 20),
                            label: Text(
                              'Kembali',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}