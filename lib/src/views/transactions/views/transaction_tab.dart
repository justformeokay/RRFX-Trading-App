import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/containers/no_account.dart';
import 'package:rrfx/src/views/transactions/views/close_transaction_meta_5.dart';
import 'package:rrfx/src/views/transactions/views/open_transacton_meta_5.dart';

class TransactionTab extends StatefulWidget {
  const TransactionTab({super.key});

  @override
  State<TransactionTab> createState() => _TransactionTabState();
}

class _TransactionTabState extends State<TransactionTab> with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AccountController controller = Get.put(AccountController());
  late TabController _tabController;

  Future<void> playSuccessSound() async {
    await _audioPlayer.play(AssetSource("sounds/applepay.mp3"));
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool canPress = controller.hasAccounts;
      if (!canPress) return noAccountDetected();
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Expanded(
                child: Text( "Transactions", style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: CustomColor.secondaryColor)),
              ),
            ],
          ),
          bottom: TabBar(
            overlayColor: WidgetStateProperty.all(CustomColor.secondaryColor.withOpacity(0.1)),
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: CustomColor.secondaryColor.withOpacity(0.1),
            ),
            splashFactory: NoSplash.splashFactory,
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: CustomColor.secondaryColor,
            indicatorWeight: 3,
            labelColor: CustomColor.secondaryColor,
            unselectedLabelColor: CustomColor.secondaryColor.withOpacity(0.5),
            dividerColor: Get.theme.dividerColor.withOpacity(0.2),
            labelStyle: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
            tabs: const [
              Tab(text: "OPEN"),
              Tab(text: "CLOSED")
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            OpenTransactonMeta5(),
            CloseTransactionMeta5()
          ],
        ),
      );
    });
  }
}
