import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/alerts/default.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/languages/language_variable.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/views/accounts/step_10_total_assets.dart';
import 'package:rrfx/src/views/mainpage.dart';
import 'components/step_position.dart';

class Step8OtherIncomeRange extends StatefulWidget {
  const Step8OtherIncomeRange({super.key});

  @override
  State<Step8OtherIncomeRange> createState() => _Step8OtherIncomeRange();
}

class _Step8OtherIncomeRange extends State<Step8OtherIncomeRange> {

  RxInt selectedValue = 1.obs;

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
              child: Text(LanguageGlobalVar.CANCEL.tr, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            )
          ]
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Other Annual Income Range?", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                itemCount: GlobalVariable.otherIncomePerYear.length,
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
                        title: Text(GlobalVariable.otherIncomePerYear[index]),
                        value: index + 1,
                        groupValue: selectedValue.value,
                        onChanged: (value) {
                          selectedValue(value);
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: StepUtilities.stepOnlineRegister(
          size: size,
          title: "Other Income",
          onPressed: (){
            Get.to(() => const Step10TotalAssets());
          },
          progressEnd: 6,
          currentAllPageStatus: 2,
          progressStart: 5
        ),
      ),
    );
  }
}
