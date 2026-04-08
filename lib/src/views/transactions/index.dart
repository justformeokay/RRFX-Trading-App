import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
import 'package:rrfx/src/components/buttons/custom_buttons.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/containers/popup.dart';
import 'package:rrfx/src/controllers/home.dart';
import 'package:rrfx/src/controllers/regol.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:rrfx/src/helpers/error_handler.dart';
import 'package:rrfx/src/helpers/handlers/holiday.dart';
import 'package:rrfx/src/models/trades/trading_account_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Transaction extends StatefulWidget {
  const Transaction({super.key});

  @override
  State<Transaction> createState() => _TransactionState();
}

class _TransactionState extends State<Transaction> {
  String selected = "Aktif";
  var selectedIndex = 0.obs;
  DateTime now = DateTime.now();
  Timer? _refreshTimer;
  HomeController homeController = Get.put(HomeController());
  TradingController tradingController = Get.put(TradingController());
  RegolController regolController = Get.put(RegolController());
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playSuccessSound() async {
    await _audioPlayer.play(AssetSource("sounds/applepay.mp3"));
  }

  RxList<dynamic> allAccountTrading = [
    Demo(
      balance: "0",
      currency: "USD",
      id: "4db87140662bd68076ef786f7163cedc",
      leverage: "400.00",
      login: "0",
      marginFree: "0",
      marginFreePercent: "0",
      maxWithdrawal: "0",
      minDeposit: "0",
      minTopup: "0",
      minWithdrawal: "",
      namaTipeAkun: "Demo",
      pnl: "0",
      rate: "Floating",
      totalDeposit: "0",
      totalWithdrawal: "0",
      type: "Demo"
    ),
    Real(
      balance: "0",
      currency: "USD",
      id: "4db87140662bd68076ef786f7163cedc",
      leverage: "400.00",
      login: "0",
      marginFree: "0",
      marginFreePercent: "0",
      maxWithdrawal: "0",
      minDeposit: "0",
      minTopup: "0",
      minWithdrawal: "",
      namaTipeAkun: "Demo",
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
        // CustomScaffoldMessanger.showAppSnackBar(context, message: tradingController.responseMessage.value);
        return;
      }
      if(tradingController.tradingAccountModels.value?.response.real?.isEmpty == true){
        return;
      }
      final demo = tradingController.tradingAccountModels.value?.response.demo ?? [];
      final real = tradingController.tradingAccountModels.value?.response.real ?? [];
      allAccountTrading.clear();
      allAccountTrading..clear()..addAll(demo)..addAll(real);
      // print(allAccountTrading);
    });
  }

  Future<void> getAndSetAccountTradingV2() async {
    await tradingController.getTradingAccount().then((resultTradingAccount) {
      if (!resultTradingAccount) {
        // CustomScaffoldMessanger.showAppSnackBar(context, message: tradingController.responseMessage.value);
        return;
      }
      final demo = tradingController.tradingAccountModels.value?.response.demo ?? [];
      final real = tradingController.tradingAccountModels.value?.response.real ?? [];
      allAccountTrading.clear();
      allAccountTrading..clear()..addAll(demo)..addAll(real);
      loadAccountSelected().then((result){
        selectedIndex(result);
      });
    });
  }

  Future<int> loadAccountSelected() async {
    final prefs = await SharedPreferences.getInstance();
    int index = prefs.getInt('accountAccountIndex') ?? 0;
    return index;
  }


  void fetchOrdersForSelected() {
    if (!mounted) return;
    if(allAccountTrading.isEmpty){
      print("FETCH ORDERS tidak dijalankan karena all akun trading 0");
      return;
    }
    final login = allAccountTrading[selectedIndex.value].login.toString();
    tradingController.openOrder(login: login).then((resultOpenOrder) {
      if (resultOpenOrder.isEmpty == true) {}
    });
    tradingController.closedOrder(login: login).then((resultClosedOrder) {
      if (resultClosedOrder.isEmpty == true) {}
    });
  }

  void _restartRefreshTimer() {
    _refreshTimer?.cancel();
    bool isHoliday = isForexHoliday(now);
    if (isHoliday) return;
    _refreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      fetchOrdersForSelected();
    });
  }

  void onSelectAccount(int index) {
    selectedIndex.value = index;
    _restartRefreshTimer();
    fetchOrdersForSelected();
  }
  

  @override
  void initState() {
    super.initState();
    getAndSetAccountTradingV2().then((result) {
      fetchOrdersForSelected();
      _restartRefreshTimer();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Obx(
      () => Scaffold(
        appBar: allAccountTrading.isEmpty ? null : CustomAppBar.defaultAppBar(
          autoImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(180),
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
                      // Text("Transaksi", style: GoogleFonts.inter(fontSize: 50, fontWeight: FontWeight.w700, color: CustomColor.secondaryColor, height: 0.5)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Transaksi", style: GoogleFonts.inter(fontSize: 50, fontWeight: FontWeight.w700, color: CustomColor.secondaryColor, height: 0.5)),
                          Obx(
                            () => GestureDetector(
                              onTap: tradingController.isLoading.value ? null : (){
                                if(allAccountTrading.isEmpty){
                                  CustomScaffoldMessanger.showAppSnackBar(context, message: "Anda tidak memiliki akun real maupun demo");
                                  return;
                                }
                                CustomMaterialBottomSheets.defaultBottomSheet(context, title: "Pilih Akun Trading", size: size, children: List.generate(allAccountTrading.length, (i){
                                  if(allAccountTrading.isEmpty){
                                    return const SizedBox();
                                  }
                                  return ListTile(
                                    onTap: () async {
                                      final prefs = await SharedPreferences.getInstance();
                                      selectedIndex.value = i;
                                      prefs.setInt('accountAccountIndex', selectedIndex.value);
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
                                    title: Obx(() => Text("${allAccountTrading[i].type != null ? allAccountTrading[i].type.toString().toUpperCase() : ""} : ${allAccountTrading[i].namaTipeAkun}", style: TextStyle(fontWeight: FontWeight.bold))),
                                    subtitle: Obx(() => Text("${allAccountTrading[i].currency} - Akun ID :${allAccountTrading[i].login}", style: TextStyle(color: Theme.of(context).textTheme.titleSmall?.color))),
                                    trailing: selectedIndex.value == i ? const Icon(Icons.check, color: Colors.green) : null,
                                  );
                                }));
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30.0),
                                  color: CustomColor.secondaryColor.withOpacity(0.2),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Bootstrap.person_fill, color: CustomColor.secondaryColor, size: 20.0),
                                    const SizedBox(width: 5.0),
                                    Obx(() => allAccountTrading.isEmpty == true ? const SizedBox() : Text(allAccountTrading[selectedIndex.value].login, style: Get.textTheme.bodyLarge))
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text("Trading", style: GoogleFonts.inter(fontSize: 50, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.titleLarge?.color)),
                      const SizedBox(height: 5.0),
                      Obx(() => allAccountTrading.isEmpty == true ? const SizedBox() : Text("Semua daftar transaksi Aktif, Pending, dan Closed Akun ${allAccountTrading[selectedIndex.value].login}", style: TextStyle(color: CustomColor.textThemeLightSoftColor, fontSize: 15))),
                    ],
                  ),
                ),
                Obx(
                  () => tradingController.tradingAccountModels.value?.response.demo == null ? const SizedBox() : SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Obx(
                              () {
                                if(tradingController.tradingAccountModels.value?.response.demo?.isEmpty == true || allAccountTrading.isEmpty){
                                  return SizedBox(
                                    width: double.infinity,
                                    height: double.infinity,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const SizedBox(height: 80.0),
                                            Lottie.asset('assets/json/cat.json'),
                                            const SizedBox(height: 10.0),
                                            Text("Tidak ada akun demo maupun real"),
                                            const SizedBox(height: 5.0),
                                            Text("Anda dapat membuat akun demo dengan cara klik tombol dibawah", textAlign: TextAlign.center),
                                            const SizedBox(height: 5.0),
                                            Obx(
                                              () => CustomButtons.buildOutlinedButton(
                                                onPressed: (){
                                                  regolController.createDemoAccount().then((result) {
                                                    if(result){
                                                      CustomScaffoldMessanger.showAppSnackBar(context, message: "Akun demo berhasil dibuat", type: SnackBarType.success);
                                                      tradingController.getTradingAccount().then((result) {});
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
                                return SegmentedButton<String>(
                                  style: SegmentedButton.styleFrom(
                                    selectedBackgroundColor: CustomColor.secondaryColor,
                                    side: BorderSide(color: CustomColor.secondaryColor),
                                    backgroundColor: Colors.transparent,
                                    selectedForegroundColor: Colors.black,
                                    textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                  ),
                                  segments: const <ButtonSegment<String>>[
                                    ButtonSegment(
                                      value: 'Aktif',
                                      label: Text('Aktif'),
                                    ),
                                    ButtonSegment(
                                      value: 'Closed',
                                      label: Text('Closed'),
                                    ),
                
                                  ],
                                  selected: <String>{selected},
                                  onSelectionChanged: (newSelection) {
                                    setState(() {
                                      selected = newSelection.first;
                                    });
                                  },
                                  multiSelectionEnabled: false,
                                  showSelectedIcon: false,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          )
        ),
        body: Obx(() {
          if(tradingController.isLoading.value){
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
          if(allAccountTrading.isEmpty == true){
            return SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 80.0),
                      Lottie.asset('assets/json/cat.json'),
                      const SizedBox(height: 10.0),
                      Text("Tidak ada akun demo maupun real"),
                      const SizedBox(height: 5.0),
                      Text("Anda dapat membuat akun demo dengan cara klik tombol dibawah", textAlign: TextAlign.center),
                      const SizedBox(height: 5.0),
                      Obx(
                        () => CustomButtons.buildOutlinedButton(
                          onPressed: (){
                            regolController.createDemoAccount().then((result) {
                              if(result){
                                CustomScaffoldMessanger.showAppSnackBar(context, message: "Akun demo berhasil dibuat", type: SnackBarType.success);
                                tradingController.getTradingAccount().then((result) {});
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
          switch(selected){
            case "Aktif":
              return aktifTransaksiTab();
            case "Pending":
              return SizedBox(
                width: size.width,
                height: size.height / 1.2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset('assets/json/cat.json'),
                    const SizedBox(height: 16),
                    const Text("Fitur masih dalam pengembangan"),
                  ],
                ),
              );
            case "Closed":
              return closedTransaksiTab();
            default:
              return SizedBox(
                width: size.width,
                height: size.height / 1.2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset('assets/json/cat.json'),
                    const SizedBox(height: 16),
                    const Text("Tidak ada informasi"),
                  ],
                ),
              );
          }
        })
      ),
    );
  }

  String formatNumber(dynamic value, {int fractionDigits = 5}) {
    // Batasi jumlah angka di belakang koma
    String formatted = value.toStringAsFixed(fractionDigits);

    // Hilangkan trailing zero yang tidak perlu
    formatted = formatted.replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");

    return formatted;
  }


  Widget aktifTransaksiTab(){
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Obx(
          () {
            if(tradingController.isLoading.value){
              return SizedBox(
                width: size.width,
                height: size.height / 2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset('assets/json/loader.json'),
                      SizedBox(height: 10.0),
                      Text("Getting Market...")
                    ],
                  )
                )
              );
            }
            if(allAccountTrading.isEmpty == true){
              print("Masuk allAccountTrading.isEmpty");
              return SizedBox(
                child: Column(
                  children: [
                    Text("Tidak ada akun demo maupun real", style: TextStyle(color: Colors.white))
                  ],
                ),
              );
            }
            if(tradingController.tradingAccountModels.value?.response.demo?.isEmpty == true){
              return SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 80.0),
                        Lottie.asset('assets/json/cat.json'),
                        const SizedBox(height: 10.0),
                        Text("Tidak ada akun demo maupun real"),
                        const SizedBox(height: 5.0),
                        Text("Anda dapat membuat akun demo dengan cara klik tombol dibawah", textAlign: TextAlign.center),
                        const SizedBox(height: 5.0),
                        Obx(
                          () => CustomButtons.buildOutlinedButton(
                            onPressed: (){
                              regolController.createDemoAccount().then((result) {
                                if(result){
                                  CustomScaffoldMessanger.showAppSnackBar(context, message: "Akun demo berhasil dibuat", type: SnackBarType.success);
                                  tradingController.getTradingAccount().then((result) {});
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
            // if(tradingController.tradingAccountModels.value?.response.real?.isEmpty == true){
            //   return SizedBox(
            //     width: double.infinity,
            //     height: double.infinity,
            //     child: Padding(
            //       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            //       child: Center(
            //         child: Column(
            //           children: [
            //             const SizedBox(height: 80.0),
            //             Lottie.asset('assets/json/cat.json'),
            //             const SizedBox(height: 10.0),
            //             Text("Tidak ada akun Real"),
            //             const SizedBox(height: 5.0),
            //             Text("Anda dapat membuat akun Real dengan cara klik tombol dibawah", textAlign: TextAlign.center),
            //             const SizedBox(height: 5.0),
            //             Obx(
            //               () => CustomButtons.buildOutlinedButton(
            //                 onPressed: () async {
            //                   if(homeController.pendingModel.value?.response?.isEmpty == true){
            //                     await regolController.progressAccount();
            //                     // Get.to(() => const CreateReal());
            //                     Get.to(() => const Step1());
            //                   }else if(homeController.pendingModel.value?.response?.isNotEmpty == true){
            //                     if(homeController.pendingModel.value?.response?[0].status == "Register"){
            //                       CustomScaffoldMessanger.showAppSnackBar(context, message: "Akun masih dalam proses verifikasi oleh admin, tidak dapat melakukan perubahan data atau membuat akun real baru");
            //                     }else if(homeController.pendingModel.value?.response?[0].status == "Ditolak"){
            //                       // Get.to(() => const CreateReal());
            //                       Get.to(() => const Step1());
            //                     }else if(homeController.pendingModel.value?.response?[0].status == "Good Fund"){
            //                       CustomScaffoldMessanger.showAppSnackBar(context, message: "Akun masih dalam proses verifikasi oleh admin, tidak dapat melakukan perubahan data atau membuat akun real baru");
            //                     }else if(homeController.pendingModel.value?.response?[0].status == "Waiting"){
            //                       CustomScaffoldMessanger.showAppSnackBar(context, message: "Akun masih dalam proses verifikasi oleh admin, tidak dapat melakukan perubahan data atau membuat akun real baru");
            //                     }
            //                   }else{
            //                     CustomScaffoldMessanger.showAppSnackBar(context, message: "Status akun tidak dapat dikenali");
            //                   }
            //                 },
            //                 text: tradingController.isLoading.value ? "Membuat akun Real..." : "Buat akun Real"
            //               ),
            //             )
            //           ],
            //         ),
            //       ),
            //     ),
            //   );
            // }
            if(tradingController.openOrderModel.value?.response?.isEmpty == true || tradingController.openOrderModel.value?.response == null){
              return SizedBox(
                width: size.width,
                height: size.height / 1.2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset('assets/json/cat.json'),
                    const SizedBox(height: 16),
                    const Text("Tidak ada transaksi Open"),
                  ],
                ),
              );
            }
            return SizedBox(
              height: size.height / 1.2,
              child: Obx(
                () => ListView.builder(
                  itemCount: tradingController.openOrderModel.value?.response?.length ?? 0,
                  itemBuilder: (context, index) {
                    final profit = tradingController.openOrderModel.value?.response?[index].profit;
                    Color profitColor;
                    if (profit == null) {
                      profitColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;
                    } else if (profit < 0) {
                      profitColor = Colors.red; // rugi
                    } else if (profit > 0) {
                      profitColor = Colors.blue; // untung
                    } else {
                      profitColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey; // netral
                    }
                    IconData iconData = EvaIcons.question_mark;
                    Color color = Colors.indigo;
                    switch(tradingController.openOrderModel.value?.response?[index].orderType){
                      case "sell":
                        iconData = IonIcons.arrow_down_circle;
                        color = Colors.red;
                        break;
                      case "Sell":
                        iconData = IonIcons.arrow_down_circle;
                        color = Colors.red;
                        break;
                      case "buy":
                        iconData = IonIcons.arrow_up_circle;
                        color = Colors.green;
                        break;
                      case "Buy":
                        iconData = IonIcons.arrow_up_circle;
                        color = Colors.green;
                        break;
                    }
                    return ListTile(
                      onTap: (){
                        // Get.to(() => DerivChartPage(login: int.parse(allAccountTrading[selectedIndex.value].login), balance: allAccountTrading[selectedIndex.value].balance, marketName: tradingController.openOrderModel.value?.response?[index].symbol));
                      },
                      onLongPress: () {
                        showClosePositionDialog(
                          biayaInap: tradingController.openOrderModel.value?.response?[index].swap ?? 0.0,
                          context: context,
                          biaya: 0.0,
                          lot: tradingController.openOrderModel.value?.response?[index].lot != null ? tradingController.openOrderModel.value!.response![index].lot! : 0.0,
                          onConfirm: () async {
                            try {
                              await tradingController.closingOrder(
                                loginID: allAccountTrading[selectedIndex.value].login,
                                ticketID: tradingController.openOrderModel.value?.response?[index].ticket.toString(),
                              );
                              
                              tradingController.openOrder(login: allAccountTrading[selectedIndex.value].login.toString());
                              playSuccessSound();
                              
                              tradingController.closedOrder(login: allAccountTrading[selectedIndex.value].login.toString()).then((resultClosed){
                                CustomScaffoldMessanger.showAppSnackBar(
                                  context,
                                  message: "Berhasil menutup posisi ${tradingController.openOrderModel.value?.response?[index].symbol} - ${tradingController.openOrderModel.value?.response?[index].lot}",
                                );
                              });
                            } catch (e) {
                              await ErrorHandler.showErrorDialog(
                                e,
                                title: 'Gagal Menutup Posisi',
                              );
                            }
                          },
                          price: tradingController.openOrderModel.value?.response?[index].currentPrice != null ? tradingController.openOrderModel.value?.response![index].currentPrice! : 0.0,
                          profit: tradingController.openOrderModel.value?.response?[index].profit != null ? tradingController.openOrderModel.value?.response![index].profit! : 0.0,
                          symbol: tradingController.openOrderModel.value?.response?[index].symbol ?? "-",
                        );
                      },
                      contentPadding: EdgeInsets.only(right: 0),
                      leading: Container(
                        width: 43,
                        height: 43,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color
                        ),
                        child: Center(child: Icon(iconData)),
                      ),
                      title: Row(
                        children: [
                          Text(tradingController.openOrderModel.value?.response?[index].symbol != null ? tradingController.openOrderModel.value!.response![index].symbol! : "", style: GoogleFonts.inter(color: Colors.blue, fontWeight: FontWeight.w700)),
                          const Text(", "),
                          Text(tradingController.openOrderModel.value?.response?[index].lot != null ? tradingController.openOrderModel.value!.response![index].lot.toString() : "", style: GoogleFonts.inter(color: color, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            tradingController.openOrderModel.value?.response?[index].openPrice?.toString() ?? "",
                            style: GoogleFonts.inter(
                              color: Theme.of(context).textTheme.bodyMedium?.color, // ikut theme
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Icon(
                            Icons.arrow_right,
                            color: Theme.of(context).iconTheme.color?.withOpacity(0.6), // ikut theme juga
                          ),
                          Text(
                            tradingController.openOrderModel.value?.response?[index].currentPrice?.toString() ?? "",
                            style: GoogleFonts.inter(
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      trailing: Text(profit.toString(), style: GoogleFonts.inter(
                        fontSize: 15,
                        color: profitColor, // ikut theme
                        fontWeight: FontWeight.w800,
                      )),
                    );
                  },
                ),
              ),
            );
          }
        ),
      ),
    );
  }


  Widget closedTransaksiTab(){
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Obx(
          () {
            if(tradingController.isLoading.value){
              return SizedBox(
                width: size.width,
                height: size.height / 2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset('assets/json/loader.json'),
                      SizedBox(height: 10.0),
                      Text("Getting Market...")
                    ],
                  )
                )
              );
            }
            if(tradingController.tradingAccountModels.value?.response.demo?.isEmpty == true){
              return SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 80.0),
                        Lottie.asset('assets/json/cat.json'),
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
                                  tradingController.getTradingAccount().then((result) {
                                    
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
            // if(tradingController.tradingAccountModels.value?.response.real?.isEmpty == true){
            //   return SizedBox(
            //     width: double.infinity,
            //     height: double.infinity,
            //     child: Padding(
            //       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            //       child: Center(
            //         child: Column(
            //           children: [
            //             const SizedBox(height: 80.0),
            //             Lottie.asset('assets/json/cat.json'),
            //             const SizedBox(height: 10.0),
            //             Text("Tidak ada akun Real"),
            //             const SizedBox(height: 5.0),
            //             Text("Anda dapat membuat akun Real dengan cara klik tombol dibawah", textAlign: TextAlign.center),
            //             const SizedBox(height: 5.0),
            //             Obx(
            //               () => CustomButtons.buildOutlinedButton(
            //                 onPressed: () async {
            //                   if(homeController.pendingModel.value?.response?.isEmpty == true){
            //                     await regolController.progressAccount();
            //                     Get.to(() => const CreateReal());
            //                   }else if(homeController.pendingModel.value?.response?.isNotEmpty == true){
            //                     if(homeController.pendingModel.value?.response?[0].status == "Register"){
            //                       CustomScaffoldMessanger.showAppSnackBar(context, message: "Akun masih dalam proses verifikasi oleh admin, tidak dapat melakukan perubahan data atau membuat akun real baru");
            //                     }else if(homeController.pendingModel.value?.response?[0].status == "Ditolak"){
            //                       Get.to(() => const CreateReal());
            //                     }else if(homeController.pendingModel.value?.response?[0].status == "Good Fund"){
            //                       CustomScaffoldMessanger.showAppSnackBar(context, message: "Akun masih dalam proses verifikasi oleh admin, tidak dapat melakukan perubahan data atau membuat akun real baru");
            //                     }else if(homeController.pendingModel.value?.response?[0].status == "Waiting"){
            //                       CustomScaffoldMessanger.showAppSnackBar(context, message: "Akun masih dalam proses verifikasi oleh admin, tidak dapat melakukan perubahan data atau membuat akun real baru");
            //                     }
            //                   }else{
            //                     CustomScaffoldMessanger.showAppSnackBar(context, message: "Status akun tidak dapat dikenali");
            //                   }
            //                 },
            //                 text: tradingController.isLoading.value ? "Membuat akun Real..." : "Buat akun Real"
            //               ),
            //             )
            //           ],
            //         ),
            //       ),
            //     ),
            //   );
            // }
            if(tradingController.tradingHistoryModel.value?.response?.isEmpty == true || tradingController.tradingHistoryModel.value?.response == null){
              return SizedBox(
                width: size.width,
                height: size.height / 1.2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset('assets/json/cat.json'),
                    const SizedBox(height: 16),
                    const Text("Tidak ada riwayat transaksi"),
                  ],
                ),
              );
            }

            return SizedBox(
              height: size.height / 1.2,
              child: Obx(
                () => ListView.builder(
                  itemCount: tradingController.tradingHistoryModel.value?.response?.length,
                  itemBuilder: (context, index) {
                    final profit = tradingController.tradingHistoryModel.value?.response?[index].profit;
                    Color? profitColor;
                    if(profit == null){
                      if (profit == null) {
                        profitColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;
                      } else if (double.parse(profit) < 0) {
                        profitColor = Colors.red; // rugi
                      } else if (double.parse(profit) > 0) {
                        profitColor = Colors.blue; // untung
                      } else {
                        profitColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey; // netral
                      }
                    }
                    
                    IconData iconData = EvaIcons.question_mark;
                    Color color = Colors.indigo;
                    switch(tradingController.tradingHistoryModel.value?.response?[index].orderType){
                      case "sell":
                        iconData = IonIcons.arrow_down_circle;
                        color = Colors.red;
                        break;
                      case "Sell":
                        iconData = IonIcons.arrow_down_circle;
                        color = Colors.red;
                        break;
                      case "buy":
                        iconData = IonIcons.arrow_up_circle;
                        color = Colors.green;
                        break;
                      case "Buy":
                        iconData = IonIcons.arrow_up_circle;
                        color = Colors.green;
                        break;
                    }
                    return ListTile(
                      onTap: (){
                        showClosedOrderDialog(context, {
                          "symbol": tradingController.tradingHistoryModel.value?.response?[index].symbol ?? '',
                          "lot": tradingController.tradingHistoryModel.value?.response?[index].lot ?? '',
                          "orderType": tradingController.tradingHistoryModel.value?.response?[index].orderType ?? '',
                          "profit": tradingController.tradingHistoryModel.value?.response?[index].profit ?? '',
                          "openPrice": tradingController.tradingHistoryModel.value?.response?[index].openPrice ?? '',
                          "closePrice": tradingController.tradingHistoryModel.value?.response?[index].closePrice ?? '',
                          "openTime": tradingController.tradingHistoryModel.value?.response?[index].openTime ?? '',
                          "closeTime": tradingController.tradingHistoryModel.value?.response?[index].closeTime ?? '',
                        });
                      },
                      onLongPress: () {},
                      contentPadding: EdgeInsets.only(right: 0),
                      leading: Container(
                        width: 43,
                        height: 43,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color
                        ),
                        child: Center(child: Icon(iconData)),
                      ),
                      title: Row(
                        children: [
                          Text(tradingController.tradingHistoryModel.value?.response?[index].symbol != null ? tradingController.tradingHistoryModel.value!.response![index].symbol! : "", style: GoogleFonts.inter(color: Colors.blue, fontWeight: FontWeight.w700)),
                          const Text(", "),
                          Text(tradingController.tradingHistoryModel.value?.response?[index].lot != null ? tradingController.tradingHistoryModel.value!.response![index].lot.toString() : "", style: GoogleFonts.inter(color: color, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            tradingController.tradingHistoryModel.value?.response?[index].openPrice ?? '0',
                            style: GoogleFonts.inter(
                              color: Theme.of(context).textTheme.bodyMedium?.color, // ikut theme
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Icon(
                            Icons.arrow_right,
                            color: Theme.of(context).iconTheme.color?.withOpacity(0.6), // ikut theme juga
                          ),
                          Text(
                            tradingController.tradingHistoryModel.value?.response?[index].closePrice != null ? tradingController.tradingHistoryModel.value!.response![index].closePrice : "",
                            style: GoogleFonts.inter(
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      trailing: Text(profit ?? '0', style: GoogleFonts.inter(
                        fontSize: 15,
                        color: profitColor, // ikut theme
                        fontWeight: FontWeight.w800,
                      )),
                    );
                  },
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}