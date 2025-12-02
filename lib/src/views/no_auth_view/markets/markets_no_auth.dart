import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/alerts/popup.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/views/chart/components/flag_pair.dart';
import 'package:rrfx/src/views/markets/models/market_group_model.dart';
import 'package:rrfx/src/views/no_auth_view/markets/markets_no_auth_controller.dart';

class MarketsNoAuth extends StatefulWidget {
  const MarketsNoAuth({super.key});

  @override
  State<MarketsNoAuth> createState() => _MarketsNoAuthState();
}

class _MarketsNoAuthState extends State<MarketsNoAuth> {
  final controller = Get.put(MarketsNoAuthController());

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      controller.fetchSymbols();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return DefaultTabController(
        length: controller.tabCategories.length,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(120),
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Market', style: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w800, color: CustomColor.secondaryColor)),
                  const SizedBox(height: 8),
                  TabBar(
                    tabAlignment: TabAlignment.center,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: CustomColor.secondaryColor,
                    unselectedLabelColor: CustomColor.secondaryColor.withOpacity(0.5),
                    labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
                    indicatorColor: CustomColor.secondaryColor,
                    isScrollable: true,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                    indicatorWeight: 3,
                    dividerColor: Colors.grey.withOpacity(0.2),
                    tabs: controller.tabCategories.map((category) {
                      return Tab(text: category.capitalizeFirst ?? category);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: controller.tabCategories.map((category) {
              return TabBody(category: category);
            }).toList(),
          ),
        ),
      );
    });
  }
}

class TabBody extends GetView<MarketsNoAuthController> {
  final String category;
  const TabBody({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final symbols = controller.getSymbolsForCategory(category);
      IconData icon;
      switch(category.capitalizeFirst){
        case "Favorit":
          icon = Iconsax.star_1_outline;
        case "Komoditi":
          icon = Iconsax.box_1_outline;
        default:
          icon = Iconsax.dollar_circle_outline;
      }
      if (symbols.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 45.0),
              const SizedBox(height: 8.0),
              Text('Tidak ada simbol di kategori ${category.capitalizeFirst}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: () async {
          controller.fetchSymbols();
        },
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          itemCount: symbols.length,
          itemBuilder: (context, index) {
            final symbol = symbols[index];

            // Ambil data realtime dari Supabase

            return Obx(
              () {
                final tick = controller.liveTicks[symbol.symbol];
                return SymbolCardTile(
                symbol: symbol,
                currentCategory: category,
                bid: tick?.bid.toStringAsFixed(symbol.digits) ?? "-",
                ask: tick?.ask.toStringAsFixed(symbol.digits) ?? "-",
                high: tick?.bidHigh.toStringAsFixed(symbol.digits) ?? "-",
                low: tick?.bidLow.toStringAsFixed(symbol.digits) ?? "-",
              );
              }
            );
          },
        ),
      );
    });
  }
}

class SymbolCardTile extends GetView<MarketsNoAuthController> {
  final MarketSymbol symbol;
  final String currentCategory;
  final String bid;
  final String ask;
  final String high;
  final String low;

  const SymbolCardTile({
    super.key,
    required this.symbol,
    required this.currentCategory,
    required this.bid,
    required this.ask,
    required this.high,
    required this.low,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        AuthDirectionPopup.show();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1B1B1B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.25)
                  : Colors.grey.shade400.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 Symbol header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      FlagPair(marketName: symbol.symbol, size: 35.0),
                      const SizedBox(width: 10.0),
                      Text(
                        symbol.symbolAlias,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: CustomColor.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Text(
                currentCategory == 'FAVORIT'
                    ? (symbol.groupName.capitalizeFirst ?? 'Pasar')
                    : currentCategory.capitalizeFirst ?? 'Pasar',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onBackground.withOpacity(0.6),
                ),
              ),

              const SizedBox(height: 14),

              Divider(
                color: isDark ? Colors.white12 : Colors.grey.shade300,
                height: 1,
              ),

              const SizedBox(height: 14),

              /// 🔹 Market ticks info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniInfo(context, "Bid", bid, Colors.greenAccent.shade400),
                  _buildMiniInfo(context, "Ask", ask, Colors.redAccent.shade200),
                  _buildMiniInfo(context, "High", high, Colors.blueAccent.shade200),
                  _buildMiniInfo(context, "Low", low, Colors.orangeAccent.shade200),
                ],
              ),

              const SizedBox(height: 14),

              Divider(
                color: isDark ? Colors.white10 : Colors.grey.shade300,
                height: 1,
              ),

              const SizedBox(height: 12),

              /// 🔹 Technical details
              Wrap(
                spacing: 20,
                runSpacing: 10,
                children: [
                  _buildDetail(context, "Spread", symbol.spread.toString()),
                  _buildDetail(context, "Min Vol", symbol.volumeMin.toString()),
                  _buildDetail(context, "Max Vol", symbol.volumeMax.toString()),
                  _buildDetail(context, "Contract", symbol.contractSize.toString()),
                  _buildDetail(context, "Digits", symbol.digits.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// MINI INFO (Bid / Ask / High / Low)
  Widget _buildMiniInfo(BuildContext context, String label, String value, Color color) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: theme.colorScheme.onBackground.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  /// TECHNICAL DETAIL ITEM
  Widget _buildDetail(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: theme.colorScheme.onBackground.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}
