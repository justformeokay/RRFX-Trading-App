import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/alerts/default.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/containers/utilities.dart';
import 'package:rrfx/src/components/languages/language_variable.dart';
import 'package:rrfx/src/components/painters/loading_water.dart';
import 'package:rrfx/src/components/textfields/void_textfield.dart';
import 'package:rrfx/src/controllers/regol.dart';
import 'package:rrfx/src/helpers/handlers/image_picker.dart';
import 'package:rrfx/src/views/accounts/disclosure_stetement.dart';
import 'package:rrfx/src/views/mainpage.dart';
import 'components/step_position.dart';

class Step17UploadPhoto extends StatefulWidget {
  const Step17UploadPhoto({super.key});

  @override
  State<Step17UploadPhoto> createState() => _Step17UploadPhotoState();
}

class _Step17UploadPhotoState extends State<Step17UploadPhoto> {

  final _formKey = GlobalKey<FormState>();
  TextEditingController documentFirstName = TextEditingController();
  TextEditingController documentSecondName = TextEditingController();
  RegolController regolController = Get.find();

  RxList<String> listDokumenPendukung1 = ['Rekening Koran Bank', 'Tagihan Kartu Kredit'].obs;
  RxList<String> listDokumenPendukung2 = ['Tagihan Listrik', 'Tagihan Telepon'].obs;


  RxString documentFirstURL = "".obs; // Rekening Koran Bank / Tagihan Kartu Kredit
  RxString documentSecondURL = "".obs; // Tagihan Listrik / Telepon
  RxString documentThirdURL = "".obs; // NPWP
  RxBool isLoading = false.obs;
  RxBool selectedStatement = false.obs;
  RxBool isImageOnline1 = false.obs;
  RxBool isImageOnline2 = false.obs;
  RxBool isImageOnline3 = false.obs;

  RxString selectedDocumentFirstName = "".obs;
  RxString selectedDocumentSecondName = "".obs;
  RxString selectedDocumentThirdName = "".obs;


  @override
  void initState() {
    super.initState();
    if(regolController.accountModel.value?.response?.appFotoImage1 != null){
      documentFirstURL.value = regolController.accountModel.value!.response!.appFotoImage1!;
      isImageOnline1(true);
    }

    if(regolController.accountModel.value?.response?.appFotoImage2 != null){
      documentSecondURL.value = regolController.accountModel.value!.response!.appFotoImage2!;
      isImageOnline2(true);
    }

    if(regolController.accountModel.value?.response?.appFotoImage3 != null){
      documentThirdURL.value = regolController.accountModel.value!.response!.appFotoImage3!;
      isImageOnline3(true);
    }
  }

  @override
  void dispose() {
    documentFirstName.dispose();
    documentSecondName.dispose();
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
                      subtitle: "Pilih jenis dokumen pendukung dan masukkan gambar sesuai jenis dokumen yang anda pilih",
                      title: "Dokumen Pendukung",
                      children: [
                        // Document First
                        VoidTextField(controller: documentFirstName, fieldName: "Dokumen Pendukung 1", hintText: "Dokumen Pendukung 1", labelText: "Dokumen Pendukung 1", onPressed: () async {
                          CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, isScrolledController: false, title: "Pilih Jenis Dokumen Pendukung 1 untuk disubmit", children: List.generate(listDokumenPendukung1.length, (i){
                            return ListTile(
                              onTap: (){
                                documentFirstName.text = listDokumenPendukung1[i];
                                selectedDocumentFirstName(documentFirstName.text);
                                Navigator.pop(context);
                              },
                              title: Text(listDokumenPendukung1[i], style: GoogleFonts.inter()),
                            );
                          }));
                        }),

                        Obx(
                          () => selectedDocumentFirstName.value == ""
                            ? const SizedBox()
                            : UtilitiesWidget.uploadPhoto(
                                isImageOnline: isImageOnline1.value,
                                title: selectedDocumentFirstName.value,
                                urlPhoto: documentFirstURL.value,
                                onPressed: () async {
                                  final pickedImage = await CustomImagePicker.pickImageFromCameraAndReturnUrl();
                                  if (pickedImage.isNotEmpty) {
                                    documentFirstURL.value = pickedImage; // ganti URL dengan file lokal
                                    isImageOnline1.value = false; // ubah status ke offline
                                  }
                                },
                              ),
                        ),

                        const SizedBox(height: 20),
                        VoidTextField(controller: documentSecondName, fieldName: "Dokumen Pendukung 2", hintText: "Dokumen Pendukung 2", labelText: "Dokumen Pendukung 2", onPressed: () async {
                          CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, isScrolledController: false, title: "Pilih Jenis Dokumen Pendukung 2 untuk disubmit", children: List.generate(listDokumenPendukung2.length, (i){
                            return ListTile(
                              onTap: (){
                                documentSecondName.text = listDokumenPendukung2[i];
                                selectedDocumentSecondName(documentSecondName.text);
                                Navigator.pop(context);
                              },
                              title: Text(listDokumenPendukung2[i], style: GoogleFonts.inter()),
                            );
                          }));
                        }),
                        // Document Second
                        Obx(
                          () => selectedDocumentSecondName.value == ""
                            ? const SizedBox()
                            : UtilitiesWidget.uploadPhoto(
                                isImageOnline: isImageOnline2.value,
                                title: selectedDocumentSecondName.value,
                                urlPhoto: documentSecondURL.value,
                                onPressed: () async {
                                  final pickedImage = await CustomImagePicker.pickImageFromCameraAndReturnUrl();
                                  if (pickedImage.isNotEmpty) {
                                    documentSecondURL.value = pickedImage; // ganti URL dengan file lokal
                                    isImageOnline2.value = false; // ubah status ke offline
                                  }
                                },
                              ),
                        ),
                      ]
                    ),

                    UtilitiesWidget.titleContent(
                      title: "Dokumen Pajak",
                      subtitle: "Unggah dokumen NPWP anda",
                      children: [
                        Obx(
                          () => isLoading.value
                              ? const SizedBox()
                              : UtilitiesWidget.uploadPhoto(
                                  isImageOnline: isImageOnline3.value,
                                  title: "NPWP",
                                  onPressed: () async {
                                    final pickedImage = await CustomImagePicker.pickImageFromCameraAndReturnUrl(useCamera: true);
                                    if (pickedImage.isNotEmpty) {
                                      documentThirdURL.value = pickedImage;
                                      isImageOnline3.value = false;
                                    }
                                  },
                                  urlPhoto: documentThirdURL.value,
                                ),
                        ),
                      ],
                    )

                  ],
                ),
              ),
            ),
            bottomNavigationBar: Obx(
              () => StepUtilities.stepOnlineRegister(
                size: size,
                title: regolController.isLoading.value ? "Loading..." : LanguageGlobalVar.VERIFICATION_IDENTITY.tr,
                onPressed: regolController.isLoading.value ? null : (){
                  if(documentFirstURL.value == ""){
                    CustomScaffoldMessanger.showAppSnackBar(context, message: "Mohon unggah dokumen pendukung 1");
                    return;
                  }
                  if(documentSecondURL.value == ""){
                    CustomScaffoldMessanger.showAppSnackBar(context, message: "Mohon unggah dokumen pendukung 1");
                    return;
                  }

                  if(documentThirdURL.value == ""){
                    CustomScaffoldMessanger.showAppSnackBar(context, message: "Mohon unggah dokumen NPWP");
                    return;
                  }

                  if(_formKey.currentState!.validate()){
                    regolController.stepDokumenPendukung(
                      dokumenPendukung1: isImageOnline1.value ? "" : documentFirstURL.value,
                      dokumenPendukung2: isImageOnline2.value ? "" : documentSecondURL.value,
                      dokumenPendukung3: isImageOnline3.value ? "" : documentThirdURL.value,
                    ).then((result) async{
                      if(result){
                        await regolController.progressAccount();
                        Get.to(() => const HalamanDisclosure());
                      }else{
                        CustomAlert.alertError(context, message: regolController.responseMessage.value);
                      }
                    });
                  }
                },
                progressEnd: 4,
                progressStart: 3
              ),
            ),
          ),
        ),
        Obx(() => regolController.isLoading.value ? LoadingWater() : const SizedBox())
      ],
    );
  }
}
