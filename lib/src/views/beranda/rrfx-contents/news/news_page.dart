import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/views/beranda/rrfx-contents/news/news_card.dart';
import 'news_controller.dart';

class NewsPage extends StatelessWidget {
  final controller = Get.put(NewsController());

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0E0E0E) : Colors.white,
      appBar: AppBar(
        forceMaterialTransparency: true,
        elevation: 0,
        title: Text(
          "News",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),

      body: Obx(() {
        if (controller.news.isEmpty && controller.loading.value) {
          return _buildShimmer(isDark);
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (scroll) {
            if (scroll.metrics.pixels == scroll.metrics.maxScrollExtent &&
                controller.loadMore.value &&
                !controller.loading.value) {
              controller.fetchNews();
            }
            return false;
          },

          child: ListView.separated(
            padding: const EdgeInsets.all(18),
            itemBuilder: (_, i) {
              if (i == controller.news.length) {
                return controller.loadMore.value
                    ? _buildLoader()
                    : const SizedBox();
              }
              return NewsCard(data: controller.news[i]);
            },
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemCount: controller.news.length + 1,
          ),
        );
      }),
    );
  }

  Widget _buildLoader() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: CircularProgressIndicator(strokeWidth: 2, color: CustomColor.secondaryColor),
      ),
    );
  }

  Widget _buildShimmer(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(18),
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        height: 120,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: isDark ? Colors.white12 : Colors.black12,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
