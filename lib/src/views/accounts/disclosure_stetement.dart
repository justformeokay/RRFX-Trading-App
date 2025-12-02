import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/buttons/elevated_button.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/tables/number_text_list.dart';
import 'package:rrfx/src/components/tables/pernyataan_persetujuan.dart';
import 'package:rrfx/src/components/textstyles/default.dart';
import 'package:rrfx/src/views/accounts/step_13_perselisihan.dart' show Step13PenyelesaianPerselisihan;

class HalamanDisclosure extends StatefulWidget {
  const HalamanDisclosure({super.key});

  @override
  State<HalamanDisclosure> createState() => _HalamanDisclosureState();
}

class _HalamanDisclosureState extends State<HalamanDisclosure> {

  RxBool selectedStatement = false.obs;
  DateTime now = DateTime.now();

  Stream<DateTime> timeStream() {
    return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.defaultAppBar(
        autoImplyLeading: true
      ),
      body: SingleChildScrollView(
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
            StatementWidget.pernyataanTelahMembaca(dynamicTitlePart: "SECARA DETAIL BACA SELURUH DOKUMEN PEMBERITAHUAN ADANYA RISIKO DAN DOKUMEN PERJANJIAN PEMBERIAN AMANAT"),
            Text('Demikian Pernyataan ini dibuat dengan sebenarnya dalam keadaan sadar, sehat jasmani dan rohani serta tanpa paksaan apapun dari pihak manapun.', style: TextStyle(fontSize: 15), textAlign: TextAlign.justify,),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Obx(
                      () => Row(
                        children: [
                          Checkbox(
                            fillColor: WidgetStatePropertyAll(CustomColor.secondaryBackground.withValues(alpha: 0.3)),
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
                            fillColor: WidgetStatePropertyAll(CustomColor.secondaryBackground.withValues(alpha: 0.3)),
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
            ),
            const SizedBox(height: 10.0),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 3, bottom: 20),
        child: DefaultButton.defaultElevatedButton(
          onPressed: (){
            if(!selectedStatement.value){
              CustomScaffoldMessanger.showAppSnackBar(context, message: "Mohon centang \"YA\" pada checkbox persetujuan profil perusahaan berjangka", type: SnackBarType.error);
              return;
            }
            Get.to(() => const Step13PenyelesaianPerselisihan());
          },
          title: "Lanjutkan"
        ),
      ),
    );
  }
}