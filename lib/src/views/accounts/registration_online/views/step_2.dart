import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/alerts/default.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/containers/utilities.dart';
import 'package:rrfx/src/components/textfields/void_textfield.dart';
import 'package:rrfx/src/controllers/regol.dart';
import 'package:rrfx/src/views/accounts/registration_online/components/button_next_previous.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/progress_account_controller.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/statement_controller.dart';
import 'package:rrfx/src/views/accounts/registration_online/repository/regol_repository.dart';
import 'package:rrfx/src/views/accounts/registration_online/views/step_3.dart';

class Step2 extends StatefulWidget {
  const Step2({super.key});

  @override
  State<Step2> createState() => _Step2State();
}

class _Step2State extends State<Step2> {
  RxInt selectedIndex = 0.obs;
  RxBool isLoading = false.obs;
  RxBool selectedType = false.obs;
  RxBool selectedCDDType = false.obs;
  RxInt selectedCDDTypeIndex = 1.obs;
  RxInt selectedRadio = 1.obs;
  RxString accountTypeSuffix = "".obs;
  final RegolRepository _regolRepository = Get.find<RegolRepository>();

  TextEditingController productController = TextEditingController();
  TextEditingController cddTipeController = TextEditingController();
  RegolController regolController = Get.put(RegolController());
  StatementController controller = Get.put(StatementController());
  final progressController = Get.find<ProgressAccountController>();

  @override
  void initState() {
    super.initState();
    regolController.isLoading(true);
    progressController.fetchProgressAccount().then((result){
      final data = progressController.progressData.value;
      final cddList = data?.data?.cddTipe ?? [];
      if (cddList.isEmpty) {
        return CustomScaffoldMessanger.showAppSnackBar(context, message: "CDD Type tidak dapat ditemukan", type: SnackBarType.info);
      }
      regolController.getProducts().then((result){
        if(!result){
          CustomAlert.alertError(context);
          return false;
        }
        productController.text = progressController.progressData.value?.response?.type.toString() ?? "";
        int index = regolController.productModels.value?.response.indexWhere((element) => element.type?.toUpperCase() == progressController.progressData.value?.response?.type) ?? -1;
        if(index != -1){
          selectedIndex.value = index;
          selectedType.value = true;
          int index2 = regolController.productModels.value?.response[index].products?.indexWhere((element2) => element2.suffix == progressController.progressData.value?.response?.typeAcc) ?? -1;
          if(index2 != -1){
            accountTypeSuffix(regolController.productModels.value?.response[index].products?[index2].suffix);
            selectedRadio(index2 + 1);
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
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar.defaultAppBar(
          autoImplyLeading: true,
          title: "Step 2"
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: UtilitiesWidget.titleContent(
            title: "Pilih Akun",
            subtitle: "Pilih jenis akun trading yang akan anda buat",
            children: [
              Obx(() {
                final data = progressController.progressData.value;
                if (progressController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: CustomColor.secondaryColor));
                }
                final cddList = data?.data?.cddTipe ?? [];
                if (cddList.isEmpty) {
                  return const Text("CDD Type belum tersedia");
                }
                return VoidTextField(
                  readOnly: true,
                  controller: cddTipeController,
                  fieldName: "CDD Type",
                  hintText: "Pilih CDD Type",
                  labelText: "CDD Type",
                  onPressed: () {
                    CustomMaterialBottomSheets.defaultBottomSheet(
                      context,
                      size: size,
                      title: "Pilih Tipe CDD",
                      isScrolledController: false,
                      children: List.generate(cddList.length, (index) {
                        final item = cddList[index];
                        if (item.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        // final key = item.keys.first;
                        final value = item.values.first;

                        return ListTile(
                          title: Text(value.isNotEmpty ? value : "Tidak diketahui"),
                          onTap: () {
                            cddTipeController.text = value;
                            Get.back();
                          },
                        );
                      }),
                    );
                  },
                );
              }),
              Obx(
                () => selectedCDDType.value == false ? const SizedBox() : VoidTextField(controller: productController, fieldName: "Trading Account Type", hintText:  "Trading Account Type", labelText: "Trading Account Type", onPressed: (){
                  CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Choose Trading Account Type", children: List.generate(regolController.productModels.value?.response.length ?? 0, (i){
                    return ListTile(
                      onTap: (){
                        Navigator.pop(context);
                        selectedIndex(i);
                        productController.text = regolController.productModels.value?.response[i].type != null ? regolController.productModels.value!.response[i].type!.toUpperCase() : "-";
                        selectedType(true);
                        accountTypeSuffix(regolController.productModels.value?.response[i].products?[0].suffix);
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
        bottomNavigationBar: ButtonNextPrevious(
          onPressed: () async {
            String? selectedCDD;
            if(cddTipeController.text == "Standart"){
              selectedCDD = "1";
            }else{
              selectedCDD = "2";
            }
            if(!controller.selectedStatement.value){
              CustomScaffoldMessanger.showAppSnackBar(context, message: "Mohon centang \"YA\" pada checkbox persetujuan profil perusahaan berjangka", type: SnackBarType.error);
              return;
            }
            bool result = await _regolRepository.step2(accountType: accountTypeSuffix.value, cddType: selectedCDD);
            if(result) {
              Get.to(() => const Step3());
              return;
            }
            CustomScaffoldMessanger.showAppSnackBar(context, message: _regolRepository.responseMessage.value, type: SnackBarType.error);
          },
        )
      )
    );
  }
}