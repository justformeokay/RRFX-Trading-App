import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'market_analysis_controller.dart';
import 'market_analysis_card.dart';

class MarketAnalysisPage extends StatefulWidget {
  const MarketAnalysisPage({super.key});

  @override
  State<MarketAnalysisPage> createState() => _MarketAnalysisPageState();
}

class _MarketAnalysisPageState extends State<MarketAnalysisPage> {
  final controller = Get.put(MarketAnalysisController());
  final ScrollController scroll = ScrollController();

  @override
  void initState() {
    super.initState();

    scroll.addListener(() {
      if (scroll.position.pixels >= scroll.position.maxScrollExtent - 150) {
        controller.fetchMore();
      }
    });
  }

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text("Market Analysis"),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: CustomColor.secondaryColor));
        }

        if (controller.analysis.isEmpty) {
          return _noAvailableData();
        }

        return ListView.separated(
          controller: scroll,
          padding: const EdgeInsets.all(16),
          itemCount: controller.analysis.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (_, index) {
            if (index == controller.analysis.length) {
              return controller.isLoadMore.value
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : const SizedBox();
            }

            return MarketAnalysisCard(
              data: controller.analysis[index],
            );
          },
        );
      }),
    );
  }


  Widget _noAvailableData() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ICON
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.black.withOpacity(0.05),
              ),
              child: Icon(
                Icons.analytics_rounded,
                size: 48,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),

            const SizedBox(height: 20),

            // TITLE
            Text(
              "Belum Ada Market Analysis",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),

            const SizedBox(height: 10),

            // DESCRIPTION
            Text(
              "Konten market analysis akan muncul di halaman ini "
              "jika sudah tersedia dari platform RRFX.",
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1.45,
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
