import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:rrfx/src/controllers/user_controller.dart';
import 'package:rrfx/src/models/trades/trading_account_models.dart';

import 'detail_deposit.dart';

class DepositWithdrawalHistory extends StatefulWidget {
  const DepositWithdrawalHistory({super.key});

  @override
  State<DepositWithdrawalHistory> createState() => _DepositWithdrawalHistoryState();
}

class _DepositWithdrawalHistoryState extends State<DepositWithdrawalHistory> {
  UserController userController = Get.find();

  RxList<Map<String, dynamic>> listHistoryDeposit = <Map<String, dynamic>>[
    {"isDeposit": true, "balance": 300},
    {"isDeposit": false, "balance": 100},
  ].obs;

  RxInt selectedIndex = 0.obs;
  RxInt initialIndexTab = 0.obs;
  RxString selectedLoginID = "".obs;
  TradingController tradingController = Get.put(TradingController());
  RxList<dynamic> allAccountTrading = [
    Real(
      balance: "0",
      currency: "USD",
      id: "0",
      leverage: "400.00",
      login: "0",
      marginFree: "0",
      marginFreePercent: "0",
      maxWithdrawal: "0",
      minDeposit: "0",
      minTopup: "0",
      minWithdrawal: "",
      namaTipeAkun: "-",
      pnl: "0",
      rate: "Floating",
      totalDeposit: "0",
      totalWithdrawal: "0",
      type: "Demo"
    ),
  ].obs;

  Future<void> getAndSetAccountTrading() async {
    await tradingController.getTradingAccount().then((resultTradingAccount) {
      if (!resultTradingAccount) {
        CustomScaffoldMessanger.showAppSnackBar(context, message: tradingController.responseMessage.value);
        return;
      }
      final real = tradingController.tradingAccountModels.value?.response.real ?? [];
      allAccountTrading.clear();
      allAccountTrading..clear()..addAll(real);
      selectedIndex(0);
      selectedLoginID(allAccountTrading[0].login.toString());
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getAndSetAccountTrading();
      userController.historyWithdrawAndDeposit();
      userController.getInternalTransferHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Obx(
      () => DefaultTabController(
        length: 3,
        initialIndex: initialIndexTab.value,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Riwayat Deposit & Withdrawal", style: GoogleFonts.inter()),
            bottom: TabBar(
              dividerHeight: 0.5,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: CustomColor.secondaryColor,
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelColor: Theme.of(context).textTheme.labelSmall?.color,
              tabAlignment: TabAlignment.fill,
              indicatorColor: CustomColor.secondaryColor,
              dividerColor: Theme.of(context).dividerColor.withOpacity(0.3),
              tabs: const [
                Tab(text: 'Deposit'),
                Tab(text: 'Withdrawal'),
                Tab(text: 'Internal Transfer'),
              ],
            ),
          ),
          body: TabBarView(
              physics: const BouncingScrollPhysics(),
              children: [
                buildDepositHistory(context, size),
                buildWithdrawHistory(context, size),
                buildInternalTransfer(context, size),
              ],
            ),
          ),
      ),
    );
  }

  Widget buildInternalTransfer(BuildContext context, Size size){
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Obx((){
      if(userController.isLoading.value){
        return SizedBox(
          width: size.width,
          height: size.height / 1.2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/json/loader.json', width: 200, height: 200),
            ],
          ),
        );
      }

      if(userController.internalTransferHistory.value?.response.isEmpty == true){
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with gradient background
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        CustomColor.secondaryColor.withValues(alpha: 0.2),
                        Colors.purple.withValues(alpha: 0.2),
                      ],
                    ),
                  ),
                  child: Icon(
                    BoxIcons.bx_transfer_alt,
                    size: 60,
                    color: CustomColor.secondaryColor,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Title
                Text(
                  "No Internal Transfer",
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                // Description
                Text(
                  "Belum ada riwayat transfer internal\nantara akun trading Anda",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Info Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        context,
                        BoxIcons.bx_info_circle,
                        "Transfer Mudah",
                        "Pindahkan dana antar akun dengan cepat",
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        context,
                        Iconsax.clock_outline,
                        "Riwayat Otomatis",
                        "Semua transfer tercatat secara otomatis",
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Refresh Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await userController.getInternalTransferHistory();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(
                      "Refresh",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColor.secondaryColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final transfers = userController.internalTransferHistory.value?.response ?? [];
      
      // Remove duplicates based on transaction code
      final uniqueTransfers = <String, dynamic>{};
      for (var transfer in transfers) {
        final key = transfer.code ?? transfer.datetime ?? '';
        if (key.isNotEmpty && !uniqueTransfers.containsKey(key)) {
          uniqueTransfers[key] = transfer;
        }
      }
      
      // Sort transfers by date descending (newest first)
      final sortedTransfers = uniqueTransfers.values.toList()..sort((a, b) {
        try {
          if (a.datetime == null && b.datetime == null) return 0;
          if (a.datetime == null) return 1;
          if (b.datetime == null) return -1;
          return DateTime.parse(b.datetime!).compareTo(DateTime.parse(a.datetime!));
        } catch (e) {
          return 0;
        }
      });
      
      // Group by month
      Map<String, List<dynamic>> groupedTransfers = {};
      for (var transfer in sortedTransfers) {
        try {
          if(transfer.datetime == null) continue; // Skip if datetime is null
          final dateTime = DateTime.parse(transfer.datetime!);
          final monthKey = "${_getMonthName(dateTime.month)} ${dateTime.year}";
          if (!groupedTransfers.containsKey(monthKey)) {
            groupedTransfers[monthKey] = [];
          }
          groupedTransfers[monthKey]!.add(transfer);
        } catch (e) {
          // If date parsing fails, group under "Unknown"
          if (!groupedTransfers.containsKey("Unknown")) {
            groupedTransfers["Unknown"] = [];
          }
          groupedTransfers["Unknown"]!.add(transfer);
        }
      }
      
      return RefreshIndicator(
        color: CustomColor.secondaryColor,
        onRefresh: () async {
          await userController.getInternalTransferHistory();
        },
        child: Scrollbar(
          thumbVisibility: true,
          thickness: 4.0,
          radius: const Radius.circular(10),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: groupedTransfers.length,
            itemBuilder: (context, groupIndex) {
              final monthKey = groupedTransfers.keys.elementAt(groupIndex);
              final monthTransfers = groupedTransfers[monthKey]!;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month Header
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: CustomColor.secondaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        monthKey,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Month Items
                ...List.generate(monthTransfers.length, (i) {
                  final item = monthTransfers[i];
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade900 : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark 
                            ? Colors.black.withOpacity(0.2) 
                            : Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          _showTransferDetail(context, item);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Header: Code & DateTime
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: CustomColor.secondaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          BoxIcons.bx_transfer_alt,
                                          color: CustomColor.secondaryColor,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "#${item.code ?? '-'}",
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: theme.textTheme.bodyLarge?.color,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _formatDateTime(item.datetime ?? '-'),
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: theme.textTheme.bodySmall?.color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.green.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      item.amount ?? '\$0',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Divider
                              Container(
                                height: 1,
                                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Transfer Details: From → To
                              Row(
                                children: [
                                  // FROM
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.red.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.arrow_upward_rounded,
                                                size: 14,
                                                color: Colors.red,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                "FROM",
                                                style: GoogleFonts.inter(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.red,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            item.from ?? '-',
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: theme.textTheme.bodyLarge?.color,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Ticket: ${item.ticketFrom ?? '-'}",
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              color: theme.textTheme.bodySmall?.color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                                  // Arrow Icon
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Icon(
                                      Icons.arrow_forward_rounded,
                                      color: CustomColor.secondaryColor,
                                      size: 24,
                                    ),
                                  ),
                                  
                                  // TO
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.blue.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.arrow_downward_rounded,
                                                size: 14,
                                                color: Colors.blue,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                "TO",
                                                style: GoogleFonts.inter(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.blue,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            item.to ?? '-',
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: theme.textTheme.bodyLarge?.color,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Ticket: ${item.ticketTo ?? '-'}",
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              color: theme.textTheme.bodySmall?.color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
        ), 
      );
    });
  }

  void _showTransferDetail(BuildContext context, dynamic item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              
              // Title
              Text(
                "Transfer Details",
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Details
              _detailRow("Transaction Code", item.code ?? '-', theme),
              _detailRow("Amount", item.amount ?? '\$0', theme, isAmount: true),
              _detailRow("From Account", item.from ?? '-', theme),
              _detailRow("From Ticket", item.ticketFrom ?? '-', theme),
              _detailRow("To Account", item.to ?? '-', theme),
              _detailRow("To Ticket", item.ticketTo ?? '-', theme),
              _detailRow("Date & Time", item.datetime ?? '-', theme),
              
              const SizedBox(height: 24),
              
              // Close Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColor.secondaryColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Close",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value, ThemeData theme, {bool isAmount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: isAmount ? FontWeight.w800 : FontWeight.w600,
              color: isAmount 
                ? Colors.green 
                : theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDepositHistory(BuildContext context, Size size) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Obx(
      () {
        if(userController.isLoading.value){
          return SizedBox(
            width: size.width,
            height: size.height / 1.2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/json/loader.json', width: 200, height: 200),
              ],
            ),
          );
        }
        
        if(userController.historyDepoWd.value?.response.isEmpty == true){
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with gradient background
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.green.withValues(alpha: 0.2),
                          Colors.teal.withValues(alpha: 0.2),
                        ],
                      ),
                    ),
                    child: Icon(
                      AntDesign.arrow_down_outline,
                      size: 60,
                      color: Colors.green,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Title
                  Text(
                    "No Deposit History",
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Description
                  Text(
                    "Belum ada riwayat deposit\nke akun trading Anda",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          context,
                          Iconsax.wallet_add_outline,
                          "Deposit Cepat",
                          "Isi saldo dengan berbagai metode pembayaran",
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          context,
                          Iconsax.shield_tick_outline,
                          "Aman & Terpercaya",
                          "Transaksi dilindungi dengan enkripsi",
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Refresh Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await userController.historyWithdrawAndDeposit();
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(
                        "Refresh",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColor.secondaryColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        final deposits = userController.historyDepoWd.value?.response
            .where((res) => res.type == "Deposit" || res.type == "Deposit New Account")
            .toList() ?? [];

        if (deposits.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with gradient background
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.green.withValues(alpha: 0.2),
                          Colors.teal.withValues(alpha: 0.2),
                        ],
                      ),
                    ),
                    child: Icon(
                      AntDesign.arrow_down_outline,
                      size: 60,
                      color: Colors.green,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Title
                  Text(
                    "No Deposit History",
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Description
                  Text(
                    "Belum ada riwayat deposit\nke akun trading Anda",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          context,
                          Iconsax.wallet_add_outline,
                          "Deposit Cepat",
                          "Isi saldo dengan berbagai metode pembayaran",
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          context,
                          Iconsax.shield_tick_outline,
                          "Aman & Terpercaya",
                          "Transaksi dilindungi dengan enkripsi",
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Refresh Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await userController.historyWithdrawAndDeposit();
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(
                        "Refresh",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColor.secondaryColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        // Group by month
        Map<String, List<dynamic>> groupedDeposits = {};
        for (var deposit in deposits) {
          try {
            final dateTime = DateTime.parse(deposit.datetime);
            final monthKey = "${_getMonthName(dateTime.month)} ${dateTime.year}";
            if (!groupedDeposits.containsKey(monthKey)) {
              groupedDeposits[monthKey] = [];
            }
            groupedDeposits[monthKey]!.add(deposit);
          } catch (e) {
            // If date parsing fails, group under "Unknown"
            if (!groupedDeposits.containsKey("Unknown")) {
              groupedDeposits["Unknown"] = [];
            }
            groupedDeposits["Unknown"]!.add(deposit);
          }
        }
        
        return RefreshIndicator(
          color: CustomColor.secondaryColor,
          onRefresh: () async {
            await userController.historyWithdrawAndDeposit();
          },
          child: Scrollbar(
            thumbVisibility: true,
            thickness: 4.0,
            radius: const Radius.circular(10),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: groupedDeposits.length,
              itemBuilder: (context, groupIndex) {
                final monthKey = groupedDeposits.keys.elementAt(groupIndex);
                final monthDeposits = groupedDeposits[monthKey]!;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month Header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: CustomColor.secondaryColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          monthKey,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Month Items
                  ...List.generate(monthDeposits.length, (i) {
                    final result = monthDeposits[i];
                    
                    Color statusColor = Colors.grey;
                    IconData statusIcon = Icons.pending;
                    
                    switch (result.status) {
                      case "pending":
                        statusColor = Colors.orange.shade400;
                        statusIcon = Icons.pending;
                        break;
                      case "success":
                        statusColor = Colors.green.shade400;
                        statusIcon = Icons.check_circle;
                        break;
                      case "reject":
                        statusColor = Colors.red.shade400;
                        statusIcon = Icons.cancel;
                        break;
                      default:
                        statusColor = Colors.grey.shade400;
                        statusIcon = Icons.help;
                    }
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade900 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark 
                              ? Colors.black.withOpacity(0.2) 
                              : Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Get.to(() => TransactionDetailView(id: result.id));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Icon
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    AntDesign.arrow_down_outline,
                                    color: Colors.green,
                                    size: 24,
                                  ),
                                ),
                                
                                const SizedBox(width: 16),
                                
                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        result.type ?? "Deposit",
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: theme.textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.account_circle,
                                            size: 14,
                                            color: theme.textTheme.bodySmall?.color,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "ID ${result.login ?? '-'}",
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: theme.textTheme.bodySmall?.color,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 12,
                                            color: theme.textTheme.bodySmall?.color,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatDateTime(result.datetime),
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: theme.textTheme.bodySmall?.color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Amount & Status
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      result.amount ?? '\$0',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: statusColor.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            statusIcon,
                                            size: 12,
                                            color: statusColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            result.status ?? '',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: statusColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
          ),
        );
      }
    );
  }

  Widget buildWithdrawHistory(BuildContext context, Size size) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(
      () {
        if(userController.isLoading.value){
          return SizedBox(
            width: size.width,
            height: size.height / 1.2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/json/loader.json', width: 200, height: 200),
              ],
            ),
          );
        }

        if(userController.historyDepoWd.value?.response.isEmpty == true){
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with gradient background
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.orange.withValues(alpha: 0.2),
                          Colors.deepOrange.withValues(alpha: 0.2),
                        ],
                      ),
                    ),
                    child: Icon(
                      AntDesign.arrow_up_outline,
                      size: 60,
                      color: Colors.orange,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Title
                  Text(
                    "No Withdrawal History",
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Description
                  Text(
                    "Belum ada riwayat penarikan dana\ndari akun trading Anda",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          context,
                          Iconsax.wallet_minus_outline,
                          "Penarikan Mudah",
                          "Tarik profit Anda kapan saja",
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          context,
                          Iconsax.clock_outline,
                          "Proses Cepat",
                          "Withdrawal diproses dalam 1-24 jam",
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Refresh Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await userController.historyWithdrawAndDeposit();
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(
                        "Refresh",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColor.secondaryColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final withdrawals = userController.historyDepoWd.value?.response
            .where((res) => res.type == "Withdrawal")
            .toList() ?? [];

        if (withdrawals.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with gradient background
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.orange.withValues(alpha: 0.2),
                          Colors.deepOrange.withValues(alpha: 0.2),
                        ],
                      ),
                    ),
                    child: Icon(
                      AntDesign.arrow_up_outline,
                      size: 60,
                      color: Colors.orange,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Title
                  Text(
                    "No Withdrawal History",
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Description
                  Text(
                    "Belum ada riwayat penarikan dana\ndari akun trading Anda",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          context,
                          Iconsax.wallet_minus_outline,
                          "Penarikan Mudah",
                          "Tarik profit Anda kapan saja",
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          context,
                          Iconsax.clock_outline,
                          "Proses Cepat",
                          "Withdrawal diproses dalam 1-24 jam",
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Refresh Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await userController.historyWithdrawAndDeposit();
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(
                        "Refresh",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColor.secondaryColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Group by month
        Map<String, List<dynamic>> groupedWithdrawals = {};
        for (var withdrawal in withdrawals) {
          try {
            final dateTime = DateTime.parse(withdrawal.datetime);
            final monthKey = "${_getMonthName(dateTime.month)} ${dateTime.year}";
            if (!groupedWithdrawals.containsKey(monthKey)) {
              groupedWithdrawals[monthKey] = [];
            }
            groupedWithdrawals[monthKey]!.add(withdrawal);
          } catch (e) {
            // If date parsing fails, group under "Unknown"
            if (!groupedWithdrawals.containsKey("Unknown")) {
              groupedWithdrawals["Unknown"] = [];
            }
            groupedWithdrawals["Unknown"]!.add(withdrawal);
          }
        }

        return RefreshIndicator(
          color: CustomColor.secondaryColor,
          onRefresh: () async {
            await userController.historyWithdrawAndDeposit();
          },
          child: Scrollbar(
            thumbVisibility: true,
            thickness: 4.0,
            radius: const Radius.circular(10),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: groupedWithdrawals.length,
              itemBuilder: (context, groupIndex) {
                final monthKey = groupedWithdrawals.keys.elementAt(groupIndex);
                final monthWithdrawals = groupedWithdrawals[monthKey]!;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month Header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: CustomColor.secondaryColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          monthKey,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Month Items
                  ...List.generate(monthWithdrawals.length, (i) {
                    final result = monthWithdrawals[i];
                    
                    Color statusColor = Colors.grey;
                    IconData statusIcon = Icons.pending;
                    
                    switch (result.status) {
                      case "pending":
                        statusColor = Colors.orange.shade400;
                        statusIcon = Icons.pending;
                        break;
                      case "success":
                        statusColor = Colors.green.shade400;
                        statusIcon = Icons.check_circle;
                        break;
                      case "reject":
                        statusColor = Colors.red.shade400;
                        statusIcon = Icons.cancel;
                        break;
                      default:
                        statusColor = Colors.grey.shade400;
                        statusIcon = Icons.help;
                    }
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade900 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark 
                              ? Colors.black.withOpacity(0.2) 
                              : Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Get.to(() => TransactionDetailView(id: result.id));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Icon
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    AntDesign.arrow_up_outline,
                                    color: Colors.orange,
                                    size: 24,
                                  ),
                                ),
                                
                                const SizedBox(width: 16),
                                
                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        result.type ?? "Withdrawal",
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: theme.textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.account_circle,
                                            size: 14,
                                            color: theme.textTheme.bodySmall?.color,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "ID ${result.login ?? '-'}",
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: theme.textTheme.bodySmall?.color,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 12,
                                            color: theme.textTheme.bodySmall?.color,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatDateTime(result.datetime),
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: theme.textTheme.bodySmall?.color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Amount & Status
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      result.amount ?? '\$0',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: statusColor.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            statusIcon,
                                            size: 12,
                                            color: statusColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            result.status ?? '',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: statusColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
          ),
        );

      }
    );
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[month - 1];
  }

  String _formatDateTime(String datetime) {
    try {
      final dt = DateTime.parse(datetime);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dateToCheck = DateTime(dt.year, dt.month, dt.day);
      
      if (dateToCheck == today) {
        return "Today, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      } else if (dateToCheck == today.subtract(const Duration(days: 1))) {
        return "Yesterday, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      } else {
        return "${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      }
    } catch (e) {
      return datetime;
    }
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String title, String description) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                CustomColor.secondaryColor.withValues(alpha: 0.2),
                CustomColor.secondaryColor.withValues(alpha: 0.1),
              ],
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: CustomColor.secondaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}