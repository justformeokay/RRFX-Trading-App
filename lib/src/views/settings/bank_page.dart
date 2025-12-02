import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/controllers/utilities.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/containers/utilities.dart';
import 'package:rrfx/src/components/textfields/name_textfield.dart';
import 'package:rrfx/src/components/textfields/number_textfield.dart';
import 'package:rrfx/src/components/textfields/phone_textfield.dart';
import 'package:rrfx/src/components/textfields/void_textfield.dart';
import 'package:rrfx/src/controllers/setting.dart';
import 'package:rrfx/src/helpers/variables/countrycurrency.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';

class MyBankPage extends StatefulWidget {
  const MyBankPage({super.key});

  @override
  State<MyBankPage> createState() => _MyBankPage();
}

class _MyBankPage extends State<MyBankPage> {

  final _formKey = GlobalKey<FormState>();
  UtilitiesController utilitiesController = Get.put(UtilitiesController());
  TextEditingController currencyController = TextEditingController();
  TextEditingController bankNameController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController ownerController = TextEditingController();
  TextEditingController rootController = TextEditingController();
  TextEditingController jenisRekening = TextEditingController();
  TextEditingController nomorRekening = TextEditingController();

  TextEditingController currencyController2 = TextEditingController();
  TextEditingController bankNameController2 = TextEditingController();
  TextEditingController cityController2 = TextEditingController();
  TextEditingController rootController2 = TextEditingController();
  TextEditingController jenisRekening2 = TextEditingController();
  TextEditingController nomorRekening2 = TextEditingController();
  SettingController settingController = Get.put(SettingController());
  RxBool addedBank = false.obs;

  List<Map<dynamic, dynamic>> resultBank = [];
  RxList<dynamic> daftarBank = <String>[].obs;

  @override
  void initState() {
  super.initState();
    Future.delayed(Duration.zero, (){
      settingController.getUserBank().then((responseGetBankUser){
        if(!responseGetBankUser){
          CustomScaffoldMessanger.showAppSnackBar(context, message: utilitiesController.responseMessage.value, type: SnackBarType.error);
          return;
        }
        if(settingController.userBankModel.value?.response != null){
          bankNameController.text = settingController.userBankModel.value?.response?[0].name ?? "";
          nomorRekening.text = settingController.userBankModel.value?.response?[0].account ?? "";
          if(settingController.userBankModel.value!.response!.length > 1){
            bankNameController2.text = settingController.userBankModel.value?.response?[1].name ?? "";
            nomorRekening2.text = settingController.userBankModel.value?.response?[1].account ?? "";
          }
        }
      });
      utilitiesController.getBankList().then((resultGetBankList){
        for(int i = 0; i < resultGetBankList.length; i++){
          daftarBank.add(resultGetBankList[i]);
        }
      });
    });
  }

  @override
  void dispose() {
    currencyController.dispose();
    bankNameController.dispose();
    cityController.dispose();
    rootController.dispose();
    jenisRekening.dispose();
    nomorRekening.dispose();

    currencyController2.dispose();
    bankNameController2.dispose();
    cityController2.dispose();
    rootController2.dispose();
    jenisRekening2.dispose();
    nomorRekening2.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBar.defaultAppBar(
            autoImplyLeading: true,
            title: "Bank Information",
            actions: [
              CupertinoButton(
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.getString('accessToken');
                  if(_formKey.currentState!.validate()){
                    settingController.editBank(
                      type: jenisRekening.text,
                      bankName: bankNameController.text,
                      branch: rootController.text,
                      number: nomorRekening.text,
                      currencyType: currencyController.text,
                      owner: ownerController.text,
                      bankID: ''
                    ).then((result){});
                  }
                },
                child: Text("Simpan", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: CustomColor.defaultColor)),
              )
            ]
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    UtilitiesWidget.titleContent(
                        title: "Bank Information",
                        subtitle: "Please give the bank account details on your name that will be used with withdrawal of funds",
                        children: [
                          VoidTextField(controller: currencyController, fieldName: "Currency Type", hintText: "Currency Type", labelText: "Currency Type", onPressed: () async {
                            CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Choose your bank currency type", children: List.generate(currencyCodes.length, (i){
                              return ListTile(
                                onTap: (){
                                  Navigator.pop(context);
                                  currencyController.text = currencyCodes[i].code;
                                },
                                title: Text("${currencyCodes[i].code} - ${currencyCodes[i].name}", style: GoogleFonts.inter()),
                              );
                            }));
                          }),
                          VoidTextField(controller: bankNameController, fieldName: "Bank Name", hintText: "Bank Name", labelText: "Bank Name", onPressed: () async {
                            CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Choose your bank currency type", children: List.generate(daftarBank.length, (i){
                              return ListTile(
                                onTap: (){
                                  Navigator.pop(context);
                                  bankNameController.text = daftarBank[i];
                                },
                                title: Text("${daftarBank[i]}", style: GoogleFonts.inter()),
                              );
                            }));
                          }),
                          NameTextField(controller: ownerController, fieldName: "Nama Pemilik Rekening", hintText: "Nama Pemilik Rekening", labelText: "Nama Pemilik Rekening"),
                          NameTextField(controller: cityController, fieldName: "City", hintText: "City", labelText: "City"),
                          NameTextField(controller: rootController, fieldName: "Cabang", hintText: "Cabang", labelText: "Cabang", useValidator: false),
                          VoidTextField(controller: jenisRekening, fieldName: "Jenis Rekening", hintText: "Jenis Rekening", labelText: "Jenis Rekening", onPressed: () async {
                            CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Choose your saving bank type", children: List.generate(GlobalVariable.jenisTabungan.length, (i){
                              return ListTile(
                                onTap: (){
                                  Navigator.pop(context);
                                  jenisRekening.text = GlobalVariable.jenisTabungan[i];
                                },
                                title: Text(GlobalVariable.jenisTabungan[i], style: GoogleFonts.inter()),
                              );
                            }));
                          }),
                          NumberTextField(controller: nomorRekening, fieldName: "Nomor Rekening", hintText: "Nomor Rekening", labelText: "Nomor Rekening", useValidator: false, maxLength: 20),
                          // SizedBox(
                          //   height: 40,
                          //   width: size.width / 1.7,
                          //   child: Obx(
                          //   () => CustomOutlinedButton.defaultOutlinedButton(
                          //     onPressed: (){
                          //       addedBank.value = !addedBank.value;
                          //     },
                          //     title: addedBank.value ? "Hapus Bank" : "Tambah Informasi Bank"
                          //     ),
                          //   ),
                          // ),
                        ]
                    ),
                  ],
                ),
              ),

              Obx(() => addedBank.value ? addBank(size,
                bankNameController2: bankNameController2,
                cityController2: cityController2,
                currencyController2: currencyController2,
                jenisRekening2: jenisRekening2,
                nomorRekening2: nomorRekening2,
                rootController2: rootController2,
              ) : const SizedBox())
            ],
          ),
        ),
      ),
    );
  }

  Widget addBank(Size size, {TextEditingController? currencyController2, TextEditingController? bankNameController2, TextEditingController? cityController2, TextEditingController? rootController2, TextEditingController? jenisRekening2, TextEditingController? nomorRekening2}){
    return UtilitiesWidget.titleContent(
        title: "Bank Information",
        subtitle: "Please give the bank account details on your name that will be used with withdrawal of funds",
        children: [
          VoidTextField(controller: currencyController2, fieldName: "Currency Type", hintText: "Currency Type", labelText: "Currency Type", onPressed: () async {
            CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Choose your bank currency type", children: List.generate(currencyCodes.length, (i){
              return ListTile(
                onTap: (){
                  Navigator.pop(context);
                  currencyController2!.text = currencyCodes[i].code;
                },
                title: Text("${currencyCodes[i].code} - ${currencyCodes[i].name}", style: GoogleFonts.inter()),
              );
            }));
          }),
          VoidTextField(controller: bankNameController2, fieldName: "Bank Name", hintText: "Bank Name", labelText: "Bank Name", onPressed: () async {
            CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Choose your bank currency type", children: List.generate(resultBank.length, (i){
              return ListTile(
                onTap: (){
                  Navigator.pop(context);
                  bankNameController2!.text = resultBank[i]['Name'];
                },
                title: Text("${resultBank[i]['Name']}", style: GoogleFonts.inter()),
              );
            }));
          }),
          NameTextField(controller: cityController2, fieldName: "City", hintText: "City", labelText: "City"),
          NameTextField(controller: rootController2, fieldName: "Cabang", hintText: "Cabang", labelText: "Cabang"),
          VoidTextField(controller: jenisRekening2, fieldName: "Jenis Rekening", hintText: "Jenis Rekening", labelText: "Jenis Rekening", onPressed: () async {
            CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Choose your saving bank type", children: List.generate(GlobalVariable.jenisTabungan.length, (i){
              return ListTile(
                onTap: (){
                  Navigator.pop(context);
                  jenisRekening2!.text = GlobalVariable.jenisTabungan[i];
                },
                title: Text(GlobalVariable.jenisTabungan[i], style: GoogleFonts.inter()),
              );
            }));
          }),
          PhoneTextField(controller: nomorRekening2, fieldName: "Nomor Rekening", hintText: "Nomor Rekening", labelText: "Nomor Rekening"),
        ]
    );
  }
}

