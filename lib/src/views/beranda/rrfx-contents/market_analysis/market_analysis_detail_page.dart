import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'market_analysis_detail_controller.dart';

class MarketAnalysisDetailPage extends StatelessWidget {
  final String slug;

  const MarketAnalysisDetailPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MarketAnalysisDetailController());
    controller.fetchDetail(slug);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text("Market Analysis Detail"),
        elevation: 0,
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          final bool isLandscape = orientation == Orientation.landscape;

          return Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: CustomColor.secondaryColor));
            }

            final data = controller.analysis.value;
            if (data == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.analytics_outlined, size: 64, color: theme.colorScheme.primary),
                    const SizedBox(height: 12),
                    Text("Market analysis not found", style: theme.textTheme.titleMedium),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ============================================================
                  // LANDSCAPE MODE → IMAGE + TITLE + AUTHOR SIDE BY SIDE
                  // PORTRAIT MODE → seperti biasa vertical
                  // ============================================================
                  if (isLandscape)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // IMAGE
                        Expanded(
                          flex: 4,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                            child: Image.network(
                              data.image,
                              height: 240,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // TEXT SIDE
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
                                const SizedBox(height: 20),

                                // AUTHOR CARD
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: isDark ? Colors.white12 : Colors.black12,
                                      backgroundImage: data.authorAvatar != null
                                          ? NetworkImage(data.authorAvatar!)
                                          : null,
                                      child: data.authorAvatar == null
                                          ? Icon(Icons.person,
                                              color: isDark ? Colors.white : Colors.black87)
                                          : null,
                                    ),
                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data.authorName,
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: theme.textTheme.titleMedium?.color,
                                            ),
                                          ),
                                          Text(
                                            data.authorSpecialist ?? _formatDate(data.publishDate),
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.textTheme.bodySmall?.color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )

                  // ============================================================
                  // PORTRAIT LAYOUT
                  // ============================================================
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // IMAGE
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                          child: Image.network(
                            data.image,
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // TITLE
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            data.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // AUTHOR CARD
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: isDark ? Colors.white12 : Colors.black12,
                                backgroundImage: data.authorAvatar != null
                                    ? NetworkImage(data.authorAvatar!)
                                    : null,
                                child: data.authorAvatar == null
                                    ? Icon(Icons.person,
                                        color: isDark ? Colors.white : Colors.black87)
                                    : null,
                              ),
                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data.authorName,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.textTheme.titleMedium?.color,
                                      ),
                                    ),
                                    Text(
                                      data.authorSpecialist ?? _formatDate(data.publishDate),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.textTheme.bodySmall?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),

                  // ============================================================
                  // HTML CONTENT
                  // ============================================================
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
                        "h2": Style(
                          fontSize: FontSize(22),
                          fontWeight: FontWeight.bold,
                          margin: Margins.only(top: 24, bottom: 12),
                        )
                      },
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            );
          });
        },
      ),
    );
  }

  // ============================
  // DATE FORMATTER INDONESIA
  // ============================
  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return "-";

    try {
      final dateOnly = rawDate.split("T").first;
      final date = DateTime.parse(dateOnly);

      return DateFormat("EEEE, d MMMM yyyy", "id_ID").format(date);
    } catch (_) {
      return rawDate;
    }
  }
}
