import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/languages/language_variable.dart';
import 'package:rrfx/src/controllers/network_controller.dart';
import 'package:rrfx/src/controllers/theme_controller.dart';
import 'package:rrfx/src/controllers/trading_account_controller.dart';
import 'package:rrfx/src/service/auth_service.dart';
import 'package:rrfx/src/views/advance_charts/webview_chart_view.dart';
import 'package:rrfx/src/views/beranda/index_v2.dart';
import 'package:rrfx/src/views/markets/views/markets_meta_5.dart';
import 'package:rrfx/src/views/settings/index.dart';
import 'package:rrfx/src/views/transactions/views/transaction_tab.dart';

class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  int _selectedIndex = 0;

  TradingAccountController tradingAccountController = Get.put(
    TradingAccountController(),
  );
  AuthService authServiceController = Get.put(AuthService());
  NetworkController network = Get.put(NetworkController());
  ThemeController themeController = Get.put(ThemeController());

  static final List<Widget> _widgetOptions = <Widget>[
    const IndexV2(),
    const MarketsMeta5View(),
    const WebViewChartView(),
    const TransactionTab(),
    const Settings(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scaffoldBg =
        theme.scaffoldBackgroundColor; // ambil background scaffold

    return Obx(() {
      // Jika tidak ada koneksi, tampilkan layar koneksi terputus
      if (!network.hasConnection.value) {
        return _buildNoConnectionScreen(context, theme);
      }

      // Tampilan normal jika ada koneksi
      return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          body: _widgetOptions.elementAt(_selectedIndex),
          bottomNavigationBar: Container(
            color: scaffoldBg,
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              elevation: 0,

              backgroundColor: scaffoldBg,

              selectedItemColor: CustomColor.secondaryColor,
              unselectedItemColor: theme.colorScheme.onSurfaceVariant
                  .withOpacity(0.4),

              selectedIconTheme: IconThemeData(
                size: 25,
                color: CustomColor.secondaryColor,
              ),
              unselectedIconTheme: IconThemeData(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
              ),

              selectedLabelStyle: GoogleFonts.inter(fontSize: 14),
              unselectedLabelStyle: GoogleFonts.inter(fontSize: 14),

              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.home_outline),
                  activeIcon: Icon(Iconsax.home_bold),
                  label: LanguageGlobalVar.HOME.tr,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.global_outline),
                  activeIcon: Icon(Iconsax.global_bold),
                  label: "Market",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.chart_2_outline),
                  activeIcon: Icon(Iconsax.chart_21_bold),
                  label: "Trade",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.clock_outline),
                  activeIcon: Icon(Iconsax.clock_bold),
                  label: "History",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.setting_outline),
                  activeIcon: Icon(Iconsax.setting_bold),
                  label: "Lainnya",
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildNoConnectionScreen(BuildContext context, ThemeData theme) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.scaffoldBackgroundColor,
              theme.scaffoldBackgroundColor.withOpacity(0.95),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon animasi
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red.withOpacity(0.1),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Iconsax.wifi_square_outline,
                          size: 70,
                          color: Colors.red.withOpacity(0.8),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),

                // Title
                Text(
                  'Koneksi Terputus',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  'Sepertinya Anda tidak terhubung ke internet. Periksa koneksi WiFi atau data seluler Anda.',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Tips Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.dividerColor.withOpacity(0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
                            'Tips Mengatasi Masalah',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTipItem(
                        icon: Iconsax.wifi_outline,
                        text: 'Periksa apakah WiFi sudah aktif',
                        theme: theme,
                      ),
                      const SizedBox(height: 12),
                      _buildTipItem(
                        icon: Iconsax.mobile_outline,
                        text: 'Aktifkan data seluler jika diperlukan',
                        theme: theme,
                      ),
                      const SizedBox(height: 12),
                      _buildTipItem(
                        icon: Iconsax.refresh_outline,
                        text: 'Coba restart router atau perangkat',
                        theme: theme,
                      ),
                      const SizedBox(height: 12),
                      _buildTipItem(
                        icon: Iconsax.airplane_outline,
                        text: 'Pastikan mode pesawat tidak aktif',
                        theme: theme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Retry Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Cek koneksi ulang
                      final results = await Connectivity().checkConnectivity();
                      network.hasConnection.value =
                          !results.contains(ConnectivityResult.none);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColor.secondaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.refresh_outline, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Coba Lagi',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Status indicator
                Obx(
                  () => AnimatedOpacity(
                    opacity: network.isCheckingSpeed.value ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              CustomColor.secondaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Memeriksa koneksi...',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
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

  Widget _buildTipItem({
    required IconData icon,
    required String text,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.onSurface.withOpacity(0.4),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
