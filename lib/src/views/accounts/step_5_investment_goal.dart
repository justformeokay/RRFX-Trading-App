import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/alerts/default.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/containers/utilities.dart';
import 'package:rrfx/src/components/languages/language_variable.dart';
import 'package:rrfx/src/components/textfields/name_textfield.dart';
import 'package:rrfx/src/controllers/regol.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/views/accounts/step_19_familly_bappebti.dart';
import 'package:rrfx/src/views/mainpage.dart';

import 'components/step_position.dart';

class Step5InvestmentGoal extends StatefulWidget {
  const Step5InvestmentGoal({super.key});

  @override
  State<Step5InvestmentGoal> createState() => _Step5InvestmentGoal();
}

class _Step5InvestmentGoal extends State<Step5InvestmentGoal> {

  RegolController regolController = Get.find();
  TextEditingController investmentGoalController = TextEditingController();
  RxInt selectedValue = 1.obs;
  RxString selectedName = "".obs;

  int setInvestGoals({String? name}){
    switch(name){
      case "lindung nilai":
        selectedName(GlobalVariable.investmentGoalIndonesia[0]);
        return selectedValue(1);
      case "gain":
        selectedName(GlobalVariable.investmentGoalIndonesia[1]);
        return selectedValue(2);
      case "spekulasi":
        selectedName(GlobalVariable.investmentGoalIndonesia[2]);
        return selectedValue(3);
      case "lainnya":
        selectedName(GlobalVariable.investmentGoalIndonesia[3]);
        return selectedValue(4);
      default:
        return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    setInvestGoals(name: regolController.accountModel.value?.response?.tujuanInvestasi);
    selectedValue(1);
    selectedName(GlobalVariable.investmentGoalIndonesia[0]);
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
                child: Text("Pilih Tujuan Investasi", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                itemCount: GlobalVariable.investmentGoalIndonesia.length,
                itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Obx(
                    () => RadioListTile(
                      enableFeedback: true,
                      toggleable: false,
                      selected: false,
                      activeColor: CustomColor.secondaryColor,
                      hoverColor: CustomColor.secondaryColor.withOpacity(0.2),
                      overlayColor: WidgetStatePropertyAll(CustomColor.secondaryColor.withOpacity(0.2)),
                      selectedTileColor: CustomColor.secondaryColor,
                      shape: StadiumBorder(
                        side: BorderSide(color: CustomColor.secondaryColor)
                      ),
                      title: Text(GlobalVariable.investmentGoalIndonesia[index]),
                      value: index + 1,
                      groupValue: selectedValue.value,
                      onChanged: (value) {
                        selectedValue(value);
                        selectedName(GlobalVariable.investmentGoalIndonesia[index]);
                        investmentGoalController.text = selectedName.value;
                      },
                    ),
                  ),
                );
              },),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Obx(() => selectedValue.value == 4 ? UtilitiesWidget.titleContent(
                  title: "Tujuan Investasi ",
                  subtitle: "Mohon inputkan tujuan investasi anda",
                  children: [
                    NameTextField(controller: investmentGoalController, fieldName: "Inputkan Tujuan Investasi", hintText: "Inputkan Tujuan Investasi", labelText: "Inputkan Tujuan Investasi"),
                  ]
                ) : Container()),
              )
            ],
          ),
        ),
        bottomNavigationBar: Obx(
          () => StepUtilities.stepOnlineRegister(
            size: size,
            title: regolController.isLoading.value ? "Uploading..." : "Investment Goal",
            onPressed: regolController.isLoading.value ? null : (){
              if(selectedValue.value == 4){
                if(investmentGoalController.text.isEmpty){
                  CustomAlert.alertError(context, message: "Please fill the investment goal field");
                  return;
                }
                regolController.postStepFive(investmentGoal: investmentGoalController.text).then((result){
                  if(result){
                    Get.to(() => Step19FamilyBappebti());
                    CustomScaffoldMessanger.showAppSnackBar(context, message: regolController.responseMessage.value);
                  }else{
                    CustomAlert.alertError(context, message: regolController.responseMessage.value);
                  }
                });
              }else{
                regolController.postStepFive(investmentGoal: selectedName.value).then((result){
                  if(result){
                    Get.to(() => Step19FamilyBappebti());
                  }else{
                    CustomAlert.alertError(context, message: regolController.responseMessage.value);
                  }
                });
              }
            },
            progressEnd: 4,
            currentAllPageStatus: 2,
            progressStart: 1
          ),
        ),
      ),
    );
  }
}
