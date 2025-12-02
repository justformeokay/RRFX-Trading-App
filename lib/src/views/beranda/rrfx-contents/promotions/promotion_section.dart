import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/views/beranda/rrfx-contents/promotions/promotion_controller.dart';
import 'package:rrfx/src/views/beranda/rrfx-contents/promotions/promotion_detail_page.dart';

class PromotionSection extends StatefulWidget {
  const PromotionSection({super.key});

  @override
  State<PromotionSection> createState() => _PromotionSectionState();
}

class _PromotionSectionState extends State<PromotionSection> {
  final PromotionController controller = Get.put(PromotionController());
  final PageController pageCtrl = PageController(viewportFraction: 0.88);

  Timer? autoSlideTimer;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (controller.promotions.isNotEmpty) {
        if (currentPage < controller.promotions.length - 1) {
          currentPage++;
        } else {
          currentPage = 0;
        }
        pageCtrl.animateToPage(
          currentPage,
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    autoSlideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() {
      if (controller.isLoading.value) {
        return const SizedBox(
          height: 180,
          child: Center(
            child: CircularProgressIndicator(color: CustomColor.secondaryColor),
          ),
        );
      }
      if (controller.promotions.isEmpty) {
        return const SizedBox.shrink();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Promo Rewards",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white60 : Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: pageCtrl,
              itemCount: controller.promotions.length,
              itemBuilder: (context, index) {
                final item = controller.promotions[index];
                return _buildPromotionCard(isDark, item);
              },
            ),
          )
        ],
      );
    });
  }

  Widget _buildPromotionCard(bool isDark, dynamic item) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: GestureDetector(
        onTap: () {
          Get.to(() => PromotionDetailPage(slug: item.slug));
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              Image.network(
                item.image,
                fit: BoxFit.cover
              ),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.05),
                      Colors.black.withOpacity(0.55)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // Title
              Positioned(
                bottom: 16,
                left: 14,
                right: 14,
                child: Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    height: 1.3,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
