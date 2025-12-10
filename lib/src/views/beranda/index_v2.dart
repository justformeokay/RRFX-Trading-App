import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/account_list/account_selection_bottom_sheet.dart';
import 'package:rrfx/src/components/alerts/popup.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/controllers/home.dart';
import 'package:rrfx/src/controllers/regol.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:rrfx/src/controllers/utilities.dart';
import 'package:rrfx/src/helpers/formatters/regex_formatter.dart';
import 'package:rrfx/src/models/beranda/trading_card_models.dart';
import 'package:rrfx/src/views/accounts/account_information.dart';
import 'package:rrfx/src/views/accounts/demo_account_information.dart';
import 'package:rrfx/src/views/accounts/registration_online/views/step_0_password_meta.dart';
import 'package:rrfx/src/views/beranda/all_trading_signals.dart';
import 'package:rrfx/src/views/beranda/rrfx-contents/market_analysis/market_analysis_detail_page.dart';
import 'package:rrfx/src/views/beranda/rrfx-contents/market_analysis/market_analysis_page.dart';
import 'package:rrfx/src/views/beranda/rrfx-contents/news/news_detail_page.dart';
import 'package:rrfx/src/views/beranda/rrfx-contents/news/news_page.dart';
import 'package:rrfx/src/views/beranda/rrfx-contents/promotions/promotion_section.dart';
import 'package:rrfx/src/views/chart/components/flag_pair.dart';
import 'package:rrfx/src/views/no_auth_view/explore/explore_content_controller.dart';
import 'package:rrfx/src/views/trade/deposit.dart';
import 'package:rrfx/src/views/advance_charts/webview_chart_view_from_tile.dart';
import 'package:rrfx/src/views/trade/internal_transfer.dart';
import 'package:rrfx/src/views/trade/withdrawal.dart';

class IndexV2 extends StatefulWidget {
  const IndexV2({super.key});

  @override
  State<IndexV2> createState() => _IndexV2State();
}

class _IndexV2State extends State<IndexV2> {
  UtilitiesController utilitiesController = Get.put(UtilitiesController());
  TradingController tradingController = Get.put(TradingController());
  RegolController regolController = Get.put(RegolController());
  HomeController homeController = Get.put(HomeController());
  final AccountController controller = Get.put(AccountController());
  ExploreContentController contentController = Get.put(ExploreContentController());
  RxInt selectedIndexAccountTrading = 0.obs;
  RxString selectedAccountTrading = "".obs;
  RxString selectedBalanceAccount = "0".obs;
  RxString selectedTypeAccount = "RRFX".obs;
  RxInt selectedEquityAccount = 0.obs;
  RxBool showHideBalance = false.obs;
  RxBool haveDemoAccount = false.obs;
  RxBool haveRealAccount = false.obs;
  RxBool isLoadingAccount = false.obs;
  Map<String, String>? flag;
  Timer? _timer;
  RxList menus = [
    {
      "app_name"  : 'Transaksi',
      "icon" : Icons.wallet_sharp
    },
    {
      "app_name"  : 'Signals',
      "icon" : FontAwesome.bolt_solid
    },
    {
      "app_name"  : 'Buat Akun',
      "icon" : FontAwesome.plus_solid
    },
    {
      "app_name"  : 'News',
      "icon" : FontAwesome.rss_solid
    },
    {
      "app_name"  : 'Market Analysis',
      "icon" : Clarity.analytics_line
    },
  ].obs;

  void startTradingSignalTimer() {
    final now = DateTime.now();
    if (now.weekday >= 1 && now.weekday <= 5) {
      _timer = Timer.periodic(const Duration(seconds: 20), (timer) {
        _runTradingSignal();
      });
    } else {
      debugPrint("Hari ini weekend, timer tidak dijalankan");
    }
  }

  var selectedIndex = 0.obs;
  RxBool wasGetAccountTrading = false.obs;


  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      _runTradingSignal();
      contentController.fetchNews();
      contentController.fetchMarketAnalysis();
      startTradingSignalTimer();
    });
  }

  void _runTradingSignal() {
    utilitiesController.getTradingSignals();
  }

  @override
  void dispose() {
    _timer?.cancel(); // hentikan timer saat widget dihapus
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey.withOpacity(0.1),
      appBar: AppBar(
        forceMaterialTransparency: true,
        leadingWidth: size.width / 1.5,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              CircleAvatar(backgroundImage: AssetImage('assets/icons/icon-rrfx.png'), radius: 20, backgroundColor: Colors.white),
              const SizedBox(width: 5.0),
              Text("RRFX", style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16, color: CustomColor.secondaryColor))
            ],
          ),
        ),
        actions: [
          Obx(() {
            final theme = Theme.of(context);
            final onSurface = theme.colorScheme.onSurface;
            final onSurfaceVariant = onSurface.withOpacity(0.6);
            bool canPress = controller.hasAccounts;
            final acc = controller.selectedAccount.value;
            if (!canPress) return const SizedBox();
            return TextButton(
              onPressed: isLoadingAccount.value ? null : () async {
                isLoadingAccount.value = true;
                await controller.fetchAccountInfo().then((result){
                  isLoadingAccount.value = false;
                  if(controller.hasAccounts){
                    AccountSelectionBottomSheet.show();
                  }
                });
              },
              style: TextButton.styleFrom(
                overlayColor: theme.colorScheme.primary.withOpacity(0.05),
                padding: EdgeInsets.zero,
              ),
              child: isLoadingAccount.value ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.0, color: CustomColor.secondaryColor)) : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.box_search_outline,
                      color: onSurface,
                      size: 20.0,
                    ),
                    const SizedBox(width: 7.0),

                    // TEXT
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          canPress ? (acc?.namaTipeAkun?.toUpperCase() ?? '') : 'TIDAK ADA AKUN',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: canPress ? onSurfaceVariant : onSurface.withOpacity(0.4),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          acc?.login ?? 'Pilih Akun',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: canPress ? onSurface : onSurface.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          })
        ],
      ),
      body: RefreshIndicator(
        color: CustomColor.secondaryColor,
        onRefresh: () async {
          await controller.fetchAccountInfo();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Obx(
                () => !controller.hasAccounts ? const SizedBox() : Container(
                  margin: const EdgeInsets.all(16.0),
                  width: double.infinity,
                  height: size.width / 2.3,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor, // ✅ lebih tepat
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Theme.of(context).dividerColor, width: 0.1),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        spreadRadius: 1.0,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // === Balance Section ===
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Total Balance",
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: Theme.of(context).textTheme.bodyMedium?.color,
                                      ),
                                    ),
                                    const SizedBox(width: 7.0),
                                    Container(
                                      padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10.0),
                                        color: CustomColor.secondaryBackground
                                      ),
                                      child: Obx(() => !controller.hasAccounts ? const SizedBox() : Text(controller.selectedAccount.value?.type != null ? controller.selectedAccount.value!.type!.toUpperCase() : 'N/A', style: TextStyle(color: Colors.black, fontSize: 9.0, fontWeight: FontWeight.w800))),
                                    )
                                  ],
                                ),
                                Obx(
                                  () => CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: (){
                                      showHideBalance(!showHideBalance.value);
                                    },
                                    child: Row(
                                      children: [
                                        Obx(
                                          () => !controller.hasAccounts ? const SizedBox() : Text("${controller.selectedAccount.value?.accountCurrency} ${showHideBalance.value ? "****" : controller.selectedAccount.value?.balance}",
                                            style: GoogleFonts.inter(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                              color: Theme.of(context).textTheme.bodyLarge?.color,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 5.0),
                                        Icon(showHideBalance.value ? Icons.visibility : Icons.visibility_off, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7), size: 20.0),
                                      ],
                                    ),
                                  ),
                                ),
                                Text(
                                  "Equity: ${controller.selectedAccount.value?.accountCurrency} ${controller.selectedAccount.value?.equity ?? 0}",
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: Get.textTheme.bodySmall?.color,
                                  ),
                                ),
                                Text(
                                  "Free Margin (%): ${controller.selectedAccount.value?.marginFreePercent ?? 0}%",
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: Get.textTheme.bodySmall?.color,
                                  ),
                                ),
                              ],
                            ),
                
                            // === Deposit & Withdraw Section ===
                            Obx(
                              () {
                                if(!controller.hasAccounts){
                                  return const SizedBox();
                                }
                                if(controller.selectedAccount.value?.type == "demo"){
                                  return const SizedBox();
                                }
                                return CupertinoButton(onPressed: (){
                                  FeatureUnderDevPopup.show();
                                }, child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(Iconsax.gift_outline, color: CustomColor.secondaryColor, size: 25.0),
                                      const SizedBox(height: 4.0),
                                      Text("Rewards", style: GoogleFonts.inter(fontSize: 12.0, fontWeight: FontWeight.bold, color: CustomColor.secondaryColor))
                                    ],
                                  )
                                );
                              }
                            ),
                          ],
                        ),
                      ),
                
                      // === Free Margin Section ===
                      Container(
                        height: 50.0,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(10.0),
                            bottomRight: Radius.circular(10.0),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              CustomColor.secondaryColor.withOpacity(0.3),
                              CustomColor.secondaryColor.withOpacity(0.2),
                              CustomColor.secondaryColor.withOpacity(0.1),
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Free Margin: ",
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                                Obx(
                                  () => !controller.hasAccounts ? const SizedBox() : Text(
                                    "${controller.selectedAccount.value?.accountCurrency} ${controller.selectedAccount.value?.marginFree}",
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: Theme.of(context).textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Obx(
                              () => CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: tradingController.isLoading.value ? null : (){
                                  if(!controller.hasAccounts){
                                    return;
                                  }
                                  if(controller.selectedAccount.value?.type == "demo"){
                                    Get.to(() => DemoAccountInformation(loginID: controller.selectedAccount.value?.login));
                                  }else if(controller.selectedAccount.value?.type == "real"){
                                    Get.to(() => AccountInformation(loginID: controller.selectedAccount.value?.login));
                                  }else{
                                    CustomScaffoldMessanger.showAppSnackBar(context, message: "Anda belum memiliki akun", type: SnackBarType.info);
                                  }
                                },
                                child: Text(
                                  "Lihat Detail",
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: !controller.hasAccounts ? Colors.grey : CustomColor.secondaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                width: double.infinity,
                color: Theme.of(context).cardColor, // ✅ mengikuti theme
                child: Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(menus.length, (i) {
                      final appName = menus[i]['app_name'] as String;
                      final icon = menus[i]['icon'] as IconData;

                      return Expanded(
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => _handleMenuTap(context, size, appName),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: appName == "Rewards" ? Colors.grey.shade700 : CustomColor.secondaryBackground.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  icon,
                                  color: appName == "Rewards" ? Colors.white60 : CustomColor.secondaryColor,
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
                                  color: appName == "Rewards" ? Colors.grey.shade700 : Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              PromotionSection(),
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                padding: const EdgeInsets.all(16.0),
                color: Theme.of(context).cardColor, // ✅ support light/dark theme
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Trading Signal", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 15)),
                        Obx(
                          () => CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: utilitiesController.isLoading.value ? null : () {
                              final signals = utilitiesController.tradingSignal.value?.message ?? [];
                              if(signals.isEmpty){
                                return;
                              }
                              Get.to(() => const AllTradingSignals());
                            },
                            child: Text("Lihat Semua", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: utilitiesController.tradingSignal.value?.message?.isEmpty == true ? Colors.grey : CustomColor.secondaryColor, fontSize: 13)),
                          ),
                        )
                      ],
                    ),

                    /// === Trading Signal List ===
                    Obx(() {
                      final signals = utilitiesController.tradingSignal.value?.message ?? [];
                      if (signals.isEmpty && !utilitiesController.isLoading.value) {
                        return Center(child: _buildEmptyMarketAnalysis(context));
                      }
                      final itemCount = signals.length.clamp(0, 6); // ✅ max 3 item

                      if (itemCount == 0) {
                        return Center(child: _buildEmptyMarketAnalysis(context));
                      }

                      return Column(
                        children: List.generate(itemCount, (i) {
                          final signal = signals[i];
                          final analysis = signal.analysis;
                          final flags = RegexFormatter.getFlagsFromPairName(signal.symbol ?? "EURUSD");
                          return buildCard(
                            context,
                            size,
                            TradingSignalCardData(
                              upper: analysis?.indicators?.bollingerBands?.upper?.toString(),
                              lower: analysis?.indicators?.bollingerBands?.lower?.toString(),
                              recommendation: analysis?.recommendation,
                              marketName: signal.symbol,
                              flagPair: flags['flag_one'],
                              flagPaired: flags['flag_two'],
                              bid: analysis?.currentPrice?.bid?.toString(),
                              ask: analysis?.currentPrice?.ask?.toString(),
                              date: analysis?.lastUpdate != null
                                ? DateFormat("EEEE, dd MMMM yyyy HH:mm:ss")
                                .format(DateTime.parse(analysis!.lastUpdate!))
                                : "-",
                            stopLoss: analysis?.tradingSuggestions?.stopLoss?.toString(),
                          ), utilitiesController.isLoading.value, (){
                            String? selectedAccountType = controller.selectedAccount.value?.type;
                            if(selectedAccountType == null){
                              return;
                            }
                            selectedAccountType.toLowerCase();
                            print(signal.symbol);
                            Get.to(() => WebViewChartViewFromTile(
                              login: int.parse(controller.selectedAccount.value?.login ?? '0'), 
                              marketName: "${signal.symbol}.db", 
                              balance: double.tryParse(controller.selectedAccount.value?.balance ?? "0")
                            ));
                          },
                          (){
                            
                          }
                          );
                        }),
                      );
                    }),
                  ],
                ),
              ),
              Obx(() => _buildMarketAnalysisContentSection()),
              Obx(() => _buildNewsSection()),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCard(BuildContext context, Size size, TradingSignalCardData data, bool isLoading, VoidCallback? onTap, VoidCallback? onTapTile) {
    Color color = Colors.blueGrey;
    IconData icon = Icons.help_outline;
    
    switch (data.recommendation?.toUpperCase()) {
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

    return GestureDetector(
      onTap: onTapTile,
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
            /// === Kiri: Info Pasar ===
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Pasangan mata uang + waktu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          FlagPair(marketName: data.marketName ?? "", size: 35.0),
                          const SizedBox(width: 5.0),
                          Text(
                            data.marketName ?? "-",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 5.0),
                      Flexible(
                        child: Text(data.date ?? "-", overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 10.0, )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
              
                  /// Bid - Ask - High - Low
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _buildInfoColumn(context, "Bid", data.bid)),
                      Expanded(child: _buildInfoColumn(context, "Ask", data.ask)),
                      Expanded(child: _buildInfoColumn(context, "High", data.upper)),
                      Expanded(child: _buildInfoColumn(context, "Low", data.lower)),
                    ],
                  ),
                ],
              ),
            ),
      
            /// === Kanan: Potensi ===
            CupertinoButton(
              onPressed: onTap,
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: color,
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
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
      Text(
        label,
        style: GoogleFonts.inter( color: Colors.grey, fontSize: 10),
      ),
      const SizedBox(height: 4),
      Text(
        value ?? "0.0",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    ],
  );
}

  /// === Extracted Handler Function ===
  void _handleMenuTap(BuildContext context, Size size, String appName) {
    switch (appName) {
      case "Transaksi":
        CustomMaterialBottomSheets.defaultBottomSheet(
          context,
          isScrolledController: false,
          title: "Pilih Transaksi",
          size: size,
          children: [
            ListTile(
              leading: const Icon(Icons.arrow_downward, color: Colors.green),
              title: Text('Deposit', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              style: ListTileStyle.list,
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                if(!controller.hasAccounts){
                  showNoRealAccountPopup();
                  return;
                }
                if(controller.realAccounts.isEmpty){
                  Get.back();
                  showNoRealAccountPopup();
                  return;
                }
                Navigator.pop(context);
                Future.delayed(Duration(milliseconds: 300), (){
                  CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Pilih Akun Trading", children: List.generate(controller.realAccounts.length, (real){
                    final acc = controller.realAccounts[real];
                    return ListTile(
                      leading: Icon(Icons.account_circle_rounded, color: CustomColor.secondaryColor),
                      title: Text("${acc.namaTipeAkun} - ${acc.login}", style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                      subtitle: Text("Balance: ${controller.selectedAccount.value?.accountCurrency} ${acc.balance}", style: GoogleFonts.inter(fontSize: 12.0)),
                      onTap: (){
                        Navigator.pop(context);
                        Future.delayed( Duration(milliseconds: 300), (){
                          Get.to(() => Deposit(id: acc.id, idLogin: acc.login));
                        });
                      },
                    );
                  }));
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_upward, color: Colors.red),
              title: Text('Withdraw', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              style: ListTileStyle.list,
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                if(!controller.hasAccounts){
                  showNoRealAccountPopup();
                  return;
                }
                if(controller.realAccounts.isEmpty){
                  Get.back();
                  showNoRealAccountPopup();
                  return;
                }
                Navigator.pop(context);
                Future.delayed(Duration(milliseconds: 300), (){
                  CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Pilih Akun Trading", children: List.generate(controller.realAccounts.length, (real){
                    final acc = controller.realAccounts[real];
                    return ListTile(
                      leading: Icon(Icons.account_circle_rounded, color: CustomColor.secondaryColor),
                      title: Text("${acc.namaTipeAkun} - ${acc.login}", style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                      subtitle: Text("Balance: ${controller.selectedAccount.value?.accountCurrency} ${acc.balance}", style: GoogleFonts.inter(fontSize: 12.0)),
                      onTap: (){
                        Navigator.pop(context);
                        Future.delayed( Duration(milliseconds: 300), (){
                          Get.to(() => Withdrawal(id: acc.id, idLogin: acc.login));
                        });
                      },
                    );
                  }));
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.sync_alt, color: Colors.red),
              title: Text('Internal Transfer', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              style: ListTileStyle.list,
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                if(!controller.hasAccounts){
                  showNoRealAccountPopup();
                  return;
                }
                if(controller.realAccounts.isEmpty){
                  Get.back();
                  showNoRealAccountPopup();
                  return;
                }
                Navigator.pop(context);
                Future.delayed(Duration(milliseconds: 300), (){
                  CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Pilih Akun Trading", children: List.generate(controller.realAccounts.length, (real){
                    final acc = controller.realAccounts[real];
                    return ListTile(
                      leading: Icon(Icons.account_circle_rounded, color: CustomColor.secondaryColor),
                      title: Text("${acc.namaTipeAkun} - ${acc.login}", style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                      subtitle: Text("Balance: ${controller.selectedAccount.value?.accountCurrency} ${acc.balance}", style: GoogleFonts.inter(fontSize: 12.0)),
                      onTap: (){
                        Navigator.pop(context);
                        Future.delayed( Duration(milliseconds: 300), (){
                          Get.to(() => InternalTransfer(loginID: acc.id, loginNumber: acc.login));
                        });
                      },
                    );
                  }));
                });
              },
            ),
          ]
        );
        break;
      case "Signals":
        Get.to(() => const AllTradingSignals());
        break;
      case "Market Analysis":
        // Get.to(() => const CardGridPage(title: "Market Analysis"));
        Get.to(() => const MarketAnalysisPage());
        break;
      case "News":
        // Get.to(() => const CardGridPage());
        Get.to(() => NewsPage());
        break;
      case "Buat Akun":
        if(!controller.hasAccounts){
          CustomScaffoldMessanger.showAppSnackBar(context, message: "Anda tidak memiliki akun real, dan demo, sistem otomatis akan membuat akun demo");
          regolController.createDemoAccount().then((result) async {
            if (result) {
              CustomScaffoldMessanger.showAppSnackBar(
                context,
                message: "Akun demo berhasil dibuat",
                type: SnackBarType.success,
              );
              final success = await tradingController.getTradingAccount();
              await controller.fetchAccountInfo();
              if (success) {
                haveDemoAccount(true);
              } else {
                CustomScaffoldMessanger.showAppSnackBar(
                  context,
                  message: tradingController.responseMessage.value,
                  type: SnackBarType.error,
                );
                haveDemoAccount(false);
              }
            } else {
              CustomScaffoldMessanger.showAppSnackBar(
                context,
                message: regolController.responseMessage.value,
                type: SnackBarType.error,
              );
            }
          });
        }else{
          homeController.getPendingAccount().then((result) async{
            if(!result){
              CustomScaffoldMessanger.showAppSnackBar(context, message: "Gagal mendapatkan akun pending");
              return;
            }
            if(homeController.pendingModel.value?.response?.isEmpty == true){
              await regolController.progressAccount();
              Get.to(() => CreateMT5PasswordPage());
            }else if(homeController.pendingModel.value?.response?.isNotEmpty == true){
              if(homeController.pendingModel.value?.response?[0].status == "Registrasi"){
                CustomScaffoldMessanger.showAppSnackBar(context, message: "Akun masih dalam proses ${homeController.pendingModel.value?.response?[0].status}");
              }else if(homeController.pendingModel.value?.response?[0].status == "Ditolak"){
                Get.to(() => CreateMT5PasswordPage());
              }else if(homeController.pendingModel.value?.response?[0].status == "Regol belum selesai"){
                Get.to(() => CreateMT5PasswordPage());
              }else{
                CustomScaffoldMessanger.showAppSnackBar(context, message: "Akun masih dalam proses ${homeController.pendingModel.value?.response?[0].status}");
              }
            }else{
              CustomScaffoldMessanger.showAppSnackBar(context, message: "Status akun tidak dapat dikenali");
            }
          });
        }
        break;
      default:
        debugPrint("ERROR ROUTES DIRECTION: $appName");
    }
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
            OutlinedButton.icon(
              onPressed: utilitiesController.isLoading.value ? null : () async {
                await utilitiesController.getNewsList();
              },
              icon: const Icon(Icons.refresh_rounded, color: CustomColor.secondaryColor),
                label:Text("Coba Muat Ulang", style: GoogleFonts.inter(
                  color: CustomColor.secondaryColor,
                  fontWeight: FontWeight.w700,
                )),
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
        ],
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
                  fontSize: 18,
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

  Widget _sectionLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: CircularProgressIndicator(color: CustomColor.secondaryColor),
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

  String _formatDate(String? raw) {
    if (raw == null) return "-";

    try {
      final date = DateTime.parse(raw);
      return DateFormat("d MMM yyyy, HH:mm", "id_ID").format(date);
    } catch (e) {
      return raw;
    }
  }
}