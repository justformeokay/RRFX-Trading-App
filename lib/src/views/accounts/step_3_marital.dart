import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/alerts/default.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/containers/utilities.dart';
import 'package:rrfx/src/components/languages/language_variable.dart';
import 'package:rrfx/src/components/painters/loading_water.dart';
import 'package:rrfx/src/components/textfields/name_text_field_new.dart';
import 'package:rrfx/src/components/textfields/phone_textfield.dart';
import 'package:rrfx/src/components/textfields/void_textfield.dart';
import 'package:rrfx/src/controllers/regol.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/views/accounts/step_4_emergency_contact.dart';
import 'package:rrfx/src/views/mainpage.dart';

import 'components/step_position.dart';

class Step3Marital extends StatefulWidget {
  const Step3Marital({super.key});

  @override
  State<Step3Marital> createState() => _Step3Marital();
}

class _Step3Marital extends State<Step3Marital> {

  TextEditingController maritalStatusController = TextEditingController();
  TextEditingController wifeHusbandName = TextEditingController();
  TextEditingController phoneHomeController = TextEditingController();
  TextEditingController faxController = TextEditingController();
  RxBool showNameWifeOrHusband = false.obs;
  final _formKey = GlobalKey<FormState>();
  RxBool isLoading = false.obs;

  // Init Class Controller Trading
  RegolController regolController = Get.find();

  @override 
  void initState() {
    super.initState();
    maritalStatusController.text = regolController.accountModel.value?.response?.maritalStatus ?? "";
    phoneHomeController.text = regolController.accountModel.value?.response?.phoneHome ?? "";
    faxController.value = TextEditingValue(text: regolController.accountModel.value?.response?.faxHome ?? "");
    wifeHusbandName.text = regolController.accountModel.value?.response?.wifeHusbandName ?? "";
    if(maritalStatusController.text.toLowerCase() == "tidak kawin"){
      showNameWifeOrHusband(false);
    }else{
      showNameWifeOrHusband(true);
    }
  }

  @override
  void dispose() {
    maritalStatusController.dispose();
    phoneHomeController.dispose();
    wifeHusbandName.dispose();
    faxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: CustomAppBar.defaultAppBar(
              autoImplyLeading: true,
              title: LanguageGlobalVar.PERSONAL_INFORMATION.tr,
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
                      title: "Status Pernikahan",
                      subtitle: "Pilih pernikahan status anda",
                      children: [
                        Obx(
                          () => isLoading.value ? const SizedBox() : VoidTextField(controller: maritalStatusController, fieldName: "Status Pernikahan", hintText: "Status Pernikahan", labelText: "Status Pernikahan", onPressed: () async {
                            CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, isScrolledController: true, title: "Pilih menu item Status Pernikahan", children: List.generate(GlobalVariable.maritalIndoVersion.length, (i){
                              return ListTile(
                                title: Text(GlobalVariable.maritalIndoVersion[i], style: GoogleFonts.inter()),
                                onTap: (){
                                  Navigator.pop(context);
                                  maritalStatusController.text = GlobalVariable.maritalIndoVersion[i];
                                  if(maritalStatusController.text == "Tidak Kawin"){
                                    showNameWifeOrHusband(false);
                                  }else{
                                    showNameWifeOrHusband(true);
                                  }
                                }
                              );
                            }));
                          }),
                        ),
                        Obx(() => showNameWifeOrHusband.value ? NameTextFieldNewVersion(controller: wifeHusbandName, fieldName: "Wife or Husband Name", hintText: "Wife or Husband Name", labelText: "Wife or Husband Name", useValidator: true) : const SizedBox()),
                      ]
                    ),
                    UtilitiesWidget.titleContent(
                      title: "Informasi Lainnya",
                      subtitle: "Lengkapi informasi lainnya jika ada",
                      children: [
                        PhoneTextField(controller: phoneHomeController, fieldName: "Phone Home (Opsional)", hintText: "Phone Home (Opsional)", labelText: "Phone Home (Opsional)", useValidator: false),
                        PhoneTextField(controller: faxController, fieldName: "Fax Number (Opsional)", hintText: "Fax Number (Opsional)", labelText: "Fax Number (Opsional)", useValidator: false),
                      ]
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: StepUtilities.stepOnlineRegister(
              size: size,
              title: "Marital Status",
              onPressed: (){
                if(!_formKey.currentState!.validate()){
                  CustomAlert.alertError(context, message: "Please fill all the fields");
                  return false;
                }

                regolController.postStepThree(faxNumber: faxController.text, maritalStatus: maritalStatusController.text, phoneHome: phoneHomeController.text, wifeName: wifeHusbandName.text).then((result){
                  if(!result){
                    CustomAlert.alertError(context, message: regolController.responseMessage.value);
                    return false;
                  }

                  regolController.accountModel.value?.response?.maritalStatus = maritalStatusController.text;
                  regolController.accountModel.value?.response?.phoneHome = phoneHomeController.text;
                  regolController.accountModel.value?.response?.faxHome = faxController.text;
                  regolController.accountModel.value?.response?.wifeHusbandName = wifeHusbandName.text;
                  Get.to(() => const Step4EmergencyContact());
                });
              },
              progressEnd: 5,
              progressStart: 4
            ),
          ),
        ),
        Obx(() => regolController.isLoading.value ? LoadingWater() : const SizedBox())
      ],
    );
  }
}
