import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/helpers/widgets/app_network_image.dart';
import 'package:intl/intl.dart';

class ArticleCard extends StatelessWidget {
  final Map data;

  const ArticleCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    final title = data["title"] ?? "-";
    final category = data["sub_category"]?["name"] ?? "";
    final thumbnail = data["thumbnail"];
    final publish = data["publish_date"];
    final author = data["author"]?["fullname"] ?? "";

    final date = DateFormat("dd MMM yyyy").format(DateTime.parse(publish));

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        print("Open Article: ${data["slug"]}");
      },

      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 3),
              color: isDark ? Colors.black.withOpacity(0.35)
                            : Colors.grey.withOpacity(0.18),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: AppNetworkImage(
                thumbnail,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white12 : Colors.black12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Title
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 16,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        author,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
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
}
