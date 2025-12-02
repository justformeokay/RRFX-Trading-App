import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
import 'package:rrfx/src/components/buttons/outlined_button.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/containers/utilities.dart';
import 'package:rrfx/src/components/textfields/descriptive_textfield.dart';
import 'package:rrfx/src/components/textfields/email_textfield.dart';
import 'package:rrfx/src/components/textfields/name_text_field_new.dart';
import 'package:rrfx/src/components/textfields/name_textfield.dart';
import 'package:rrfx/src/components/textfields/number_textfield.dart';
import 'package:rrfx/src/components/textfields/phone_textfield.dart';
import 'package:rrfx/src/components/textfields/void_textfield.dart';
import 'package:rrfx/src/controllers/home.dart';
import 'package:rrfx/src/controllers/user_controller.dart';
import 'package:rrfx/src/controllers/wilayah_controller.dart';
import 'package:rrfx/src/helpers/formatters/masking_email.dart';
import 'package:rrfx/src/helpers/formatters/regex_formatter.dart';
import 'package:rrfx/src/helpers/handlers/date_pickers.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  UserController userController = Get.put(UserController());

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController jenisKelamin = TextEditingController();
  TextEditingController tempatLahir = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController kabupatenController = TextEditingController();
  TextEditingController provinsiController = TextEditingController();
  TextEditingController kecamatanController = TextEditingController();
  TextEditingController desaController = TextEditingController();
  TextEditingController zipController = TextEditingController();
  TextEditingController tanggalLahir = TextEditingController();
  HomeController homeController = Get.find();
  WilayahController wilayahController = Get.put(WilayahController());
  RxString selectedDateBirth = "".obs;
  RxBool editingMode = false.obs;
  RxBool isLoading = false.obs;
  final _formKey = GlobalKey<FormState>();

  void setUserPlace(){
    wilayahController.getProvinsi().then((resultProvince){
      // Province
      if(!resultProvince){
        CustomScaffoldMessanger.showAppSnackBar(context, message: wilayahController.responseMessage.value);
        return;
      }
      if(wilayahController.listProvinsiModel.value?.response?.isEmpty == true){
        return;
      }
      for(int i = 0; i < wilayahController.listProvinsiModel.value!.response!.length; i++){
        if(wilayahController.listProvinsiModel.value!.response![i].selected == true){
          provinsiController.text = wilayahController.listProvinsiModel.value!.response![i].name!;
          wilayahController.selectedProvince(wilayahController.listProvinsiModel.value!.response![i].name);
          break;
        }
      }

      // Kabupaten
      wilayahController.getKabupatenKota().then((resultKabupaten){
        if(!resultKabupaten){
          return;
        }
        if(wilayahController.listKotaModel.value?.response?.isEmpty == true){
          return;
        }
        for(int i = 0; i < wilayahController.listKotaModel.value!.response!.length; i++){
          if(wilayahController.listKotaModel.value!.response![i].selected == true){
            kabupatenController.text = wilayahController.listKotaModel.value!.response![i].name!;
            wilayahController.selectedCity(wilayahController.listKotaModel.value!.response![i].name);
            break;
          }else{
            editingMode(true);
          }
        }

        // Kecamatan
        wilayahController.getKecamatan().then((resultKecamatan){
          if(!resultKecamatan){
            return;
          }
          if(wilayahController.listKecamatanModel.value?.response?.isEmpty == true){
            return;
          }
          for(int i = 0; i < wilayahController.listKecamatanModel.value!.response!.length; i++){
            if(wilayahController.listKecamatanModel.value!.response![i].selected == true){
              kecamatanController.text = wilayahController.listKecamatanModel.value!.response![i].name!;
              wilayahController.selectedDistrict(wilayahController.listKecamatanModel.value!.response![i].name);
              break;
            }
          }

          // Desa
          wilayahController.getDesa().then((resultDesa){
            if(!resultDesa){
              return;
            }
            if(wilayahController.listDesaModel.value?.response?.isEmpty == true){
              return;
            }
            for(int i = 0; i < wilayahController.listDesaModel.value!.response!.length; i++){
              if(wilayahController.listDesaModel.value!.response![i].selected == true){
                desaController.text = wilayahController.listDesaModel.value!.response![i].name!;
                wilayahController.selectedSubDistrict(wilayahController.listDesaModel.value!.response![i].name);
                break;
              }
            }
          });
        });
      });
    });
  }

  void setProfileControllers() {
    final profile = userController.profileModel.value;

    nameController.text = profile?.name ?? "";
    // phoneController.text = profile?.phone != null ? maskPhoneNumber(profile!.phone!) : "";
    String? rawPhone = profile?.phone;

    // Jika phone tidak null, hilangkan prefix +62 atau 62
    if (rawPhone != null) {
      rawPhone = rawPhone.replaceAll(RegExp(r'^\+62'), '').replaceAll(RegExp(r'^62'), '');  // hapus prefix 62 juga
    }

    // Set ke controller dengan masking
    phoneController.text = rawPhone != null ? maskPhoneNumber(rawPhone) : "";
    emailController.text = profile?.email != null ? maskEmail(profile!.email!) : "";

    // Gender
    if (profile?.gender?.isNotEmpty ?? false) {
      jenisKelamin.text = profile!.gender!;
      editingMode(false);
    } else {
      editingMode(true);
    }

    // Address
    if (profile?.address?.isNotEmpty ?? false) {
      addressController.text = RegexFormatter.decodeHtmlTextManual(profile!.address!);
      editingMode(false);
    } else {
      editingMode(true);
    }

    // Country
    if (profile?.country?.isNotEmpty ?? false) {
      countryController.text = profile!.country!;
      editingMode(false);
    } else {
      editingMode(true);
    }

    // ZIP
    if (profile?.zip?.isNotEmpty ?? false) {
      zipController.text = profile!.zip!;
      editingMode(false);
    } else {
      editingMode(true);
    }    

    // Tempat Lahir
    if (profile?.tmptLahir?.isNotEmpty ?? false) {
      tempatLahir.text = profile!.tmptLahir!;
      editingMode(false);
    } else {
      editingMode(true);
    }

    // City
    if (profile?.city?.isNotEmpty ?? false) {
      kabupatenController.text = profile!.city!;
      editingMode(false);
    } else {
      editingMode(true);
    }

    if (profile?.tglLahir != null && profile!.tglLahir!.isNotEmpty) {
      final tgl = profile.tglLahir!.trim(); // hapus spasi
      if (tgl == "0000-00-00") {
        tanggalLahir.text = "2000-01-01";
        editingMode(true);  // bisa edit
      } else {
        tanggalLahir.text = tgl;
        editingMode(false); // tidak bisa edit
      }
    } else {
      editingMode(true);
    }
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final resultGet = await userController.getProfile();
      if (resultGet) {
        setProfileControllers();
      }
      setUserPlace();
    });
  }

  @override
  void dispose() {
    jenisKelamin.dispose();
    tempatLahir.dispose();
    tanggalLahir.dispose();
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    emailController.dispose();
    kabupatenController.dispose();
    countryController.dispose();
    zipController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar.defaultAppBar(
          title: "Edit Profilku",
          autoImplyLeading: true,
          actions: [
            SizedBox(
              height: 30,
              child: Obx(
                () => CustomOutlinedButton.defaultOutlinedButton(
                  title: userController.isLoading.value ? "Processing..." : "Simpan",
                  onPressed: userController.isLoading.value ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      if (jenisKelamin.text == "Laki-laki") jenisKelamin.text = "laki-laki";
                      if (jenisKelamin.text == "Perempuan") jenisKelamin.text = "perempuan";

                      final updated = await userController.updateProfile(
                        address: addressController.text,
                        gender: jenisKelamin.text,
                        dateOfBirth: selectedDateBirth.value == "" ? tanggalLahir.text : selectedDateBirth.value,
                        placeOfBirth: tempatLahir.text,
                        province: provinsiController.text,
                        city: kabupatenController.text,
                        district: kecamatanController.text,
                        village: desaController.text,
                        zipcode: zipController.text,
                      );

                      if (updated) {
                        final refreshed = await userController.getProfile();
                        if (refreshed) {
                          setState(() {
                            jenisKelamin.text = userController.profileModel.value?.gender ?? "-";
                            nameController.text = userController.profileModel.value?.name ?? "";
                            String? rawPhone = userController.profileModel.value?.phone;

                            // Jika phone tidak null, hilangkan prefix +62 atau 62
                            if (rawPhone != null) {
                              rawPhone = rawPhone.replaceAll(RegExp(r'^\+62'), '').replaceAll(RegExp(r'^62'), '');  // hapus prefix 62 juga
                            }

                            // Set ke controller dengan masking
                            phoneController.text = rawPhone != null ? maskPhoneNumber(rawPhone) : "";
                            emailController.text = userController.profileModel.value?.email != null ? maskEmail(userController.profileModel.value!.email!) : "";
                            addressController.text = userController.profileModel.value?.address != null ? RegexFormatter.decodeHtmlTextManual(userController.profileModel.value!.address!) : "";
                            countryController.text = userController.profileModel.value?.country ?? "";
                            zipController.text = userController.profileModel.value?.zip ?? "";
                            tanggalLahir.text = userController.profileModel.value?.tglLahir ?? "";
                            tempatLahir.text = userController.profileModel.value?.tmptLahir ?? "";
                          });
                        }
                        CustomScaffoldMessanger.showAppSnackBar(context, message: "Berhasil update profil", type: SnackBarType.success);
                      } else {
                        CustomScaffoldMessanger.showAppSnackBar(context, message: userController.responseMessage.value, type: SnackBarType.error);
                      }
                    } else {
                      CustomScaffoldMessanger.showAppSnackBar(context, message: "Form tidak boleh kosong", type: SnackBarType.error);
                    }
                  }
                ),
              ),
            ),
            const SizedBox(width: 10)
          ]
        ),
        body: Obx(
          () => RefreshIndicator(
            color: CustomColor.secondaryColor,
            onRefresh: isLoading.value ? ()async{} : () async {
              await userController.getProfile().then((resultGet){
                if(resultGet){
                  jenisKelamin.text = userController.profileModel.value?.gender ?? "-";
                  nameController.text = userController.profileModel.value?.name ?? "";
                  String? rawPhone = userController.profileModel.value?.phone;
                  if (rawPhone != null) {
                    rawPhone = rawPhone.replaceAll(RegExp(r'^\+62'), '').replaceAll(RegExp(r'^62'), '');  // hapus prefix 62 juga
                  }
                  phoneController.text = rawPhone != null ? maskPhoneNumber(rawPhone) : "";
                  emailController.text = userController.profileModel.value?.email != null ? maskEmail(userController.profileModel.value!.email!) : "";
                  addressController.text = userController.profileModel.value?.address != null ? RegexFormatter.decodeHtmlTextManual(userController.profileModel.value!.address!) : "";
                  countryController.text = userController.profileModel.value?.country ?? "";
                  zipController.text = userController.profileModel.value?.zip ?? "";
                  tanggalLahir.text = userController.profileModel.value?.tglLahir ?? "";
                  tempatLahir.text = userController.profileModel.value?.tmptLahir ?? "";
                }
              });
            },
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: UtilitiesWidget.titleContent(
                  title: "Edit Profile Saya",
                  subtitle: "Mohon untuk penuhi semua field profile anda agar anda bisa melakukan pembuatan akun trading",
                  children: [
                    NameTextField(controller: nameController, fieldName: "Nama Lengkap", hintText: "Nama Lengkap Saya", labelText: "Nama Lengkap Saya", useValidator: false, readOnly: true),
                    EmailTextField(controller: emailController, fieldName: "Alamat Email", hintText: "Alamat Email", labelText: "Alamat Email", readOnly: true, useValidator: false, useCustomOnchange: false),
                    PhoneTextField(controller: phoneController, fieldName: "Nomor WhatsApp", hintText: "Nomor WhatsApp", labelText: "Nomor WhatsApp", useValidator: false, readOnly: true),
                    Obx(
                      () => VoidTextField(controller: jenisKelamin, readOnly: editingMode.value ? false : jenisKelamin.text.isNotEmpty, useValidator: false, fieldName: "Jenis Kelamin", hintText: "Jenis Kelamin", labelText: "Jenis Kelamin", iconData: Bootstrap.gender_ambiguous, onPressed: () async {
                        CustomMaterialBottomSheets.defaultBottomSheet(context, isScrolledController: false, size: size, title: "Pilih jenis kelamin", children: List.generate(2, (i){
                          if(i == 0){
                            return ListTile(
                              onTap: (){
                                Navigator.pop(context);
                                jenisKelamin.text = "Laki-laki";
                              },
                              title: Text("Laki-laki", style: GoogleFonts.inter()),
                            );
                          }
                          return ListTile(
                            onTap: (){
                              Navigator.pop(context);
                              jenisKelamin.text = "Perempuan";
                            },
                            title: Text("Perempuan", style: GoogleFonts.inter()),
                          );
                        }));
                      }),
                    ),
                    Obx(
                      () => VoidTextField(
                        iconData: Clarity.calendar_line,
                        readOnly:  editingMode.value ? false : tanggalLahir.text.isNotEmpty,
                        controller: tanggalLahir,
                        fieldName: "Tanggal Lahir",
                        hintText: "Tanggal Lahir",
                        labelText: "Tanggal Lahir",
                        onPressed: () async {
                          DateTime? selected = await CustomDatePicker.material(context);
                          if (selected != null) {
                            tanggalLahir.text = CustomDatePicker.formatIndonesiaDate(selected);
                            selectedDateBirth(DateFormat('yyyy-MM-dd').format(selected));
                          }
                        },
                      ),
                    ),

                    Obx(() => NameTextFieldNewVersion(controller: tempatLahir, readOnly: editingMode.value ? false : tempatLahir.text.isNotEmpty, fieldName: "Tempat Lahir", hintText: "Tempat Lahir", labelText: "Tempat Lahir", useValidator: true, iconData: CupertinoIcons.placemark)),
                    Obx(
                      () => VoidTextField(
                        onPressed: wilayahController.isLoading.value || provinsiController.text.isNotEmpty  ? null : (){
                          CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, isScrolledController: true, title: "Pilih Provinsi", children: List.generate(wilayahController.listProvinsiModel.value?.response?.length ?? 0, (i){
                            return ListTile(
                              title: Text(wilayahController.listProvinsiModel.value?.response?[i].name ?? "", style: GoogleFonts.inter()),
                              onTap: () async {
                                Navigator.pop(context);
                                provinsiController.text = wilayahController.listProvinsiModel.value?.response?[i].name ?? "";
                                wilayahController.selectedProvince(wilayahController.listProvinsiModel.value?.response?[i].name ?? "");
                                await wilayahController.getKabupatenKota();
                              },
                            );
                          }));
                        },
                        controller: provinsiController, readOnly: provinsiController.text.isNotEmpty, fieldName: "Provinsi", hintText: "Provinsi", labelText: "Provinsi", iconData: CupertinoIcons.placemark),
                    ),
                    Obx(
                      () => VoidTextField(
                        onPressed: wilayahController.isLoading.value || kabupatenController.text.isNotEmpty ? null : (){
                          CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, isScrolledController: true, title: "Pilih Kabupaten", children: List.generate(wilayahController.listKotaModel.value?.response?.length ?? 0, (i){
                            return ListTile(
                              title: Text(wilayahController.listKotaModel.value?.response?[i].name ?? "", style: GoogleFonts.inter()),
                              onTap: () async {
                                Navigator.pop(context);
                                kabupatenController.text = wilayahController.listKotaModel.value?.response?[i].name ?? "";
                                wilayahController.selectedCity(wilayahController.listKotaModel.value?.response?[i].name ?? "");
                                await wilayahController.getKecamatan();
                              },
                            );
                          }));
                        },
                        controller: kabupatenController, readOnly: kabupatenController.text.isNotEmpty, fieldName: "Kabupaten", hintText: "Kabupaten", labelText: "Kabupaten", iconData: CupertinoIcons.placemark),
                    ),
                    Obx(
                      () => VoidTextField(
                        onPressed: wilayahController.isLoading.value || kecamatanController.text.isNotEmpty  ? null : (){
                          CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, isScrolledController: true, title: "Pilih Kecamatan", children: List.generate(wilayahController.listKecamatanModel.value?.response?.length ?? 0, (i){
                            return ListTile(
                              title: Text(wilayahController.listKecamatanModel.value?.response?[i].name ?? "", style: GoogleFonts.inter()),
                              onTap: () async{
                                Navigator.pop(context);
                                kecamatanController.text = wilayahController.listKecamatanModel.value?.response?[i].name ?? "";
                                wilayahController.selectedDistrict(wilayahController.listKecamatanModel.value?.response?[i].name ?? "");
                                await wilayahController.getDesa();
                              },
                            );
                          }));
                        },
                        controller: kecamatanController, readOnly: kecamatanController.text.isNotEmpty, fieldName: "Kecamatan", hintText: "Kecamatan", labelText: "Kecamatan", iconData: CupertinoIcons.placemark),
                    ),
                    Obx(
                      () => VoidTextField(
                        onPressed: wilayahController.isLoading.value || desaController.text.isNotEmpty ? null : (){
                          CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, isScrolledController: true, title: "Pilih Desa", children: List.generate(wilayahController.listDesaModel.value?.response?.length ?? 0, (i){
                            return ListTile(
                              title: Text(wilayahController.listDesaModel.value?.response?[i].name ?? "", style: GoogleFonts.inter()),
                              onTap: (){
                                Navigator.pop(context);
                                desaController.text = wilayahController.listDesaModel.value?.response?[i].name ?? "";
                                wilayahController.selectedSubDistrict(wilayahController.listDesaModel.value?.response?[i].name ?? "");
                                zipController.text = wilayahController.listDesaModel.value?.response?[i].postalCode ?? "";
                              },
                            );
                          }));
                        },
                        controller: desaController, readOnly: desaController.text.isNotEmpty, fieldName: "Desa", hintText: "Desa", labelText: "Desa", iconData: CupertinoIcons.placemark),
                    ),
                    Obx(() => DescriptiveTextField(controller: addressController, readOnly: editingMode.value ? false : addressController.text.isNotEmpty, fieldName: "Alamat Lengkap", hintText: "Alamat Lengkap Saya", labelText: "Alamat Lengkap Saya", useValidator: false, iconData: CupertinoIcons.placemark,)),
                    Obx(() => NameTextField(controller: countryController, readOnly: editingMode.value ? false : countryController.text.isNotEmpty, fieldName: "Country", hintText: "Country", labelText: "Country", useValidator: false, iconData: Icons.flag_outlined)),
                    NumberTextField(readOnly: true, controller: zipController, fieldName: "Kode Pos", hintText: "Kode Pos", labelText: "Kode Pos", maxLength: 5, useValidator: false),
                    // SizedBox(
                    //   width: double.infinity,
                    //   child: CustomOutlinedButton.defaultOutlinedButton(
                    //     onPressed: (){
                    //       Get.to(() => const MyBankPage());
                    //     },
                    //     title: "Edit Bank Profil Saya"
                    //   ),
                    // ),
                    const SizedBox(height: 40.0),
                  ]
                ),
              )
            ),
          ),
        ),
      ),
    );
  }
}
