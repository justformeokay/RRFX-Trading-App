import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/appbars/default.dart';
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
import 'package:rrfx/src/views/accounts/registration_online/repository/regol_repository.dart';
import 'package:rrfx/src/views/accounts/registration_online/views/step_14.dart';

class Step13 extends StatefulWidget {
  const Step13({super.key});

  @override
  State<Step13> createState() => _Step13State();
}

class _Step13State extends State<Step13> {

  StatementController controller = Get.find();
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
  TextEditingController pernyataanSimulasi = TextEditingController();
  TextEditingController namaPerusahaanPialang = TextEditingController();

  RxList<String> pernyataan = <String>["Ya", "Tidak"].obs;

  RegolController regolController = Get.find();
  HomeController userController = Get.find();
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
      kodePos.text = progressController.progressData.value?.response?.postalCode == "0" || progressController.progressData.value?.response?.postalCode == null ? "" : progressController.progressData.value!.response!.postalCode!;
      
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
    pernyataanSimulasi.dispose();
    namaPerusahaanPialang.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppBar.defaultAppBar(
        autoImplyLeading: true,
        title: "Step 13"
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            CustomText.titleMedium(context, text: "Formulir Dokumen Pernyataan Bertanggung Jawab Atas Kode Akses Transaksi Nasabah (Personal Access Password)"),
            const SizedBox(height: 15.0),
            CustomText.titleMedium(context, text: "PERNYATAAN BERTANGGUNG JAWAB ATAS KODE AKSES TRANSAKSI NASABAH (Personal Access Password)"),
            const SizedBox(height: 10.0),
            NameTextFieldNewVersion(
              controller: nama,
              requiredField: true,
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
              useValidator: false,
              requiredField: true,
              iconData: Clarity.number_list_line,
              controller: noIdentitas,
              readOnly: true,
              labelText: "Nomor Identitas",
              fieldName: "Nomor Identitas",
              hintText: "Nomor Identitas",
              maxLength: 16,
            ),
            const SizedBox(height: 15),
            StatementWidget.kodeAkses(context),
            const SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.4)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("PERINGATAN !", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 15),
                  Text("Pialang Berjangka, Wakil Pialang Berjangka, pegawai Pialang Berjangka, atau Pihak yang memiliki kepentingan dengan dengan Pialang Berjangka dilarang menerima kode akses transaksi Nasabah (Personal Access Password).", style: TextStyle(fontWeight: FontWeight.w700), textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: 15),
            CustomText.normal(context, text: "Demikian Pernyataan ini dibuat dengan sebenarnya dalam keadaan sadar, sehat jasmani dan rohani serta tanpa paksaan apapun dari pihak manapun"),
            TimeAndStatement(),
            const SizedBox(height: 10.0),
          ],
        ),
      ),
      bottomNavigationBar: ButtonNextPrevious(
        onPressed: () async {
          if(!controller.selectedStatement.value){
            CustomScaffoldMessanger.showAppSnackBar(context, message: "Mohon centang \"YA\" pada checkbox persetujuan profil perusahaan berjangka", type: SnackBarType.error);
            return;
          }
          bool result = await _regolRepository.step13();
          if(result) {
            Get.to(() => const Step14());
            return;
          }
          CustomScaffoldMessanger.showAppSnackBar(context, message: _regolRepository.responseMessage.value, type: SnackBarType.error);
        },
      )
    );
  }
}