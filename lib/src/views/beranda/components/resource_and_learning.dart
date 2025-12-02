import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/colors/default.dart';

class LearningSection extends StatelessWidget {
  final List<ResourceItem> items = [
    ResourceItem("Stock Market Basics", "Understand how stocks work.", "Read More", "assets/images/promotion.jpg"),
    ResourceItem("Candlestick Patterns", "Master key trading signals.", "Watch Video", "assets/images/promotion.jpg"),
    ResourceItem("Forex Strategies", "Learn profitable techniques.", "Download Ebook", "assets/images/promotion.jpg"),
    ResourceItem("Crypto Trends 2023", "Explore the latest insights.", "Read More", "assets/images/promotion.jpg"),
    ResourceItem("Risk Management", "Minimize losses effectively.", "Learn More", "assets/images/promotion.jpg"),
  ];

  LearningSection({super.key});

  @override
  Widget build(BuildContext context) {
    final int totalRows = (items.length / 2).ceil();
    final double cardHeight = 350;
    final double maxHeight = 5 * cardHeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Resources & Learning",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: totalRows > 5 ? maxHeight : totalRows * cardHeight,
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: totalRows > 5 ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.65,
            ),
            itemBuilder: (context, index) {
              return ResourceCard(item: items[index]);
            },
          ),
        ),
      ],
    );
  }
}

class ResourceItem {
  final String title;
  final String description;
  final String action;
  final String imagePath;

  ResourceItem(this.title, this.description, this.action, this.imagePath);
}

class ResourceCard extends StatelessWidget {
  final ResourceItem item;

  const ResourceCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(item.imagePath, height: 100, width: double.infinity, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 8),
            Text(item.title, style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(item.description, style: TextStyle(color: Colors.grey[700])),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 30,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: CustomColor.defaultColor)
                    ),
                    child: Text(item.action, textAlign: TextAlign.center, style: GoogleFonts.inter(color: CustomColor.defaultColor, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
