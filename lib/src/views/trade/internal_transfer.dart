import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/loadings/default.dart';
import 'package:rrfx/src/helpers/formatters/number_formatter.dart';
import 'package:rrfx/src/components/alerts/default.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
import 'package:rrfx/src/components/buttons/outlined_button.dart';
import 'package:rrfx/src/components/containers/utilities.dart';
import 'package:rrfx/src/components/textfields/number_textfield.dart';
import 'package:rrfx/src/components/textfields/void_textfield.dart';
import 'package:rrfx/src/controllers/setting.dart';
import 'package:rrfx/src/controllers/trading.dart';

class InternalTransfer extends StatefulWidget {
  const InternalTransfer({super.key, this.loginID, this.loginNumber});
  final String? loginNumber;
  final String? loginID;

  @override
  State<InternalTransfer> createState() => _InternalTransferState();
}

class _InternalTransferState extends State<InternalTransfer> {

  RxBool isLoading = false.obs;
  final _formKey = GlobalKey<FormState>();
  RxString selectedTradingIDSender = "".obs;
  RxString selectedTradingIDReceiver = "".obs;
  RxString finalTransferAmount = "".obs;
  RxList akunTradingList = [].obs;
  RxInt selectedIndexAccountTradingPengirim = 0.obs;
  RxInt selectedIndexAccountTradingPenerima = 0.obs;
  SettingController settingController = Get.put(SettingController());
  TradingController tradingController = Get.put(TradingController());
  TextEditingController myAccountTradingSender = TextEditingController();
  TextEditingController myAccountTradingReceiver = TextEditingController();
  TextEditingController amount = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLoading(true);
    Future.delayed(Duration.zero, (){
      tradingController.getTradingAccount().then((resultTrading){
        if(widget.loginID != null && widget.loginNumber != null){
          myAccountTradingSender.text = widget.loginNumber!;
          selectedTradingIDSender(widget.loginID!);
        }
        if(tradingController.tradingAccountModels.value!.response.real?.isNotEmpty == true){
          if(tradingController.tradingAccountModels.value!.response.real!.length > 1){
            myAccountTradingSender.text = "${tradingController.tradingAccountModels.value!.response.real![0].login!} - \$${tradingController.tradingAccountModels.value!.response.real![0].balance!}";
            selectedTradingIDSender(tradingController.tradingAccountModels.value?.response.real?[0].login);
            myAccountTradingReceiver.text = "${tradingController.tradingAccountModels.value!.response.real![1].login!} - \$${tradingController.tradingAccountModels.value!.response.real![1].balance!}";
            selectedTradingIDReceiver(tradingController.tradingAccountModels.value?.response.real?[1].login);
          }else{
            myAccountTradingSender.text = tradingController.tradingAccountModels.value!.response.real![0].login!;
            selectedTradingIDSender(tradingController.tradingAccountModels.value?.response.real?[0].login);
            CustomScaffoldMessanger.showAppSnackBar(context, message: "Anda hanya memiliki 1 akun trading. ");
          }
        }
        if(!resultTrading){
          CustomAlert.alertError(context, message: tradingController.responseMessage.value);
        }
      });
      isLoading(false);
    });
  }

  @override
  void dispose() {
    amount.dispose();
    myAccountTradingReceiver.dispose();
    myAccountTradingSender.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isLoading(false);
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar.defaultAppBar(
          title: "Internal Transfer",
          autoImplyLeading: true,
          actions: [
            SizedBox(
              height: 30,
              child: Obx(
                () => CustomOutlinedButton.defaultOutlinedButton(
                  title: "Submit",
                  onPressed: settingController.isLoading.value ? null : () async {
                    if(_formKey.currentState!.validate()){
                      final String amountOutput = NumberFormatter.cleanCurrencyString(amount.text);
                      finalTransferAmount(amountOutput);
                      settingController.internalTransfer(
                        amount: finalTransferAmount.value,
                        tradingIDReceiver: selectedTradingIDReceiver.value,
                        tradingIDSender: selectedTradingIDSender.value
                      ).then((resultWD){
                        if(resultWD){
                          CustomAlert.alertDialogCustomSuccess(context, message: settingController.responseMessage.value, onTap: (){
                            Get.back();
                            Get.back();
                          });
                          return;
                        }
                        CustomAlert.alertError(context, message: settingController.responseMessage.value);
                      });
                    }
                  }
                ),
              ),
            ),
            const SizedBox(width: 10)
          ]
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    UtilitiesWidget.titleContent(
                      title: "Akun Trading Pengirim",
                      subtitle: "Pastikan jumlah balance anda mencukupi untuk proses internal transfer",
                      children: [
                        Obx(
                          () => VoidTextField(controller: myAccountTradingSender, requiredField: true, readOnly: true, fieldName: "Akun Trading Pengirim", hintText: "Akun Trading Pengirim", labelText: "Akun Trading Pengirim", onPressed: settingController.isLoading.value ? null : () async {
                            CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Pilih Akun Trading Pengirim", children: List.generate(tradingController.tradingAccountModels.value?.response.real?.length ?? 0, (i){
                              return ListTile(
                                onTap: (){
                                  selectedIndexAccountTradingPengirim(i);
                                  Navigator.pop(context);
                                  myAccountTradingSender.text = "${tradingController.tradingAccountModels.value?.response.real?[i].login} - \$${tradingController.tradingAccountModels.value?.response.real?[i].balance}";
                                  selectedTradingIDSender(tradingController.tradingAccountModels.value?.response.real?[i].login);
                                },
                                leading: Container(
                                  padding: EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade200
                                  ),
                                  child: Text("${i+1}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18)),
                                ),
                                trailing: selectedIndexAccountTradingPengirim.value == i ? const Icon(Icons.check, color: Colors.green) : null,
                                subtitle: Text("Balance \$${tradingController.tradingAccountModels.value?.response.real?[i].balance}"),
                                title: Text("ID ${tradingController.tradingAccountModels.value?.response.real?[i].login}", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                              );
                            }));
                          }),
                        ),
                      ]
                    ),

                    UtilitiesWidget.titleContent(
                      title: "Akun Trading Penerima",
                      subtitle: "Pastikan jumlah balance anda mencukupi untuk proses internal transfer",
                      children: [
                        Obx(
                          () => VoidTextField(
                            requiredField: true,
                            controller: myAccountTradingReceiver,
                            fieldName: "Akun Trading Penerima",
                            hintText: "Akun Trading Penerima",
                            labelText: "Akun Trading Penerima",
                            onPressed: settingController.isLoading.value ? null : () async {
                              final allAccounts = tradingController.tradingAccountModels.value?.response.real ?? [];

                              // Filter: hanya tampil akun selain pengirim
                              final receiverAccounts = allAccounts.where(
                                (acc) => acc.id != selectedTradingIDSender.value
                              ).toList();

                              CustomMaterialBottomSheets.defaultBottomSheet(
                                context,
                                size: size,
                                title: "Pilih Akun Trading Penerima",
                                children: List.generate(receiverAccounts.length, (i) {
                                  final acc = receiverAccounts[i];
                                  return ListTile(
                                    onTap: () {
                                      selectedIndexAccountTradingPenerima(i);
                                      Navigator.pop(context);
                                      myAccountTradingReceiver.text = "${acc.login} - \$${acc.balance}";
                                      selectedTradingIDReceiver(acc.login);
                                    },
                                    trailing: selectedIndexAccountTradingPenerima.value == i
                                        ? const Icon(Icons.check, color: Colors.green)
                                        : null,
                                    subtitle: Text("Balance \$${acc.balance}"),
                                    title: Text("ID ${acc.login}", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                                  );
                                }),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            
                    UtilitiesWidget.titleContent(
                      title: "Jumlah Transfer",
                      subtitle: "Pastikan jumlah balance anda mencukupi untuk proses internal transfer",
                      children: [
                        NumberTextField(controller: amount, fieldName: "Jumlah Transfer", hintText: "Jumlah Transfer", labelText: "Jumlah Transfer", maxLength: 20, withCurrencyFormatter: true, currencyType: "US", useValidator: false,),
                      ]
                    )
                  ],
                ),
              ),
            ),
            Obx(() => LoadingOverlay(isLoading: settingController.isLoading.value))
          ],
        ),
      ),
    );
  }
}
