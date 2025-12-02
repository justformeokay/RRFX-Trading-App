import 'package:country_flags/country_flags.dart';
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
import 'package:rrfx/src/views/trade/deriv_chart_page.dart';

class Indexv3 extends StatefulWidget {
  const Indexv3({super.key});

  @override
  State<Indexv3> createState() => _Indexv3State();
}

class _Indexv3State extends State<Indexv3> {
  TradingController tradingController = Get.put(TradingController());
  RegolController regolController = Get.put(RegolController());
  HomeController homeController = Get.find();
  RxString selectedLogin = ''.obs;
  RxString selectedLoginBalance = ''.obs;
  RxInt selectedIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final resultTradingAccount = await tradingController.getAllTradingAccount();

      if (!resultTradingAccount) {
        return;
      }

      if (tradingController.allAccounts.isNotEmpty) {
        final firstAcc = tradingController.allAccounts.first;
        selectedLogin.value = firstAcc.login ?? '0';
        selectedLoginBalance.value = firstAcc.balance ?? '0';
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
        title: Container(
          padding: EdgeInsets.symmetric(vertical: 5.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: CustomColor.secondaryColor.withOpacity(0.2)
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Bootstrap.person_fill, color: CustomColor.secondaryColor, size: 18.0),
                  const SizedBox(width: 5.0),
                  Obx(() => Text(selectedLogin.value, style: Get.textTheme.bodyLarge))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Bootstrap.currency_dollar, color: CustomColor.secondaryColor, size: 18.0),
                  const SizedBox(width: 5.0),
                  Obx(() => Text(selectedLoginBalance.value, style: Get.textTheme.bodyLarge))
                ],
              ),
            ],
          ),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CustomColor.secondaryColor.withOpacity(0.2)
            ),
            child: Obx(
              () => CupertinoButton(
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
                child: Icon(Bootstrap.person_fill_gear, color: CustomColor.secondaryColor),
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
        //       padding: const EdgeInsets.symmetric(horizontal: 16.0),
        //       child: Center(
        //         child: Column(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
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

        if(tradingController.symbolModel.value?.response == null){
          return SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Clarity.trash_line, size: 30.0),
                const SizedBox(height: 20.0),
                Text('Tidak ada symbols didapat')
              ],
            ),
          );
        }

        if(tradingController.symbolModel.value?.response?.isEmpty == true){
          return SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Clarity.trash_line, size: 30.0),
                const SizedBox(height: 20.0),
                Text('Tidak ada symbols didapat')
              ],
            ),
          );
        }
        return RefreshIndicator(
          color: CustomColor.secondaryColor,
          onRefresh: () async {
            await tradingController.getSymbols(loginID: selectedLogin.value).then((result){
              if(!result){
                CustomScaffoldMessanger.showAppSnackBar(context, message: tradingController.responseMessage.value);
              }
            });
          },
          child: ListView.builder(
            itemCount: tradingController.symbolModel.value?.response?.length ?? 0,
            itemBuilder: (context, index) {
              final symbol = tradingController.symbolModel.value?.response?[index].symbol ?? "-";

              // Ambil 3 huruf pertama = base, 3 huruf terakhir = quote
              final base = symbol.length >= 3 ? symbol.substring(0, 3) : "";
              final quote = symbol.length >= 6 ? symbol.substring(3, 6) : "";

              return ListTile(
                onTap: (){
                  Get.to(() => DerivChartPage(login: int.parse(selectedLogin.value), balance: selectedLoginBalance.value, marketName: tradingController.symbolModel.value?.response?[index].symbol));
                },
                leading: PairFlag(base: base, quote: quote),
                title: Text(
                  symbol,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
                subtitle: Text(
                  "Spread ${tradingController.symbolModel.value?.response?[index].spread ?? "-"}",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      "Trade",
                      style: TextStyle(color: CustomColor.secondaryColor),
                    ),
                    Icon(Icons.arrow_right, color: CustomColor.secondaryColor),
                  ],
                ),
              );
            },
          )
        );
      }),
    );
  }
}


class PairFlag extends StatelessWidget {
  final String base;
  final String quote;

  const PairFlag({super.key, required this.base, required this.quote});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Lingkaran background
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade900,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
              ],
            ),
          ),
          // Bendera atas (base currency)
          Align(
            alignment: Alignment.topCenter,
            child: _buildFlag(base),
          ),
          // Bendera bawah (quote currency)
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildFlag(quote),
          ),
        ],
      ),
    );
  }

  Widget _buildFlag(String code) {
    if (code.toUpperCase() == "EUR") {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          "assets/images/eur.png", // pastikan kamu punya asset ini
          width: 20,
          height: 15,
          fit: BoxFit.cover,
        ),
      );
    }

    if (code.toUpperCase() == "XAU") {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          "assets/images/xau.png", // pastikan kamu punya asset ini
          width: 20,
          height: 15,
          fit: BoxFit.cover,
        ),
      );
    }

    if (code.toUpperCase() == "USK") {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          "assets/images/usk.png", // pastikan kamu punya asset ini
          width: 20,
          height: 15,
          fit: BoxFit.cover,
        ),
      );
    }

    if (code.toUpperCase() == "XAG") {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          "assets/images/xag.png", // pastikan kamu punya asset ini
          width: 20,
          height: 15,
          fit: BoxFit.cover,
        ),
      );
    }

    if (code.toUpperCase() == "CLSK") {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          "assets/images/clsk.png", // pastikan kamu punya asset ini
          width: 20,
          height: 15,
          fit: BoxFit.cover,
        ),
      );
    }

    return CountryFlag.fromCountryCode(
      _mapCurrencyToCountryCode(code),
      width: 20,
      height: 15,
      shape: const RoundedRectangle(4),
    );
  }

  String _mapCurrencyToCountryCode(String currency) {
    const map = {
      "USD": "us",
      "JPY": "jp",
      "GBP": "gb",
      "AUD": "au",
      "CAD": "ca",
      "CHF": "ch",
      "NZD": "nz",
      "IDR": "id",
      // EUR nanti ditangani via asset
    };
    return map[currency.toUpperCase()] ?? "xx"; // fallback
  }
}
