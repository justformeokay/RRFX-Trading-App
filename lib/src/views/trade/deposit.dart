import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/alerts/default.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
import 'package:rrfx/src/components/buttons/outlined_button.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/containers/utilities.dart';
import 'package:rrfx/src/components/loaders/animated_field_loader.dart';
import 'package:rrfx/src/components/textfields/name_textfield.dart';
import 'package:rrfx/src/components/textfields/number_textfield_new.dart';
import 'package:rrfx/src/components/textfields/void_textfield.dart';
import 'package:rrfx/src/controllers/setting.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:rrfx/src/helpers/formatters/deposit_withdraw_prefix.dart';
import 'package:rrfx/src/helpers/formatters/number_formatter.dart';
import 'package:rrfx/src/helpers/handlers/image_picker.dart';
import 'package:rrfx/src/views/mainpage.dart';

class Deposit extends StatefulWidget {
  const Deposit({super.key, this.idLogin, this.id});
  final String? idLogin;
  final String? id;

  @override
  State<Deposit> createState() => _DepositState();
}

class _DepositState extends State<Deposit> {
  
  SettingController settingController = Get.put(SettingController());
  TradingController tradingController = Get.put(TradingController());
  final accountController = Get.find<AccountController>();
  RxString selectedBankAdminID = "".obs;
  RxString selectedBankUserID = "".obs;
  RxString selectedTradingID = "".obs;
  RxString selectedPhotoPath = "".obs;
  RxString selectedTradingLogin = "".obs;
  RxString finalDepositAmount = "0".obs;
  RxBool isLoading = false.obs;
  RxString currencyCodeSelected = "".obs;
  RxString accountCurrencySelected = "".obs;
  RxString minDepositSelected = "0".obs;
  RxString maxDepositSelected = "0".obs;
  RxList akunTradingList = [].obs;
  final _formKey = GlobalKey<FormState>();
  TextEditingController myBankCabang = TextEditingController();
  TextEditingController myBankName = TextEditingController();
  TextEditingController myBankNumber = TextEditingController();
  TextEditingController myBankType = TextEditingController();
  TextEditingController myAmount = TextEditingController();
  TextEditingController myAccountTrading = TextEditingController();

  TextEditingController bankAdminName = TextEditingController();
  TextEditingController bankAdminHolder = TextEditingController();
  TextEditingController bankAdminNumber = TextEditingController();
  TextEditingController bankAdminCurrency = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if(widget.idLogin != null){
        selectedTradingID(widget.id);
        selectedTradingLogin(widget.idLogin);
        myAccountTrading.text = selectedTradingLogin.value;
      }
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
            myAccountTrading.text = "${acc.login} - ${acc.accountCurrency} ${acc.balance}";
            selectedTradingID(acc.id);
            accountCurrencySelected(acc.currency ?? "");
            minDepositSelected(acc.minDeposit ?? "0");
            maxDepositSelected(acc.maxDeposit ?? "0");
          }
        }
      });
      settingController.getAdminBank().then((resultBank){
        if(!resultBank){
          CustomAlert.alertError(context, message: settingController.responseMessage.value);
          return;
        }
        selectedBankAdminID(settingController.adminBankModel.value?.response?[0].id);
        bankAdminHolder.text = settingController.adminBankModel.value?.response?[0].bankHolder ?? "";
        bankAdminNumber.text = settingController.adminBankModel.value?.response?[0].bankAccount ?? "";
        bankAdminName.text = settingController.adminBankModel.value?.response?[0].bankName ?? "";
        bankAdminCurrency.text = settingController.adminBankModel.value?.response?[0].currency ?? "0";
        currencyCodeSelected(settingController.adminBankModel.value?.response?[0].currency ?? "");
        settingController.getUserBank().then((resultGetMyBank){
          if(!resultGetMyBank){
            CustomAlert.alertError(context, message: settingController.responseMessage.value);
            return;
          }

          if(settingController.userBankModel.value?.response == null){
            CustomAlert.alertError(context, message: "Anda belum menginput bank, silahkan edit terlebih dahulu informasi bank pada menu Settings Edit Profile", onTap: (){Get.off(() => Mainpage());});
            return;
          }
          selectedBankUserID(settingController.userBankModel.value?.response?[0].id);
          myBankName.text = settingController.userBankModel.value?.response?[0].name ?? "";
          myBankNumber.text = settingController.userBankModel.value?.response?[0].account ?? "";
        });
      });
    });
  }

  @override
  void dispose() {
    myBankCabang.dispose();
    myBankName.dispose();
    myBankNumber.dispose();
    myBankType.dispose();
    myAmount.dispose();
    bankAdminName.dispose();
    bankAdminHolder.dispose();
    bankAdminCurrency.dispose();
    bankAdminNumber.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar.defaultAppBar(
          title: "Deposit",
          autoImplyLeading: true,
          actions: [
            SizedBox(
              height: 25,
              child: Obx(
                () => isLoading.value ? SizedBox(
                    width: 25,
                    height: 25,
                    child: CircularProgressIndicator(strokeWidth: 2.0, color: CustomColor.secondaryColor)) : CustomOutlinedButton.defaultOutlinedButton(
                  title: settingController.isLoading.value ? "Processing..." :  "Submit",
                  onPressed: settingController.isLoading.value ? null : () async {
                    if(selectedBankAdminID.value.isEmpty){
                      AppSnackbar.error("Bank admin harus dipilih terlebih dahulu.");
                      return;
                    }
                    if(selectedBankUserID.value.isEmpty){
                      AppSnackbar.error("Rekening Bank harus dipilih terlebih dahulu.");
                      return;
                    }
                    if(selectedTradingID.value.isEmpty){
                      AppSnackbar.error("Akun trading harus dipilih terlebih dahulu.");
                      return;
                    }
                    if(finalDepositAmount.value == "0" || finalDepositAmount.value.isEmpty){
                      AppSnackbar.error("Jumlah deposit tidak boleh kosong atau nol.");
                      return;
                    }
                    
                    // Validasi minimal deposit
                    double minDeposit = double.tryParse(minDepositSelected.value) ?? 0;
                    double depositAmount = double.tryParse(finalDepositAmount.value) ?? 0;
                    if(depositAmount < minDeposit){
                      String minDepositFormatted = accountCurrencySelected.value == "IDR" 
                          ? NumberFormattersService.formatRupiah(minDeposit.toInt())
                          : NumberFormattersService.formatUSD(minDeposit);
                      AppSnackbar.error("Jumlah deposit minimal adalah $minDepositFormatted");
                      return;
                    }
                    
                    // Validasi maksimal deposit
                    double maxDeposit = double.tryParse(maxDepositSelected.value) ?? 0;
                    if(maxDeposit > 0 && depositAmount > maxDeposit){
                      String maxDepositFormatted = accountCurrencySelected.value == "IDR" 
                          ? NumberFormattersService.formatRupiah(maxDeposit.toInt())
                          : NumberFormattersService.formatUSD(maxDeposit);
                      AppSnackbar.error("Jumlah deposit maksimal adalah $maxDepositFormatted");
                      return;
                    }

                    isLoading(true);
                    String keyDeposit = generateFixedId("deposit");

                    if(_formKey.currentState!.validate()){

                      /// ✔ FIX UTAMA ADA DI SINI
                      if (accountCurrencySelected.value == "IDR") {
                        final int amount = NumberFormatter.parseRupiahToInt(myAmount.text);
                        finalDepositAmount.value = amount.toString();
                      } else {
                        String cleanUsd = myAmount.text.replaceAll(RegExp(r'[^0-9.]'), "");
                        finalDepositAmount.value = cleanUsd; 
                      }

                      print("Submit deposit");
                      print("Jumlah deposit: ${finalDepositAmount.value}");

                      settingController.deposit(
                        imageURL: selectedPhotoPath.value,
                        accountID: selectedTradingLogin.value,
                        amount: finalDepositAmount.value,
                        bankAdminID: selectedBankAdminID.value,
                        bankUserID: selectedBankUserID.value,
                        key: keyDeposit
                      ).then((result){
                        if(result){
                          CustomAlert.alertDialogCustomSuccess(
                            context,
                            message: settingController.responseMessage.value,
                            onTap: (){
                              Get.back();
                              Get.back();
                            }
                          );
                          isLoading(false);
                          return;
                        }
                        isLoading(false);
                        AppSnackbar.error(settingController.responseMessage.value);
                      });
                    }
                  }
                ),
              ),
            ),
            const SizedBox(width: 10)
          ]
        ),
        body: RefreshIndicator(
          color: CustomColor.defaultColor,
          onRefresh: () async {
            await settingController.getAdminBank();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  UtilitiesWidget.titleContent(
                    title: "Bank Admin",
                    subtitle: "Pilih bank admin sesuai dengan currency akun yang anda pilih sebelumnya saat pembuatan akun trading",
                    children: [
                      Obx(
                        () => VoidTextField(requiredField: true, controller: bankAdminHolder, readOnly: false, fieldName: "Admin Bank Holder", hintText: "Admin Bank Holder", labelText: "Admin Bank Holder", iconData: Iconsax.user_bold, onPressed: settingController.isLoading.value ? null : () async {
                          CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Pilih bank admin yang sesuai dengan rekening anda", children: List.generate(settingController.adminBankModel.value?.response?.length ?? 0, (i){
                            return ListTile(
                              leading: Icon(Iconsax.user_bold, color: isDark ? Colors.white : Colors.black),
                              onTap: (){
                                Navigator.pop(context);
                                bankAdminHolder.text = settingController.adminBankModel.value?.response?[i].bankHolder ?? "";
                                selectedBankAdminID(settingController.adminBankModel.value?.response?[i].id);
                                bankAdminNumber.text = settingController.adminBankModel.value?.response?[i].bankAccount ?? "";
                                bankAdminName.text = settingController.adminBankModel.value?.response?[i].bankName ?? "";
                                bankAdminCurrency.text = settingController.adminBankModel.value?.response?[i].currency ?? "0";
                                currencyCodeSelected(settingController.adminBankModel.value?.response?[i].currency ?? "");
                                
                                // Reset Akun Trading dan Jumlah Deposit
                                myAccountTrading.text = "";
                                selectedTradingID("");
                                selectedTradingLogin("");
                                accountCurrencySelected("");
                                minDepositSelected("0");
                                maxDepositSelected("0");
                                myAmount.text = "";
                                finalDepositAmount("0");
                              },
                              title: Text("${settingController.adminBankModel.value?.response?[i].bankHolder ?? ""} - ${settingController.adminBankModel.value?.response?[i].currency ?? ""}", style: GoogleFonts.inter()),
                            );
                          }));
                        }),
                      ),
                      NameTextField(requiredField: true, controller: bankAdminCurrency, fieldName: "Kurs Akun Bank", hintText: "Kurs Akun Bank", labelText: "Kurs Akun Bank", readOnly: true, useValidator: false),
                      NameTextField(requiredField: true, controller: bankAdminName, fieldName: "Nama Bank", hintText: "Nama Bank", labelText: "Nama Bank", readOnly: true, useValidator: false),
                      NameTextField(requiredField: true, controller: bankAdminNumber, fieldName: "Nomor Rekening", hintText: "Nomor Rekening", labelText: "Nomor Rekening", readOnly: true, useValidator: false),
                    ]
                  ),

                  UtilitiesWidget.titleContent(
                    title: "Bank Anda",
                    subtitle: "Pilih bank yang anda miliki",
                    children: [
                      Obx(
                        () => VoidTextField(readOnly: false, requiredField: true, controller: myBankName, fieldName: "Nama Bank", hintText: "Nama Bank", labelText: "Nama Bank", iconData: Iconsax.building_bold, onPressed: settingController.isLoading.value ? null : () async {
                          CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Pilih bank yang anda miliki", children: List.generate(settingController.userBankModel.value?.response?.length ?? 0, (i){
                            return ListTile(
                              leading: Icon(Iconsax.building_bold, color: isDark ? Colors.white : Colors.black),
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
                        () {
                          return Stack(
                            children: [
                              VoidTextField(
                                requiredField: true, 
                                readOnly: widget.idLogin == null ? false : true, 
                                controller: myAccountTrading, 
                                fieldName: "Akun Trading", 
                                hintText: "Akun Trading", 
                                labelText: "Akun Trading", 
                                iconData: Iconsax.wallet_2_bold, 
                                onPressed: isLoading.value ? null : () async {
                                  isLoading(true);
                                  accountController.fetchAccountInfo(forceRefresh: true).then((result){
                                    isLoading(false);
                                    if(!accountController.hasAccounts){
                                      AppSnackbar.error("Akun trading tidak ditemukan. Silakan pilih akun yang valid.");
                                      isLoading(false);
                                      return;
                                    }
                                    if(widget.idLogin == null){
                                      CustomMaterialBottomSheets.defaultBottomSheet(context, title: "Pilih Akun Trading ${currencyCodeSelected.value} Anda", size: size, children: List.generate(accountController.realAccounts.length, (i){
                                        final account = accountController.realAccounts[i];
                                        if(account.currency != currencyCodeSelected.value){
                                          return const SizedBox();
                                        }
                                        return ListTile(
                                          subtitle: Text("Kurs ${account.currency} - ${account.login ?? "-"}", style: GoogleFonts.inter(fontWeight: FontWeight.w400)),
                                          title: Text("${account.namaTipeAkun ?? "-"} (${account.accountCurrency} ${account.balance})", style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                                          onTap: (){
                                            myAccountTrading.text = "${account.login} - ${account.accountCurrency} ${account.balance}";
                                            selectedTradingID(account.id);
                                            selectedTradingLogin(account.login);
                                            accountCurrencySelected(account.currency ?? "");
                                            minDepositSelected(account.minDeposit ?? "0");
                                            maxDepositSelected(account.maxDeposit ?? "0");
                                            myAmount.text = "";
                                            finalDepositAmount("0");
                                            Get.back();
                                          },
                                          leading: Icon(Iconsax.wallet_2_bold, color: CustomColor.secondaryColor),
                                        );
                                      }));
                                    }
                                  });
                                }
                              ),
                              if(isLoading.value)
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: AnimatedFieldLoader(
                                    loadingText: 'Mengambil Data Akun...',
                                    isDark: isDark,
                                    spinnerColor: CustomColor.secondaryColor,
                                    textColor: CustomColor.secondaryColor,
                                  ),
                                ),
                            ],
                          );
                        } 
                      ),

                      // TextField untuk jumlah deposit, berdasarkan currency akun trading yang dipilih
                      Obx(() {
                        if(accountCurrencySelected.value.isEmpty){
                          return const SizedBox();
                        }
                        if(accountCurrencySelected.value != "IDR" && accountCurrencySelected.value != "USD"){
                          return const SizedBox();
                        }
                        
                        // Get min and max deposit value for hint
                        double minDeposit = double.tryParse(minDepositSelected.value) ?? 0;
                        double maxDeposit = double.tryParse(maxDepositSelected.value) ?? 0;
                        String minDepositHint = accountCurrencySelected.value == "IDR" 
                            ? "Min. ${NumberFormattersService.formatRupiah(minDeposit.toInt())}" 
                            : "Min. ${NumberFormattersService.formatUSD(minDeposit)}";
                        String maxDepositHint = maxDeposit > 0 
                            ? (accountCurrencySelected.value == "IDR" 
                                ? " - Max. ${NumberFormattersService.formatRupiah(maxDeposit.toInt())}" 
                                : " - Max. ${NumberFormattersService.formatUSD(maxDeposit)}")
                            : "";
                        
                        return NumberTextfieldNew(
                          requiredField: true,
                          controller: myAmount,
                          fieldName: "Jumlah Deposit",
                          hintText: accountCurrencySelected.value == "IDR" ? "Masukkan nominal (Rp) - $minDepositHint$maxDepositHint" : "Masukkan nominal (\$) - $minDepositHint$maxDepositHint",
                          labelText: accountCurrencySelected.value == "IDR" ? "Jumlah Deposit (Rp)" : "Jumlah Deposit (\$)",
                          onChanged: (value) {
                            String clean = value.replaceAll(RegExp(r'[^0-9]'), "");

                            if (clean.isEmpty) {
                              myAmount.text = "";
                              finalDepositAmount.value = "";
                              return;
                            }

                            if (accountCurrencySelected.value == "IDR") {
                              int amount = int.parse(clean);

                              // ---- Format ke tampilan ----
                              myAmount.text = NumberFormattersService.formatRupiah(amount);

                              // ---- Simpan nilai final sebagai string ----
                              finalDepositAmount.value = amount.toString();
                            } 
                            else {
                              // ---- USD: dua desimal ----
                              double val = double.parse(clean) / 100;

                              // ---- Format ke tampilan ----
                              myAmount.text = NumberFormattersService.formatUSD(val);

                              // ---- Simpan nilai final yang BENAR (string) ----
                              finalDepositAmount.value = val.toString(); 
                              // contoh: 0.2, 20.0, 150.55
                            }

                            // menjaga cursor tetap di akhir
                            myAmount.selection = TextSelection.fromPosition(
                              TextPosition(offset: myAmount.text.length),
                            );
                          }
                        );
                      })
                    ]
                  ),
                  UtilitiesWidget.titleContent(
                    title: "Bukti Transfer (Opsional)",
                    subtitle: "Upload foto bukti transfer anda agar proses Deposit dapat kami proses dan dapat dipertanggung jawabkan kebenarannya. Maksimal ukuran file 5 MB dengan format Jpeg, JPG, PNG.",
                    children: [
                      Obx(
                        () => settingController.isLoading.value ? const SizedBox() : UtilitiesWidget.uploadPhoto(isImageOnline: false, title: "Bukti Transfer (Opsional)", onPressed: () async {
                            final imagePath = await CustomImagePicker.pickImageFromCameraAndReturnUrl();
                            // Hanya set jika path valid (tidak kosong dan bukan error message)
                            if(imagePath.isNotEmpty && !imagePath.contains('Exception')) {
                              selectedPhotoPath(imagePath);
                            }
                          },
                          urlPhoto: selectedPhotoPath.value
                        ),
                      ),
                    ]
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
