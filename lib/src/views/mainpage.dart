import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/languages/language_variable.dart';
import 'package:rrfx/src/controllers/network_controller.dart';
import 'package:rrfx/src/controllers/theme_controller.dart';
import 'package:rrfx/src/controllers/trading_account_controller.dart';
import 'package:rrfx/src/service/auth_service.dart';
import 'package:rrfx/src/views/chart/views/chart_tab.dart';
import 'package:rrfx/src/views/markets/controllers/market_controller.dart';
import 'package:rrfx/src/views/markets/views/market_page.dart';
import 'package:rrfx/src/views/beranda/index_v2.dart';
import 'package:rrfx/src/views/settings/index.dart';
import 'package:rrfx/src/views/transactions/views/transaction_tab.dart';

class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  int _selectedIndex = 0;

  TradingAccountController tradingAccountController = Get.put(TradingAccountController());
  AuthService authServiceController = Get.put(AuthService());
  NetworkController network = Get.put(NetworkController());
  ThemeController themeController = Get.put(ThemeController());
  MarketController controller = Get.put(MarketController());

  static final List<Widget> _widgetOptions = <Widget>[
    const IndexV2(),
    MarketPage(),
    const ChartTab(),
    // const ChartAdvance(),
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
    final scaffoldBg = theme.scaffoldBackgroundColor; // ambil background scaffold

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
            unselectedItemColor: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),

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
                icon: Icon(ZondIcons.explore),
                label: LanguageGlobalVar.HOME.tr,
              ),
              BottomNavigationBarItem(
                icon: Icon(Bootstrap.globe_asia_australia),
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
                icon: Icon(BoxIcons.bxl_squarespace),
                label: "Lainnya",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
