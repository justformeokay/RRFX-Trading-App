import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/tables/number_text_list.dart';
import 'package:rrfx/src/components/tables/pernyataan_persetujuan.dart';
import 'package:rrfx/src/components/textstyles/default.dart';
import 'package:rrfx/src/controllers/home.dart';
import 'package:rrfx/src/views/accounts/registration_online/components/button_next_previous.dart';
import 'package:rrfx/src/views/accounts/registration_online/components/time_and_statement.dart';
import 'package:rrfx/src/views/accounts/registration_online/components/today_statement.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/progress_account_controller.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/statement_controller.dart';
import 'package:rrfx/src/views/accounts/registration_online/repository/regol_repository.dart';
import 'package:rrfx/src/views/accounts/registration_online/views/step_17.dart';

class Step15 extends StatefulWidget {
  const Step15({super.key});

  @override
  State<Step15> createState() => _Step15State();
}

class _Step15State extends State<Step15> {

  StatementController controller = Get.find();
  HomeController userController = Get.find();
  final RegolRepository _regolRepository = Get.find<RegolRepository>();
  final progressController = Get.find<ProgressAccountController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.defaultAppBar(
        autoImplyLeading: true,
        title: "Step 15"
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            CustomText.normal(context, text: "SURAT PERNYATAAN"),
            Obx(
              () => Pernyataan(
                name1: userController.profileModel.value?.name ?? "-",
                jenisIdentitas: progressController.progressData.value?.response?.idType ?? "-",
                alamat: progressController.progressData.value?.response?.address ?? "-",
                nomorIdentitas: progressController.progressData.value?.response?.idNumber ?? '0',
                wakilPialang: "Rachmat Setiyadi",
                companyName: "PT RRFX Investasi Berjangka",
              ),
            ),
            NumberedTextList(
              withIndex: true,
              subtitle: '',
              items: [
                'Telah sepenuhnya membaca, mengerti, serta memahami penjelasan mengenai isi dokumen Perjanjian Pemberian Amanat Nasabah, dokumen Pemberitahuan Adanya Risiko, serta semua ketentuan dan peraturan perdagangan (tradingrules);',
                'Telah menerima penjelasan dan mengerti bahwa hanya Wakil Pialang Berjangka yang berhak menjelaskan dokumen Pemberitahuan Adanya Risiko, dokumen Perjanjian Pemberian Amanat, serta peraturan perdagangan (tradingrules);',
                'TIDAK ADA PENDAPATAN TETAP (FIXED INCOME) dalam Perdagangan Berjangka.',
                'Telah menerima penjelasan dan mengerti bahwa user id dan password bersifat pribadi dan rahasia sehingga tidak akan menyerahkan kepada pihak manapun termasuk kepada Wakil Pialang Berjangka, pihak yang dipekerjakan maupun pihak yang diberdayakan Pialang Berjangka, segala risiko akibat penyerahan user id dan password kepada pihak lain menjadi tanggung jawab saya; dan',
                'Telah menerima penjelasan dan mengerti mekanisme penyelesaian perselisihan dan pilihan tempat penyelesaian perselisihan yakni melalui Badan Arbitrase atau Pengadilan Negeri.',
              ],
            ),
            CustomText.normal(context, text: "Terhadap apa yang saya jalankan dalam transaksi ini berikut segala risiko yang akan timbul akibat transaksi sepenuhnya akan menjadi tanggung jawab saya."),
            StatementWidget.suratPernyataan(),
            const SizedBox(height: 10.0),
            CustomText.normal(context, text: "Demikian surat pernyataan ini saya buat dalam keadaan sadar, sehat jasmani dan rohani serta tanpa paksaan dari pihakmanapun."),
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
          bool result = await _regolRepository.step15();
          if(result) {
            Get.to(() => Step17());
            return;
          }
          CustomScaffoldMessanger.showAppSnackBar(context, message: _regolRepository.responseMessage.value, type: SnackBarType.error);
        },
      )
    );
  }
}