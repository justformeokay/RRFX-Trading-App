import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'news_detail_controller.dart';

class NewsDetailPage extends StatelessWidget {
  final String slug;

  const NewsDetailPage({
    super.key,
    required this.slug,
  });

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
              return const Center(child: CircularProgressIndicator(color: CustomColor.secondaryColor));
            }
            final data = controller.detail.value;
            if (data == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.newspaper_rounded, size: 64, color: theme.colorScheme.primary),
                    const SizedBox(height: 12),
                    Text("News not found", style: theme.textTheme.titleMedium),
                  ],
                ),
              );
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
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                            child: Image.network(
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
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // AUTHOR + DATE
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 20),
                                    const SizedBox(width: 6),
                                    Text(data.author, style: theme.textTheme.bodyMedium),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.circle, size: 6),
                                    const SizedBox(width: 12),
                                    Icon(Icons.access_time_rounded, size: 18, color: theme.textTheme.bodyMedium?.color),
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
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                          child: Image.network(
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
                              Text(data.author, style: theme.textTheme.bodyMedium),
                              const SizedBox(width: 12),
                              const Icon(Icons.circle, size: 6),
                              const SizedBox(width: 12),
                              Icon(Icons.access_time_rounded, size: 18, color: theme.textTheme.bodyMedium?.color),
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
                        )
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
