import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
import 'package:rrfx/src/components/buttons/elevated_button.dart';
import 'package:rrfx/src/components/containers/utilities.dart';
import 'package:rrfx/src/components/textfields/name_text_field_new.dart';
import 'package:rrfx/src/components/textfields/number_textfield.dart';
import 'package:rrfx/src/components/textfields/void_textfield.dart';
import 'package:rrfx/src/controllers/setting.dart';
import 'package:rrfx/src/controllers/user_controller.dart';
import 'package:rrfx/src/controllers/utilities.dart';
import 'package:rrfx/src/helpers/handlers/image_picker.dart';

class InformasiDetailBankSaya extends StatefulWidget {
  const InformasiDetailBankSaya({super.key, this.bankCurrency, this.bankName, this.bankOwnerName, this.bankNumber, this.bankType, this.bankBranch, required this.editingMode, this.editDitolakMode, this.idBankEditingMode});
  final String? bankCurrency;
  final String? bankName;
  final String? idBankEditingMode;
  final String? bankOwnerName;
  final String? bankNumber;
  final String? bankType;
  final String? bankBranch;
  final bool? editDitolakMode;
  final bool editingMode;

  @override
  State<InformasiDetailBankSaya> createState() => _InformasiDetailBankSayaState();
}

class _InformasiDetailBankSayaState extends State<InformasiDetailBankSaya> {
  final _formKey = GlobalKey<FormState>();
  RxString urlBukuRekening= "".obs;
  RxList<dynamic> daftarBank = <String>[].obs;
  UserController userController = Get.put(UserController());
  UtilitiesController utilitiesController = Get.put(UtilitiesController());
  SettingController settingController = Get.put(SettingController());
  TextEditingController bankNameController = TextEditingController();
  TextEditingController ownerController = TextEditingController();
  TextEditingController nomorRekening = TextEditingController();

  void setBankDetailToController(InformasiDetailBankSaya widget) {
    bankNameController.text = widget.bankName ?? "";
    nomorRekening.text = widget.bankNumber ?? "";
  }


  @override
  void initState() {
    super.initState();
    userController.getProfile();
    utilitiesController.getBankList().then((resultGetBankList){
      setBankDetailToController(widget);
      ownerController.text = userController.profileModel.value?.name ?? "";
      for(int i = 0; i < resultGetBankList.length; i++){
        daftarBank.add(resultGetBankList[i]);
      }
    });
  }

  @override
  void dispose() {
    ownerController.dispose();
    bankNameController.dispose();
    nomorRekening.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    print(">>> editingMode: ${widget.editingMode}");
    print(">>> editDitolakMode: ${widget.editDitolakMode}");
    print(">>> idBankEditingMode: ${widget.idBankEditingMode}");
    print(">>> bankName: ${widget.bankName}");
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar.defaultAppBar(
          title: !widget.editingMode ? "Informasi Bank Saya" : "Tambah Bank",
          autoImplyLeading: true
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      UtilitiesWidget.titleContent(
                        title: "Bank Information",
                        subtitle: "Inputkan informasi bank anda",
                        children: [
                          VoidTextField(controller: bankNameController, fieldName: "Bank Name", hintText: "Bank Name", labelText: "Bank Name", onPressed: !widget.editingMode ? null : () async {
                            CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Choose your bank currency type", children: List.generate(daftarBank.length, (i){
                              return ListTile(
                                onTap: (){
                                  Navigator.pop(context);
                                  bankNameController.text = daftarBank[i];
                                },
                                title: Text("${daftarBank[i]}", style: GoogleFonts.inter()),
                              );
                            }));
                          }),
                          NameTextFieldNewVersion(controller: ownerController, fieldName: "Nama Pemilik Rekening", hintText: "Nama Pemilik Rekening", labelText: "Nama Pemilik Rekening", readOnly: false, useValidator: true),
                          NumberTextField(controller: nomorRekening, fieldName: "Nomor Rekening", hintText: "Nomor Rekening", labelText: "Nomor Rekening", maxLength: 16, minLength: 10, useValidator: false, readOnly: !widget.editingMode),
                          widget.editDitolakMode == true || widget.editingMode == true ? Obx(
                            () => utilitiesController.isLoading.value ? const SizedBox() : UtilitiesWidget.uploadPhotoV2(context, isImageOnline: false, title: "Foto Buku rekening", onPressed: () async {
                              urlBukuRekening(await CustomImagePicker.pickImageFromCameraAndReturnUrl(useCamera: true));
                            }, urlPhoto: urlBukuRekening.value),
                          ) : const SizedBox(),
                        ]
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: widget.editingMode == false ? null : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Obx(
            () => DefaultButton.defaultElevatedButton(
              onPressed: userController.isLoading.value ? null : (){
                print(">>> urlBukuRekening: ${urlBukuRekening.value}");
                if(_formKey.currentState!.validate()){
                  if(urlBukuRekening.value == ""){
                    CustomScaffoldMessanger.showAppSnackBar(context, message: "Mohon upload gambar buku rekening", type: SnackBarType.error);
                    return;
                  }
                  if (widget.editingMode == true && widget.editDitolakMode == true) {
                    userController.editBankRegol(
                      bankHolder: ownerController.text,
                      account: nomorRekening.text,
                      bankID: widget.idBankEditingMode,
                      bankName: bankNameController.text,
                      urlBukuRekening: urlBukuRekening.value
                    ).then((resltEditDitolak) {
                      if (!resltEditDitolak) {
                        CustomScaffoldMessanger.showAppSnackBar(
                          context,
                          message: userController.responseMessage.value,
                          type: SnackBarType.error,
                        );
                        return;
                      }
                      CustomScaffoldMessanger.showAppSnackBar(
                        context,
                        message: userController.responseMessage.value,
                        type: SnackBarType.success,
                      );
                      settingController.getUserBank().then((resultGetMyBank) {
                        Get.back();
                      });
                    });
                  } else {
                    userController.addBankRegol(
                      account: nomorRekening.text,
                      bankPemilik: ownerController.text,
                      bankName: bankNameController.text,
                      urlBukuRekening: urlBukuRekening.value,
                    ).then((result) {
                      if (!result) {
                        CustomScaffoldMessanger.showAppSnackBar(
                          context,
                          message: userController.responseMessage.value,
                          type: SnackBarType.error,
                        );
                        return;
                      }
                      CustomScaffoldMessanger.showAppSnackBar(
                        context,
                        message: userController.responseMessage.value,
                        type: SnackBarType.success,
                      );
                      settingController.getUserBank().then((resultGetMyBank) {
                        Get.back();
                      });
                    });
                  }
                }
              },
              title: utilitiesController.isLoading.value ? "Processing..." : "Konfirmasi"
            ),
          ),
        ),
      ),
    );
  }
}