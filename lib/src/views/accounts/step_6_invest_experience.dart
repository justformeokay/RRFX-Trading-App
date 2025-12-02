import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/alerts/default.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/containers/utilities.dart';
import 'package:rrfx/src/components/languages/language_variable.dart';
import 'package:rrfx/src/components/textfields/name_textfield.dart';
import 'package:rrfx/src/controllers/regol.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/views/accounts/step_8_income_range.dart';
import 'package:rrfx/src/views/mainpage.dart';

import 'components/step_position.dart';

class Step6InvestmentExperience extends StatefulWidget {
  const Step6InvestmentExperience({super.key});

  @override
  State<Step6InvestmentExperience> createState() => _Step6InvestmentExperience();
}

class _Step6InvestmentExperience extends State<Step6InvestmentExperience> {

  RxInt selectedValue = 1.obs;
  RxBool showBrokerName = true.obs;
  TextEditingController companyNameController = TextEditingController();
  RegolController regolController = Get.find();

  int setInvestExperience({String? experience, String? brokerName}){
    switch(experience){
      case "ya":
        showBrokerName(true);
        companyNameController.text = brokerName ?? "";
        return selectedValue(1);
      case "tidak":
        showBrokerName(false);
        return selectedValue(2);
      default:
        return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    selectedValue(2);
    showBrokerName(false);
    setInvestExperience(experience: regolController.accountModel.value?.response?.pengalamanInvestasi, brokerName: regolController.accountModel.value?.response?.pengalamanInvestasiBidang);
  }

  @override
  void dispose() {
    companyNameController.dispose();
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
          title: "Investment",
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Apakah anda pernah berinvestasi sebelumnya?", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                itemCount: GlobalVariable.investExperienceIndo.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Obx(
                      () => RadioListTile(
                        enableFeedback: true,
                        toggleable: false,
                        selected: false,
                        selectedTileColor: CustomColor.defaultColor,
                        shape: StadiumBorder(
                          side: BorderSide(color: CustomColor.defaultColor)
                        ),
                        title: Text(GlobalVariable.investExperienceIndo[index]),
                        value: index + 1,
                        groupValue: selectedValue.value,
                        onChanged: (value) {
                          selectedValue(value);
                          if(index == 0){
                            showBrokerName(true);
                          }else{
                            showBrokerName(false);
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
              Obx(
                () => showBrokerName.value ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: UtilitiesWidget.titleContent(
                    title: "Bidang Investasi",
                    subtitle: "Inputkan nama bidang investasi yang pernah anda coba.",
                    children: [
                      NameTextField(controller: companyNameController, fieldName: "Nama Bidang Investasi", hintText: "Nama Bidang Investasi", labelText: "Nama Bidang Investasi"),
                    ]
                  ),
                ) : const SizedBox(),
              )
            ],
          ),
        ),
        bottomNavigationBar: Obx(
          () => StepUtilities.stepOnlineRegister(
            size: size,
            title: regolController.isLoading.value ? "Uploading..." : "Investment Experience",
            onPressed: regolController.isLoading.value ? null : (){
              if(showBrokerName.value){
                if(companyNameController.text == ""){
                  CustomAlert.alertError(context, message: "Mohon nama perusahaan diisi");
                }else{
                  regolController.postStepSix(companyName: companyNameController.text, experience: GlobalVariable.investExperienceIndo[selectedValue.value-1].toLowerCase()).then((result){
                    if(result){
                      // Get.to(() => const Step7BalanceSources());
                      Get.to(() => const Step8IncomeRange());
                    }else{
                      CustomAlert.alertError(context, message: regolController.responseMessage.value);
                    }
                  });
                }
              }else{
                regolController.postStepSix(companyName: companyNameController.text, experience: GlobalVariable.investExperienceIndo[selectedValue.value-1].toLowerCase()).then((result){
                  if(result){
                    Get.to(() => const Step8IncomeRange());
                  }else{
                    CustomAlert.alertError(context, message: regolController.responseMessage.value);
                  }
                });
              }
            },
            progressEnd: 4,
            currentAllPageStatus: 2,
            progressStart: 3
          ),
        ),
      ),
    );
  }
}
