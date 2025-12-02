import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum NewsCardType {
  news,
  marketAnalysis,
  fundamentals,
}

class NewsCard extends StatelessWidget {
  final String author;
  final String title;
  final String description;
  final String date;
  final String imageUrl;
  final NewsCardType type;
  final VoidCallback? onTap;

  const NewsCard({
    super.key,
    required this.author,
    required this.title,
    required this.description,
    required this.date,
    required this.imageUrl,
    this.type = NewsCardType.news,
    this.onTap,
  });

  Color _typeColor(bool isDark) {
    switch (type) {
      case NewsCardType.news:
        return isDark ? Colors.blue.shade300 : Colors.blue.shade600;
      case NewsCardType.marketAnalysis:
        return isDark ? Colors.amber.shade300 : Colors.amber.shade700;
      case NewsCardType.fundamentals:
        return isDark ? Colors.green.shade300 : Colors.green.shade700;
    }
  }

  String _typeLabel() {
    switch (type) {
      case NewsCardType.news:
        return "News";
      case NewsCardType.marketAnalysis:
        return "Market Analysis";
      case NewsCardType.fundamentals:
        return "Fundamentals";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    final colorAccent = _typeColor(isDark);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.18)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.broken_image, size: 40),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // TAG TYPE
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: colorAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _typeLabel(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorAccent,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // TITLE
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),

            const SizedBox(height: 6),

            // DESCRIPTION
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                height: 1.35,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),

            const SizedBox(height: 14),

            // FOOTER (AUTHOR + DATE)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  author,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorAccent,
                    fontSize: 13,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: isDark ? Colors.white60 : Colors.black45,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
