import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/tables/pernyataan_persetujuan.dart';
import 'package:rrfx/src/components/textfields/descriptive_textfield.dart';
import 'package:rrfx/src/components/textfields/name_text_field_new.dart';
import 'package:rrfx/src/components/textfields/number_textfield.dart';
import 'package:rrfx/src/components/textfields/void_textfield.dart';
import 'package:rrfx/src/components/textstyles/default.dart';
import 'package:rrfx/src/controllers/home.dart';
import 'package:rrfx/src/controllers/regol.dart';
import 'package:rrfx/src/controllers/wilayah_controller.dart';
import 'package:rrfx/src/helpers/handlers/date_pickers.dart';
import 'package:rrfx/src/views/accounts/registration_online/components/button_next_previous.dart';
import 'package:rrfx/src/views/accounts/registration_online/components/time_and_statement.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/progress_account_controller.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/statement_controller.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/step_controller.dart';
import 'package:rrfx/src/views/accounts/registration_online/repository/regol_repository.dart';
import 'package:rrfx/src/views/accounts/registration_online/views/step_5.dart';

class Step4 extends StatefulWidget {
  const Step4({super.key});

  @override
  State<Step4> createState() => _Step4State();
}

class _Step4State extends State<Step4> {
  StatementController statementController = Get.find<StatementController>();
  final RegolRepository _regolRepository = Get.find<RegolRepository>();
  final progressController = Get.find<ProgressAccountController>();
  TextEditingController nama = TextEditingController();
  TextEditingController tempatLahir= TextEditingController();
  TextEditingController tanggalLahir= TextEditingController();
  TextEditingController alamatRumah = TextEditingController();
  TextEditingController provinsi = TextEditingController();
  TextEditingController kabupatenKota = TextEditingController();
  TextEditingController kecamatan = TextEditingController();
  TextEditingController desa = TextEditingController();
  TextEditingController kodePos = TextEditingController();
  TextEditingController rt = TextEditingController();
  TextEditingController rw = TextEditingController();
  TextEditingController tipeIdentitas = TextEditingController();
  TextEditingController noIdentitas = TextEditingController();
  TextEditingController noDemoAcc = TextEditingController();

  RxString selectedJenisIdentitas = "KTP".obs;
  RxString selectedStatusKepemilikanRumah = "Pribadi".obs;
  RxString selectedGender = "Laki-laki".obs;
  RxString selectedMaritalStatus = "Tidak Kawin".obs;
  RxList<String> statusKepemilikanRumah = <String>["Pribadi", "Keluarga", "Sewa/Kontrak", "Lainnya"].obs;
  RxList<String> genderList = <String>["Laki-laki", "Perempuan"].obs;
  RxList<String> maritalList = <String>["Tidak Kawin", "Kawin", "Janda", "Duda"].obs;
  final _formKey = GlobalKey<FormState>();
  RxInt lengthID = 1.obs;
  RxString rawDateBirth = ''.obs;

  RegolController regolController = Get.find();
  WilayahController wilayahController = Get.put(WilayahController());
  HomeController userController = Get.find();
  final controller = Get.find<StepController>();

  RxString simulasiAkunDemoURL = "".obs;
  RxBool isLoading = false.obs;
  RxBool selectedStatement = true.obs;
  RxBool imageLoaded = false.obs;

  // Loading states for cascading dropdowns
  RxBool provinsiLoading = true.obs;
  RxBool kabupatenLoading = false.obs;
  RxBool kecamatanLoading = false.obs;
  RxBool desaLoading = false.obs;

  @override
void initState() {
  super.initState();
  Future.delayed(Duration.zero, () async {
    await progressController.fetchProgressAccount();
    final tipeList = progressController.tipeIdentitasList;
    if (tipeList.isNotEmpty) {
      tipeIdentitas.text = tipeList.first;
    }
    tipeIdentitas.text = progressController.progressData.value?.response?.idType ?? tipeIdentitas.text;
    if (tipeIdentitas.text == "KTP") {
      lengthID(16);
    } else if (tipeIdentitas.text == "PASSPORT") {
      lengthID(9);
    } else if (tipeIdentitas.text == "KITAS") {
      lengthID(20);
    } else {
      lengthID(100);
    }
    nama.text = progressController.progressData.value?.response?.namaLengkap ?? userController.profileModel.value?.name ?? '';
    noIdentitas.text = progressController.progressData.value?.response?.idNumber ?? '';
    tempatLahir.text = progressController.progressData.value?.response?.placeOfBirth ?? '';
    if(progressController.progressData.value?.response?.dateOfBirth != null){
      final parsedDate = DateFormat("EEEE, dd MMMM yyyy", "id_ID").format(DateTime.parse(progressController.progressData.value!.response!.dateOfBirth!));
      tanggalLahir.text = parsedDate;
    }
    regolController.isLoading(true);
    rt.text = progressController.progressData.value?.response?.rt ?? '';
    rw.text = progressController.progressData.value?.response?.rw ?? '';
    alamatRumah.text = progressController.progressData.value?.response?.address ?? "";
    provinsi.text = progressController.progressData.value?.response?.province ?? "";
    wilayahController.selectedProvince.value = provinsi.text;
    kabupatenKota.text = progressController.progressData.value?.response?.city ?? "";
    wilayahController.selectedCity.value = kabupatenKota.text;
    kecamatan.text = progressController.progressData.value?.response?.district ?? "";
    wilayahController.selectedDistrict.value = kecamatan.text;
    desa.text = progressController.progressData.value?.response?.village ?? "";
    wilayahController.selectedSubDistrict.value = desa.text;
    kodePos.text = progressController.progressData.value?.response?.postalCode == "0" || progressController.progressData.value?.response?.postalCode == null ? "" : progressController.progressData.value!.response!.postalCode!;
    wilayahController.getProvinsi().then((resultProvince) {
      if (!resultProvince) {
        CustomScaffoldMessanger.showAppSnackBar(context, message: wilayahController.responseMessage.value, type: SnackBarType.error);
      }
      // Enable provinsi field ketika data sudah didapat
      provinsiLoading.value = false;
    });
    await controller.fetchAccounts();
    if (controller.accounts.isEmpty) {
      Get.log("ACCOUNTS IS NULL");
      return;
    }
    for (int i = 0; i < controller.accounts.length; i++) {
      if (controller.accounts[i].type == 'demo') {
        noDemoAcc.text = controller.accounts[i].login;
      }
    }
    regolController.isLoading(false);
  });
}



  @override
  void dispose() {
    nama.dispose();
    tempatLahir.dispose();
    tanggalLahir.dispose();
    alamatRumah.dispose();
    provinsi.dispose();
    kabupatenKota.dispose();
    kecamatan.dispose();
    desa.dispose();
    kodePos.dispose();
    rt.dispose();
    rw.dispose();
    tipeIdentitas.dispose();
    noIdentitas.dispose();
    noDemoAcc.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar.defaultAppBar(
          autoImplyLeading: true,
          title: "Step 4"
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText.titleHeadingPage(context, text: "FORMULIR PERNYATAAN TELAH MELAKUKAN SIMULASI PERDAGANGAN BERJANGKA KOMODITI"),
                  const SizedBox(height: 10.0),
                  const Divider(height: 1, thickness: 0.5),
                  const SizedBox(height: 10.0),
                  CustomText.normal(context, text: "Yang mengisi formulir di bawah ini:", align: TextAlign.start),
                  const SizedBox(height: 10.0),
                  NameTextFieldNewVersion(
                    controller: nama,
                    requiredField: true,
                    readOnly: false,
                    labelText: "Nama Lengkap",
                    fieldName: "Nama Lengkap",
                    hintText: "Mohon isi Nama Lengkap",
                    maxLength: 50,
                  ),
                  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: NameTextFieldNewVersion(
                          iconData: CupertinoIcons.placemark,
                          controller: tempatLahir,
                          requiredField: true,
                          readOnly: false,
                          labelText: "Tempat Lahir",
                          fieldName: "Tempat Lahir",
                          hintText: "Tempat Lahir",
                          maxLength: 20,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: VoidTextField(
                          requiredField: true,
                          iconData: Clarity.calendar_line,
                          controller: tanggalLahir,
                          readOnly: false,
                          labelText: "Tanggal Lahir",
                          fieldName: "Tanggal Lahir",
                          hintText: "Tanggal Lahir",
                          onPressed: () async{
                            DateTime? selected;
                            selected = await CustomDatePicker.material(context);
                            if(selected != null){
                              tanggalLahir.text = CustomDatePicker.formatIndonesiaDate(selected);
                              rawDateBirth.value = DateFormat('yyyy-MM-dd').format(selected);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  DescriptiveTextField(
                    requiredField: true,
                    useValidator: false,
                    iconData: Clarity.home_line,
                    controller: alamatRumah,
                    labelText: "Alamat Rumah",
                    fieldName: "Alamat Rumah",
                    hintText: "Input Alamat Rumah",
                  ),
                  const SizedBox(height: 10.0),
                  // Province
                  Obx(
                    () => VoidTextField(
                      requiredField: true, 
                      controller: provinsi, 
                      readOnly: provinsiLoading.value, 
                      fieldName: "Provinsi", 
                      hintText: provinsiLoading.value ? "Memuat data..." : "Provinsi", 
                      labelText: "Provinsi", 
                      iconData: Clarity.map_line, 
                      onPressed: provinsiLoading.value ? null : () {
                        CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Pilih Provinsi Anda", children: List.generate(wilayahController.listProvinsiModel.value?.response?.length ?? 0, (i){
                          return ListTile(
                            leading: Icon(Icons.location_city_outlined, color: CustomColor.textThemeDarkSoftColor),
                            title: Text(wilayahController.listProvinsiModel.value?.response?[i].name ?? "-"),
                            onTap: (){
                              wilayahController.selectedCity.value = '';
                              wilayahController.selectedDistrict.value = '';
                              wilayahController.selectedSubDistrict.value = '';
                              kabupatenKota.clear();
                              kecamatan.clear();
                              desa.clear();
                              kodePos.clear();
                              Navigator.pop(context);
                              provinsi.text = wilayahController.listProvinsiModel.value?.response?[i].name ?? "-";
                              wilayahController.selectedProvince.value = provinsi.text;
                              
                              // Enable kabupaten dan start loading
                              kabupatenLoading.value = true;
                              wilayahController.getKabupatenKota().then((_) {
                                kabupatenLoading.value = false;
                              });
                            },
                          );
                        }));
                      },
                    ),
                  ),
              
                  // Kabupaten
                  Obx(
                    () => VoidTextField(
                      requiredField: true, 
                      controller: kabupatenKota, 
                      readOnly: kabupatenLoading.value || wilayahController.selectedProvince.value == "", 
                      fieldName: "Kabupaten", 
                      hintText: kabupatenLoading.value ? "Memuat data..." : "Kabupaten", 
                      labelText: "Kabupaten", 
                      iconData: Clarity.map_line, 
                      onPressed: (kabupatenLoading.value || wilayahController.selectedProvince.value == "") ? null : () {
                        if(wilayahController.selectedProvince.value == ''){
                          CustomScaffoldMessanger.showAppSnackBar(context, message: "Mohon pilih Provinsi terlebih dahulu");
                          return;
                        }
                        CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Pilih Kabupaten Anda", children: List.generate(wilayahController.listKotaModel.value?.response?.length ?? 0, (i){
                          return ListTile(
                            leading: Icon(Icons.location_city_outlined, color: CustomColor.textThemeDarkSoftColor),
                            title: Text(wilayahController.listKotaModel.value?.response?[i].name ?? "-"),
                            onTap: (){
                              wilayahController.selectedDistrict.value = '';
                              wilayahController.selectedSubDistrict.value = '';
                              kecamatan.clear();
                              desa.clear();
                              kodePos.clear();
                              Navigator.pop(context);
                              kabupatenKota.text = wilayahController.listKotaModel.value?.response?[i].name ?? "-";
                              wilayahController.selectedCity.value = kabupatenKota.text;
                              
                              // Enable kecamatan dan start loading
                              kecamatanLoading.value = true;
                              wilayahController.getKecamatan().then((_) {
                                kecamatanLoading.value = false;
                              });
                            },
                          );
                        }));
                      },
                    ),
                  ),
              
                  // Kecamatan
                  Obx(
                    () => VoidTextField(
                      requiredField: true, 
                      controller: kecamatan, 
                      readOnly: kecamatanLoading.value || wilayahController.selectedCity.value == "", 
                      fieldName: "Kecamatan", 
                      hintText: kecamatanLoading.value ? "Memuat data..." : "Kecamatan", 
                      labelText: "Kecamatan", 
                      iconData: Clarity.map_line, 
                      onPressed: (kecamatanLoading.value || wilayahController.selectedCity.value == "") ? null : () {
                        if(wilayahController.selectedCity.value == ''){
                          CustomScaffoldMessanger.showAppSnackBar(context, message: "Mohon pilih Kabupaten terlebih dahulu");
                          return;
                        }
                        CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Pilih Kecamatan Anda", children: List.generate(wilayahController.listKecamatanModel.value?.response?.length ?? 0, (i){
                          return ListTile(
                            leading: Icon(Icons.location_city_outlined, color: CustomColor.textThemeDarkSoftColor),
                            title: Text(wilayahController.listKecamatanModel.value?.response?[i].name ?? "-"),
                            onTap: (){
                              wilayahController.selectedSubDistrict.value = '';
                              desa.clear();
                              kodePos.clear();
                              Navigator.pop(context);
                              kecamatan.text = wilayahController.listKecamatanModel.value?.response?[i].name ?? "-";
                              wilayahController.selectedDistrict.value = kecamatan.text;
                              
                              // Enable desa dan start loading
                              desaLoading.value = true;
                              wilayahController.getDesa().then((_) {
                                desaLoading.value = false;
                              });
                            },
                          );
                        }));
                      },
                    ),
                  ),
              
                  // Desa
                  Obx(
                    () => VoidTextField(
                      requiredField: true, 
                      controller: desa, 
                      fieldName: "Desa", 
                      readOnly: desaLoading.value || wilayahController.selectedDistrict.value == "", 
                      iconData: Icons.holiday_village_rounded, 
                      hintText: desaLoading.value ? "Memuat data..." : "Desa", 
                      labelText: "Desa", 
                      onPressed: (desaLoading.value || wilayahController.selectedDistrict.value == "") ? null : () {
                        if(wilayahController.selectedDistrict.value == ''){
                          CustomScaffoldMessanger.showAppSnackBar(context, message: "Mohon pilih Kecamatan terlebih dahulu");
                          return;
                        }
                        CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Pilih Desa Anda", children: List.generate(wilayahController.listDesaModel.value?.response?.length ?? 0, (i){
                          return ListTile(
                            leading: Icon(Icons.location_city_outlined, color: CustomColor.textThemeDarkSoftColor),
                            title: Text(wilayahController.listDesaModel.value?.response?[i].name ?? "-"),
                            onTap: (){
                              Navigator.pop(context);
                              desa.text = wilayahController.listDesaModel.value?.response?[i].name ?? "-";
                              wilayahController.selectedSubDistrict.value = desa.text;
                              kodePos.text = wilayahController.listDesaModel.value?.response?[i].postalCode ?? "-";
                            },
                          );
                        }));
                      },
                    ),
                  ),
              
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: NumberTextField(
                          useValidator: false,
                          iconData: Clarity.number_list_line,
                          controller: rt,
                          readOnly: false,
                          labelText: "RT",
                          fieldName: "RT",
                          hintText: "RT",
                          maxLength: 3,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: NumberTextField(
                          useValidator: false,
                          iconData: Clarity.number_list_line,
                          controller: rw,
                          readOnly: false,
                          labelText: "RW",
                          fieldName: "RW",
                          hintText: "RW",
                          maxLength: 3,
                        ),
                      ),
                    ],
                  ),
              
                  // Tipe Identitas
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 83,
                        width: size.width / 3,
                        child: NumberTextField(
                          requiredField: true,
                          useValidator: false,
                          iconData: Clarity.number_list_line,
                          controller: kodePos,
                          readOnly: false,
                          labelText: "Kode Pos",
                          fieldName: "Kode Pos",
                          hintText: "Kode Pos",
                          maxLength: 16,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Obx(() {
                          final tipeList = progressController.tipeIdentitasList;
                          final isLoading = progressController.isLoading.value;
                          if (isLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (tipeList.isEmpty) {
                            return VoidTextField(
                              requiredField: true,
                              controller: tipeIdentitas,
                              readOnly: false,
                              fieldName: "Tipe Identitas",
                              iconData: EvaIcons.credit_card,
                              hintText: "Data tidak tersedia",
                              labelText: "Tipe Identitas",
                            );
                          }
                          return VoidTextField(
                            requiredField: true,
                            controller: tipeIdentitas,
                            readOnly: false, // tetap readonly, biar user pilih lewat bottom sheet
                            fieldName: "Tipe Identitas",
                            iconData: EvaIcons.credit_card,
                            hintText: "Pilih tipe identitas",
                            labelText: "Tipe Identitas",
                            onPressed: () {
                              CustomMaterialBottomSheets.defaultBottomSheet(
                                context,
                                size: size,
                                title: "Pilih Tipe Identitas Anda",
                                children: List.generate(tipeList.length, (i) {
                                  return ListTile(
                                    title: Text(tipeList[i]),
                                    onTap: () {
                                      setState(() {
                                        noIdentitas.clear();
                                        tipeIdentitas.text = tipeList[i];
                                        if (tipeList[i] == "KTP") {
                                          lengthID(16);
                                        } else if (tipeList[i] == "PASSPORT") {
                                          lengthID(9);
                                        } else if (tipeList[i] == "KITAS") {
                                          lengthID(20);
                                        } else {
                                          lengthID(100);
                                        }
                                      });
                                      Navigator.pop(context);
                                    },
                                  );
                                }),
                              );
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                  Obx(() {
                    // Tentukan input formatter sesuai tipe ID
                    List<TextInputFormatter> inputFormatters = [];

                    if (tipeIdentitas.text == "KITAS") {
                      // Hanya huruf (a-z, A-Z), angka (0-9), dan tanda "-"
                      inputFormatters = [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-]')),
                      ];
                    } else if(tipeIdentitas.text == "PASSPORT"){
                      inputFormatters = [
                        FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9-]+$')),
                      ];
                    } else {
                      // Selain KITAS → hanya angka
                      inputFormatters = [
                        FilteringTextInputFormatter.digitsOnly,
                      ];
                    }

                    final Widget labelWidget = RichText(
                      text: TextSpan(
                        text: "Nomor Identitas",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        children: [
                          const TextSpan(
                            text: " *",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );

                    return TextFormField(
                      controller: noIdentitas,
                      readOnly: tipeIdentitas.text.isEmpty || tipeIdentitas.text == "-",
                      maxLength: lengthID.value,
                      inputFormatters: inputFormatters,
                      keyboardType: tipeIdentitas.text == "KITAS"
                        ? TextInputType.text
                        : tipeIdentitas.text == "PASSPORT"
                            ? TextInputType.text
                            : TextInputType.number,
                      decoration: InputDecoration(
                        label: labelWidget,
                        prefixIconColor: CustomColor.textThemeDarkSoftColor,
                        prefixIcon: SizedBox(width: 30, child: Icon(Icons.credit_card)),
                        labelStyle: const TextStyle(color: CustomColor.textThemeDarkSoftColor),
                        hintText: tipeIdentitas.text == "KITAS"
                          ? "Masukkan nomor KITAS (huruf, angka, atau simbol)"
                          : tipeIdentitas.text == "Passport"
                              ? "Masukkan nomor Passport (huruf atau angka)"
                              : "Masukkan nomor KTP (angka saja)",
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

                        if (tipeIdentitas.text == "KITAS") {
                          if (!RegExp(r'^[a-zA-Z0-9\-]+$').hasMatch(value)) {
                            return "Nomor KITAS hanya boleh huruf, angka, dan tanda -";
                          }
                        } else if(tipeIdentitas.text == "PASSPORT"){
                          final regex = RegExp(r'^[a-zA-Z0-9-]+$');
                          if (!regex.hasMatch(value)) {
                            return "Nomor Passport hanya boleh huruf, angka, dan tanda -";
                          }
                        } else {
                          if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return "Nomor identitas hanya boleh angka";
                          }
                        }
                        return null;
                      },
                    );
                  }),
                  StatementWidget.pernyataanTelahMelakukanSimulasi(dynamicTitlePart: "PT. RRFX Investasi Berjangka"),
                  TimeAndStatement(),
                ],
              ),
            ),
          )
        ),
        bottomNavigationBar: ButtonNextPrevious(
          onPressed: () async {
            // Validasi semua field yang wajib diisi
            final List<Map<String, String>> emptyFields = [];

            if (nama.text.isEmpty) emptyFields.add({'field': 'Nama Lengkap', 'icon': '👤'});
            if (tempatLahir.text.isEmpty) emptyFields.add({'field': 'Tempat Lahir', 'icon': '📍'});
            if (tanggalLahir.text.isEmpty) emptyFields.add({'field': 'Tanggal Lahir', 'icon': '📅'});
            if (alamatRumah.text.isEmpty) emptyFields.add({'field': 'Alamat Rumah', 'icon': '🏠'});
            if (provinsi.text.isEmpty) emptyFields.add({'field': 'Provinsi', 'icon': '🗺️'});
            if (kabupatenKota.text.isEmpty) emptyFields.add({'field': 'Kabupaten/Kota', 'icon': '🏙️'});
            if (kecamatan.text.isEmpty) emptyFields.add({'field': 'Kecamatan', 'icon': '🏘️'});
            if (desa.text.isEmpty) emptyFields.add({'field': 'Desa', 'icon': '🌾'});
            if (kodePos.text.isEmpty) emptyFields.add({'field': 'Kode Pos', 'icon': '📬'});
            if (tipeIdentitas.text.isEmpty || tipeIdentitas.text == "-") emptyFields.add({'field': 'Tipe Identitas', 'icon': '🆔'});
            if (noIdentitas.text.isEmpty) emptyFields.add({'field': 'Nomor Identitas', 'icon': '📋'});

            // Jika ada field yang kosong, tampilkan dialog modern
            if (emptyFields.isNotEmpty) {
              _showValidationDialog(context, emptyFields);
              return;
            }

            if (_formKey.currentState!.validate()) {
              try {
                final inputDate = tanggalLahir.text.trim();
                final parsedDate = DateFormat("EEEE, dd MMMM yyyy", "id_ID").parse(inputDate);

                // Ubah ke format API-friendly: yyyy-MM-dd
                final formattedDate = DateFormat("yyyy-MM-dd").format(parsedDate);
                if (!statementController.selectedStatement.value) {
                  CustomScaffoldMessanger.showAppSnackBar(
                    context,
                    message: "Mohon centang \"YA\" pada checkbox persetujuan profil perusahaan berjangka",
                    type: SnackBarType.error,
                  );
                  return;
                }
                print("Nama Lengkap: ${nama.text}");

                bool result = await _regolRepository.step4(
                  alamatRumah: alamatRumah.text,
                  desa: desa.text,
                  kabupatenKota: kabupatenKota.text,
                  kecamatan: kecamatan.text,
                  kodePos: kodePos.text,
                  namaLengkap: nama.text,
                  nomorIdentitas: noIdentitas.text,
                  provinsi: provinsi.text,
                  rt: rt.text,
                  rw: rw.text,
                  tempatLahir: tempatLahir.text,
                  tanggalLahir: formattedDate,
                  tipeIdentitas: tipeIdentitas.text,
                );

                if (result) {
                  Get.to(() => const Step5());
                  return;
                }

                CustomScaffoldMessanger.showAppSnackBar(
                  context,
                  message: _regolRepository.responseMessage.value,
                  type: SnackBarType.error,
                );
              } catch (e) {
                print("❌ Gagal memformat tanggal: $e");
                CustomScaffoldMessanger.showAppSnackBar(
                  context,
                  message: "Format tanggal tidak valid. Gunakan format seperti: Kamis, 11 November 1999",
                  type: SnackBarType.error,
                );
              }
              return;
            }

            CustomScaffoldMessanger.showAppSnackBar(
              context,
              message: "Mohon isi semua field",
            );
          },
        ),
      )
    );
  }

  /// Modern validation dialog yang informatif
  void _showValidationDialog(
    BuildContext context,
    List<Map<String, String>> emptyFields,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final colorScheme = Theme.of(context).colorScheme;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isDark ? colorScheme.surface : Colors.white,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header dengan icon
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.withOpacity(0.15),
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        size: 40,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      'Field Wajib Diisi',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? colorScheme.onSurface
                            : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // Description
                    Text(
                      'Mohon lengkapi ${emptyFields.length} field berikut sebelum melanjutkan',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? colorScheme.onSurfaceVariant
                            : Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // List of empty fields
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isDark
                            ? colorScheme.surfaceVariant.withOpacity(0.5)
                            : Colors.grey.shade100,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Column(
                        children: List.generate(
                          emptyFields.length,
                          (index) {
                            final field = emptyFields[index];
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  Text(
                                    field['icon'] ?? '•',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      field['field'] ?? 'Unknown field',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? colorScheme.onSurface
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.priority_high_rounded,
                                    size: 18,
                                    color: Colors.red.shade400,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Close button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColor.secondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Kembali dan Lengkapi',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}