import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
import 'package:rrfx/src/components/buttons/custom_buttons.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/controllers/home.dart';
import 'package:rrfx/src/controllers/regol.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:rrfx/src/helpers/formatters/number_formatter.dart';
import 'package:rrfx/src/views/advance_charts/webview_chart_view_from_tile.dart';

class AllMarketPage extends StatefulWidget {
  const AllMarketPage({super.key});

  @override
  State<AllMarketPage> createState() => _AllMarketPageState();
}

class _AllMarketPageState extends State<AllMarketPage> {
  TradingController tradingController = Get.put(TradingController());
  RegolController regolController = Get.put(RegolController());
  HomeController homeController = Get.find();
  RxString selectedLogin = '-'.obs;
  RxString selectedAccountType = '-'.obs;
  RxString selectedLoginBalance = '-'.obs;
  RxInt selectedIndex = 0.obs;
  RxList allTradingAccounts = [].obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final resultTradingAccount = await tradingController.getAllTradingAccount();

      if (!resultTradingAccount) {
        // CustomScaffoldMessanger.showAppSnackBar(
        //   context,
        //   message: tradingController.responseMessage.value,
        // );
        return;
      }

      if (tradingController.allAccounts.isNotEmpty) {
        final firstAcc = tradingController.allAccounts.first;
        selectedLogin.value = firstAcc.login ?? '0';
        selectedLoginBalance.value = firstAcc.balance ?? '0';
        selectedAccountType.value = firstAcc.type ?? 'Demo';
      }

      final resultSymbols = await tradingController.getSymbols(
        loginID: selectedLogin.value,
      );

      if (!resultSymbols) {
        // CustomScaffoldMessanger.showAppSnackBar(
        //   context,
        //   message: tradingController.responseMessage.value,
        // );
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Container(
          height: 46,
          padding: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: CustomColor.secondaryColor.withOpacity(0.2)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 40.0,
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 3.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  color: CustomColor.secondaryColor.withOpacity(0.8)
                ),
                child: Center(child: Obx(() => Text(selectedAccountType.value.toString().toUpperCase(), style: TextStyle(color: Colors.black, fontSize: 11.0)))),
              ),
              Container(
                height: 40.0,
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  color: CustomColor.secondaryColor.withOpacity(0.8)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Bootstrap.person_fill, size: 12.0, color: Colors.black),
                    const SizedBox(width: 2.0),
                    Obx(() => Text(selectedLogin.value,  style: TextStyle(color: Colors.black, fontSize: 11.0))),
                  ],
                ),
              ),
              Container(
                height: 40.0,
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 3.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  color: CustomColor.secondaryColor.withOpacity(0.8)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Bootstrap.currency_dollar, size: 12.0, color: Colors.black),
                    const SizedBox(width: 2.0),
                    Obx(() => Text(selectedLoginBalance.value,  style: TextStyle(color: Colors.black, fontSize: 11.0))),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CustomColor.secondaryColor.withOpacity(0.2)
            ),
            child: Obx(
              () => CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: tradingController.isLoading.value ? null : (){
                  CustomMaterialBottomSheets.defaultBottomSheet(
                    context,
                    size: size,
                    title: "Daftar Akun Trading",
                    isScrolledController: true,
                    children: List.generate(tradingController.allAccounts.length, (i) {
                      final account = tradingController.allAccounts[i]; // ambil item sekali
                      final isSelected = selectedIndex.value == i;
            
                      return ListTile(
                        onTap: () async {
                          selectedIndex.value = i;
                          selectedLogin.value = account.login ?? '0';
                          selectedLoginBalance.value = account.balance ?? '0';
                          selectedAccountType.value = account.type ?? 'Demo';
                          Get.back();
                        },
                        leading: Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade200,
                          ),
                          child: Text(
                            "${i + 1}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        title: Text(
                          "${account.type?.toUpperCase() ?? ''} - ${account.login ?? '-'}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "${account.currency ?? ''} • Leverage: 1:${NumberFormatter.cleanNumber(account.leverage ?? '0')}",
                          style: TextStyle(
                            color: Theme.of(context).textTheme.titleSmall?.color,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                      );
                    }),
                  );
                },
                child: Icon(Bootstrap.person_fill_gear, color: CustomColor.secondaryColor, size: 20.0),
              ),
            ),
          )
        ]
      ),
      body: Obx((){
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
        if(tradingController.tradingAccountModels.value?.response.demo?.isEmpty == true && tradingController.tradingAccountModels.value?.response.real?.isEmpty == true){
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
                              tradingController.getTradingAccount(forceRefresh: true).then((result) {
                                
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
        if(tradingController.symbolModel.value == null){
          return SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 30.0),
                const SizedBox(height: 5.0),
                Text("Gagal mendaptkan informasi market")
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: tradingController.symbolModel.value?.response?.length ?? 0,
          itemBuilder: (context, index) {
            final item = tradingController.symbolModel.value?.response?[index];
            final theme = Theme.of(context);
            if (item == null) return const SizedBox();

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Get.to(() => WebViewChartViewFromTile(
                        login: int.parse(selectedLogin.value),
                        balance: double.tryParse(selectedLoginBalance.value),
                        marketName: item.symbol ?? '',
                      ));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Icon kiri
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: CustomColor.secondaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.show_chart_rounded,
                          color: Colors.green,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Symbol & spread info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.symbol ?? "-",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Spread ${item.spread ?? "-"}",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Tombol "Trade"
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: CustomColor.secondaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Trade",
                              style: TextStyle(
                                color: CustomColor.secondaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.green,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}