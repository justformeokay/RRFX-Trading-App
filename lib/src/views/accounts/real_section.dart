import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/controllers/home.dart';
import 'package:rrfx/src/controllers/regol.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:rrfx/src/helpers/formatters/number_formatter.dart';
import 'package:rrfx/src/views/accounts/account_information.dart';
import 'package:rrfx/src/views/accounts/components/card_real.dart';
import 'package:rrfx/src/views/accounts/registration_online/views/step_0_password_meta.dart';
import 'package:rrfx/src/views/settings/documents/views/document_list_page.dart';
import 'package:rrfx/src/views/trade/deposit.dart';
import 'package:rrfx/src/views/trade/withdrawal.dart';
import 'components/card_info_account.dart';
import 'package:get/get.dart';


RxList<Map<String, RxBool>> accountActive = <Map<String, RxBool>>[].obs;

class RealSection extends StatefulWidget {
  const RealSection({super.key});

  @override
  State<RealSection> createState() => _RealSectionState();
}

class _RealSectionState extends State<RealSection> {
  TradingController tradingController = Get.put(TradingController());
  RegolController regolController = Get.put(RegolController());
  HomeController homeController = Get.find();

  @override
  void initState() {
    super.initState();
    if(accountActive.isEmpty){
      accountActive.value = [];
      if(tradingController.tradingAccountModels.value?.response.real != null){
        for(int i = 0; i < tradingController.tradingAccountModels.value!.response.real!.length; i++){
          accountActive.add({
            "active": false.obs,
          });
        }
      }
    }
    Future.delayed(Duration.zero, (){
      homeController.getPendingAccount().then((result){
        if(!result){
          CustomScaffoldMessanger.showAppSnackBar(context, message: "Failed to get pending account");
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: CustomColor.secondaryColor,
      onRefresh: () async {},
      child: Obx(
        (){
          if(tradingController.tradingAccountModels.value?.response.demo?.isNotEmpty == true && tradingController.tradingAccountModels.value?.response.real?.isEmpty == true){
            return SizedBox(
              width: double.infinity,
              height: double.maxFinite,
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CardInfoAccount(isDemo: false, onTapCreateReal: () async {
                        if(homeController.pendingModel.value?.response?.isEmpty == true){
                          Get.to(() => CreateMT5PasswordPage());
                        }else if(homeController.pendingModel.value?.response?.isNotEmpty == true){
                          if(homeController.pendingModel.value?.response?[0].status == "Register"){
                            CustomScaffoldMessanger.showAppSnackBar(context, message: "Akun masih dalam proses verifikasi oleh admin, tidak dapat melakukan perubahan data atau membuat akun real baru");
                          }else if(homeController.pendingModel.value?.response?[0].status == "Ditolak"){
                            Get.to(() => CreateMT5PasswordPage());
                          }else if(homeController.pendingModel.value?.response?[0].status == "Good Fund"){
                            CustomScaffoldMessanger.showAppSnackBar(context, message: "Akun masih dalam proses verifikasi oleh admin, tidak dapat melakukan perubahan data atau membuat akun real baru");
                          }else if(homeController.pendingModel.value?.response?[0].status == "Waiting"){
                            CustomScaffoldMessanger.showAppSnackBar(context, message: "Akun masih dalam proses verifikasi oleh admin, tidak dapat melakukan perubahan data atau membuat akun real baru");
                          }else{
                            if(homeController.pendingModel.value?.response?[0].status == "Regol belum selesai"){
                              Get.to(() => CreateMT5PasswordPage());
                            }
                          }
                        }else{
                          CustomScaffoldMessanger.showAppSnackBar(context, message: "Status akun tidak dapat dikenali");
                        }
                      }),
                    ],
                  ),
                ),
              ),
            );
          }
          return ListView(
              children: List.generate((tradingController.tradingAccountModels.value?.response.real?.length ?? 0) + 1, (i){
                final realAccounts = tradingController.tradingAccountModels.value?.response.real ?? [];
                if(i == realAccounts.length){
                  return Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if(homeController.pendingModel.value?.response?.isEmpty == true){
                          await regolController.progressAccount();
                          Get.to(() => CreateMT5PasswordPage());
                        }else if(homeController.pendingModel.value?.response?.isNotEmpty == true){
                          if(homeController.pendingModel.value?.response?[0].status == "Register"){
                            CustomScaffoldMessanger.showAppSnackBar(context, message: "Akun masih dalam proses verifikasi oleh admin, tidak dapat melakukan perubahan data atau membuat akun real baru");
                          }else if(homeController.pendingModel.value?.response?[0].status == "Ditolak"){
                            Get.to(() => CreateMT5PasswordPage());
                          }else if(homeController.pendingModel.value?.response?[0].status == "Good Fund"){
                            CustomScaffoldMessanger.showAppSnackBar(context, message: "Akun masih dalam proses verifikasi oleh admin, tidak dapat melakukan perubahan data atau membuat akun real baru");
                          }else if(homeController.pendingModel.value?.response?[0].status == "Waiting"){
                            CustomScaffoldMessanger.showAppSnackBar(context, message: "Akun masih dalam proses verifikasi oleh admin, tidak dapat melakukan perubahan data atau membuat akun real baru");
                          }else{
                            if(homeController.pendingModel.value?.response?[0].status == "Regol belum selesai"){
                              Get.to(() => CreateMT5PasswordPage());
                            }
                          }
                        }else{
                          CustomScaffoldMessanger.showAppSnackBar(context, message: "Status akun tidak dapat dikenali");
                        }
                      },
                      icon: Icon(Icons.add_circle_outlined, color: Colors.black),
                      label: Text("Buat Akun Real Baru"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColor.secondaryColor,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  );
                }
                return TradingAccountCard(
                  onDeposit: (){
                    Get.to(() => const Deposit());
                  },
                  onWithdraw: (){
                    Get.to(() => const Withdrawal());
                  },
                  onDocuments: (){
                    Get.to(() => DocumentListPage(loginID: tradingController.tradingAccountModels.value?.response.real?[i].login));
                  },
                  onMore: () => Get.to(() => AccountInformation(loginID: tradingController.tradingAccountModels.value?.response.real?[i].login)),
                  balance: tradingController.tradingAccountModels.value?.response.real?[i].balance ?? "-",
                  currency: tradingController.tradingAccountModels.value?.response.real?[i].currency ?? "-",
                  leverage: "1:${tradingController.tradingAccountModels.value?.response.real?[i].leverage ?? "-"}",
                  login: tradingController.tradingAccountModels.value?.response.real?[i].login ?? "-",
                  namaTipeAkun: tradingController.tradingAccountModels.value?.response.real?[i].namaTipeAkun ?? "-",
                  type: tradingController.tradingAccountModels.value?.response.real?[i].type ?? "-",
                  pnl: tradingController.tradingAccountModels.value?.response.real?[i].pnl ?? "-",
                );
              }),
          );
        }
      ),
    );
  }

  CupertinoButton cardAccountReal({
    String? accountNumber,
    String? leverage,
    String? balance,
    String? type,
    String? currencyType,
    bool isConnected = false,
    VoidCallback? onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        Get.to(() => AccountInformation(loginID: accountNumber));
      },
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final secondaryText = theme.textTheme.bodySmall?.color ?? Colors.black54;
          final cardBg = theme.cardColor; // otomatis adaptasi dark/light theme

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: cardBg,
              border: Border.all(color: CustomColor.secondaryBackground.withOpacity(0.7), width: 0.3),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo + Connected status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currencyType != null ? currencyType.toUpperCase() : "-",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: CustomColor.secondaryColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Icon(Icons.candlestick_chart, color: CustomColor.secondaryColor, size: 24),
                const SizedBox(height: 10),

                // Account Number
                Text(
                  accountNumber != null ? NumberFormatter.formatCardNumber(accountNumber) : "0",
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CustomColor.secondaryColor,
                  ),
                  maxLines: 1,
                ),

                const SizedBox(height: 5),
                Text(
                  balance == null ? "\$0" : "\$${balance.split('.').first}",
                  style: GoogleFonts.inter(fontSize: 15, color: CustomColor.secondaryColor),
                ),

                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      type != null ? type.toUpperCase() : "-",
                      style: GoogleFonts.inter(fontSize: 13, color: CustomColor.secondaryColor),
                    ),
                    Text(" / ", style: GoogleFonts.inter(fontSize: 13, color: secondaryText)),
                    Text(
                      leverage != null ? leverage.split('.').first : "1:100",
                      style: GoogleFonts.inter(fontSize: 13, color: CustomColor.secondaryColor),
                    ),
                  ],
                ),

                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _actionButton(
                      icon: CupertinoIcons.arrow_down_circle,
                      label: "Deposit",
                      onTap: () => Get.to(() => const Deposit()),
                    ),
                    const SizedBox(width: 8),
                    _actionButton(
                      icon: CupertinoIcons.arrow_up_circle,
                      label: "Withdrawal",
                      onTap: () => Get.to(() => const Withdrawal()),
                    ),
                    const SizedBox(width: 8),
                    _actionButton(
                      icon: MingCute.pdf_line,
                      label: "Documents",
                      // onTap: () => Get.to(() => Documents(loginID: accountNumber)),
                      onTap: () => Get.to(() => DocumentListPage(loginID: accountNumber)),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _actionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: CustomColor.secondaryColor, size: 16),
          const SizedBox(width: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: CustomColor.secondaryColor,
            ),
          )
        ],
      ),
    );
  }

  void showPasswordDialog(BuildContext context, String accountID){
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Masukkan Password'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColor.secondaryColor
              ),
              onPressed: () async {
                String password = passwordController.text;
                tradingController.inputPassword(accountId: accountID, password: password).then((result){
                  if(result['status']){
                    CustomScaffoldMessanger.showAppSnackBar(context, message: result['message'], type: SnackBarType.success);
                  }
                });
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: Text('Submit', style: GoogleFonts.inter(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
