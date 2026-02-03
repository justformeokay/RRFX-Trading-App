import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rrfx/src/components/alerts/popup.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/buttons/custom_buttons.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/widgets/build_version_indicator.dart';
import 'package:rrfx/src/controllers/utilities.dart';
import 'package:rrfx/src/views/beranda/rrfx-contents/market_analysis/market_analysis_detail_page.dart';
import 'package:rrfx/src/views/beranda/rrfx-contents/market_analysis/market_analysis_page.dart';
import 'package:rrfx/src/views/beranda/rrfx-contents/news/news_detail_page.dart';
import 'package:rrfx/src/views/beranda/rrfx-contents/news/news_page.dart';
import 'package:rrfx/src/views/beranda/rrfx-contents/promotions/promotion_detail_page.dart';
import 'package:rrfx/src/views/chart/components/flag_pair.dart';
import 'package:rrfx/src/views/no_auth_view/explore/explore_content_controller.dart';
import 'package:rrfx/src/views/trade/derivchart_without_loginid.dart';

class ExploreNoAuth extends StatefulWidget {
  const ExploreNoAuth({super.key});

  @override
  State<ExploreNoAuth> createState() => _ExploreNoAuthState();
}

class _ExploreNoAuthState extends State<ExploreNoAuth> {
  UtilitiesController utilitiesController = Get.put(UtilitiesController());
  RxBool isLoading = false.obs;
  RxBool hasConnection = true.obs;

  late PageController promoPageController;
  late ScrollController _scrollController;
  Timer? promoAutoScrollTimer;
  StreamSubscription? _connectionSubscription;

  ExploreContentController contentController = Get.put(ExploreContentController());

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    contentController.fetchPromotions();
    utilitiesController.getTradingSignals();
    contentController.fetchNews();
    contentController.fetchMarketAnalysis();
    promoPageController = PageController(viewportFraction: 0.88);
    _startPromoAutoScroll();
    
    // Monitor connection
    _checkConnection();
    _connectionSubscription = Connectivity().onConnectivityChanged.listen((result) {
      hasConnection.value = !result.contains(ConnectivityResult.none);
    });
  }

  Future<void> _checkConnection() async {
    final result = await Connectivity().checkConnectivity();
    hasConnection.value = !result.contains(ConnectivityResult.none);
  }

  @override
  void dispose() {
    promoPageController.dispose();
    promoAutoScrollTimer?.cancel();
    _connectionSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startPromoAutoScroll() {
    promoAutoScrollTimer?.cancel(); // prevent duplicate timers

    promoAutoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;

      final itemCount = contentController.promotions.length;
      if (itemCount == 0) return;

      final nextPage = promoPageController.page!.round() + 1;

      promoPageController.animateToPage(
        nextPage % itemCount,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Obx(() {
      // Show no connection screen if offline
      if (!hasConnection.value) {
        return _buildNoConnectionScreen(context, size);
      }

      return Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _buildBannerIntroduction(size: size, context: context),
                _buildMenusItem(size.height),
                Obx(() => _buildPromotionBannerSection()),
                Obx(() => isLoading.value ? const CircularProgressIndicator(color: CustomColor.secondaryColor) : _buildMarketAnalysisSection()),
                Obx(() => _buildMarketAnalysisContentSection()),
                Obx(() => _buildNewsSection()),
              ],
            ),
          ),
          // Floating Build Version Indicator dengan scroll detection
          BuildVersionIndicator(
            scrollController: _scrollController,
            margin: const EdgeInsets.fromLTRB(16, 50, 5, 16),
            showBuildNumber: true,
            autoHideOnScroll: true,
          ),
        ],
      );
    });
  }

  Widget _buildPromotionBannerSection() {
    final theme = Theme.of(context);

    if (contentController.isLoadingPromotions.value) {
      return _bannerLoading();
    }

    if (contentController.promotions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Promotions",
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 170,
          child: Listener(
            onPointerDown: (_) {
              promoAutoScrollTimer?.cancel();       // stop while dragging
            },
            onPointerUp: (_) {
              _startPromoAutoScroll();              // resume after drag
            },
            child: PageView.builder(
              controller: promoPageController,
              itemCount: contentController.promotions.length,
              itemBuilder: (context, index) {
                final item = contentController.promotions[index];
                return _buildPromoBannerCard(item);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoBannerCard(dynamic item) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Get.to(() => PromotionDetailPage(slug: item["slug"]));
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  item["image"],
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  child: Text(
                    item["title"],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _bannerLoading() {
    return SizedBox(
      height: 170,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, __) => Container(
          width: 300,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: 3,
      ),
    );
  }



  Widget _buildMarketAnalysisContentSection() {
    if (contentController.isLoadingAnalysis.value) {
      return _sectionLoading();
    }

    if (contentController.analysis.isEmpty) {
      return _sectionEmpty("Market Analysis");
    }

    return _buildSectionContainer(
      title: "Market Analysis",
      onSeeAll: () => Get.to(() => const MarketAnalysisPage()),
      child: Column(
        children: contentController.analysis.map((item) {
          return _newsCardItem(item, onTap: () => Get.to(() => MarketAnalysisDetailPage(slug: item["slug"])));
        }).toList(),
      ),
    );
  }

  Widget _buildNewsSection() {
    if (contentController.isLoadingNews.value) {
      return _sectionLoading();
    }

    if (contentController.news.isEmpty) {
      return _sectionEmpty("News");
    }

    return _buildSectionContainer(
      title: "Latest News",
      onSeeAll: () => Get.to(() => NewsPage()),
      child: Column(
        children: contentController.news.map((item) {
          return _newsCardItem(item, onTap: () => Get.to(() => NewsDetailPage(slug: item["slug"])));
        }).toList(),
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required Widget child,
    required VoidCallback onSeeAll,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  "Lihat Semua",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: CustomColor.secondaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          child
        ],
      ),
    );
  }


  Widget _buildBannerIntroduction({required Size size, required BuildContext context}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: size.height / 3,
      padding: const EdgeInsets.all(16.0),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage(
            isDark
              ? 'assets/images/dark.png'
              : 'assets/images/light.png',
          ),
          fit: BoxFit.cover,
        ),
      ),

      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔹 Logo + Title
            Row(
              children: [
                Image.asset('assets/images/logo-rrfx-3.png', width: 35),
                const SizedBox(width: 10.0),
                Text(
                  "RRFX",
                  style: GoogleFonts.inter(
                    color: CustomColor.secondaryColor,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              "Selamat datang di RRFX",
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Trading Komoditi, Forex & Index teregulasi oleh BAPPEBTI, OJK dan BI",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.9),
              ),
            ),


            const SizedBox(height: 10),

            SizedBox(
              width: 150,
              child: CustomButtons.buildFilledButton(
                text: "Mulai Trading",
                onPressed: () => AuthDirectionPopup.show(),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _newsCardItem(dynamic item, {VoidCallback? onTap}) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap ?? () => AuthDirectionPopup.show(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
              child: Image.network(
                item["thumbnail"] ?? item["image"],
                width: 110,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category
                    if (item["sub_category"] != null)
                      Text(
                        item["sub_category"]["name"] ?? "",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: CustomColor.secondaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                    const SizedBox(height: 4),

                    // Title
                    Text(
                      item["title"],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Publish date
                    Text(
                      _formatDate(item["publish_date"]),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


  Widget _buildMenusItem(double height) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      width: double.infinity,
      color: Theme.of(context).cardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buttonMenuItem(icon: FontAwesome.plus_solid, appName: 'Buat Akun', context: context, onTap: () => AuthDirectionPopup.show()),
          _buttonMenuItem(icon: FontAwesome.bolt_solid, appName: 'Signals', context: context, onTap: () => AuthDirectionPopup.show()),
          _buttonMenuItem(icon: Iconsax.gift_outline, appName: 'Rewards', context: context, onTap: () => AuthDirectionPopup.show()),
          _buttonMenuItem(icon: FontAwesome.rss_solid, appName: 'News', context: context, onTap: () => Get.to(() => NewsPage())),
          _buttonMenuItem(icon: Clarity.analytics_line, appName: 'Market Analysis', context: context, onTap: () => Get.to(() => const MarketAnalysisPage())),
        ]
      ),
    );
  }

  Widget _buttonMenuItem({required IconData icon, required String appName, required BuildContext context, VoidCallback? onTap}) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: CustomColor.secondaryBackground.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: CustomColor.secondaryColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            appName,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMarketAnalysis(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          
          // 🎨 Icon Circle modern
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: CustomColor.secondaryColor.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.query_stats_rounded,
              size: 40,
              color: CustomColor.secondaryColor,
            ),
          ),
          const SizedBox(height: 18),
          Text("Belum Ada Sinyal Trading",
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          // 🧾 Subtitle
          Text("Kami akan menampilkan analisa pasar\nketika sinyal terbaru tersedia.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          Obx(
            () => OutlinedButton.icon(
              onPressed: utilitiesController.isLoading.value ? null : () async {
                await utilitiesController.getTradingSignals();
              },
              icon: Obx(() => utilitiesController.isLoading.value ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 1, color: CustomColor.secondaryColor)) : const Icon(Icons.refresh_rounded, color: CustomColor.secondaryColor)),
              label: Obx(
                () => utilitiesController.isLoading.value ? Text("Mendapatkan Signals...",  style: GoogleFonts.inter(
                  color: Colors.grey,
                  fontWeight: FontWeight.w700,
                )) : Text("Coba Muat Ulang", style: GoogleFonts.inter(
                  color: CustomColor.secondaryColor,
                  fontWeight: FontWeight.w700,
                )),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: CustomColor.secondaryColor,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: CustomColor.secondaryColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMarketAnalysisSection(){
    final signals = utilitiesController.tradingSignal.value?.message ?? [];
    if (signals.isEmpty && !utilitiesController.isLoading.value) {
      return _buildEmptyMarketAnalysis(context);
    }
    final itemCount = signals.length.clamp(0, 6);
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      color: Theme.of(context).cardColor, // ✅ mengikuti theme
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Trading Signals",
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Get the Trading Signals updates to maximize your trading opportunities.",
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(itemCount, (index) =>  
          _buildItemMarket(
            onPressed: () {
              if(signals[index].symbol != null){
                Get.to(() => TradingChartView(marketName: signals[index].symbol!));
                return;
              }
              CustomScaffoldMessanger.showAppSnackBar(context, message: "Symbol is null");
            },
            recommendation: signals[index].analysis?.recommendation,
            bid: signals[index].analysis?.currentPrice?.bid.toString(),
            ask: signals[index].analysis?.currentPrice?.ask.toString(),
            high: signals[index].analysis?.indicators?.bollingerBands?.upper.toString(),
            low: signals[index].analysis?.indicators?.bollingerBands?.lower.toString(),
            symbol: signals[index].symbol,
            date: signals[index].analysis?.lastUpdate,
            )
          )
          // List of Market Analysis Items
        ]
      )
    );
  }

  Widget _buildItemMarket({
    required VoidCallback onPressed, 
    String? recommendation,
    String? bid, 
    String? ask,
    String? high,
    String? low,
    String? symbol,
    String? date
  }) {
    Color color = Colors.blueGrey;
    IconData icon = Icons.help_outline;
    switch (recommendation?.toUpperCase()) {
      case "BUY":
        color = Colors.green.shade400;
        icon = OctIcons.arrow_up_right;
        break;
      case "STRONG SELL":
        color = Colors.pink;
        icon = OctIcons.arrow_down_right;
        break;
      case "STRONG BUY":
        color = Colors.green;
        icon = OctIcons.arrow_up_right;
        break;
      case "SELL":
        color = Colors.red;
        icon = OctIcons.arrow_down_right;
        break;
      case "NEUTRAL":
        color = Colors.purple;
        icon = Icons.line_axis;
        break;
      default:
        color = Colors.blueGrey;
        icon = Icons.help_outline;
    }
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 10.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          FlagPair(marketName: symbol ?? "", size: 35.0),
                          const SizedBox(width: 5.0),
                          Text(symbol ?? "",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 5.0),
                      Flexible(
                        child: Text(DateFormat().format(DateTime.tryParse(date ?? "") ?? DateTime.now()), overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 10.0, color: Colors.grey)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
              
                  /// Bid - Ask - High - Low
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoColumn(context, "Bid", (bid).toString()),
                      _buildInfoColumn(context, "Ask", (ask).toString()),
                      _buildInfoColumn(context, "High", (high).toString()),
                      _buildInfoColumn(context, "Low", (low).toString()),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16.0),

            /// === Kanan: Potensi ===
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: color,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget kecil untuk kolom info
  Widget _buildInfoColumn(BuildContext context, String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter( color: Colors.grey, fontSize: 10)),
        const SizedBox(height: 4),
        Text(value ?? "0.0", maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color)),
      ],
    );
  }

  String _formatDate(String? raw) {
      if (raw == null) return "-";

      try {
        final date = DateTime.parse(raw);
        return DateFormat("d MMM yyyy, HH:mm", "id_ID").format(date);
      } catch (e) {
        return raw;
      }
    }

  Widget _sectionLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: CircularProgressIndicator(color: CustomColor.secondaryColor),
      ),
    );
  }

  Widget _sectionEmpty(String sectionName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          "No $sectionName available.",
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }

  /// Modern No Connection Screen
  Widget _buildNoConnectionScreen(BuildContext context, Size size) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: size.height - MediaQuery.of(context).padding.top,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Icon
                AnimatedBuilder(
                  animation: AlwaysStoppedAnimation(1),
                  builder: (context, child) {
                    return Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: CustomColor.secondaryColor.withOpacity(0.1),
                      ),
                      child: Center(
                        child: Icon(
                          Iconsax.wifi_square_outline,
                          size: 60,
                          color: CustomColor.secondaryColor,
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Title
                Text(
                  "Koneksi Internet Terputus",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "Periksa kembali koneksi internet Anda dan coba lagi.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Tips Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CustomColor.secondaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: CustomColor.secondaryColor.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Iconsax.info_circle_outline,
                            size: 20,
                            color: CustomColor.secondaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Tips:",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "• Pastikan WiFi atau data mobile Anda aktif\n"
                        "• Coba matikan dan nyalakan ulang perangkat\n"
                        "• Periksa pengaturan jaringan Anda",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Retry Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: CustomButtons.buildFilledButton(
                      text: "Coba Lagi",
                      onPressed: () {
                        _checkConnection();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
