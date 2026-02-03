import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/tables/number_text_list.dart';
import 'package:rrfx/src/components/tables/pernyataan_persetujuan.dart';
import 'package:rrfx/src/components/textstyles/default.dart';
import 'package:rrfx/src/views/accounts/registration_online/components/button_next_previous.dart';
import 'package:rrfx/src/views/accounts/registration_online/components/time_and_statement.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/statement_controller.dart';
import 'package:rrfx/src/views/accounts/registration_online/repository/regol_repository.dart';
import 'package:rrfx/src/views/accounts/registration_online/views/sid_registration.dart';

class Step6 extends StatefulWidget {
  const Step6({super.key});

  @override
  State<Step6> createState() => _Step6State();
}

class _Step6State extends State<Step6> with SingleTickerProviderStateMixin {

  StatementController controller = Get.find();
  final RegolRepository _regolRepository = Get.find<RegolRepository>();

  late ScrollController _scrollController;
  late AnimationController _scrollAnimController;
  bool _showScrollButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollAnimController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _scrollController.addListener(_updateScrollButtonVisibility);
  }

  void _updateScrollButtonVisibility() {
    bool shouldShow = _scrollController.offset < _scrollController.position.maxScrollExtent - 500;
    if (shouldShow != _showScrollButton) {
      setState(() {
        _showScrollButton = shouldShow;
      });
    }
  }

  void _scrollToBottom() {
    _scrollAnimController.forward().then((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      ).then((_) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _scrollAnimController.reverse();
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.defaultAppBar(
        autoImplyLeading: true,
        title: "Step 6"
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            CustomText.titleHeadingPage(context, text: "PERNYATAAN PENGUNGKAPAN"),
            CustomText.titleHeadingPage(context, text: "(DISCLOSURE STATEMENT)"),
            NumberedTextList(
              withIndex: true,
              subtitle: '',
              items: [
                'Perdagangan Berjangka BERISIKO SANGAT TINGGI tidak cocok untuk semua orang. Pastikan bahwa anda SEPENUHNYA MEMAHAMI RISIKO ini sebelum melakukan perdagangan.',
                'Perdagangan Berjangka merupakan produk keuangan dengan leverage dan dapat menyebabkan KERUGIAN ANDA MELEBIHI setoran awal Anda. Anda harus siap apabila SELURUH DANA ANDA HABIS.',
                'TIDAK ADA PENDAPATAN TETAP (FIXED INCOME) dalam Perdagangan Berjangka.',
                'Apabila anda PEMULA kami sarankan untuk mempelajari mekanisme transaksinya, PERDAGANGAN BERJANGKA membutuhkan pengetahuan dan pemahaman khusus.',
                'ANDA HARUS MELAKUKAN TRANSAKSI SENDIRI, segala risiko yang akan timbul akibat transaksi sepenuhnya akan menjadi tanggung jawab Saudara.',
                'User id dan password BERSIFAT PRIBADI DAN RAHASIA, anda bertanggung jawab atas penggunaannya, JANGAN SERAHKAN ke pihak lain terutama Wakil Pialang Berjangka dan pegawai Pialang Berjangka.',
                'ANDA berhak menerima LAPORAN ATAS TRANSAKSI yang anda lakukan. Waktu anda 2 X 24 JAM UNTUK MEMBERIKAN SANGGAHAN. Untuk transaksi yang TELAH SELESAI (DONE/SETTLE) DAPAT ANDA CEK melalui sistem informasi transaksi nasabah yang berfungsi untuk memastikan transaksi anda telah terdaftar di Lembaga Kliring Berjangka.',
              ],
            ),
            StatementWidget.perjanjainPemberianAmanat(),
            const SizedBox(height: 10.0),
            TimeAndStatement(),
            const SizedBox(height: 10.0),
          ],
        ),
      ),
      floatingActionButton: _showScrollButton
        ? ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.1).animate(_scrollAnimController),
            child: FloatingActionButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              onPressed: _scrollToBottom,
              backgroundColor: CustomColor.secondaryColor,
              foregroundColor: Colors.black,
              elevation: 2,
              tooltip: 'Scroll ke Bawah',
              child: Icon(Iconsax.arrow_down_1_outline),
            ),
          )
        : null,
      bottomNavigationBar: ButtonNextPrevious(
        onPressed: () async {
          if(!controller.selectedStatement.value){
            CustomScaffoldMessanger.showAppSnackBar(context, message: "Mohon centang \"YA\" pada checkbox persetujuan profil perusahaan berjangka", type: SnackBarType.error);
            return;
          }
          bool result = await _regolRepository.step6();
          if(result) {
            // Get.to(() => const Step7());
            Get.to(() => const SIDRegistrationPage());
            return;
          }
          CustomScaffoldMessanger.showAppSnackBar(context, message: _regolRepository.responseMessage.value, type: SnackBarType.error);
        },
      )
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollAnimController.dispose();
    super.dispose();
  }
}