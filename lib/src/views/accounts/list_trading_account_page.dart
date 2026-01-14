import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/alerts/default.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:rrfx/src/views/trade/index.dart';

class ListTradingAccountPage extends StatefulWidget {
  const ListTradingAccountPage({super.key});

  @override
  State<ListTradingAccountPage> createState() => _ListTradingAccountPageState();
}

class _ListTradingAccountPageState extends State<ListTradingAccountPage> {
  TradingController tradingController = Get.find();
  RxList<Map<String, dynamic>> accountTrading = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> unAddedAccountTrading = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;

  Future<void> loadTradingAccount() async {
    isLoading(true);
    accountTrading.value = await tradingController.getTradingAccountV2().then((result) => result);
    isLoading(false);
  }

  @override
  void initState() {
    super.initState();
    loadTradingAccount();
    Future.delayed(Duration(seconds: 1), (){
      tradingController.tradingAccountModels.value?.response.real?.forEach((element) {
        if(accountTrading.where((e) => e['login'].toString() == element.login.toString()).isEmpty) {
          unAddedAccountTrading.add({
            'id': element.id,
            'login': element.login,
            'balance': element.balance,
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => isLoading.value ? const Text("Getting...") : ListView.builder(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: accountTrading.length,
          itemBuilder: (context, index) => GestureDetector(
            onLongPress: () {
              CustomAlert.alertDialogCustomInfo(title: "Hapus Akun Trading", message: "Apakah anda yakin ingin menghapus akun trading ini?", textButton: "Ya", moreThanOneButton: true, onTap: () {
                Get.back();
                tradingController.deleteTradingAccount(accountId: accountTrading[index]['id']).then((result) {
                  if(result['status'] != true) {
                    CustomAlert.alertError(context, message: result['message']);
                    return false;
                  }

                  accountTrading.removeAt(index);
                  CustomAlert.alertDialogCustomSuccess(context, message: "Akun trading berhasil dihapus", onTap: (() { Get.back(); }));
                  loadTradingAccount();
                });
              });
            },
            onTap: (){
              CustomAlert.alertDialogCustomInfoButton(
                title: "Pilih Chart View",
                message: "Terdapat 2 pilhan View untuk chart",
                widgets: [
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        elevation: 5,
                        backgroundColor: CustomColor.defaultColor
                      ),
                      onPressed: (){
                        Get.back();
                        // Get.to(() => DerivChartPage(login: accountTrading[index]['login']));
                      },
                      child: Text("Deriv Chart", style: GoogleFonts.inter(color: Colors.white), textAlign: TextAlign.center)),
                  ),

                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        elevation: 5,
                        backgroundColor: CustomColor.defaultColor
                      ),
                      onPressed: (){
                        Get.back();
                        // Get.to(() => MarketDetail(login: accountTrading[index]['login']));
                      },
                      child: Text("Synfusion Chart", style: GoogleFonts.inter(color: Colors.white), textAlign: TextAlign.center)),
                  ),
                ]
              );
            },
            child: StockTile(
              login: accountTrading[index]['login'].toString(),
              balance: double.parse(accountTrading[index]['balance'].toString()),
            ),
          )
        ),
      )
    );
  }
}
