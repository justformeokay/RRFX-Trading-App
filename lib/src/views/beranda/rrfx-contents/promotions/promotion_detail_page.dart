import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'promotion_detail_controller.dart';

class PromotionDetailPage extends StatelessWidget {
  final String slug;
  const PromotionDetailPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PromotionDetailController(slug));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text("Promotion Detail"),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          final bool isLandscape = orientation == Orientation.landscape;

          return Obx(() {
            if (controller.loading.value) {
              return const Center(
                child: CircularProgressIndicator(color: CustomColor.secondaryColor),
              );
            }

            final data = controller.detail.value;
            if (data == null) {
              return const Center(child: Text("Failed to load promotion details."));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ============================================================
                  // LANDSCAPE MODE → Image & Title info SIDE BY SIDE
                  // PORTRAIT MODE → Vertical as usual
                  // ============================================================
                  if (isLandscape)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // IMAGE
                        Expanded(
                          flex: 4,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              data.image,
                              height: 230,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        const SizedBox(width: 20),

                        // TITLE + META
                        Expanded(
                          flex: 6,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                Text(
                                  data.title,
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Meta Row
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: theme.textTheme.bodyMedium?.color,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _formatDate(data.publishDate),
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.textTheme.bodyMedium?.color,
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
                  else ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        data.image,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      data.title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16, color: theme.textTheme.bodyMedium?.color),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate(data.publishDate),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),

                  // ============================================================
                  // HTML CONTENT
                  // ============================================================
                  HtmlWidget(
                    data.content,
                    textStyle: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
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

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return "-";

    try {
      final dateOnly = rawDate.split("T").first;
      final date = DateTime.parse(dateOnly);

      return DateFormat("EEEE, d MMMM yyyy", "id_ID").format(date);
    } catch (e) {
      return rawDate;
    }
  }
}
