import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/alerts/default.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/containers/utilities.dart';
import 'package:rrfx/src/components/languages/language_variable.dart';
import 'package:rrfx/src/components/textfields/descriptive_textfield.dart';
import 'package:rrfx/src/components/textfields/name_textfield.dart';
import 'package:rrfx/src/components/textfields/phone_textfield.dart';
import 'package:rrfx/src/components/textfields/void_textfield.dart';
import 'package:rrfx/src/controllers/regol.dart';
import 'package:rrfx/src/controllers/setting.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/views/accounts/step_12_bank_information.dart';
import 'package:rrfx/src/views/accounts/step_17_dokumen_pendukung.dart';
import 'package:rrfx/src/views/mainpage.dart';
import 'components/step_position.dart';

class Step11JobHistory extends StatefulWidget {
  const Step11JobHistory({super.key});

  @override
  State<Step11JobHistory> createState() => _Step11JobHistory();
}

class _Step11JobHistory extends State<Step11JobHistory> {

  final _formKey = GlobalKey<FormState>();
  TextEditingController businessNameController = TextEditingController();
  TextEditingController namaPekerjaanController = TextEditingController();
  TextEditingController categoryBusinessNameController = TextEditingController();
  TextEditingController yourJobCategoryController = TextEditingController();
  TextEditingController jobPositionController = TextEditingController();
  TextEditingController durationOfWorkController = TextEditingController();
  TextEditingController durationOfLastWorkController = TextEditingController();
  TextEditingController currentAddressOffice = TextEditingController();
  TextEditingController officePhoneContact = TextEditingController();
  TextEditingController faxController = TextEditingController();
  SettingController settingController = Get.put(SettingController());

  RegolController regolController = Get.find();

  @override
  void initState() {
    super.initState();
    businessNameController.text = regolController.accountModel.value?.response?.kerjaNama ?? "";
    categoryBusinessNameController.text = regolController.accountModel.value?.response?.kerjaBidang ?? "";
    jobPositionController.text = regolController.accountModel.value?.response?.kerjaJabatan ?? "";
    durationOfWorkController.text = regolController.accountModel.value?.response?.kerjaLama ?? "";
    currentAddressOffice.text = regolController.accountModel.value?.response?.kerjaAlamat ?? "";
    officePhoneContact.text = regolController.accountModel.value?.response?.kerjaTelepon ?? "";
    faxController.text = regolController.accountModel.value?.response?.kerjaFax ?? "";
    durationOfLastWorkController.text = regolController.accountModel.value?.response?.kerjaLamaSebelum ?? "";
    if(regolController.accountModel.value?.response?.kerjaTipe != null){
      setState(() {
        yourJobCategoryController.text = regolController.accountModel.value!.response!.kerjaTipe!;
      });
    }
  }

  @override
  void dispose() {
    businessNameController.dispose();
    categoryBusinessNameController.dispose();
    yourJobCategoryController.dispose();
    jobPositionController.dispose();
    durationOfWorkController.dispose();
    durationOfLastWorkController.dispose();
    namaPekerjaanController.dispose();
    officePhoneContact.dispose();
    faxController.dispose();
    currentAddressOffice.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: CustomAppBar.defaultAppBar(
          autoImplyLeading: true,
          title: "Job Information",
          actions: [
            CupertinoButton(
              onPressed: (){
                CustomAlert.alertDialogCustomInfo(
                  title: "Confirmation",
                  message: "Are you sure you want to cancel? All data will be lost.",
                  moreThanOneButton: true,
                  onTap: () {
                    Get.offAll(() => const Mainpage());
                  },
                  textButton: "Yes",
                );
              },
              child: Text(LanguageGlobalVar.CANCEL.tr, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: CustomColor.defaultColor)),
            )
          ]
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                UtilitiesWidget.titleContent(
                  title: "Informasi Pekerjaan Saat Ini",
                  subtitle: "Beri tahu kami tentang pekerjaan anda saat ini.",
                  children: [
                    VoidTextField(controller: yourJobCategoryController, fieldName: "Your Current Job", hintText: "Your Current Job", labelText: "Your Current Job", onPressed: () async {
                      CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Choose your current job", children: List.generate(GlobalVariable.jobListIndo.length, (i){
                        return ListTile(
                          onTap: (){
                            Navigator.pop(context);
                            setState(() {
                              yourJobCategoryController.text = GlobalVariable.jobListIndo[i];
                            });
                          },
                          title: Text(GlobalVariable.jobListIndo[i], style: GoogleFonts.inter()),
                        );
                      }));
                    }),
                    if (yourJobCategoryController.text == "Lainnya" || yourJobCategoryController.text == "lainnya") NameTextField(controller: namaPekerjaanController, fieldName: "Nama Pekerjaan", hintText: "Nama Pekerjaan", labelText: "Nama Pekerjaan"),
                    NameTextField(controller: businessNameController, fieldName: "Nama Perusahaan", hintText: "Nama Perusahaan", labelText: "Nama Perusahaan"),
                    NameTextField(controller: categoryBusinessNameController, fieldName: "Bidang Usaha", hintText: "Input nama bidang usaha", labelText: "Nama Bidang Usaha"),
                    NameTextField(controller: jobPositionController, fieldName: "Job Position", hintText: "Job Position", labelText: "Job Position"),
                    NameTextField(controller: durationOfWorkController, fieldName: "Lama Bekerja", hintText: "Lama Bekerja", labelText: "Lama Bekerja"),
                    DescriptiveTextField(controller: currentAddressOffice, fieldName: "Alamat Pekerjaan Saat Ini", hintText: "Alamat Pekerjaan Saat Ini", labelText: "Alamat Pekerjaan Saat Ini"),
                    PhoneTextField(controller: officePhoneContact, fieldName: "Office Phone Contact (Opsional)", hintText: "Office Phone Contact (Opsional)", labelText: "Office Phone Contact (Opsional)", useValidator: false),
                    PhoneTextField(controller: faxController, fieldName: "Office Fax (Opsional)", hintText: "Office Fax (Opsional)", labelText: "Office Fax (Opsional)", useValidator: false),
                  ]
                ),
                UtilitiesWidget.titleContent(
                  title: "Informasi Pekerjaan Sebelumnya",
                  subtitle: "Inputkan informasi pekerjaan sebelumnya",
                  children: [
                    NameTextField(controller: durationOfLastWorkController, fieldName: "Lama Bekerja (Opsional)", hintText: "Lama Bekerja (Opsional)", labelText: "Lama Bekerja (Opsional)"),
                  ]
                )
              ],
            ),
          ),
        ),
        bottomNavigationBar: Obx(
          () => StepUtilities.stepOnlineRegister(
            size: size,
            title: regolController.isLoading.value ? "Uploading..." : "Your Job Experience",
            onPressed: regolController.isLoading.value ? null : (){
              if(_formKey.currentState!.validate()){
                regolController.postStepEight(
                  namaPekerjaan: yourJobCategoryController.text,
                  namaPerusahaan: businessNameController.text,
                  bidangUsaha: categoryBusinessNameController.text,
                  jabatanPekerjaan: durationOfWorkController.text,
                  lamaBekerja: durationOfWorkController.text,
                  alamatKantor: currentAddressOffice.text,
                  lamaBekerjaSebelumnya: durationOfLastWorkController.text,
                ).then((result) async{
                  await regolController.progressAccount();
                  if(result){
                    settingController.getUserBank().then((resultBank){
                      if(!resultBank){
                        CustomScaffoldMessanger.showAppSnackBar(context, message: settingController.responseMessage.value, type: SnackBarType.error);
                        return;
                      }
                      if(settingController.userBankModel.value?.response == null || settingController.userBankModel.value?.response?.isEmpty == true){
                        Get.to(() => const Step12BankInformation());
                      }else{
                        CustomScaffoldMessanger.showAppSnackBar(context, message: "User memiliki rekening bank, akan diarahkan ke page selanjutnya", type: SnackBarType.info);
                        Get.to(() => const Step17UploadPhoto());
                      }
                    });
                  }else{
                    CustomAlert.alertError(context, message: "Gagal submit data, mohon pastikan kelengkapan field serta crosscheck format validasi input yang benar dan pastikan dengan koneksi internet yang stabil.");
                  }
                });
              }
            },
            progressEnd: 4,
            currentAllPageStatus: 3,
            progressStart: 1
          ),
        ),
      ),
    );
  }
}