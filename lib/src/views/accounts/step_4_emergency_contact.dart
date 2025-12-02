import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/alerts/default.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/containers/utilities.dart';
import 'package:rrfx/src/components/languages/language_variable.dart';
import 'package:rrfx/src/components/textfields/descriptive_textfield.dart';
import 'package:rrfx/src/components/textfields/name_text_field_new.dart';
import 'package:rrfx/src/components/textfields/name_textfield.dart';
import 'package:rrfx/src/components/textfields/number_textfield.dart';
import 'package:rrfx/src/components/textfields/phone_textfield.dart';
import 'package:rrfx/src/controllers/regol.dart';
import 'package:rrfx/src/controllers/utilities.dart';
import 'package:rrfx/src/views/accounts/step_5_investment_goal.dart';
import 'package:rrfx/src/views/mainpage.dart';

import 'components/step_position.dart';

class Step4EmergencyContact extends StatefulWidget {
  const Step4EmergencyContact({super.key});

  @override
  State<Step4EmergencyContact> createState() => _Step4EmergencyContact();
}

class _Step4EmergencyContact extends State<Step4EmergencyContact> {

  TextEditingController nameController = TextEditingController();
  TextEditingController relationController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController provinceController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController zipController = TextEditingController();

  RxBool showProvince = true.obs;
  RxBool showCity = false.obs;
  RxBool showVillage = false.obs;
  RxBool isIndonesia = true.obs;

  UtilitiesController utilitiesController = Get.put(UtilitiesController());
  RegolController regolController = Get.find();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameController.text = regolController.accountModel.value?.response?.drrtName ?? "";
    relationController.text = regolController.accountModel.value?.response?.drrtStatus ?? "";
    phoneController.text = regolController.accountModel.value?.response?.drrtPhone ?? "";
    addressController.text = regolController.accountModel.value?.response?.drrtAddress ?? "";
    zipController.text = regolController.accountModel.value?.response?.drrtPostalCode ?? "";
  }

  @override
  void dispose() {
    nameController.dispose();
    relationController.dispose();
    phoneController.dispose();
    zipController.dispose();
    addressController.dispose();
    countryController.dispose();
    provinceController.dispose();
    cityController.dispose();
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
                  title: "Informasi Darurat",
                  subtitle: "Mohon isi semua informasi tambahan",
                  children: [
                    NameTextFieldNewVersion(controller: nameController, fieldName: "Name", hintText: "Input emergency contact name", labelText: "Name", useValidator: true),
                    NameTextField(controller: relationController, fieldName: "Status Hubungan", hintText: "Input Status Hubungan Anda", labelText: "Status Hubungan"),
                    PhoneTextField(controller: phoneController, fieldName: "Nomor HP Kontak Darurat", hintText: "Nomor HP Kontak Darurat", labelText: "Nomor HP Kontak Darurat"),
                    DescriptiveTextField(controller: addressController, fieldName: "Emergency Contact Address", hintText: "Emergency Contact Address", labelText: "Emergency Contact Address"),
                    NumberTextField(controller: zipController, fieldName: "Zip Code", hintText: "Input Zip Code", labelText: "Zip Code", maxLength: 5),
                  ]
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Obx(
          () => StepUtilities.stepOnlineRegister(
            size: size,
            title: regolController.isLoading.value ? "Uploading..." : "Emergency Contact",
            onPressed: regolController.isLoading.value ? null : (){
              if(_formKey.currentState!.validate()){
                regolController.postStepFour(
                  emergencyAddress: addressController.text,
                  emergencyContact: phoneController.text,
                  emergencyName: nameController.text,
                  emergencyRelation: relationController.text,
                  postalCode: zipController.text
                ).then((result){
                  if(result){
                    Get.to(() => const Step5InvestmentGoal());
                  }else{
                    CustomAlert.alertError(context, message: regolController.responseMessage.value);
                  }
                });
              }
            },
            progressEnd: 5,
            progressStart: 5
          ),
        ),
      ),
    );
  }
}
