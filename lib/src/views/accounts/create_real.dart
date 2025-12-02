import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/alerts/default.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
import 'package:rrfx/src/components/buttons/elevated_button.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/languages/language_variable.dart';
import 'package:rrfx/src/components/textfields/void_textfield.dart';
import 'package:rrfx/src/controllers/regol.dart';
import 'package:rrfx/src/views/accounts/profile_perusahaan.dart';
import 'components/simple_utilities.dart';

class CreateReal extends StatefulWidget {
  const CreateReal({super.key});

  @override
  State<CreateReal> createState() => _CreateRealState();
}

class _CreateRealState extends State<CreateReal> {
  RxInt selectedIndex = 0.obs;
  RxBool isLoading = false.obs;
  RxBool selectedType = false.obs;
  RxBool selectedCDDType = false.obs;
  RxInt selectedCDDTypeIndex = 1.obs;
  RxInt selectedRadio = 1.obs;
  RxString accountTypeSuffix = "".obs;
  // RxString accountTypeSuffixName = "".obs;
  // RxString accountTypeSuffixRate = "".obs;
  // RxString accountTypeSuffixCurrency = "".obs;
  RxString selectedCDD = "Standart".obs;
  RxList cddType = ["Standart", "Sederhana"].obs;

  TextEditingController productController = TextEditingController();
  TextEditingController cddTipeController = TextEditingController();
  RegolController regolController = Get.put(RegolController());

  @override
  void initState() {
    super.initState();

    /** Fetch progressAccount */
    regolController.isLoading(true);
    regolController.progressAccount().then((result){
      regolController.getProducts().then((result){
        if(!result){
          CustomAlert.alertError(context);
          return false;
        }

        /** Assign account type to productController */
        if(regolController.accountModel.value?.response?.type != null){
          productController.text = regolController.accountModel.value?.response?.type.toString() ?? "";
          int index = regolController.productModels.value?.response.indexWhere((element) => element.type?.toUpperCase() == regolController.accountModel.value?.response?.type?.toUpperCase()) ?? -1;
          if(index != -1){
            selectedIndex(index);
            selectedType(true);
            
            int index2 = regolController.productModels.value?.response[index].products?.indexWhere((element2) => element2.suffix == regolController.accountModel.value?.response?.typeAcc) ?? -1;
            if(index2 != -1){
              accountTypeSuffix(regolController.productModels.value?.response[index].products?[index2].suffix);
              selectedRadio(index2 + 1);
            }
          }
        }
        selectedCDDType(true); // untuk sementara
        cddTipeController.text = "Standart";

        regolController.isLoading(false);
      });
    });
  }

  @override
  void dispose() {
    productController.dispose();
    cddTipeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppBar.defaultAppBar(
        autoImplyLeading: true,
        title: '',
      ),
      body: SafeArea(
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SimpleUtilities.titleCreateReal(),
                  Obx(
                    () => isLoading.value
                      ? const SizedBox()
                      : VoidTextField(
                          readOnly: true,
                          controller: cddTipeController,
                          fieldName: "Standart",
                          hintText: "Standart",
                          labelText: "CDD Type",
                          onPressed: null
                          //  () {
                          //   CustomMaterialBottomSheets.defaultBottomSheet(
                          //     context,
                          //     size: size,
                          //     title: "Choose CDD Type",
                          //     children: List.generate(
                          //       cddType.length,
                          //       (i) {
                          //         return ListTile(
                          //           onTap: (){
                          //             selectedCDD(cddType[i]);
                          //             if(selectedCDD.value == "Standart"){
                          //               selectedCDDTypeIndex(1);
                          //             }else if(selectedCDD.value == "Sederhana"){
                          //               selectedCDDTypeIndex(2);
                          //             }
                          //             Navigator.pop(context);
                          //             cddTipeController.text = cddType[i];
                          //             selectedCDDType(true);
                          //           },
                          //           title: Text(cddType[i], style: GoogleFonts.inter()),
                          //         );
                          //       },
                          //     ),
                          //   );
                          // },
                        ),
                  ),

                  Obx(
                    () => selectedCDDType.value == false ? const SizedBox() : VoidTextField(controller: productController, fieldName: "Trading Account Type", hintText:  "Trading Account Type", labelText: "Trading Account Type", onPressed: (){
                      CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Choose Trading Account Type", children: List.generate(regolController.productModels.value?.response.length ?? 0, (i){
                        print("INI LENGTH PRODUCT => ${regolController.productModels.value!.response.length}"); // ada 5
                        return ListTile(
                          onTap: (){
                            Navigator.pop(context);
                            selectedIndex(i);
                            productController.text = regolController.productModels.value?.response[i].type != null ? regolController.productModels.value!.response[i].type!.toUpperCase() : "-";
                            selectedType(true);
                            accountTypeSuffix(regolController.productModels.value?.response[i].products?[0].suffix);
                            // accountTypeSuffixRate(regolController.productModels.value?.response[i].products?[0].rate);
                            // accountTypeSuffixCurrency(regolController.productModels.value?.response[i].products?[0].currency);
                            // accountTypeSuffixName(regolController.productModels.value?.response[i].products?[0].name);
                          },
                          title: Text(regolController.productModels.value?.response[i].type != null ? regolController.productModels.value!.response[i].type!.toUpperCase() : "-", style: GoogleFonts.inter()),
                        );
                      }));
                    }),
                  ),
                  Obx(
                    () => selectedCDDType.value == false ? const SizedBox() : selectedType.value ? ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: regolController.productModels.value?.response[selectedIndex.value].products?.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Obx(
                            () => RadioListTile(
                              enableFeedback: true,
                              toggleable: false,
                              activeColor: CustomColor.secondaryColor,
                              selected: false,
                              selectedTileColor: CustomColor.secondaryColor,
                              shape: StadiumBorder(
                                side: BorderSide(color: CustomColor.secondaryColor)
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(regolController.productModels.value?.response[selectedIndex.value].products?[index].name ?? "-", style: GoogleFonts.inter(color: Theme.of(context).textTheme.titleLarge?.color, fontSize: 14, fontWeight: FontWeight.bold)),
                                      Text("Rate: ${regolController.productModels.value?.response[selectedIndex.value].type != null ? regolController.productModels.value!.response[selectedIndex.value].products![index].rate! : "-"}", style: GoogleFonts.inter(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 9)),
                                      Text("Leverage: ${regolController.productModels.value?.response[selectedIndex.value].products != null ? "1:${regolController.productModels.value!.response[selectedIndex.value].products![index].leverage}" : "1:0"}", style: GoogleFonts.inter(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 9)),
                                      Text("Komisi: ${regolController.productModels.value?.response[selectedIndex.value].products != null ? "\$${regolController.productModels.value!.response[selectedIndex.value].products![index].komisi}/lot" : "0"}", style: GoogleFonts.inter(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 9))
                                    ],
                                  ),
                                  // if(regolController.productModels.value?.response[selectedIndex.value].type != null)
                                  //   if(regolController.productModels.value!.response[selectedIndex.value].products?[index].currency == "IDR")
                                  //     Container(
                                  //       width: 30,
                                  //       decoration: BoxDecoration(
                                  //         shape: BoxShape.circle
                                  //       ),
                                  //       child: CountryFlag.fromCountryCode('ID'),)
                                  //   else
                                  //     CircleAvatar(child: CountryFlag.fromCountryCode('US'))
                                  Text(regolController.productModels.value?.response[selectedIndex.value].type != null ? regolController.productModels.value!.response[selectedIndex.value].products![index].currency! : "-", style: GoogleFonts.inter(color: Theme.of(context).textTheme.labelLarge?.color, fontSize: 12, fontWeight: FontWeight.bold))
                                ],
                              ),
                              value: index + 1,
                              groupValue: selectedRadio.value,
                              onChanged: (value) {
                                accountTypeSuffix(regolController.productModels.value?.response[selectedIndex.value].products?[index].suffix);
                                selectedRadio(value);
                              },
                            ),
                          ),
                        );
                      },
                    )
                    : const SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).canvasColor,
        padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 3, bottom: 20),
        child: Obx(
          () => DefaultButton.defaultElevatedButton(
            onPressed: regolController.isLoading.value ? null : (){
              // print(selectedCDDTypeIndex.value);
              // print(accountTypeSuffix.value);
              // print(accountTypeSuffixRate.value);
              // print(accountTypeSuffixCurrency.value);
              // print(accountTypeSuffixName.value);
              regolController.postStepZero(accountType: accountTypeSuffix.value, cddType: selectedCDDTypeIndex.value.toString()).then((result){
                if(result){
                  // Get.to(() => const Step1UploadPhoto());
                  Get.to(() => const HalamanSatuProfilPerusahaan());
                }else{
                  CustomAlert.alertWaiting(context, message: regolController.responseMessage.value);
                }
              });
            },
            title: LanguageGlobalVar.CREATE_TRADING_ACCOUNT.tr
          ),
        ),
      ),
    );
  }
}
