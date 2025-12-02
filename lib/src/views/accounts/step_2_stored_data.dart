import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/alerts/default.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/containers/utilities.dart';
import 'package:rrfx/src/components/languages/language_variable.dart';
import 'package:rrfx/src/components/painters/loading_water.dart';
import 'package:rrfx/src/components/textfields/email_textfield.dart';
import 'package:rrfx/src/components/textfields/name_text_field_new.dart';
import 'package:rrfx/src/components/textfields/name_textfield.dart';
import 'package:rrfx/src/components/textfields/number_textfield.dart';
import 'package:rrfx/src/components/textfields/phone_textfield.dart';
import 'package:rrfx/src/components/textfields/void_textfield.dart';
import 'package:rrfx/src/controllers/authentication.dart';
import 'package:rrfx/src/controllers/regol.dart';
import 'package:rrfx/src/controllers/user_controller.dart';
import 'package:rrfx/src/helpers/handlers/date_pickers.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/views/accounts/step_18_pernyataan_simulasi.dart';
import 'package:rrfx/src/views/mainpage.dart';

import 'components/step_position.dart';

class Step2StoredData extends StatefulWidget {
  const Step2StoredData({super.key});

  @override
  State<Step2StoredData> createState() => _Step2StoredData();
}

class _Step2StoredData extends State<Step2StoredData> {

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController idTypeController = TextEditingController();
  TextEditingController taxController = TextEditingController();
  TextEditingController dateBirthController = TextEditingController();
  TextEditingController placeBirthController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController motherNameController = TextEditingController();


  RegolController regolController = Get.find();
  UserController userController = Get.put(UserController());
  AuthController authController = Get.find();

  final _formKey = GlobalKey<FormState>();
  RxString selectedPhone = "62".obs;
  DateTime? selectedDateBirth;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async{
      await userController.getProfile().then((resultGet) {
        if (resultGet) {
          setState(() {
            nameController.text = userController.profileModel.value?.name ?? "";
            final phone = userController.profileModel.value?.phone ?? "";
            final phoneWithout62 = phone.replaceFirst(RegExp(r'^62'), '');
            phoneController.text = phoneWithout62;
            if(userController.profileModel.value?.tmptLahir == null){
              placeBirthController.text = regolController.accountModel.value?.response?.placeOfBirth ?? "";
            }else{
              placeBirthController.text = userController.profileModel.value?.tmptLahir ?? "";
            }
            emailController.text = userController.profileModel.value?.email ?? "";
            taxController.text = regolController.accountModel.value?.response?.npwp ?? "";
          });
        }
      });
    });
    dateBirthController.text = regolController.accountModel.value?.response?.dateOfBirth ?? '2000-01-01';
    genderController.text = userController.profileModel.value?.gender ?? regolController.accountModel.value?.response?.gender ?? "";
    motherNameController.text = regolController.accountModel.value?.response?.motherName ?? "";
  }

  @override
  void dispose() {
    motherNameController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    idTypeController.dispose();
    taxController.dispose();
    dateBirthController.dispose();
    placeBirthController.dispose();
    genderController.dispose();
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
                      title: LanguageGlobalVar.TITLE_REGOL_PAGE_2.tr,
                      subtitle: LanguageGlobalVar.SUBTITLE_REGOL_PAGE_2.tr,
                      children: [
                        NameTextField(readOnly: true, controller: nameController, fieldName: LanguageGlobalVar.FULL_NAME.tr, hintText: LanguageGlobalVar.INPUT_YOUR_NAME.tr, labelText: LanguageGlobalVar.FULL_NAME.tr, useValidator: false),
                        EmailTextField(readOnly: true, controller: emailController, fieldName: LanguageGlobalVar.EMAIL_ADDRESS.tr, hintText: LanguageGlobalVar.INPUT_YOUR_EMAIL_ADDRESS.tr, labelText: LanguageGlobalVar.EMAIL_ADDRESS.tr),
                        PhoneTextField(readOnly: false, controller: phoneController, fieldName: LanguageGlobalVar.PHONE_NUMBER.tr, hintText: "81xxxx", labelText: LanguageGlobalVar.PHONE_NUMBER.tr, useValidator: false),
                        VoidTextField(controller: dateBirthController, fieldName: LanguageGlobalVar.BIRTH_DATE.tr, hintText: LanguageGlobalVar.BIRTH_DATE.tr, labelText: LanguageGlobalVar.BIRTH_DATE.tr, onPressed: () async {
                          DateTime? selected;
                          selected = await CustomDatePicker.material(context);
                          if(selected != null){
                            dateBirthController.text = CustomDatePicker.formatIndonesiaDate(selected);
                            selectedDateBirth = selected;
                          }
                        }),
                        NameTextFieldNewVersion(controller: placeBirthController, fieldName: LanguageGlobalVar.BIRTH_PLACE.tr, hintText: LanguageGlobalVar.BIRTH_PLACE.tr, labelText: LanguageGlobalVar.BIRTH_PLACE.tr, useValidator: true),
                        VoidTextField(controller: genderController, fieldName: LanguageGlobalVar.GENDER.tr, hintText: LanguageGlobalVar.GENDER.tr, labelText: LanguageGlobalVar.GENDER.tr, onPressed: (){
                          CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, isScrolledController: false, title: LanguageGlobalVar.CHOOSE_YOUR_GENDER.tr, children: List.generate(GlobalVariable.genderIndo.length, (i){
                            return ListTile(
                              title: Text(GlobalVariable.genderIndo[i], style: GoogleFonts.inter()),
                              onTap: (){
                                Navigator.pop(context);
                                genderController.text = GlobalVariable.genderIndo[i];
                              },
                            );
                          }));
                        }),
                      ]
                    ),
                    UtilitiesWidget.titleContent(
                      title: "Informasi Tambahan",
                      subtitle: "Mohon isikan informasi tambahan",
                      children: [
                        NameTextFieldNewVersion(controller: motherNameController, fieldName: "Nama Ibu Kandung", hintText: "Nama Ibu Kandung", labelText: "Nama Ibu Kandung", useValidator: true),
                        NumberTextField(controller: taxController,  fieldName: LanguageGlobalVar.TAX_CARD.tr, hintText: LanguageGlobalVar.TAX_CARD.tr, labelText: LanguageGlobalVar.TAX_CARD.tr, maxLength: 16, useValidator: false),
                      ]
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: StepUtilities.stepOnlineRegister(
              size: size,
              title: LanguageGlobalVar.DATA_COLLECTION.tr,
              onPressed: (){
                String dateFormatted = DateFormat('yyyy-MM-dd').format(selectedDateBirth ?? DateTime.parse(dateBirthController.text));
                if(_formKey.currentState!.validate()){
                  regolController.postStepTwo(birthPlace: placeBirthController.text, dateOfBirth: dateFormatted, gender: genderController.text, taxNumber: taxController.text, name: nameController.text, phone: phoneController.text, phoneCode: selectedPhone.value, motherName: motherNameController.text).then((result){
                    if(!result){
                      CustomAlert.alertError(context, message: regolController.responseMessage.value);
                      return false;
                    } 
                    regolController.accountModel.value?.response?.placeOfBirth = placeBirthController.text;
                    regolController.accountModel.value?.response?.dateOfBirth = dateFormatted;
                    regolController.accountModel.value?.response?.gender = genderController.text;
                    regolController.accountModel.value?.response?.npwp = taxController.text;
                    Get.to(() => const Step18PrenyataanSimulasi());
                  });
                }
              },
              progressEnd: 5,
              progressStart: 2
            ),
          ),
        ),
        Obx(() => regolController.isLoading.value ? LoadingWater() : const SizedBox())
      ],
    );
  }
}
