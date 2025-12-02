import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:rrfx/src/helpers/handlers/image_picker.dart';
import 'package:rrfx/src/helpers/variables/countries.dart';
import 'package:rrfx/src/helpers/variables/id_type.dart' show idTypeList;
import 'package:rrfx/src/views/accounts/step_2_stored_data.dart';
import 'package:rrfx/src/views/mainpage.dart';
import 'components/step_position.dart';

class Step1UploadPhoto extends StatefulWidget {
  const Step1UploadPhoto({super.key});

  @override
  State<Step1UploadPhoto> createState() => _Step1UploadPhotoState();
}

class _Step1UploadPhotoState extends State<Step1UploadPhoto> {

  final _formKey = GlobalKey<FormState>();
  TextEditingController nationallyController = TextEditingController();
  TextEditingController idTypeController = TextEditingController();
  TextEditingController idTypeNumber = TextEditingController();
  RegolController regolController = Get.put(RegolController());

  final RxInt lengthID = 0.obs; // panjang maksimal ID (misal: KTP=16)
  final RxString selectedIdType = ''.obs; // tipe ID terpilih (KTP/PASSPORT/KITAS)

  RxString idPhoto = "".obs;
  RxString idPhotoSelfie = "".obs;
  RxBool isLoading = false.obs;
  RxBool imageLoaded = false.obs;

  RxBool isImageOnline1 = false.obs;
  RxBool isImageOnline2 = false.obs;

  @override
  void initState() {
    super.initState();
    idTypeController.text = regolController.accountModel.value?.response?.idType ?? "";
    idTypeNumber.text = regolController.accountModel.value?.response?.idNumber ?? "";
    nationallyController.text = regolController.accountModel.value?.response?.country ?? "";
    if(regolController.accountModel.value?.response?.idType == "KTP"){
      lengthID(16);
    }else if(regolController.accountModel.value?.response?.idType == "PASSPORT"){
      lengthID(9);
    }else if(regolController.accountModel.value?.response?.idType == "KITAS"){
      lengthID(20);
    }else{
      lengthID(100);
    }
    if(regolController.accountModel.value?.response?.appFotoTerbaru != null && regolController.accountModel.value?.response?.appFotoIdentitas != null){
      idPhoto(regolController.accountModel.value?.response?.appFotoIdentitas);
      idPhotoSelfie(regolController.accountModel.value?.response?.appFotoTerbaru);
      imageLoaded(true);
    }
  }

  @override
  void dispose() {
    nationallyController.dispose();
    idTypeController.dispose();
    idTypeNumber.dispose();
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
                      title: LanguageGlobalVar.TITLE_REGOL_PAGE_1.tr,
                      subtitle: LanguageGlobalVar.SUBTITLE_REGOL_PAGE_1.tr,
                      children: [
                        const SizedBox(height: 10),
                        VoidTextField(controller: nationallyController, fieldName: LanguageGlobalVar.NATIONALY.tr, hintText: LanguageGlobalVar.CHOOSE_NATIONALY.tr, labelText: LanguageGlobalVar.NATIONALY.tr, onPressed: (){
                          CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: LanguageGlobalVar.CHOOSE_NATIONALY.tr, children: List.generate(countryList.length, (i){
                            return ListTile(
                              onTap: (){
                                Navigator.pop(context);
                                nationallyController.text = countryList[i].name;
                              },
                              title: Text(countryList[i].name, style: GoogleFonts.inter()),
                            );
                          }));
                        }),
                        VoidTextField(onPressed: (){
                          CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: LanguageGlobalVar.CHOOSE_YOUR_ID_TYPE.tr, isScrolledController: false, children: List.generate(idTypeList.length, (i){
                            return ListTile(
                              onTap: (){
                                Navigator.pop(context);
                                idTypeNumber.clear();
                                idTypeController.text = idTypeList[i].name;
                                selectedIdType.value = idTypeList[i].name; // <-- ini penting
                                if(idTypeList[i].name == "KTP"){
                                  lengthID(16);
                                }else if(idTypeList[i].name == "PASSPORT"){
                                  lengthID(9);
                                }else if(idTypeList[i].name == "KITAS"){
                                  lengthID(20);
                                }else{
                                  lengthID(100);
                                }
                              },
                              title: Text(idTypeList[i].name, style: GoogleFonts.inter()),
                            );
                          }));
                        },
                          controller: idTypeController, fieldName: LanguageGlobalVar.ID_TYPE.tr, hintText: LanguageGlobalVar.ID_TYPE.tr, labelText: LanguageGlobalVar.ID_TYPE.tr
                        ),
                        // Obx(() => lengthID.value != 16 ? NameTextField(controller: idTypeNumber, fieldName: LanguageGlobalVar.ID_TYPE_NUMBER.tr, hintText: LanguageGlobalVar.ID_TYPE_NUMBER.tr, labelText: LanguageGlobalVar.ID_TYPE_NUMBER.tr, maxLength: lengthID.value) : NumberTextField(controller: idTypeNumber, fieldName: LanguageGlobalVar.ID_TYPE_NUMBER.tr, hintText: LanguageGlobalVar.ID_TYPE_NUMBER.tr, labelText: LanguageGlobalVar.ID_TYPE_NUMBER.tr, maxLength: lengthID.value)),
                        // TextField untuk input nomor ID
                        Obx(() {
                          // Tentukan input formatter sesuai tipe ID
                          List<TextInputFormatter> inputFormatters = [];

                          if (selectedIdType.value == "KITAS") {
                            // Hanya huruf (a-z, A-Z), angka (0-9), dan tanda "-"
                            inputFormatters = [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-]')),
                            ];
                          } else {
                            // Selain KITAS → hanya angka
                            inputFormatters = [
                              FilteringTextInputFormatter.digitsOnly,
                            ];
                          }

                          return TextFormField(
                            controller: idTypeNumber,
                            maxLength: lengthID.value,
                            inputFormatters: inputFormatters,
                            keyboardType: selectedIdType.value == "KITAS"
                                ? TextInputType.text
                                : TextInputType.number,
                            decoration: InputDecoration(
                              prefixIconColor: CustomColor.textThemeDarkSoftColor,
                              prefixIcon: SizedBox(width: 30, child: Icon(Icons.credit_card)),
                              labelStyle: const TextStyle(color: CustomColor.textThemeDarkSoftColor),
                              labelText: "Nomor Identitas",
                              hintText: selectedIdType.value == "KITAS"
                                  ? "Masukkan nomor KITAS (huruf, angka, atau -)"
                                  : "Masukkan nomor identitas (angka saja)",
                              hintStyle: GoogleFonts.inter(
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color: CustomColor.secondaryColor
                                )
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color: CustomColor.textThemeDarkSoftColor
                                )
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color: CustomColor.textThemeDarkSoftColor
                                )
                              )
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Nomor identitas wajib diisi";
                              }

                              if (selectedIdType.value == "KITAS") {
                                // validasi KITAS — hanya huruf, angka, dan tanda "-"
                                if (!RegExp(r'^[a-zA-Z0-9\-]+$').hasMatch(value)) {
                                  return "Nomor KITAS hanya boleh huruf, angka, dan tanda -";
                                }
                              } else {
                                // validasi selain KITAS — hanya angka
                                if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                  return "Nomor identitas hanya boleh angka";
                                }
                              }
                              return null;
                            },
                          );
                        }),
                        Obx(
                          () => isLoading.value ? const SizedBox() : UtilitiesWidget.uploadPhotoV2(context, isImageOnline: imageLoaded.value, title: "Foto KTP", onPressed: () async {
                            idPhoto.value = await CustomImagePicker.pickImageFromCameraAndReturnUrl(useCamera: true);
                            imageLoaded.value = false;
                          }, urlPhoto: idPhoto.value),
                        ),
                        Obx(
                          () => !isLoading.value ? Obx(
                            () => UtilitiesWidget.uploadPhotoV2(context, isImageOnline: imageLoaded.value, title: "Foto Selfie", urlPhoto: idPhotoSelfie.value, onPressed: () async {
                              idPhotoSelfie.value = await CustomImagePicker.pickImageFromCameraAndReturnUrl(useCamera: true);
                              imageLoaded.value = false;
                            }),
                          ) : const SizedBox()
                        ),
                      ]
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Obx(
              () => StepUtilities.stepOnlineRegister(
                size: size,
                title: LanguageGlobalVar.VERIFICATION_IDENTITY.tr,
                onPressed: regolController.isLoading.value ? null : (){
                  // Get.to(() => const Step2StoredData());
                  regolController.postStepOne(
                    country: nationallyController.text,
                    idType: idTypeController.text,
                    idTypeNumber: idTypeNumber.text,
                    appFotoIdentitas: imageLoaded.value ? "" : idPhoto.value,
                    appFotoTerbaru: imageLoaded.value ? "" : idPhotoSelfie.value
                  ).then((result){
                    if(!result){
                      CustomAlert.alertError(context, message: regolController.responseMessage.value);
                      return false;
                    }
                    Get.to(() => const Step2StoredData());
                  });
                },
                progressEnd: 5,
                progressStart: 1
              ),
            ),
          ),
        ),
        Obx(() => regolController.isLoading.value ? LoadingWater() : const SizedBox())
      ],
    );
  }
}
