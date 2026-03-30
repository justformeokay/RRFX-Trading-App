import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/helpers/widgets/app_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'news_detail_controller.dart';

class NewsDetailPage extends StatelessWidget {
  final String slug;

  const NewsDetailPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NewsDetailController());
    controller.fetchDetail(slug);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text("News Detail"),
        elevation: 0,
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          final bool isLandscape = orientation == Orientation.landscape;

          return Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(
                  color: CustomColor.secondaryColor,
                ),
              );
            }

            // Handle error states
            if (controller.errorType.value != NewsErrorType.none) {
              return _buildErrorState(context, theme, controller);
            }

            final data = controller.detail.value;
            if (data == null) {
              return _buildErrorState(context, theme, controller);
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==============================================================
                  // LANDSCAPE MODE → Gambar dan Judul/Author Date jadi Row
                  // PORTRAIT MODE → seperti biasa vertical
                  // ==============================================================
                  if (isLandscape)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // IMAGE
                        Expanded(
                          flex: 4,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(20),
                            ),
                            child: AppNetworkImage(
                              data.image,
                              height: 260,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // TEXT AREA → Title + Author/Date
                        Expanded(
                          flex: 6,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16, top: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // TITLE
                                Text(
                                  data.title,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),

                                // AUTHOR + DATE
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 20),
                                    const SizedBox(width: 6),
                                    Text(
                                      data.author,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.circle, size: 6),
                                    const SizedBox(width: 12),
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 18,
                                      color: theme.textTheme.bodyMedium?.color,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      data.publishDate.split("T").first,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // IMAGE HEADER (portrait)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(20),
                          ),
                          child: AppNetworkImage(
                            data.image,
                            width: double.infinity,
                            height: 240,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // TITLE (portrait)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            data.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // AUTHOR & DATE (portrait)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              const Icon(Icons.person, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                data.author,
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.circle, size: 6),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.access_time_rounded,
                                size: 18,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatDate(data.publishDate),
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),

                  // ======================
                  // HTML CONTENT
                  // ======================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Html(
                      data: data.content,
                      style: {
                        "p": Style(
                          fontSize: FontSize(16),
                          color: isDark ? Colors.white : Colors.black87,
                          lineHeight: LineHeight(1.6),
                        ),
                        "strong": Style(fontWeight: FontWeight.bold),
                        "h2": Style(
                          fontSize: FontSize(22),
                          margin: Margins.only(top: 24, bottom: 12),
                        ),
                      },
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    ThemeData theme,
    NewsDetailController controller,
  ) {
    IconData icon;
    String title;
    String description;

    switch (controller.errorType.value) {
      case NewsErrorType.noConnection:
        icon = Iconsax.wifi_square_outline;
        title = 'Tidak Ada Koneksi';
        description =
            'Sepertinya Anda tidak terhubung ke internet. Periksa koneksi WiFi atau data seluler Anda.';
        break;
      case NewsErrorType.timeout:
        icon = Iconsax.timer_1_outline;
        title = 'Koneksi Terlalu Lambat';
        description =
            'Proses memuat data memakan waktu lebih dari 10 detik. Coba periksa kecepatan internet Anda.';
        break;
      case NewsErrorType.serverError:
        icon = Iconsax.danger_outline;
        title = 'Terjadi Kesalahan';
        description =
            controller.errorMessage.value.isNotEmpty
                ? controller.errorMessage.value
                : 'Server sedang mengalami gangguan. Silakan coba lagi nanti.';
        break;
      case NewsErrorType.notFound:
        icon = Iconsax.search_status_outline;
        title = 'Berita Tidak Ditemukan';
        description =
            'Berita yang Anda cari tidak dapat ditemukan atau sudah dihapus.';
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
                    if (controller.errorType.value == NewsErrorType.noConnection ||
                        controller.errorType.value == NewsErrorType.timeout) ...[
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
                              controller.errorType.value == NewsErrorType.timeout
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
                              controller.retryFetch(slug);
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

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return "-";

    try {
      // Ambil hanya bagian tanggal sebelum "T"
      final dateOnly = rawDate.split("T").first;
      final parsedDate = DateTime.parse(dateOnly);
      final formattedDate = DateFormat("dd MMM yyyy").format(parsedDate);
      return formattedDate;
    } catch (e) {
      return "-";
    }
  }
}
