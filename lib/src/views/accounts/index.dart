import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/alerts/default.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/buttons/custom_buttons.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/controllers/regol.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:rrfx/src/controllers/trading_account_controller.dart';
import 'package:rrfx/src/views/accounts/demo_section.dart';
import 'package:rrfx/src/views/accounts/pending_account.dart';
import 'package:rrfx/src/views/accounts/real_section.dart';

class Accounts extends StatefulWidget {
  const Accounts({super.key});

  @override
  State<Accounts> createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  String selected = "Real";
  RxBool isLoading = false.obs;
  RxBool haveDemoAccount = false.obs;
  RxBool haveRealAccount = false.obs;
  TradingController tradingController = Get.put(TradingController());
  RegolController regolController = Get.put(RegolController());
  TradingAccountController tradingAccountController = Get.find();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, (){
      if(tradingAccountController.demoAccount.isEmpty){
        haveDemoAccount.value = false;
      }else{
        haveDemoAccount.value = true;
      }
      if(tradingAccountController.realAccount.isEmpty){
        haveRealAccount.value = false;
      }else{
        haveRealAccount.value = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Stack(
        children: [
          RefreshIndicator(
            backgroundColor: Colors.transparent,
            color: Colors.transparent,
            elevation: 0,
            onRefresh: () async {
              await tradingController.getTradingAccount().then((result){
                if(!result){
                  CustomAlert.alertError(context, message: tradingController.responseMessage.value);
                }else{
                  if(tradingController.tradingAccountModels.value?.response.real?.isNotEmpty == true){
                    haveDemoAccount(true);
                    haveRealAccount(true);
                  }else{
                    haveRealAccount(false);
                    if(tradingController.tradingAccountModels.value?.response.demo?.isNotEmpty == true){
                      haveDemoAccount(true);
                    }else{
                      haveDemoAccount(false);
                    }
                  }
                }
              });
            },
            child: Scaffold(
              appBar: CustomAppBar.defaultAppBar(
                autoImplyLeading: true,
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(170),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("List Trading", style: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w700, color: CustomColor.secondaryColor, height: 0.5)),
                            Text("account", style: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.titleLarge?.color)),
                            const SizedBox(height: 5.0),
                            Text("Daftar akun trading yang anda miliki. Anda dapat menggunakan untuk trading dengan platform MetaTrader 5 dan RRFX App.", style: TextStyle(color: CustomColor.textThemeLightSoftColor, fontSize: 12)),
                          ],
                        ),
                      ),
                      Obx(() {
                        if (tradingController.tradingAccountModels.value?.response.demo == null) {
                          return const SizedBox();
                        }

                        if (tradingController.tradingAccountModels.value?.response.demo?.isEmpty == true) {
                          return const SizedBox();
                        }

                        return SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SegmentedButton<String>(
                                    style: SegmentedButton.styleFrom(
                                      selectedBackgroundColor: CustomColor.secondaryColor,
                                      side: BorderSide(color: CustomColor.secondaryColor),
                                      backgroundColor: Colors.transparent,
                                      selectedForegroundColor: Colors.black,
                                      textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                    ),
                                    segments: const <ButtonSegment<String>>[
                                      ButtonSegment(value: 'Real', label: Text('Real')),
                                      ButtonSegment(value: 'Demo', label: Text('Demo')),
                                      ButtonSegment(value: 'Pending', label: Text('Pending')),
                                    ],
                                    selected: <String>{selected},
                                    onSelectionChanged: (newSelection) {
                                      setState(() {
                                        selected = newSelection.first;
                                      });
                                    },
                                    multiSelectionEnabled: false,
                                    showSelectedIcon: false,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      })

                    ],
                  )
                )
              ),
              body: Obx(() {
                if(haveDemoAccount.value == false){
                  return noHaveDemo();
                }

                Widget child;
                if (selected == "Demo") {
                  child = DemoSection();
                } else if (selected == "Real") {
                  child = RealSection();
                } else if (selected == "Pending") {
                  child = PendingAccount();
                } else {
                  child = const Text("Tidak dikenali");
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: child,
                );
              }),
              // body: Obx(() => tradingController.isLoading.value ? const SizedBox() : selected == "Demo" ? DemoSection() : RealSection())
            ),
          ),
         // Obx(() => tradingController.isLoading.value ? LoadingWater() : const SizedBox())
        ],
      ),
    );
  }

  Widget noHaveDemo(){
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 80.0),
              Icon(LineAwesome.trash_alt, color: CustomColor.secondaryColor, size: 40,),
              const SizedBox(height: 10.0),
              Text("Tidak ada akun demo"),
              const SizedBox(height: 5.0),
              Text("Anda dapat membuat akun demo dengan cara klik tombol dibawah", textAlign: TextAlign.center),
              const SizedBox(height: 5.0),
              Obx(
                () => CustomButtons.buildOutlinedButton(
                  onPressed: (){
                    regolController.createDemoAccount().then((result) {
                      if(result){
                        CustomScaffoldMessanger.showAppSnackBar(context, message: "Akun demo berhasil dibuat", type: SnackBarType.success);
                        tradingAccountController.getAndSetAccountTradingV2().then((resultGetTrading) {
                          if(tradingAccountController.demoAccount.isEmpty){
                            haveDemoAccount.value = false;
                          }else{
                            haveDemoAccount.value = true;
                          }
                          if(tradingAccountController.realAccount.isEmpty){
                            haveRealAccount.value = false;
                          }else{
                            haveRealAccount.value = true;
                          }
                        });
                      }else{
                        CustomScaffoldMessanger.showAppSnackBar(context, message: regolController.responseMessage.value, type: SnackBarType.error);
                      }
                    }); 
                  },
                  text: regolController.isLoading.value ? "Membuat akun Demo..." : "Buat akun demo"
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}