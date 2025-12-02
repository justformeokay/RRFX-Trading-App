import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/views/beranda/rrfx-contents/articles/article_card.dart';
import 'articles_controller.dart';

class ArticlesPage extends StatelessWidget {
  final controller = Get.put(ArticlesController());

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0E0E0E) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Articles",
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
        if (controller.articles.isEmpty && controller.loading.value) {
          return _buildShimmer(isDark);
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (scroll) {
            if (scroll.metrics.pixels ==
                scroll.metrics.maxScrollExtent &&
                controller.loadMore.value &&
                !controller.loading.value) {
              controller.fetchArticles();
            }
            return false;
          },

          child: ListView.separated(
            padding: const EdgeInsets.all(18),
            itemBuilder: (_, i) {
              if (i == controller.articles.length) {
                return controller.loadMore.value
                    ? _buildLoader()
                    : const SizedBox();
              }
              return ArticleCard(data: controller.articles[i]);
            },
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemCount: controller.articles.length + 1,
          ),
        );
      }),
    );
  }

  // Loading indicator on bottom
  Widget _buildLoader() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: CircularProgressIndicator(strokeWidth: 2),
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
