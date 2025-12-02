import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/alerts/default.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/containers/utilities.dart';
import 'package:rrfx/src/components/languages/language_variable.dart';
import 'package:rrfx/src/components/textfields/descriptive_textfield.dart';
import 'package:rrfx/src/components/textfields/number_textfield.dart';
import 'package:rrfx/src/components/textfields/void_textfield.dart';
import 'package:rrfx/src/controllers/two_factory_auth.dart';
import 'package:rrfx/src/controllers/regol.dart';
import 'package:rrfx/src/controllers/user_controller.dart';
import 'package:rrfx/src/controllers/utilities.dart';
import 'package:rrfx/src/controllers/wilayah_controller.dart';
import 'package:rrfx/src/views/accounts/step_3_marital.dart';
import 'package:rrfx/src/views/mainpage.dart';
import 'components/step_position.dart';

class Step18PrenyataanSimulasi extends StatefulWidget {
  const Step18PrenyataanSimulasi({super.key});

  @override
  State<Step18PrenyataanSimulasi> createState() => _Step18PrenyataanSimulasiState();
}

class _Step18PrenyataanSimulasiState extends State<Step18PrenyataanSimulasi> {

  UtilitiesController utilitiesController = Get.put(UtilitiesController());
  final _formKey = GlobalKey<FormState>();
  WilayahController wilayahController = Get.put(WilayahController());
  TextEditingController provinceController = TextEditingController();
  TextEditingController kabupatenController = TextEditingController();
  TextEditingController kecamatanController = TextEditingController();
  TextEditingController desaController = TextEditingController();
  TextEditingController zipController = TextEditingController();
  TextEditingController rtController = TextEditingController();
  TextEditingController rwController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  RegolController regolController = Get.put(RegolController());
  UserController userController = Get.find();
  TwoFactoryAuth twoFactoryAuth = Get.find();

  DateTime now = DateTime.now();

  Stream<DateTime> timeStream() {
    return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
  }


  RxString simulasiAkunDemoURL = "".obs;
  RxBool isLoading = false.obs;
  RxBool selectedStatement = true.obs;
  RxBool imageLoaded = false.obs;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      regolController.isLoading(true);
      rtController.text = regolController.accountModel.value?.response?.rt ?? '';
      rwController.text = regolController.accountModel.value?.response?.rw ?? '';
      addressController.text = regolController.accountModel.value?.response?.address ?? "";
      if(regolController.accountModel.value?.response?.appFotoSimulasi != null){
        simulasiAkunDemoURL(regolController.accountModel.value?.response?.appFotoSimulasi);
        imageLoaded(true);
      }
      provinceController.text = regolController.accountModel.value?.response?.province ?? "";
      kabupatenController.text = regolController.accountModel.value?.response?.city ?? "";
      kecamatanController.text = regolController.accountModel.value?.response?.district ?? "";
      desaController.text = regolController.accountModel.value?.response?.village ?? "";
      zipController.text = regolController.accountModel.value?.response?.postalCode ?? "";
      wilayahController.getProvinsi().then((resultProvince){
        if(!resultProvince){
          CustomScaffoldMessanger.showAppSnackBar(context, message: wilayahController.responseMessage.value, type: SnackBarType.error);
        }
      });
      regolController.isLoading(false);
    });
  }

  @override
  void dispose() {
    provinceController.dispose();
    kabupatenController.dispose();
    kecamatanController.dispose();
    desaController.dispose();
    zipController.dispose();
    rtController.dispose();
    rwController.dispose();
    addressController.dispose();
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
          title: LanguageGlobalVar.PERSONAL_INFORMATION.tr,
          actions: [
            CupertinoButton(
              onPressed: () async {
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
                  title: "Informasi Alamat",
                  subtitle: "Isi semua form yang ada dibawah ini untuk dapat melanjutkan proses pembuatan akun real.",
                  children: [
                    // Province
                    Obx(
                      () => VoidTextField(controller: provinceController, fieldName: "Provinsi", hintText: "Provinsi", labelText: "Provinsi", onPressed: wilayahController.isLoading.value ? null :(){
                        CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Pilih Provinsi Anda", children: List.generate(wilayahController.listProvinsiModel.value?.response?.length ?? 0, (i){
                          return ListTile(
                            title: Text(wilayahController.listProvinsiModel.value?.response?[i].name ?? "-", style: GoogleFonts.inter()),
                            onTap: (){
                              Navigator.pop(context);
                              provinceController.text = wilayahController.listProvinsiModel.value?.response?[i].name ?? "-";
                              wilayahController.selectedProvince(provinceController.text);
                              wilayahController.getKabupatenKota();
                            },
                          );
                        }));
                      }),
                    ),

                    // Kabupaten
                      Obx(
                        () => VoidTextField(controller: kabupatenController, fieldName: "Kabupaten", hintText: "Kabupaten", labelText: "Kabupaten", onPressed: wilayahController.isLoading.value ? null : (){
                          CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Pilih Kabupaten Anda", children: List.generate(wilayahController.listKotaModel.value?.response?.length ?? 0, (i){
                            return ListTile(
                              title: Text(wilayahController.listKotaModel.value?.response?[i].name ?? "-", style: GoogleFonts.inter()),
                              onTap: (){
                                Navigator.pop(context);
                                kabupatenController.text = wilayahController.listKotaModel.value?.response?[i].name ?? "-";
                                wilayahController.selectedCity(kabupatenController.text);
                                wilayahController.getKecamatan();
                              },
                            );
                          }));
                        }),
                      ),


                    // Kecamatan
                      Obx(
                        () => VoidTextField(controller: kecamatanController, fieldName: "Kecamatan", hintText: "Kecamatan", labelText: "Kecamatan", onPressed: wilayahController.isLoading.value ? null : (){
                          CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Pilih Kecamatan Anda", children: List.generate(wilayahController.listKecamatanModel.value?.response?.length ?? 0, (i){
                            return ListTile(
                              title: Text(wilayahController.listKecamatanModel.value?.response?[i].name ?? "-", style: GoogleFonts.inter()),
                              onTap: (){
                                Navigator.pop(context);
                                kecamatanController.text = wilayahController.listKecamatanModel.value?.response?[i].name ?? "-";
                                wilayahController.selectedDistrict(kecamatanController.text);
                                wilayahController.getDesa();
                              },
                            );
                          }));
                        }),
                      ),

                    // Desa
                      VoidTextField(controller: desaController, fieldName: "Desa", hintText: "Desa", labelText: "Desa", onPressed: (){
                        CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Pilih Desa Anda", children: List.generate(wilayahController.listDesaModel.value?.response?.length ?? 0, (i){
                          return ListTile(
                            title: Text(wilayahController.listDesaModel.value?.response?[i].name ?? "-", style: GoogleFonts.inter()),
                            onTap: (){
                              Navigator.pop(context);
                              desaController.text = wilayahController.listDesaModel.value?.response?[i].name ?? "-";
                              wilayahController.selectedSubDistrict(desaController.text);
                              zipController.text = wilayahController.listDesaModel.value?.response?[i].postalCode ?? "-";
                            },
                          );
                        }));
                      }),
                    NumberTextField(controller: zipController, readOnly: true, hintText: "Kode Pos", labelText: "Kode Pos", maxLength: 5, fieldName: "Kode Pos", useValidator: false),
                    Row(
                      children: [
                        Expanded(child: NumberTextField(controller: rtController, hintText: "RT", labelText: "RT", maxLength: 5, fieldName: "RT", useValidator: false)),
                        const SizedBox(width: 10.0),
                        Expanded(child: NumberTextField(controller: rwController, hintText: "RW", labelText: "RW", maxLength: 5, fieldName: "RW", useValidator: false)),
                      ],
                    ),
                    DescriptiveTextField(controller: addressController, hintText: "Alamat Lengkap", labelText: "Alamat Lengkap", fieldName: "Alamat Lengkap", useValidator: false)
                  ]
                ),

                /*
                UtilitiesWidget.titleContent(
                  title: "Pernyataan Simulasi",
                  subtitle: "Unggah foto simulasi penggunaan akun DEMO yang telah anda buat.",
                  children: [
                    Obx(
                      () => !isLoading.value ? Obx(
                        () => UtilitiesWidget.uploadPhotoV2(context, isImageOnline: imageLoaded.value, title: "Foto Selfie", urlPhoto: simulasiAkunDemoURL.value, onPressed: () async {
                          simulasiAkunDemoURL(await CustomImagePicker.pickImageFromCameraAndReturnUrl());
                          imageLoaded.value = false;
                        }),
                      ) : const SizedBox()),
                  ]
                )
                */
                Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Dengan mengisi kolom “YA” di bawah ini, saya menyatakan bahwa semua informasi dan semua dokumen yang saya lampirkan dalam APLIKASI PEMBUKAAN REKENING TRANSAKSI SECARA ELEKTRONIK ONLINE adalah benar dan tepat, Saya akan bertanggung jawab penuh apabila dikemudian hari terjadi sesuatu hal sehubungan dengan ketidakbenaran data yang saya berikan.", textAlign: TextAlign.justify, style: GoogleFonts.inter(color: Theme.of(context).textTheme.bodySmall?.color)),
                        const SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Obx(
                                  () => Row(
                                    children: [
                                      Checkbox(
                                        fillColor: WidgetStatePropertyAll(CustomColor.secondaryBackground.withOpacity(0.3)),
                                        checkColor: CustomColor.secondaryColor,
                                        side: WidgetStateBorderSide.resolveWith((Set<WidgetState> states) {
                                          if (states.contains(WidgetState.selected)) {
                                            return const BorderSide(color: Colors.black45); // tetap tampil meski dicentang
                                          }
                                          return const BorderSide(color: Colors.black45); // tidak dicentang
                                        }),
                                        value: selectedStatement.value == true ? true : false,
                                        onChanged: (value) => selectedStatement.value = !selectedStatement.value,
                                      ),
                                      Text("YA")
                                    ],
                                  ),
                                ),
                                Obx(
                                  () => Row(
                                    children: [
                                      Checkbox(
                                        fillColor: WidgetStatePropertyAll(CustomColor.secondaryBackground.withOpacity(0.3)),
                                        checkColor: CustomColor.secondaryColor,
                                        side: WidgetStateBorderSide.resolveWith((Set<WidgetState> states) {
                                          if (states.contains(WidgetState.selected)) {
                                            return const BorderSide(color: Colors.black45); // tetap tampil meski dicentang
                                          }
                                          return const BorderSide(color: Colors.black45); // tidak dicentang
                                        }),
                                        value: selectedStatement.value == false ? true : false,
                                        onChanged: (value) => selectedStatement.value = !selectedStatement.value,
                                      ),
                                      Text("TIDAK")
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            StreamBuilder<DateTime>(
                              stream: timeStream(),
                              builder: (context, snapshot) {
                                final now = snapshot.data ?? DateTime.now();
                                return Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text("Menerima pada Tanggal", maxLines: 1, overflow: TextOverflow.clip),
                                      Text(
                                        DateFormat('yyyy-MM-dd hh:mm:ss').format(now),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                        maxLines: 1, overflow: TextOverflow.clip
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          ],
                        )
                      ],
                    )
              ],
            ),
          ),
        ),
        bottomNavigationBar: Obx(
          () => StepUtilities.stepOnlineRegister(
            size: size,
            title: regolController.isLoading.value ? "Processing..." : LanguageGlobalVar.VERIFICATION_IDENTITY.tr,
            onPressed: regolController.isLoading.value ? null : (){
              if(_formKey.currentState!.validate()){
                if(selectedStatement.value){
                  regolController.postStepNinePernyataanSimulasi(
                    // urlPhoto: imageLoaded.value ? "" : simulasiAkunDemoURL.value,
                    appAddress: addressController.text,
                    appAgree: selectedStatement.value == true ? "ya" : "tidak",
                    appCity: kabupatenController.text,
                    appDistrict: kecamatanController.text,
                    appProvince: provinceController.text,
                    appRT: rtController.text,
                    appRW: rwController.text,
                    appVillage: desaController.text,
                    appZipcode: zipController.text
                  ).then((result){
                    if(!result){
                      CustomAlert.alertError(context, message: regolController.responseMessage.value, onTap: (){
                        if(regolController.responseMessage.value == "Anda belum melakukan transaksi dengan akun demo"){
                          Get.back();
                        }else{
                          Get.back();
                        }
                      });
                      return false;
                    }
                    Get.to(() => const Step3Marital());
                  });
                }else{
                  CustomScaffoldMessanger.showAppSnackBar(context, message: "Silakan centang pernyataan \"YA\" simulasi", type: SnackBarType.error);
                }
              }
            },
            progressEnd: 4,
            progressStart: 3
          ),
        ),
      ),
    );
  }
}