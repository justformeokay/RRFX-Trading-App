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
import 'package:rrfx/src/components/textfields/void_textfield.dart';
import 'package:rrfx/src/controllers/regol.dart';
import 'package:rrfx/src/views/accounts/step_6_invest_experience.dart';
import 'package:rrfx/src/views/mainpage.dart';
import 'components/step_position.dart';

class Step19FamilyBappebti extends StatefulWidget {
  const Step19FamilyBappebti({super.key});

  @override
  State<Step19FamilyBappebti> createState() => _Step19FamilyBappebti();
}

class _Step19FamilyBappebti extends State<Step19FamilyBappebti> {

  final _formKey = GlobalKey<FormState>();
  TextEditingController familyBappebti = TextEditingController();
  TextEditingController pernyataanPailit = TextEditingController();
  RegolController regolController = Get.put(RegolController());

  RxString idPhoto = "".obs;
  List<String> pilihan = ["Ya", "Tidak"];

  @override
  void initState() {
    super.initState();
    familyBappebti.text = regolController.accountModel.value?.response?.keluargaBursa != null ? regolController.accountModel.value!.response!.keluargaBursa!.toUpperCase() : "";
    pernyataanPailit.text = regolController.accountModel.value?.response?.pernyataanPailit != null ? regolController.accountModel.value!.response!.pernyataanPailit!.toUpperCase() : "";
  }

  @override
  void dispose() {
    familyBappebti.dispose();
    pernyataanPailit.dispose();
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
                      title: "Keluarga BAPPEBTI",
                      subtitle: "Apakah anda memiliki keluarga yang bekerja di BAPPEBTI",
                      children: [
                        const SizedBox(height: 10),
                        VoidTextField(controller: familyBappebti, fieldName: "Keluarga BAPPEBTI", hintText: "Pilih salah satu", labelText: "Keluarga BAPPEBTI", onPressed: (){
                          CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Apakah anda memiliki hubungan keluarga yang bekerja di BAPPEBTI", children: List.generate(pilihan.length, (i){
                            return ListTile(
                              onTap: (){
                                Navigator.pop(context);
                                familyBappebti.text = pilihan[i];
                              },
                              title: Text(pilihan[i], style: GoogleFonts.inter()),
                            );
                          }));
                        }),
                      ]
                    ),

                    UtilitiesWidget.titleContent(
                        title: "Pernyataan Pailit",
                        subtitle: "Apakah anda dinyatakan pailit oleh pengadilan?",
                        children: [
                          const SizedBox(height: 10),
                          VoidTextField(controller: pernyataanPailit, fieldName: "Pernyataan Pailit", hintText: "Pernyataan Pailit", labelText: "Pernyataan Pailit", onPressed: (){
                            CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Apakah anda dinyatakan pailit oleh pengadilan?", children: List.generate(pilihan.length, (i){
                              return ListTile(
                                onTap: (){
                                  Navigator.pop(context);
                                  pernyataanPailit.text = pilihan[i];
                                },
                                title: Text(pilihan[i], style: GoogleFonts.inter()),
                              );
                            }));
                          }),
                        ]
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Obx(
              () => StepUtilities.stepOnlineRegister(
              size: size,
              title: regolController.isLoading.value ? "Loading..." : "Keluarga BAPPEBTI",
              onPressed: regolController.isLoading.value ? null : (){
                regolController.postPernytaanPailit(keluargaBappebti: familyBappebti.text.toLowerCase(), pailit: pernyataanPailit.text.toLowerCase()).then((result){
                  if(result){
                    Get.to(() => const Step6InvestmentExperience());
                    return;
                  }
                  CustomAlert.alertError(context, message: regolController.responseMessage.value);
                });
              },
              progressEnd: 4,
              progressStart: 2
              ),
            ),
          ),
        ),
        Obx(() => regolController.isLoading.value ? LoadingWater() : const SizedBox())
      ],
    );
  }
}
