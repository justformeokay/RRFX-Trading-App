import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
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
import 'package:rrfx/src/views/accounts/registration_online/components/button_next_previous.dart';
import 'package:rrfx/src/views/accounts/registration_online/components/time_and_statement.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/progress_account_controller.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/statement_controller.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/step_controller.dart';
import 'package:rrfx/src/views/accounts/registration_online/repository/regol_repository.dart';
import 'package:rrfx/src/views/accounts/registration_online/views/step_6.dart';

class Step5 extends StatefulWidget {
  const Step5({super.key});

  @override
  State<Step5> createState() => _Step5State();
}

class _Step5State extends State<Step5> {
  HomeController userController = Get.find();
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
  TextEditingController pernyataanPengalaman = TextEditingController();
  TextEditingController namaPerusahaanPialang = TextEditingController();

  RxList<String> pernyataan = <String>["Ya", "Tidak"].obs;

  RegolController regolController = Get.find();
  final controller = Get.find<StepController>();
  WilayahController wilayahController = Get.put(WilayahController());

  DateTime now = DateTime.now();

  Stream<DateTime> timeStream() {
    return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await progressController.fetchProgressAccount();
      nama.text = progressController.progressData.value?.response?.namaLengkap ?? userController.profileModel.value?.name ?? '';
      tipeIdentitas.text = progressController.progressData.value?.response?.idType ?? '-';
      noIdentitas.text = progressController.progressData.value?.response?.idNumber ?? '-';
      tempatLahir.text = progressController.progressData.value?.response?.placeOfBirth ?? '-';
      tanggalLahir.text = progressController.progressData.value?.response?.dateOfBirth ?? '-';
      regolController.isLoading(true);
      rt.text = progressController.progressData.value?.response?.rt ?? '';
      rw.text = progressController.progressData.value?.response?.rw ?? '';
      alamatRumah.text = progressController.progressData.value?.response?.address ?? "";
      provinsi.text = progressController.progressData.value?.response?.province ?? "";
      kabupatenKota.text = progressController.progressData.value?.response?.city ?? "";
      kecamatan.text = progressController.progressData.value?.response?.district ?? "";
      desa.text = progressController.progressData.value?.response?.village ?? "";
      kodePos.text = progressController.progressData.value?.response?.postalCode ?? "";
      wilayahController.getProvinsi().then((resultProvince){
        if(!resultProvince){
          CustomScaffoldMessanger.showAppSnackBar(context, message: wilayahController.responseMessage.value, type: SnackBarType.error);
        }
      });
      setState(() {
        pernyataanPengalaman.text = progressController.progressData.value?.response?.pengalamanInvestasi ?? 'Ya';
        if(pernyataanPengalaman.text == "Ya" || pernyataanPengalaman.text == "ya" || pernyataanPengalaman.text == "YA"){
          namaPerusahaanPialang.text = "PT. RRFX Investasi Berjangka";
        }
      });
      await controller.fetchAccounts();
      if (controller.accounts.isEmpty) {
        Get.log("ACCOUNTS IS NULL");
        return;
      }
      for(int i = 0; i < controller.accounts.length; i++){
        if(controller.accounts[i].type == 'demo'){
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
    pernyataanPengalaman.dispose();
    namaPerusahaanPialang.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final controller = Get.put(StatementController());
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar.defaultAppBar(
          autoImplyLeading: true,
          title: "Step 5"
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText.titleHeadingPage(context, text: "FORMULIR PERNYATAAN TELAH BERPENGALAMAN MELAKSANAKAN TRANSAKSI PERDAGANGAN BERJANGKA KOMODITI"),
                const SizedBox(height: 10.0),
                const Divider(height: 1, thickness: 0.5),
                const SizedBox(height: 10.0),
                CustomText.normal(context, text: "Yang mengisi formulir di bawah ini:", align: TextAlign.start),
                const SizedBox(height: 10.0),
                NameTextFieldNewVersion(
                  controller: nama,
                  readOnly: true,
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
                        requiredField: true,
                        readOnly: true,
                        iconData: CupertinoIcons.placemark,
                        controller: tempatLahir,
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
                        readOnly: true,
                        iconData: Clarity.calendar_line,
                        controller: tanggalLahir,
                        labelText: "Tanggal Lahir",
                        fieldName: "Tanggal Lahir",
                        hintText: "Tanggal Lahir",
                        onPressed: (){},
                      ),
                    ),
                  ],
                ),
                DescriptiveTextField(
                  readOnly: true,
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
                VoidTextField(requiredField: true, controller: provinsi, fieldName: "Provinsi", hintText: "Provinsi", labelText: "Provinsi", iconData: Clarity.map_line, onPressed: (){}),

                // Kabupaten
                VoidTextField(requiredField: true, controller: kabupatenKota, fieldName: "Kabupaten", hintText: "Kabupaten", labelText: "Kabupaten", iconData: Clarity.map_line, onPressed: (){}),

                // Kecamatan
                VoidTextField(requiredField: true, controller: kecamatan, fieldName: "Kecamatan", hintText: "Kecamatan", labelText: "Kecamatan", iconData: Clarity.map_line, onPressed: (){}),

                // Desa
                VoidTextField(requiredField: true, controller: desa, fieldName: "Desa", iconData: Icons.holiday_village_rounded, hintText: "Desa", labelText: "Desa", onPressed: (){}),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: NumberTextField(
                        useValidator: false,
                        readOnly: true,
                        iconData: Clarity.number_list_line,
                        controller: rt,
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
                        readOnly: true,
                        iconData: Clarity.number_list_line,
                        controller: rw,
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
                        readOnly: true,
                        iconData: Clarity.number_list_line,
                        controller: kodePos,
                        labelText: "Kode Pos",
                        fieldName: "Kode Pos",
                        hintText: "Kode Pos",
                        maxLength: 16,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: VoidTextField(requiredField: true, controller: tipeIdentitas, fieldName: "Tipe Identitas", iconData: EvaIcons.credit_card, hintText: "Tipe Identitas", labelText: "Tipe Identitas", onPressed: (){}),
                    ),
                  ],
                ),
                NumberTextField(
                  requiredField: true,
                  useValidator: false,
                  iconData: Clarity.number_list_line,
                  controller: noIdentitas,
                  readOnly: true,
                  labelText: "Nomor Identitas",
                  fieldName: "Nomor Identitas",
                  hintText: "Nomor Identitas",
                  maxLength: 16,
                ),
                // NameTextFieldNewVersion(
                //   iconData: Clarity.number_list_line,
                //   controller: noDemoAcc,
                //   readOnly: true,
                //   labelText: "No. Demo Acc",
                //   fieldName: "No. Demo Acc",
                //   hintText: "No. Demo Acc",
                //   maxLength: 20,
                // ),
                VoidTextField(requiredField: true, controller: pernyataanPengalaman, fieldName: "Pernyataan Pengalaman", hintText: "Pernyataan Pengalaman", readOnly: false, labelText: "Pernyataan Pengalaman", onPressed: (){
                  CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, title: "Pilih Pernyataan Pengalaman Investasi", children: List.generate(pernyataan.length, (i){
                    return ListTile(
                      leading: Icon(Icons.check_circle_outline, color: pernyataanPengalaman.text == pernyataan[i] ? CustomColor.secondaryColor : CustomColor.textThemeDarkSoftColor),
                      title: Text(pernyataan[i]),
                      onTap: (){
                        setState(() {
                          pernyataanPengalaman.text = pernyataan[i];
                          if(pernyataanPengalaman.text == "Ya" || pernyataanPengalaman.text == "ya" || pernyataanPengalaman.text == "YA"){
                            namaPerusahaanPialang.text = "PT. RRFX Investasi Berjangka";
                          }
                        });
                        Navigator.pop(context);
                      },
                    );
                  }));
                }),
                pernyataanPengalaman.text == "Ya" || pernyataanPengalaman.text == "ya" || pernyataanPengalaman.text == "YA" ? NameTextFieldNewVersion(
                  requiredField: true,
                  iconData: Clarity.building_line,
                  controller: namaPerusahaanPialang,
                  labelText: "Nama Perusahaan Pialang",
                  fieldName: "Nama Perusahaan Pialang",
                  hintText: "Nama Perusahaan Pialang",
                  maxLength: 50,
                ) : const SizedBox(),
                StatementWidget.pernyataanTelahBerpengalaman(),
                TimeAndStatement(),
              ],
            ),
          )
        ),
        bottomNavigationBar: ButtonNextPrevious(
          onPressed: () async {
            if(pernyataanPengalaman.text == "") return AppSnackbar.error("Mohon pilih Pernyataan Pengalaman Investasi");
            if(pernyataanPengalaman.text == "Ya" || pernyataanPengalaman.text == "ya" || pernyataanPengalaman.text == "YA"){
              if(namaPerusahaanPialang.text == "") return AppSnackbar.error("Mohon isi Nama Perusahaan Pialang");
            }
            if(!controller.selectedStatement.value) return AppSnackbar.error("Mohon centang pernyataan di atas.");
            bool result = await _regolRepository.step5(
              pengalamanInvestasi: pernyataanPengalaman.text,
              namaPerusahaan: namaPerusahaanPialang.text
            );
          if(result) {
            Get.to(() => const Step6());
            return;
          }
          CustomScaffoldMessanger.showAppSnackBar(context, message: _regolRepository.responseMessage.value, type: SnackBarType.error);
          },
        )
      )
    );
  }
}