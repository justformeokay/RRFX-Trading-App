import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/views/beranda/rrfx-contents/news/news_detail_page.dart';

class NewsCard extends StatelessWidget {
  final Map data;

  const NewsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    final title = data["title"] ?? "-";
    final category = data["sub_category"]?["name"] ?? "General";
    final thumbnail = data["thumbnail"] ?? "";
    final publish = data["publish_date"];
    // final author = data["author"] ?? "Admin";
    // final avatar = data["author"]?["avatar"];

    final date = DateFormat("dd MMM yyyy").format(DateTime.parse(publish));

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        print("Open News: ${data["slug"]}");
        Get.to(() => NewsDetailPage(slug: data["slug"]));
      },

      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141414) : const Color(0xFFFDFDFD),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(0, 4),
              color: isDark
                  ? Colors.black.withOpacity(0.35)
                  : Colors.grey.withOpacity(0.15),
            ),
          ],
        ),

        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ==============================
            //     IMAGE THUMBNAIL LEFT
            // ==============================
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                thumbnail,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 14),

            // ==============================
            //     RIGHT SIDE CONTENT
            // ==============================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // CATEGORY
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white12 : Colors.black12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // TITLE
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // AUTHOR + DATE
                  // Row(
                  //   children: [
                  //     CircleAvatar(
                  //       radius: 11,
                  //       backgroundColor:
                  //           isDark ? Colors.white12 : Colors.black12,
                  //       backgroundImage:
                  //           avatar != null ? NetworkImage(avatar) : null,
                  //     ),
                  //     const SizedBox(width: 8),
                  //     Expanded(
                  //       child: Text(
                  //         author ?? "Admin",
                  //         overflow: TextOverflow.ellipsis,
                  //         style: TextStyle(
                  //           fontSize: 12.5,
                  //           fontWeight: FontWeight.w600,
                  //           color: isDark ? Colors.white60 : Colors.black87,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 14,
                          color:
                              isDark ? Colors.white54 : Colors.black54),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(date),
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? Colors.white60 : Colors.black87,
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
