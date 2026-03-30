import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/helpers/widgets/app_network_image.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/views/beranda/rrfx-contents/market_analysis/market_analysis_detail_page.dart';
import 'market_analysis_model.dart';

class MarketAnalysisCard extends StatelessWidget {
  final MarketAnalysisModel data;
  const MarketAnalysisCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Get.to(() => MarketAnalysisDetailPage(slug: data.slug)),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black12,
            width: 0.5,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AppNetworkImage(
                data.thumbnail,
                height: 70,
                width: 70,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 70,
                    width: 70,
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isDark ? Colors.white54 : Colors.black54,
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      color:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 28,
                      color:
                          isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Row(
                  //   children: [
                  //     Icon(Icons.person_rounded,
                  //         size: 14,
                  //         color: isDark ? Colors.white54 : Colors.black54),
                  //     const SizedBox(width: 4),
                  //     Expanded(
                  //       child: Text(
                  //         data.authorName,
                  //         style: TextStyle(
                  //           fontSize: 12,
                  //           color: isDark ? Colors.white54 : Colors.black.withOpacity(.6),
                  //         ),
                  //         overflow: TextOverflow.ellipsis,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(data.publishDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return "-";

    try {
      // Ambil hanya bagian tanggal sebelum "T"
      final dateOnly = rawDate.split("T").first;

      final date = DateTime.parse(dateOnly);

      // Format bahasa Indonesia
      return DateFormat("EEEE, d MMMM yyyy", "id_ID").format(date);
    } catch (e) {
      return rawDate; // fallback
    }
  }
}
