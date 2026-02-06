import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/containers/no_account.dart';
import 'package:rrfx/src/views/transactions/views/close_transaction_meta_5.dart';
import 'package:rrfx/src/views/transactions/views/open_transacton_meta_5.dart';
import 'package:rrfx/src/views/transactions/views/pending_orders_page.dart';

class TransactionTab extends StatefulWidget {
  const TransactionTab({super.key});

  @override
  State<TransactionTab> createState() => _TransactionTabState();
}

class _TransactionTabState extends State<TransactionTab>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AccountController controller = Get.put(AccountController());
  late TabController _tabController;
  int _currentIndex = 0;

  Future<void> playSuccessSound() async {
    await _audioPlayer.play(AssetSource("sounds/applepay.mp3"));
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _currentIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final bool canPress = controller.hasAccounts;
      if (!canPress) return noAccountDetected();

      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          title: Text(
            "Transactions",
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: CustomColor.secondaryColor,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildModernTabBar(isDark),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const BouncingScrollPhysics(),
          children: const [
            OpenTransactonMeta5(),
            PendingOrdersPage(),
            CloseTransactionMeta5(),
          ],
        ),
      );
    });
  }

  Widget _buildModernTabBar(bool isDark) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade900.withOpacity(0.6)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: CustomColor.secondaryColor,
          boxShadow: [
            BoxShadow(
              color: CustomColor.secondaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor:
            isDark ? Colors.grey.shade500 : Colors.grey.shade600,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        labelPadding: EdgeInsets.zero,
        padding: const EdgeInsets.all(3),
        tabs: [
          _buildTab(
            icon: Iconsax.chart_1_outline,
            activeIcon: Iconsax.chart_1_bold,
            label: 'Open',
            index: 0,
          ),
          _buildTab(
            icon: Iconsax.clock_outline,
            activeIcon: Iconsax.clock_bold,
            label: 'Pending',
            index: 1,
          ),
          _buildTab(
            icon: Iconsax.tick_circle_outline,
            activeIcon: Iconsax.tick_circle_bold,
            label: 'Closed',
            index: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = _currentIndex == index;
    return Tab(
      height: 38,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 15,
            ),
            const SizedBox(width: 5),
            Text(label),
          ],
        ),
      ),
    );
  }
}
