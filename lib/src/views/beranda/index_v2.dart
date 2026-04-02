import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:rrfx/src/helpers/widgets/app_network_image.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/account_list/account_selection_bottom_sheet.dart';
import 'package:rrfx/src/components/alerts/popup.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/alerts/modern_alert_dialog.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/popups/pending_verification_popup.dart';
import 'package:rrfx/src/controllers/home.dart';
import 'package:rrfx/src/controllers/regol.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:rrfx/src/controllers/utilities.dart';
import 'package:rrfx/src/helpers/formatters/regex_formatter.dart';
import 'package:rrfx/src/models/beranda/trading_card_models.dart';
import 'package:rrfx/src/views/accounts/account_information.dart';
import 'package:rrfx/src/views/accounts/demo_account_information.dart';
import 'package:rrfx/src/views/accounts/registration_online/views/step_0_password_meta.dart';
import 'package:rrfx/src/views/accounts/registration_online/views/step_3.dart';
import 'package:rrfx/src/views/beranda/all_trading_signals.dart';
import 'package:rrfx/src/views/beranda/rrfx-contents/market_analysis/market_analysis_detail_page.dart';
import 'package:rrfx/src/views/beranda/rrfx-contents/market_analysis/market_analysis_page.dart';
import 'package:rrfx/src/views/beranda/rrfx-contents/news/news_detail_page.dart';
import 'package:rrfx/src/views/beranda/rrfx-contents/news/news_page.dart';
import 'package:rrfx/src/views/beranda/rrfx-contents/promotions/promotion_section.dart';
import 'package:rrfx/src/views/chart/components/flag_pair.dart';
import 'package:rrfx/src/views/no_auth_view/explore/explore_content_controller.dart';
import 'package:rrfx/src/views/no_auth_view/mainpage_no_auth.dart';
import 'package:rrfx/src/views/trade/deposit.dart';
import 'package:rrfx/src/views/advance_charts/webview_chart_view_from_tile.dart';
import 'package:rrfx/src/views/trade/internal_transfer.dart';
import 'package:rrfx/src/views/trade/withdrawal.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  ExploreContentController contentController = Get.put(
    ExploreContentController(),
  );
  RxInt selectedIndexAccountTrading = 0.obs;
  RxString selectedAccountTrading = "".obs;
  RxString selectedBalanceAccount = "0".obs;
  RxString selectedTypeAccount = "RRFX".obs;
  RxInt selectedEquityAccount = 0.obs;
  RxBool showHideBalance = false.obs;
  RxBool haveDemoAccount = false.obs;
  RxBool haveRealAccount = false.obs;
  RxBool isLoadingAccount = false.obs;
  bool _isCreatingDemoAccount = false; // Track demo account creation
  Map<String, String>? flag;
  Timer? _timer;
  RxList menus =
      [
        {"app_name": 'Transaksi', "icon": Icons.wallet_sharp},
        {"app_name": 'Signals', "icon": FontAwesome.bolt_solid},
        {"app_name": 'Buat Akun', "icon": FontAwesome.plus_solid},
        {"app_name": 'News', "icon": FontAwesome.rss_solid},
        {"app_name": 'Market Analysis', "icon": Clarity.analytics_line},
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

  RxBool containsPendingAccount = false.obs;
  RxString pendingAccountStatus = "".obs;
  Rx<Color?> backgroundStatusPending = Rx<Color?>(null);
  Rx<IconData?> iconStatusPending = Rx<IconData?>(null);

  /// Map status ke icon dan warna
  Map<String, Map<String, dynamic>> statusStyleMap = {
    "Registrasi": {
      "color": Colors.blue,
      "icon": Iconsax.clock_1_outline,
      "label": "Sedang Diproses",
    },
    "Ditolak": {
      "color": Colors.red,
      "icon": Iconsax.close_circle_outline,
      "label": "Ditolak",
    },
    "Regol belum selesai": {
      "color": Colors.orange,
      "icon": Iconsax.warning_2_outline,
      "label": "Regol Belum Selesai",
    },
    "Proses Akun": {
      "color": Colors.orange,
      "icon": Iconsax.clock_1_outline,
      "label": "Proses Akun",
    },
    "Waiting": {
      "color": Colors.blue,
      "icon": Iconsax.clock_1_outline,
      "label": "Sedang di Verifikasi Admin",
    },
  };

  /// Fungsi untuk mendapatkan style (color & icon) berdasarkan status
  Map<String, dynamic> getStatusStyle(String status) {
    return statusStyleMap[status] ??
        {
          "color": Colors.grey,
          "icon": Iconsax.info_circle_outline,
          "label": status,
        };
  }

  void fetchPendingAccountStatus() {
    homeController
        .getPendingAccount()
        .then((result) {
          containsPendingAccount.value = result;

          final response = homeController.pendingModel.value?.response;
          if (response?.isNotEmpty == true) {
            final status = response![0].status ?? "Proses Akun";
            pendingAccountStatus.value = status;

            // Set icon dan color berdasarkan status
            final style = getStatusStyle(status);
            backgroundStatusPending.value = style["color"] as Color;
            iconStatusPending.value = style["icon"] as IconData;
          }
        })
        .catchError((e) {
          ErrorPopup.show(
            title: "Status Tidak Dikenali",
            message:
                "Status akun Anda tidak dapat dikenali oleh sistem. Silakan hubungi customer support kami.",
          );
        });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      _runTradingSignal();
      contentController.fetchNews();
      contentController.fetchMarketAnalysis();
      startTradingSignalTimer();
      fetchPendingAccountStatus();
    });
  }

  Future<void> _createDemoAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    if (accessToken == null || accessToken.isEmpty) {
      ModernAlertDialog.warning(
        title: 'Perlu Login',
        message: 'Anda harus login terlebih dahulu untuk membuat akun demo.',
        buttonText: 'OK',
        onPressed: () {
          Get.offAll(() => MainpageWithoutLogin());
        },
      );
      return;
    }
    if (_isCreatingDemoAccount) return;
    setState(() {
      _isCreatingDemoAccount = true;
    });

    try {
      final header = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };
      final response = await http
          .post(
            Uri.parse('${GlobalVariable.mainURL}/regol/createDemo'),
            headers: header,
          )
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw TimeoutException('Request timeout');
            },
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Get demo account reference
        final accountController = Get.find<AccountController>();

        // Close the warning dialog first
        Get.back();

        // Show success dialog and refresh account data
        ModernAlertDialog.success(
          title: 'Berhasil',
          message: 'Akun demo berhasil dibuat! Refresh halaman untuk melihat akun demo Anda.',
          buttonText: 'OK',
          onPressed: () {
            Get.back();
            accountController.fetchAccountInfo().then((_) {
              if (mounted) {
                setState(() {
                  _isCreatingDemoAccount = false;
                });
              }
            });
          },
        );
      } else {
        if (mounted) {
          ModernAlertDialog.error(
            title: 'Gagal',
            message: 'Gagal membuat akun demo. Coba lagi nanti.',
            buttonText: 'OK',
            onPressed: () {
              Get.back();
              setState(() {
                _isCreatingDemoAccount = false;
              });
            },
          );
        }
      }
    } on TimeoutException catch (_) {
      if (mounted) {
        ModernAlertDialog.error(
          title: 'Timeout',
          message:
              'Koneksi ke server memakan waktu terlalu lama. Coba lagi nanti.',
          buttonText: 'OK',
          onPressed: () {
            Get.back();
            setState(() {
              _isCreatingDemoAccount = false;
            });
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ModernAlertDialog.error(
          title: 'Gagal',
          message: 'Terjadi kesalahan saat membuat akun demo. Coba lagi nanti.',
          buttonText: 'OK',
          onPressed: () {
            Get.back();
            setState(() {
              _isCreatingDemoAccount = false;
            });
          },
        );
      }
    }
  }

  void _runTradingSignal() {
    utilitiesController.getTradingSignals();
  }

  @override
  void dispose() {
    _timer?.cancel(); // hentikan timer saat widget dihapus
    super.dispose();
  }

  /// Format balance dengan separator ribuan menggunakan periode
  /// Contoh: 57350.61 -> "57.350,61"
  String _formatBalance(dynamic balance) {
    if (balance == null || balance.toString().isEmpty) return "0,00";
    
    try {
      // Jika balance adalah string, convert ke double terlebih dahulu
      double numBalance;
      if (balance is String) {
        numBalance = double.parse(balance);
      } else if (balance is num) {
        numBalance = balance.toDouble();
      } else {
        numBalance = double.parse(balance.toString());
      }
      
      // Gunakan locale Indonesia untuk format dengan periode (ribuan) dan koma (desimal)
      final formatter = NumberFormat("#,##0.00", "id_ID");
      return formatter.format(numBalance);
    } catch (e) {
      print("Error formatting balance: $e");
      return "$balance";
    }
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
              CircleAvatar(
                backgroundImage: AssetImage('assets/icons/icon-rrfx.png'),
                radius: 20,
                backgroundColor: Colors.white,
              ),
              const SizedBox(width: 5.0),
              Text(
                "RRFX",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: CustomColor.secondaryColor,
                ),
              ),
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
              onPressed:
                  isLoadingAccount.value
                      ? null
                      : () async {
                        isLoadingAccount.value = true;
                        await controller.fetchAccountInfo().then((result) {
                          isLoadingAccount.value = false;
                          if (controller.hasAccounts) {
                            AccountSelectionBottomSheet.show();
                          }
                        });
                      },
              style: TextButton.styleFrom(
                overlayColor: theme.colorScheme.primary.withOpacity(0.05),
                padding: EdgeInsets.zero,
              ),
              child:
                  isLoadingAccount.value
                      ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: CustomColor.secondaryColor,
                        ),
                      )
                      : Padding(
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
                                  canPress
                                      ? (acc?.namaTipeAkun?.toUpperCase() ?? '')
                                      : 'TIDAK ADA AKUN',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color:
                                        canPress
                                            ? onSurfaceVariant
                                            : onSurface.withOpacity(0.4),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  acc?.login ?? 'Pilih Akun',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        canPress
                                            ? onSurface
                                            : onSurface.withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
            );
          }),
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
                () =>
                    !controller.hasAccounts
                        ? const SizedBox()
                        : Container(
                          margin: const EdgeInsets.all(16.0),
                          width: double.infinity,
                          height:
                              kIsWeb
                                  ? 200.0 // Fixed height untuk web platform
                                  : size.width /
                                      2.3, // Responsive height untuk mobile
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor, // ✅ lebih tepat
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                              width: 0.1,
                            ),
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
                                padding: const EdgeInsets.only(
                                  left: 16.0,
                                  right: 16.0,
                                  top: 16.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // === Balance Section ===
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Total Balance",
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800,
                                                color:
                                                    Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.color,
                                              ),
                                            ),
                                            const SizedBox(width: 7.0),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 2.0,
                                                horizontal: 8.0,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                color:
                                                    CustomColor
                                                        .secondaryBackground,
                                              ),
                                              child: Obx(
                                                () =>
                                                    !controller.hasAccounts
                                                        ? const SizedBox()
                                                        : Text(
                                                          controller
                                                                      .selectedAccount
                                                                      .value
                                                                      ?.type !=
                                                                  null
                                                              ? controller
                                                                  .selectedAccount
                                                                  .value!
                                                                  .type!
                                                                  .toUpperCase()
                                                              : 'N/A',
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 9.0,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                          ),
                                                        ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Obx(
                                          () => CupertinoButton(
                                            padding: EdgeInsets.zero,
                                            onPressed: () {
                                              showHideBalance(
                                                !showHideBalance.value,
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                Obx(
                                                  () =>
                                                      !controller.hasAccounts
                                                          ? const SizedBox()
                                                          : Text(
                                                            "${controller.selectedAccount.value?.accountCurrency} ${showHideBalance.value ? "****" : _formatBalance(controller.selectedAccount.value?.balance)}",
                                                            style: GoogleFonts.inter(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              color:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .textTheme
                                                                      .bodyLarge
                                                                      ?.color,
                                                            ),
                                                          ),
                                                ),
                                                const SizedBox(width: 5.0),
                                                Icon(
                                                  showHideBalance.value
                                                      ? Icons.visibility
                                                      : Icons.visibility_off,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.color
                                                      ?.withOpacity(0.7),
                                                  size: 20.0,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "Equity: ${controller.selectedAccount.value?.accountCurrency} ${controller.selectedAccount.value?.equity != null ? _formatBalance(controller.selectedAccount.value?.equity) : "0,00"}",
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                            color:
                                                Get.textTheme.bodySmall?.color,
                                          ),
                                        ),
                                        // Text(
                                        //   "Free Margin (%): ${controller.selectedAccount.value?.marginFreePercent ?? 0}%",
                                        //   style: GoogleFonts.inter(
                                        //     fontWeight: FontWeight.w500,
                                        //     fontSize: 12,
                                        //     color:
                                        //         Get.textTheme.bodySmall?.color,
                                        //   ),
                                        // ),
                                      ],
                                    ),

                                    // === Deposit & Withdraw Section ===
                                    Obx(() {
                                      if (!controller.hasAccounts) {
                                        return const SizedBox();
                                      }
                                      if (controller
                                              .selectedAccount
                                              .value
                                              ?.type ==
                                          "demo") {
                                        return const SizedBox();
                                      }
                                      return CupertinoButton(
                                        onPressed: () {
                                          FeatureUnderDevPopup.show();
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Iconsax.gift_outline,
                                              color: CustomColor.secondaryColor,
                                              size: 25.0,
                                            ),
                                            const SizedBox(height: 4.0),
                                            Text(
                                              "Rewards",
                                              style: GoogleFonts.inter(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    CustomColor.secondaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),

                              // === Free Margin Section ===
                              Container(
                                height: 50.0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(10.0),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      CustomColor.secondaryColor.withOpacity(
                                        0.3,
                                      ),
                                      CustomColor.secondaryColor.withOpacity(
                                        0.2,
                                      ),
                                      CustomColor.secondaryColor.withOpacity(
                                        0.1,
                                      ),
                                    ],
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Free Margin: ",
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                        Obx(
                                          () =>
                                              !controller.hasAccounts
                                                  ? const SizedBox()
                                                  : Text(
                                                    "${controller.selectedAccount.value?.accountCurrency} ${controller.selectedAccount.value?.marginFree != null ? _formatBalance(controller.selectedAccount.value?.marginFree) : "0,00"}",
                                                    style: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 13,
                                                      color:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyLarge
                                                              ?.color,
                                                    ),
                                                  ),
                                        ),
                                      ],
                                    ),
                                    Obx(
                                      () => CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        onPressed:
                                            tradingController.isLoading.value
                                                ? null
                                                : () {
                                                  if (!controller.hasAccounts) {
                                                    return;
                                                  }
                                                  if (controller
                                                          .selectedAccount
                                                          .value
                                                          ?.type ==
                                                      "demo") {
                                                    Get.to(
                                                      () => DemoAccountInformation(
                                                        loginID:
                                                            controller
                                                                .selectedAccount
                                                                .value
                                                                ?.login,
                                                      ),
                                                    );
                                                  } else if (controller
                                                          .selectedAccount
                                                          .value
                                                          ?.type ==
                                                      "real") {
                                                    Get.to(
                                                      () => AccountInformation(
                                                        loginID:
                                                            controller
                                                                .selectedAccount
                                                                .value
                                                                ?.login,
                                                      ),
                                                    );
                                                  } else {
                                                    CustomScaffoldMessanger.showAppSnackBar(
                                                      context,
                                                      message:
                                                          "Anda belum memiliki akun",
                                                      type: SnackBarType.info,
                                                    );
                                                  }
                                                },
                                        child: Text(
                                          "Lihat Detail",
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                            color:
                                                !controller.hasAccounts
                                                    ? Colors.grey
                                                    : CustomColor
                                                        .secondaryColor,
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
              Obx(
                () => Container(
                  margin:
                      containsPendingAccount.value
                          ? null
                          : const EdgeInsets.only(bottom: 16.0),
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
                            onPressed: () {
                              _handleMenuTap(context, size, appName);
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color:
                                        appName == "Rewards"
                                            ? Colors.grey.shade700
                                            : CustomColor.secondaryBackground
                                                .withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    icon,
                                    color:
                                        appName == "Rewards"
                                            ? Colors.white60
                                            : CustomColor.secondaryColor,
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
                                    color:
                                        appName == "Rewards"
                                            ? Colors.grey.shade700
                                            : Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.color,
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
              ),
              Obx(() {
                if (pendingAccountStatus.value.isEmpty == false && containsPendingAccount.value) {
                  final isDark = Get.isDarkMode;
                  final color = backgroundStatusPending.value ?? Colors.grey;
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      border: Border.all(
                        color: color.withOpacity(0.3),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                iconStatusPending.value ??
                                    Iconsax.info_circle_outline,
                                color: color,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Status Registrasi Akun Trading",
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color:
                                          isDark
                                              ? Colors.white
                                              : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Obx(
                                    () => Text(
                                      pendingAccountStatus.value.isEmpty
                                          ? "Sedang memproses..."
                                          : "Status: ${getStatusStyle(pendingAccountStatus.value)['label']}",
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            isDark
                                                ? Colors.white70
                                                : Colors.black54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            buildPendingStatusActionButton(),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.info_circle_outline,
                                size: 16,
                                color: color,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Proses verifikasi akun Anda sedang berlangsung. Biasanya memakan waktu 1-2 hari kerja.",
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: color,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox(height: 10);
              }),
              PromotionSection(),
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                padding: const EdgeInsets.all(16.0),
                color:
                    Theme.of(context).cardColor, // ✅ support light/dark theme
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Trading Signal",
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Obx(
                          () => CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed:
                                utilitiesController.isLoading.value
                                    ? null
                                    : () {
                                      final signals =
                                          utilitiesController
                                              .tradingSignal
                                              .value
                                              ?.message ??
                                          [];
                                      if (signals.isEmpty) {
                                        return;
                                      }
                                      Get.to(() => const AllTradingSignals());
                                    },
                            child: Text(
                              "Lihat Semua",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color:
                                    utilitiesController
                                                .tradingSignal
                                                .value
                                                ?.message
                                                ?.isEmpty ==
                                            true
                                        ? Colors.grey
                                        : CustomColor.secondaryColor,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    /// === Trading Signal List ===
                    Obx(() {
                      final signals =
                          utilitiesController.tradingSignal.value?.message ??
                          [];
                      if (signals.isEmpty &&
                          !utilitiesController.isLoading.value) {
                        return Center(
                          child: _buildEmptyMarketAnalysis(context),
                        );
                      }
                      final itemCount = signals.length.clamp(
                        0,
                        6,
                      ); // ✅ max 3 item

                      if (itemCount == 0) {
                        return Center(
                          child: _buildEmptyMarketAnalysis(context),
                        );
                      }

                      return Column(
                        children: List.generate(itemCount, (i) {
                          final signal = signals[i];
                          final analysis = signal.analysis;
                          final flags = RegexFormatter.getFlagsFromPairName(
                            signal.symbol ?? "EURUSD",
                          );
                          return buildCard(
                            context,
                            size,
                            TradingSignalCardData(
                              upper:
                                  analysis?.indicators?.bollingerBands?.upper
                                      ?.toString(),
                              lower:
                                  analysis?.indicators?.bollingerBands?.lower
                                      ?.toString(),
                              recommendation: analysis?.recommendation,
                              marketName: signal.symbol,
                              flagPair: flags['flag_one'],
                              flagPaired: flags['flag_two'],
                              bid: analysis?.currentPrice?.bid?.toString(),
                              ask: analysis?.currentPrice?.ask?.toString(),
                              date:
                                  analysis?.lastUpdate != null
                                      ? DateFormat(
                                        "EEEE, dd MMMM yyyy HH:mm:ss",
                                      ).format(
                                        DateTime.parse(analysis!.lastUpdate!),
                                      )
                                      : "-",
                              stopLoss:
                                  analysis?.tradingSuggestions?.stopLoss
                                      ?.toString(),
                            ),
                            utilitiesController.isLoading.value,
                            () {
                              // Check if user has demo accounts
                              if (controller.demoAccounts.isEmpty) {
                                ModernAlertDialog.warning(
                                  title: 'Belum Ada Akun Demo',
                                  message:
                                      'Anda perlu membuat akun demo terlebih dahulu untuk menggunakan fitur chart trading. Tekan tombol di bawah untuk membuat akun demo.',
                                  buttonText: 'Buat Akun Demo',
                                  onPressed: _createDemoAccount,
                                );
                                return;
                              }

                              String? selectedAccountType =
                                  controller.selectedAccount.value?.type;
                              if (selectedAccountType == null) {
                                return;
                              }
                              selectedAccountType.toLowerCase();
                              print(signal.symbol);
                              Get.to(
                                () => WebViewChartViewFromTile(
                                  login: int.parse(
                                    controller.selectedAccount.value?.login ??
                                        '0',
                                  ),
                                  marketName: "${signal.symbol}.db",
                                  balance: double.tryParse(
                                    controller.selectedAccount.value?.balance ??
                                        "0",
                                  ),
                                ),
                              );
                            },
                            () {},
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

  Widget buildCard(
    BuildContext context,
    Size size,
    TradingSignalCardData data,
    bool isLoading,
    VoidCallback? onTap,
    VoidCallback? onTapTile,
  ) {
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
                          FlagPair(
                            marketName: data.marketName ?? "",
                            size: 35.0,
                          ),
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
                        child: Text(
                          data.date ?? "-",
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontSize: 10.0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),

                  /// Bid - Ask - High - Low
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildInfoColumn(context, "Bid", data.bid),
                      ),
                      Expanded(
                        child: _buildInfoColumn(context, "Ask", data.ask),
                      ),
                      Expanded(
                        child: _buildInfoColumn(context, "High", data.upper),
                      ),
                      Expanded(
                        child: _buildInfoColumn(context, "Low", data.lower),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// === Kanan: Potensi ===
            CupertinoButton(
              onPressed: onTap,
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 5.0,
              ),
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
        Text(label, style: GoogleFonts.inter(color: Colors.grey, fontSize: 10)),
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

  /// === Modern Transaction Bottom Sheet ===
  void _showTransactionBottomSheet(BuildContext context, Size size) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // === Header ===
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Pilih Transaksi",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Iconsax.close_circle_outline,
                            color: Colors.black54,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // === Transaction Options ===
                  _buildTransactionCard(
                    icon: Iconsax.arrow_down_1_outline,
                    iconColor: Colors.green,
                    iconBgColor: Colors.green.withOpacity(0.1),
                    title: "Deposit",
                    subtitle: "Tambahkan dana ke akun trading Anda",
                    onTap: () {
                      Navigator.pop(context);
                      Future.delayed(const Duration(milliseconds: 300), () {
                        Get.to(() => const Deposit());
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildTransactionCard(
                    icon: Iconsax.arrow_up_3_outline,
                    iconColor: Colors.red,
                    iconBgColor: Colors.red.withOpacity(0.1),
                    title: "Withdraw",
                    subtitle: "Tarik dana dari akun trading Anda",
                    onTap: () {
                      Navigator.pop(context);
                      Future.delayed(const Duration(milliseconds: 300), () {
                        Get.to(() => const Withdrawal());
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildTransactionCard(
                    icon: Iconsax.arrow_swap_horizontal_outline,
                    iconColor: CustomColor.secondaryColor,
                    iconBgColor: CustomColor.secondaryColor.withOpacity(0.1),
                    title: "Internal Transfer",
                    subtitle: "Transfer antar akun trading Anda",
                    onTap: () {
                      Navigator.pop(context);
                      Future.delayed(const Duration(milliseconds: 300), () {
                        Get.to(() => InternalTransfer());
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// === Transaction Card Widget ===
  Widget _buildTransactionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Iconsax.arrow_right_3_outline,
                color: Colors.grey.shade400,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// === Select Account Bottom Sheet ===
  void _showSelectAccountBottomSheet(
    BuildContext context,
    Size size,
    String transactionType,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // === Header ===
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Pilih Akun Trading",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Iconsax.close_circle_outline,
                            color: Colors.black54,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // === Account List ===
                  Column(
                    children: List.generate(controller.realAccounts.length, (
                      index,
                    ) {
                      final acc = controller.realAccounts[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildAccountCard(
                          accountName: acc.namaTipeAkun ?? "",
                          accountLogin: acc.login ?? "",
                          balance: acc.balance ?? "0",
                          currency:
                              controller
                                  .selectedAccount
                                  .value
                                  ?.accountCurrency ??
                              "USD",
                          onTap: () {
                            Navigator.pop(context);
                            Future.delayed(
                              const Duration(milliseconds: 300),
                              () {
                                if (transactionType == "deposit") {
                                  Get.to(
                                    () =>
                                        Deposit(id: acc.id, idLogin: acc.login),
                                  );
                                } else if (transactionType == "withdraw") {
                                  Get.to(
                                    () => Withdrawal(
                                      id: acc.id,
                                      idLogin: acc.login,
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// === Account Card Widget ===
  Widget _buildAccountCard({
    required String accountName,
    required String accountLogin,
    required String balance,
    required String currency,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: CustomColor.secondaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Account Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CustomColor.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Iconsax.wallet_2_outline,
                  color: CustomColor.secondaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$accountName - $accountLogin",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Balance: $currency $balance",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: CustomColor.secondaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Iconsax.arrow_right_3_outline,
                color: CustomColor.secondaryColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// === Extracted Handler Function ===
  void _handleMenuTap(BuildContext context, Size size, String appName) async {
    switch (appName) {
      case "Transaksi":
        // === VALIDATION BEFORE SHOWING TRANSACTION MENU ===
        // 1. Check if user has no accounts at all
        if (!controller.hasAccounts) {
          showNoRealAccountPopup();
          return;
        }

        // 2. Check if user has no real account
        if (controller.realAccounts.isEmpty) {
          final result = await homeController.getPendingAccount();
          if (!result) {
            CustomScaffoldMessanger.showAppSnackBar(
              context,
              message: "Gagal mendapatkan data pending account",
              type: SnackBarType.error,
            );
            return;
          }

          // Check if pending account response is empty
          if (homeController.pendingModel.value?.response?.isEmpty == true) {
            showNoRealAccountPopup();
            return;
          }

          // Check if account is rejected or regol not completed
          final status = homeController.pendingModel.value?.response?[0].status;
          if (status == "Ditolak" || status == "Regol belum selesai") {
            showNoRealAccountPopup();
            return;
          }

          // If not rejected and not empty, show pending verification popup
          showPendingVerificationPopup(
            submittedDate: DateTime.now().toString().split(' ')[0],
          );
          return;
        }

        // === IF ALL VALIDATIONS PASS, SHOW TRANSACTION MENU ===
        _showTransactionBottomSheet(context, size);
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
        if (!controller.hasAccounts) {
          CustomScaffoldMessanger.showAppSnackBar(
            context,
            message:
                "Anda tidak memiliki akun real, dan demo, sistem otomatis akan membuat akun demo",
          );
          regolController.createDemoAccount().then((result) async {
            if (result) {
              SuccessDemoAccountPopup.show();
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
        } else {
          if(controller.realAccounts.isNotEmpty) {
            final hasSederhana = controller.realAccounts.any(
              (acc) => acc.cddType == "sederhana",
            );
            if (hasSederhana) {
              ModernAlertDialog.warning(
                title: 'Tidak Dapat Membuat Akun',
                message: 'Akun Anda berjenis CDD Sederhana sehingga tidak dapat membuat akun trading baru. Silakan hubungi customer support untuk informasi lebih lanjut.',
                buttonText: 'OK',
                onPressed: () => Get.back(),
              );
              return;
            }
          }
          homeController.getPendingAccount().then((result) async {
            if (!result) {
              ErrorPopup.show(
                title: "Informasi Akun Pending",
                message:
                    "Sistem tidak dapat mengambil data akun pending Anda. Silakan coba beberapa saat lagi.",
              );
              return;
            }
            if (homeController.pendingModel.value?.response?.isEmpty == true) {
              // await regolController.progressAccount();
              Get.to(() => CreateMT5PasswordPage());
            } else if (homeController.pendingModel.value?.response?.isNotEmpty == true) {
              if (homeController.pendingModel.value?.response?[0].status == "Registrasi") {
                AccountProcessingPopup.show(status: homeController.pendingModel.value?.response?[0].status ?? "Registrasi");
              } else if (homeController.pendingModel.value?.response?[0].status == "Ditolak") {
                Get.to(() => CreateMT5PasswordPage());
              } else if (homeController.pendingModel.value?.response?[0].status == "Regol belum selesai") {
                Get.to(() => CreateMT5PasswordPage());
              } else {
                AccountProcessingPopup.show(status: homeController.pendingModel.value?.response?[0].status ?? "Proses Akun");
              }
            } else {
              ErrorPopup.show(
                title: "Status Tidak Dikenali",
                message:
                    "Status akun Anda tidak dapat dikenali oleh sistem. Silakan hubungi customer support kami.",
              );
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
          Text(
            "Belum Ada Sinyal Trading",
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          // 🧾 Subtitle
          Text(
            "Kami akan menampilkan analisa pasar\nketika sinyal terbaru tersedia.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed:
                utilitiesController.isLoading.value
                    ? null
                    : () async {
                      await utilitiesController.getNewsList();
                    },
            icon: const Icon(
              Icons.refresh_rounded,
              color: CustomColor.secondaryColor,
            ),
            label: Text(
              "Coba Muat Ulang",
              style: GoogleFonts.inter(
                color: CustomColor.secondaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: CustomColor.secondaryColor),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: CustomColor.secondaryColor),
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
        children:
            contentController.analysis.map((item) {
              return _newsCardItem(
                item,
                onTap:
                    () => Get.to(
                      () => MarketAnalysisDetailPage(slug: item["slug"]),
                    ),
              );
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
        children:
            contentController.news.map((item) {
              return _newsCardItem(
                item,
                onTap: () => Get.to(() => NewsDetailPage(slug: item["slug"])),
              );
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
              Text(
                title,
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
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
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
            ),
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
              child: AppNetworkImage(
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
            ),
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

  /// Widget untuk menampilkan status badge dengan icon dan warna
  Widget buildPendingStatusBadge() {
    return Obx(() {
      final color = backgroundStatusPending.value ?? Colors.grey;
      final icon = iconStatusPending.value ?? Iconsax.info_circle_outline;
      final status = pendingAccountStatus.value;
      final style = getStatusStyle(status);
      final label = style["label"] as String? ?? status;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          border: Border.all(color: color.withOpacity(0.4), width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Widget untuk menampilkan button aksi berdasarkan status pending account
  Widget buildPendingStatusActionButton() {
    return Obx(() {
      final status = pendingAccountStatus.value;
      final color = backgroundStatusPending.value ?? Colors.grey;

      // Status "Registrasi" atau "Waiting" - button disabled/hilang
      if (status == "Registrasi" || status == "Waiting") {
        return const SizedBox.shrink(); // Hilangkan button
      }

      // Status "Ditolak" atau "Regol belum selesai" - button enabled
      final isEnabled = status == "Ditolak" || status == "Regol belum selesai";
      final buttonLabel = status == "Ditolak" ? "Buat Lagi" : "Lanjutkan";

      return SizedBox(
        width: 110,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            backgroundColor: isEnabled ? color : Colors.grey.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: isEnabled ? () {
            if(homeController.pendingModel.value?.response?[0].login != "0") {
              Get.to(() => Step3());
              return;
            }
            Get.to(() => CreateMT5PasswordPage());
          } : null,
          child: Text(
            buttonLabel,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    });
  }
}
