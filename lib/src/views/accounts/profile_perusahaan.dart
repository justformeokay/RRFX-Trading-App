import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/buttons/elevated_button.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/tables/company_profile.dart';
import 'package:rrfx/src/components/tables/list_director.dart';
import 'package:rrfx/src/components/tables/number_text_list.dart';
import 'package:rrfx/src/components/tables/pernyataan_persetujuan.dart';
import 'package:rrfx/src/components/textstyles/default.dart';
import 'package:rrfx/src/views/accounts/step_1_upload_photo.dart';

class HalamanSatuProfilPerusahaan extends StatefulWidget {
  const HalamanSatuProfilPerusahaan({super.key});

  @override
  State<HalamanSatuProfilPerusahaan> createState() => _HalamanSatuProfilPerusahaanState();
}

class _HalamanSatuProfilPerusahaanState extends State<HalamanSatuProfilPerusahaan> {

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
            CustomText.titleHeadingPage(context, text: "PROFIL PERUSAHAAN PIALANG BERJANGKA"),
            TableCompanyProfile(data: {
              'Nama': 'PT. RRFX Investasi Berjangka',
              'Alamat': 'Alamat: Ruko Soho Rodeo Drive Blok. A No. 20 (SRD-020), Desa/Kelurahan Kamal Muara, Kec. Penjaringan, Kota Adm. Jakarta Utara, Provinsi DKI Jakarta, Kode Pos: 14470',
              'No. Telepon': '021-50322008',
              'Faksimili': '(021) 252 6501',
              'E-mail': 'cs@rrfx.co.id',
              'Home-page': 'https://rrfx.co.id',
            }),

            const SizedBox(height: 20.0),
            CustomText.titleMedium(context, text: "Susunan Pengurus Perusahaan"),
            TableListDirector(title: "Dewan Direksi", data: {
              'Direktur Utama': 'Fenny Chiurman',
              'Direktur Kepatuhan': 'Ismanto Herman',
              'Direktur Operasional': 'Asep Sujana',
            }),
            TableListDirector(title: "Dewan Komisaris", data: {
              'Komisaris Utama': 'William',
              'Komisaris': 'Jeymy Yaputra Yapadi',
            }),
            NumberedTextList(
              title: 'Susunan Pemegang Saham Perusahaan',
              subtitle: '',
              items: [
                'Global Optimal Tech Pte.Ltd: 95%',
                'PT. Usaha Kreatif Indonesia: 5%',
              ],
            ),
            const Divider(color: Colors.white30),
            TableListDirector(title: "Kontrak Berjangka Yang Diperdagangkan", withIndex: false, removeTitle: true, data: {
              'Nomor dan Tanggal Izin Usaha dari Bappebti': 'No. 192/BAPPEBTI/SI/II/2003 Tanggal: 2003-02-24',
              'Nomor dan Tanggal Keanggotaan Bursa Berjangka': 'No. SPAB-043/BBJ/02/2002 Tanggal: 2002-02-13 00:00:00',
              'Nomor dan Tanggal Keanggotaan Lembaga Kliring Berjangka': 'No. 22/AK-KBI/V/2004 Tanggal: 2004-05-18 00:00:00',
              'Nomor dan Tanggal Persetujuan sebagai Peserta Sistem Perdagangan Alternatif': 'No. 1519/BAPPEBTI/SP/4/2007 Tanggal: 2007-04-18 00:00:00',
              'Nama Penyelenggara Sistem Perdagangan Alternatif': 'PT. Capital Megah Mandiri',
            }),
            TableListDirector(title: "Kontrak Berjangka Yang Diperdagangkan", withIndex: false, data: {
              'Kontrak berjangka Emas': '( GOL, GOL 250, GOL 100 )',
              'Kontrak berjangka Kopi': '( ACF, RCF )',
              'Kontrak Berjangka Olein': '( OLE, OLE 10 )',
              'Kontrak Berjangka Indeks emas': '( KBIE )',
              'Kontrak Berjangka Coklat': '( CC5 )',
            }),
            NumberedTextList(
              withIndex: true,
              title: 'Kontrak Derivatif Syariah Yang Diperdagangkan',
              subtitle: '',
              items: [
                'Kontrak Derivatif dalam Sistem Perdagangan Alternatif (SPA)',
                'Kontrak CFD Mata Uang Asing (FOREX) dan Loco Emas (XAU) , Silver (XAG) , Oil (CLSK)',
                'Indeks Saham Jepang, Indeks Saham Hongkong, NAS100, DOW, SPX500',
              ],
            ),
            NumberedTextList(
              withIndex: true,
              title: 'Kontrak Derivatif dalam Sistem Perdagangan Alternatif dengan volume minimum 0,1 (nol koma satu) lot Yang Diperdagangkan',
              items: [
                'Kontrak CFD Mata Uang Asing (FOREX) dan Loco Emas (XAU) , Silver (XAG) , Oil (CLSK)',
              ],
            ),
            NumberedTextList(
              withIndex: true,
              title: 'Biaya secara rinci yang dibebankan pada Nasabah',
              items: [
                'Berdasarkan Jenis produk Komisi \$50/lot settled / Interest / Swap / Rollover fee',
              ],
            ),
            TableListDirector(title: "Nomor atau Alamat Email jika terjadi keluhan", withIndex: false, data: {
              'Email': 'pengaduan@rrfx.co.id',
              'No. Telepon': '021-50322008',
              'Fax': '0212526501',
            }),
            NumberedTextList(
              withIndex: true,
              title: 'Sarana penyelesaian perselisihan yang dipergunakan apabila terjadi perselisihan :',
              items: [
                'Secara musyawarah untuk mencapai mufakat antara Para Pihak',
                'Memanfaatkan sarana penyelesaian perselisihan yang tersedia di Bursa Berjangka (JFX)',
                'Badan Arbitrase Perdagangan Berjangka Komoditi (BAKTI) atau Pengadilan Negeri',
              ],
            ),
            NumberedTextList(
              withIndex: true,
              title: 'Nama-Nama Wakil Pialang Berjangka yang Bekerja di Perusahaan Pialang Berjangka :',
              subtitle: '',
              items: [
                'Candra Jaya Palatehan',
                'Rachmat Setiyadi',
                'Sri Subaktiyani',
                'Eko Mulyono',
                'Setiyoko',
                'Wargianto'
              ],
            ),
            NumberedTextList(
              withIndex: true,
              title: 'Nama-Nama Wakil Pialang Berjangka yang secara khusus ditunjuk oleh Pialang Berjangka untuk melakukan verifikasi dalam rangka penerimaan Nasabah elektronik online',
              subtitle: '',
              items: [
                'Candra Jaya Palatehan',
                'Rachmat Setiyadi',
                'Sri Subaktiyani',
                'Eko Mulyono',
                'Setiyoko',
                'Wargianto'
              ],
            ),
            TableListDirector(title: "Nomor Rekening Terpisah (Segregated Account) Perusahaan Pialang Berjangka", withIndex: true, data: {
              'PT BANK CENTRAL ASIA Tbk': '0353118673 (IDR)',
              'PT BANK MANDIRI (PERSERO) Tbk': '1220013916724 (IDR)',
              'PT BANK CENTRAL ASIA Tbk ': '0353288111 (USD)',
              'PT BANK MANDIRI (PERSERO) Tbk ': '1220013916773 (USD)',
              'Bank CCB': '1010862333 (USD)',
            }),
            StatementWidget.pernyataanTelahMembaca(dynamicTitlePart: "PROFIL PERUSAHAAN PIALANG BERJANGKA"),
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
            Get.to(() => const Step1UploadPhoto());
          },
          title: "Lanjutkan"
        ),
      ),
    );
  }
}