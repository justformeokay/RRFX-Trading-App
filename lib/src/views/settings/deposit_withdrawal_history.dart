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
      userController.historyWithdrawAndDeposit().then((result) async {
        await userController.internalTransferHistory(loginID: allAccountTrading[0].login.toString());
      });
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
                        userController.internalTransferHistory(loginID: allAccountTrading[selectedIndex.value].login.toString());
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
    return Obx((){
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

      if(userController.internalTransfer.value?.response.isEmpty == true){
        return SizedBox(
          width: size.width,
          height: size.height / 1.2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/json/cat.json'),
              const SizedBox(height: 16),
              const Text("Tidak ada riwayat Internal Transfer"),
              CustomButtons.buildOutlinedButton(text: "Refresh", onPressed: () async {
                await userController.internalTransferHistory(loginID: allAccountTrading[selectedIndex.value].login.toString());
              })
            ],
          ),
        );
      }

      final result = userController.internalTransfer.value?.response;
      Color color = Colors.grey;
      return RefreshIndicator(
        color: CustomColor.secondaryColor,
        onRefresh: () async {
          userController.internalTransferHistory(loginID: allAccountTrading[selectedIndex.value].login.toString());
        },
        child: ListView.builder(
          itemCount: result?.length ?? 0,
          itemBuilder: (context, index) {
            switch (result?[index].status) {
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
                
              },
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.lightBlue,
                child: const Icon(BoxIcons.bx_transfer, color: Colors.white),
              ),
              title: Row(
                children: [
                  Text(
                    "${result?[index].login}",
                    style: GoogleFonts.inter(
                      color: theme.textTheme.bodyLarge?.color,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Amount: ${result?[index].amount}",
                    style: GoogleFonts.inter(color: theme.textTheme.bodyMedium?.color, fontSize: 10),
                  ),
                  Text(
                    "Received: ${result?[index].amountReceived}",
                    style: GoogleFonts.inter(color: theme.textTheme.bodyMedium?.color, fontSize: 10),
                  ),
                ],
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
                      result?[index].status != null ? result![index].status!.capitalize! : "",
                      style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(result?[index].datetime ?? '', style: TextStyle(fontSize: 9))
                ],
              ),
            );
          },
        ), 
      );
    });
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