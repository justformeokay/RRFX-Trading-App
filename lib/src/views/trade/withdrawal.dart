import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/alerts/default.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
import 'package:rrfx/src/components/buttons/custom_buttons.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/containers/utilities.dart';
import 'package:rrfx/src/components/textfields/name_textfield.dart';
import 'package:rrfx/src/components/textfields/number_textfield.dart';
import 'package:rrfx/src/components/textfields/otp_textfield.dart';
import 'package:rrfx/src/components/textfields/void_textfield.dart';
import 'package:rrfx/src/controllers/setting.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:rrfx/src/controllers/utilities.dart';
import 'package:rrfx/src/helpers/formatters/deposit_withdraw_prefix.dart';
import 'package:rrfx/src/helpers/formatters/number_formatter.dart';

class Withdrawal extends StatefulWidget {
  const Withdrawal({super.key, this.idLogin, this.id, this.currencyType});
  final String? idLogin;
  final String? currencyType;
  final String? id;

  @override
  State<Withdrawal> createState() => _WithdrawalState();
}

class _WithdrawalState extends State<Withdrawal> {

  SettingController settingController = Get.put(SettingController());
  UtilitiesController utilitiesController = Get.find();
  TradingController tradingController = Get.put(TradingController());
  final accountController = Get.find<AccountController>();
  RxString selectedBankUserID = "".obs;
  RxString selectedTradingID = "".obs;
  RxString selectedAccountBalance = "".obs;
  RxString selectedAccountCurrency = "".obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingAcc = false.obs;
  final _formKey = GlobalKey<FormState>();
  RxString selectedTradingLogin = "".obs;
  TextEditingController myBankCabang = TextEditingController();
  TextEditingController otpController = TextEditingController();
  TextEditingController myBankName = TextEditingController();
  TextEditingController myBankNumber = TextEditingController();
  TextEditingController myBankType = TextEditingController();
  TextEditingController myAmount = TextEditingController();
  TextEditingController myAccountTrading = TextEditingController();
  final TextEditingController convertedAmount = TextEditingController();
  RxBool showOTPField = false.obs;
  RxBool isAmountExceedBalance = false.obs;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, (){
      if(widget.idLogin != null){
        selectedTradingID(widget.id);
        selectedAccountCurrency(widget.currencyType ?? "ID");
        selectedTradingLogin(widget.idLogin);
        myAccountTrading.text = selectedTradingLogin.value;
      }
      selectedAccountCurrency(widget.currencyType ?? "ID");
      isLoading.value = true;
      accountController.fetchAccountInfo().then((accounts){
        isLoading.value = false;
        if(!accountController.hasAccounts){
          return;
        }
        if(accountController.realAccounts.isEmpty){
          return;
        }
        for(int i = 0; i < accountController.realAccounts.length; i++){
          final acc = accountController.realAccounts[i];
          if(acc.login == widget.idLogin){
            selectedTradingLogin(acc.login);
            myAccountTrading.text = "${acc.login} - USD ${acc.balance}";
            selectedTradingID(acc.id);
            selectedAccountCurrency(acc.currency);
            selectedAccountBalance(acc.balance);
          }
        }
      });
      settingController.getUserBank().then((resultGetMyBank){
        if(!resultGetMyBank){
          CustomAlert.alertError(context, message: settingController.responseMessage.value);
          return;
        }
        selectedBankUserID(settingController.userBankModel.value?.response?[0].id);
        myBankName.text = settingController.userBankModel.value?.response?[0].name ?? "";
        myBankNumber.text = settingController.userBankModel.value?.response?[0].account ?? "";
      });
    });
    // Listener AUTO FETCH
    myAmount.addListener(() {
      if (selectedAccountBalance.value.isEmpty) return;
      if (myAmount.text.trim().isEmpty) {
        isAmountExceedBalance(false);
        return;
      }

      // Clean currency
      final amount = double.tryParse(cleanCurrency(myAmount.text)) ?? 0.0;
      final balance = double.tryParse(selectedAccountBalance.value) ?? 0.0;

      // apakah input lebih besar dari saldo?
      isAmountExceedBalance(amount > balance);

      // lanjutkan fetch conversion
      fetchConvertedAmount();
    });
  }

  String cleanCurrency(String text) {
    String cleaned = text.replaceAll("\$", "").trim();
    cleaned = cleaned.replaceAll(",", "");
    return cleaned;
  }

  @override
  void dispose() {
    myBankCabang.dispose();
    myBankName.dispose();
    myBankNumber.dispose();
    myBankType.dispose();
    otpController.dispose();
    myAmount.dispose();
    convertedAmount.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar.defaultAppBar(
          title: "Withdrawal",
          autoImplyLeading: true,
        ),
        body: RefreshIndicator(
          color: CustomColor.defaultColor,
          onRefresh: () async {},
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  UtilitiesWidget.titleContent(
                    title: "Withdrawal",
                    subtitle: "Pastikan jumlah balance anda mencukupi untuk proses withdrawal",
                    children: [
                      Obx(
                        () => VoidTextField(requiredField: true, controller: myBankName, readOnly: false, fieldName: "Nama Bank", hintText: "Nama Bank", labelText: "Nama Bank", onPressed: settingController.isLoading.value ? null : () async {
                          CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Pilih bank yang anda miliki", children: List.generate(settingController.userBankModel.value?.response?.length ?? 0, (i){
                            return ListTile(
                              leading: Icon(Icons.account_balance, color: CustomColor.defaultColor),
                              onTap: (){
                                Navigator.pop(context);
                                selectedBankUserID(settingController.userBankModel.value?.response?[i].id);
                                myBankName.text = settingController.userBankModel.value?.response?[i].name ?? "";
                                myBankNumber.text = settingController.userBankModel.value?.response?[i].account ?? "";
                              },
                              title: Text(settingController.userBankModel.value?.response?[i].name ?? "", style: GoogleFonts.inter()),
                            );
                          }));
                        }),
                      ),
                      NameTextField(requiredField: true, controller: myBankNumber, fieldName: "Nomor Rekening", hintText: "Nomor Rekening", labelText: "Nomor Rekening", readOnly: true, useValidator: false),
                      Obx(
                        () => VoidTextField(requiredField: true, readOnly: isLoadingAcc.value || isLoading.value ? true : false, controller: myAccountTrading, fieldName: "Akun Trading", hintText: isLoadingAcc.value ? "Getting Akun Trading" : "Akun Trading", labelText: isLoadingAcc.value ? "Getting Akun Trading" : "Akun Trading", onPressed: isLoadingAcc.value ? null : () async {
                          isLoadingAcc.value = true;
                          await accountController.fetchAccountInfo();
                          isLoadingAcc.value = false;
                          if(widget.idLogin == null){
                            CustomMaterialBottomSheets.defaultBottomSheet(context, title: "Pilih Akun Trading", size: size, children: List.generate(accountController.realAccounts.length, (i){
                            final account = accountController.realAccounts[i];
                              return ListTile(
                                subtitle: Text(account.login ?? "-", style: GoogleFonts.inter(fontWeight: FontWeight.w400)),
                                title: Text("${account.namaTipeAkun ?? "-"} (USD ${account.balance})", style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                                onTap: (){
                                  Navigator.pop(context);
                                  selectedAccountCurrency(account.currency);
                                  myAccountTrading.text = "${account.login} - USD ${account.balance}";
                                  selectedAccountBalance(account.balance);
                                  final amount = double.tryParse(cleanCurrency(myAmount.text)) ?? 0.0;
                                  final balance = double.tryParse(account.balance ?? "0") ?? 0.0;
                                  isAmountExceedBalance(amount > balance);
                                  selectedTradingID(account.id);
                                  selectedTradingLogin(account.login);
                                },
                                leading: Icon(Icons.group),
                                trailing: Icon(AntDesign.arrow_right_outline, color: CustomColor.defaultColor),
                              );
                            }));
                          }
                        }),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Obx(
                              () => selectedTradingID.value == "" ? const SizedBox() : NumberTextField(requiredField: true, controller: myAmount, fieldName: "Jumlah Deposit", hintText: "Jumlah Withdrawal", labelText: "Jumlah Withdrawal", maxLength: 20, currencyType: "US", useValidator: false, withCurrencyFormatter: true, 
                                onTapOutside: (p0) {
                                  utilitiesController.convertingMoney(amount: myAmount.text, accountID: selectedTradingID.value).then((result){
                                    if(result == false){
                                      CustomScaffoldMessanger.showAppSnackBar(context, message: utilitiesController.responseMessage.value, type: SnackBarType.error);
                                    }else{
                                      convertedAmount.text = result['response']['amount_received'].toString();
                                      convertedAmount.text = NumberFormatter.formatCurrency(convertedAmount.text);
                                    }
                                  });
                                  },
                                  onEditingComplete: (){
                                  utilitiesController.convertingMoney(amount: myAmount.text, accountID: selectedTradingID.value).then((result){
                                    if(result == false){
                                      CustomScaffoldMessanger.showAppSnackBar(context, message: utilitiesController.responseMessage.value, type: SnackBarType.error);
                                    }else{
                                      convertedAmount.text = result['response']['amount_received'].toString();
                                      convertedAmount.text = NumberFormatter.formatCurrency(convertedAmount.text);
                                    }
                                  });
                                  },
                                  onSubmitted: (p0) {
                                  utilitiesController.convertingMoney(amount: myAmount.text, accountID: selectedTradingID.value).then((result){
                                    if(result == false){
                                      CustomScaffoldMessanger.showAppSnackBar(context, message: utilitiesController.responseMessage.value, type: SnackBarType.error);
                                    }else{
                                      convertedAmount.text = result['response']['amount_received'].toString();
                                      convertedAmount.text = NumberFormatter.formatCurrency(convertedAmount.text);
                                    }
                                  });
                              },),
                            ),
                          ),
                          const SizedBox(width: 5.0),
                          Obx(
                            () => SizedBox(
                              height: selectedTradingID.value == "" ? 0 :  51,
                              child: Obx(
                                () => selectedTradingID.value == "" ? const SizedBox() : CustomButtons.buildFilledButton(
                                  enabled: !settingController.isLoadingOTP.value &&
                                    selectedAccountBalance.value != "0.00" &&
                                    selectedTradingLogin.value.isNotEmpty &&
                                    !isAmountExceedBalance.value,
                                  text: settingController.isLoadingOTP.value ? "Sending..." : "Send OTP", onPressed: !isAmountExceedBalance.value && !settingController.isLoadingOTP.value ? () async {
                                    if(selectedTradingLogin.value == ""){
                                      AppSnackbar.error("Pilih akun trading terlebih dahulu.");
                                      return;
                                    }
                                    if(selectedAccountBalance.value == "0.00") {
                                      AppSnackbar.error("Akun anda belum memiliki saldo. mohon lakukan deposit terlebih dahulu.");
                                      return;
                                    }
                                    await settingController.kirimOTPWithdraw().then((result){
                                      if(!result){
                                        showOTPField(false);
                                        AppSnackbar.error(settingController.responseMessage.value);
                                        return;
                                      }
                                      showOTPField(true);
                                      AppSnackbar.success("Kode OTP telah dikirim ke email terdaftar anda.");
                                    });
                                  } : null
                                ),
                              )
                            ),
                          )
                        ],
                      ),
                      OTPTextField(
                        labelText: "Kode OTP",
                        requiredField: true,
                        controller: otpController,
                        fieldName: "Masukkan kode OTP",
                        hintText: "Kode OTP",
                      ),
                      Obx(() => selectedTradingLogin.value == "" ? const SizedBox() : selectedAccountCurrency.value == "USD" ? const SizedBox() : NumberTextField(controller: convertedAmount, fieldName: "Hasil Konversi", hintText: "Hasil Konversi", labelText: "Hasil Konversi", maxLength: 20, currencyType: selectedAccountCurrency.value == "IDR" ? "ID" : "US", withCurrencyFormatter: true, useValidator: false, readOnly: true)),
                    ]
                  ),
                  Obx(() => isAmountExceedBalance.value
                    ? Text(
                        "Jumlah withdrawal melebihi balance akun.",
                        style: TextStyle(color: Colors.red, fontSize: 13),
                      )
                    : SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Obx(
          () {
            final isDisabled = isLoading.value ||
              otpController.text.isEmpty ||
              myAmount.text.isEmpty ||
              selectedAccountBalance.value == "0.00" ||
              selectedTradingLogin.value.isEmpty ||
              settingController.isLoadingOTP.value ||
              isAmountExceedBalance.value;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isDisabled
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) {
                          AppSnackbar.error("Form tidak valid. Mohon periksa kembali input anda.");
                          return;
                        }

                        if(myBankName.text.isEmpty || myBankNumber.text.isEmpty){
                          AppSnackbar.error("Data bank tidak valid. Mohon periksa kembali data bank anda.");
                          return;
                        }

                        if(otpController.text.isEmpty){
                          AppSnackbar.error("Kode OTP wajib diisi.");
                          return;
                        }

                        if (selectedAccountBalance.value == "0.00") {
                          AppSnackbar.error("Akun anda belum memiliki saldo. Mohon lakukan deposit terlebih dahulu.");
                          return;
                        }

                        isLoading(true);

                        try {
                          accountController.fetchAccountInfo().then((result){
                            if(!accountController.hasAccounts){
                              AppSnackbar.error("Akun trading tidak ditemukan. Silakan pilih akun yang valid.");
                              isLoading(false);
                              return;
                            }
                            for(int i = 0; i < accountController.realAccounts.length; i++){
                              final acc = accountController.realAccounts[i];
                              if(acc.login == selectedTradingLogin.value){
                                final balance = double.tryParse(acc.balance ?? "0") ?? 0.0;
                                final amount = double.tryParse(cleanCurrency(myAmount.text)) ?? 0.0;
                                if(amount > balance){
                                  AppSnackbar.error("Jumlah withdrawal melebihi balance akun.");
                                  isLoading(false);
                                  return;
                                }
                              }
                            }
                          });
                          final randomKey = generateFixedId("withdrawal");
                          final result = await settingController.withdrawal(
                            otp: otpController.text,
                            bankUserID: selectedBankUserID.value,
                            amount: cleanCurrency(myAmount.text),
                            tradingID: selectedTradingLogin.value,
                            key: randomKey,
                          );

                          if (result) {
                            CustomAlert.alertDialogCustomSuccess(
                              context,
                              message: settingController.responseMessage.value,
                              onTap: () {
                                Get.back();
                                Get.back();
                              },
                            );
                          } else {
                            CustomAlert.alertError(
                              context,
                              message: settingController.responseMessage.value,
                            );
                          }
                        } catch (e) {
                          AppSnackbar.error("Terjadi kesalahan: ${e.toString()}");
                        } finally {
                          isLoading(false);
                        }
                      },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: isDisabled ? Colors.grey.shade400 : CustomColor.secondaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading.value
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          "Submit",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> fetchConvertedAmount() async {
    final amount = myAmount.text;
    try {
      final result = await utilitiesController.convertingMoney(
        amount: amount,
        accountID: selectedTradingID.value,
      );
      if (result == false) {
        CustomScaffoldMessanger.showAppSnackBar(
          context,
          message: utilitiesController.responseMessage.value,
          type: SnackBarType.error,
        );
        return;
      }
      final received = result['response']["amount_received"].toString();
      convertedAmount.text = NumberFormatter.formatCurrency(received);
    } catch (e) {
      AppSnackbar.error("Gagal mengambil nilai konversi. Silakan coba lagi.");
    }
  }

}