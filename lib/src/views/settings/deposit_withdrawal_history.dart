import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
import 'package:rrfx/src/components/buttons/custom_buttons.dart';
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
            actions: [
              CupertinoButton(
                onPressed: (){
                  CustomMaterialBottomSheets.defaultBottomSheet(context, title: "Pilih Akun Trading", size: size, children: List.generate(allAccountTrading.length, (i){
                    return ListTile(
                      onTap: (){
                        selectedIndex.value = i;
                        // userController.internalTransferHistory(loginID: allAccountTrading[selectedIndex.value].login.toString());
                        Get.back();
                      },
                      leading: Container(
                        padding: EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200
                        ),
                        child: Text("${i+1}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18)),
                      ),
                      title: Obx(() => Text("${allAccountTrading[i].type != null ? allAccountTrading[i].type.toString().toUpperCase() : ""} - ${allAccountTrading[i].login}", style: TextStyle(fontWeight: FontWeight.bold))),
                      subtitle: Obx(() => Text("Currency ${allAccountTrading[i].currency}", style: TextStyle(color: Theme.of(context).textTheme.titleSmall?.color))),
                      trailing: selectedIndex.value == i ? const Icon(Icons.check, color: Colors.green) : null,
                    );
                  }));
                },
                child: Icon(Icons.person_search, color: CustomColor.secondaryColor)
              )
              
            ],
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
        return SizedBox(
          width: size.width,
          height: size.height / 1.2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/json/cat.json', width: 200, height: 200),
              const SizedBox(height: 16),
              Text(
                "Tidak ada riwayat Internal Transfer",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 16),
              CustomButtons.buildOutlinedButton(
                text: "Refresh", 
                onPressed: () async {
                  await userController.getInternalTransferHistory();
                }
              )
            ],
          ),
        );
      }

      final result = userController.internalTransferHistory.value?.response;
      
      return RefreshIndicator(
        color: CustomColor.secondaryColor,
        onRefresh: () async {
          await userController.getInternalTransferHistory();
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: result?.length ?? 0,
          itemBuilder: (context, index) {
            final item = result![index];
            
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
                                      item.datetime ?? '-',
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
          },
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
    return Obx(
      () {
        if(userController.isLoading.value){
          return SizedBox(
            width: size.width,
            height: size.height / 1.2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/json/loader.json'),
              ],
            ),
          );
        }
        if(userController.historyDepoWd.value?.response.isEmpty == true){
          return SizedBox(
            width: size.width,
            height: size.height / 1.2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/json/cat.json'),
                const SizedBox(height: 16),
                const Text("Tidak ada riwayat Deposit"),
              ],
            ),
          );
        }
        final deposits = userController.historyDepoWd.value?.response.where((res) => res.type == "Deposit" || res.type == "Deposit New Account").toList() ?? [];

        if (deposits.isEmpty) {
          return SizedBox(
            width: size.width,
            height: size.height / 1.2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/json/cat.json'),
                const SizedBox(height: 16),
                const Text("Tidak ada riwayat Deposit"),
              ],
            ),
          );
        }
        return RefreshIndicator(
          color: CustomColor.secondaryColor,
          onRefresh: () async {
            await userController.historyWithdrawAndDeposit();
          },
          child: ListView(
            children: List.generate(deposits.length, (i) {
              final result = deposits[i];
          
              Color color = Colors.grey;
              switch (result.status) {
                case "pending":
                  color = Colors.blue.shade400;
                  break;
                case "success":
                  color = Colors.green.shade400;
                  break;
                case "reject":
                  color = Colors.red.shade400;
                  break;
                default:
                  color = Colors.grey.shade400;
              }
          
              return ListTile(
                onTap: () {
                  Get.to(() => TransactionDetailView(id: result.id));
                },
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.green,
                  child: const Icon(AntDesign.arrow_down_outline, color: Colors.white),
                ),
                title: Text(
                  "${result.type} - ID ${result.login}",
                  style: GoogleFonts.inter(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  result.amount,
                  style: GoogleFonts.inter(color: theme.textTheme.bodyMedium?.color),
                ),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        result.status != "" ? result.status.capitalize! : "",
                        style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Text(result.datetime, style: TextStyle(fontSize: 9))
                  ],
                ),
              );
            }),
          ),
        );
      }
    );
  }

  Widget buildWithdrawHistory(BuildContext context, Size size) {
    final theme = Theme.of(context);

    return Obx(
      () {
        if(userController.isLoading.value){
          return SizedBox(
            width: size.width,
            height: size.height / 1.2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/json/loader.json'),
              ],
            ),
          );
        }

        if(userController.historyDepoWd.value?.response.isEmpty == true){
          return SizedBox(
            width: size.width,
            height: size.height / 1.2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/json/cat.json'),
                const SizedBox(height: 16),
                const Text("Tidak ada riwayat Withdrawal"),
              ],
            ),
          );
        }

        final withdrawals = userController.historyDepoWd.value?.response.where((res) => res.type == "Withdrawal").toList() ?? [];

        if (withdrawals.isEmpty) {
          return SizedBox(
            width: size.width,
            height: size.height / 1.2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/json/cat.json'),
                const SizedBox(height: 16),
                const Text("Tidak ada riwayat Withdrawal"),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: CustomColor.secondaryColor,
          onRefresh: () async {
            await userController.historyWithdrawAndDeposit();
          },
          child: ListView(
            children: List.generate(withdrawals.length, (i) {
              final result = withdrawals[i];
          
              Color color = Colors.grey;
              switch (result.status) {
                case "pending":
                  color = Colors.blue.shade400;
                  break;
                case "success":
                  color = Colors.green.shade400;
                  break;
                case "reject":
                  color = Colors.red.shade400;
                  break;
                default:
                  color = Colors.grey.shade400;
              }
          
              return ListTile(
                onTap: () {
                  Get.to(() => TransactionDetailView(id: result.id));
                },
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.orangeAccent,
                  child: const Icon(AntDesign.arrow_up_outline, color: Colors.white),
                ),
                title: Text(
                  "${result.type} - ID ${result.login}",
                  style: GoogleFonts.inter(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  result.amount,
                  style: GoogleFonts.inter(color: theme.textTheme.bodyMedium?.color),
                ),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        result.status != "" ? result.status.capitalize! : "",
                        style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Text(result.datetime, style: TextStyle(fontSize: 9))
                  ],
                ),
              );
            }),
          ),
        );

      }
    );
  }
}