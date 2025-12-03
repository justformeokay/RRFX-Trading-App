import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/controllers/firebase_api_controller.dart';
import 'package:rrfx/src/helpers/handlers/permissions.dart';
import 'package:rrfx/src/views/no_auth_view/explore/explore_no_auth.dart';
import 'package:rrfx/src/views/no_auth_view/history/history_no_auth.dart';
import 'package:rrfx/src/views/no_auth_view/markets/markets_no_auth.dart';
import 'package:rrfx/src/views/no_auth_view/settings/settings_no_auth.dart';
import 'package:rrfx/src/views/trade/derivchart_without_loginid.dart';

class MainpageWithoutLogin extends StatefulWidget {
  const MainpageWithoutLogin({super.key});

  @override
  State<MainpageWithoutLogin> createState() => _MainpageWithoutLoginState();
}

class _MainpageWithoutLoginState extends State<MainpageWithoutLogin> {
  
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const ExploreNoAuth(),
    const MarketsNoAuth(),
    const TradingChartView(marketName: "EURUSD", ),
    const HistoryNoAuth(),
    const SettingsNoAuth(),
  ];
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    FirebaseAPI.getToken();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await PermissionHandlers.requestPermissions();
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
                label: "Explore",
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