import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/tables/pernyataan_persetujuan.dart';
import 'package:rrfx/src/components/textstyles/default.dart';
import 'package:rrfx/src/controllers/home.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/agreement_section_controller.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/progress_account_controller.dart';
import 'package:rrfx/src/views/accounts/registration_online/repository/regol_repository.dart';
import 'package:rrfx/src/views/accounts/registration_online/views/Step_12.dart';
import 'package:rrfx/src/views/accounts/registration_online/components/aggrement_section_list.dart';
import 'package:rrfx/src/views/accounts/registration_online/components/agreement_section_with_table.dart';
import 'package:rrfx/src/views/accounts/registration_online/components/agrement_dispute_section.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/views/accounts/registration_online/components/button_next_previous.dart';
import 'package:rrfx/src/views/accounts/registration_online/components/time_and_statement.dart';
import 'package:rrfx/src/views/accounts/registration_online/components/today_statement.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/statement_controller.dart';

class Step11 extends StatefulWidget {
  const Step11({super.key});

  @override
  State<Step11> createState() => _Step11State();
}

class _Step11State extends State<Step11> {

  StatementController controller = Get.find();
  final AgreementSectionController agreementController = Get.put(AgreementSectionController());
  HomeController userController = Get.find();
  final progressController = Get.find<ProgressAccountController>();
  final RegolRepository _regolRepository = Get.find<RegolRepository>();
  String selectedPerselisihan = "Badan Arbitrase Perdagangan Berjangka Komoditi (BAKTI) berdasarkan Peraturan dan Prosedur Badan Arbitrase Perdagangan Berjangka Komoditi (BAKTI)";
  String selecterdKantorPerselisihan = "JAKARTA UTARA";

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await progressController.fetchProgressAccount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.defaultAppBar(
        autoImplyLeading: true,
        title: "Step 11"
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            CustomText.titleHeadingPage(context, text: "PERJANJIAN PEMBERIAN AMANAT SECARA ELEKTRONIK ONLINE UNTUK TRANSAKSI KONTRAK DERIVATIF DALAM SISTEM PERDAGANGAN ALTERNATIF"),
            const SizedBox(height: 15),
            CustomText.titleHeadingPage(context, text: "PERHATIAN !"),
            CustomText.normal(context, text: "PERJANJIAN INI MERUPAKAN KONTRAK HUKUM. HARAP DIBACA DENGAN SEKSAMA !"),
            Obx(
              () => TodayStatement(
                name1: userController.profileModel.value?.name ?? "-",
                job1: progressController.progressData.value?.response?.kerjaNama ?? "-",
                address1: progressController.progressData.value?.response?.address ?? "-",
                name2: "Rachmat Setiyadi",
                job2: "(Petugas Wakil Pialang yang Ditunjuk Memverifikasi)",
                address2: "Ruko Soho Rodeo Drive Blok. A No. 20 (SRD-020), Desa/Kelurahan Kamal Muara, Kec. Penjaringan, Kota Adm. Jakarta Utara, Provinsi DKI Jakarta 14470",
                companyName: "PT RRFX Investasi Berjangka",
              ),
            ),
            StatementWidget.paraPihak(context),
            const SizedBox(height: 15.0),
            CustomText.normal(context, text: "Para Pihak sepakat untuk mengadakan Perjanjian Pemberian Amanat untuk melakukan transaksi penjualan maupun pembelian Kontrak Derivatif Dalam Sistem Perdagangan Alternatif dengan ketentuan sebagai berikut :", align: TextAlign.justify),
            const SizedBox(height: 15.0),
            AgreementSectionList(
              sections: {
                "Margin dan Pembayaran Lainnya": [
                  "Nasabah menempatkan sejumlah dana (Margin) ke Rekening Terpisah (Segregated Account) Pialang Berjangka sebagai Margin Awal dan wajib mempertahankannya sebagaimana ditetapkan.",
                  "Membayar biaya-biaya yang diperlukan untuk transaksi, yaitu biaya transaksi, pajak, komisi, dan biaya pelayanan, biaya bunga sesuai tingkat yang berlaku, dan biaya lainnya yang dapat dipertanggungjawabkan berkaitan dengan transaksi sesuai amanat Nasabah, maupun biaya rekening Nasabah.",
                ],
                "Pelaksanaan Transaksi": [
                  "Setiap transaksi Nasabah dilaksanakan secara elektronik online oleh Nasabah yang bersangkutan;",
                  "Setiap amanat Nasabah yang diterima dapat langsung dilaksanakan sepanjang nilai Margin yang tersedia pada rekeningnya mencukupi dan eksekusinya dapat menimbulkan perbedaan waktu terhadap proses pelaksanaan transaksi tersebut. Nasabah harus mengetahui posisi Margin dan posisi terbuka sebelum memberikan amanat untuk transaksi berikutnya.",
                  "Setiap transaksi Nasabah secara bilateral dilawankan dengan Penyelenggara Sistem Perdagangan Alternatif PT Capital Megah Mandiri yang bekerjasama dengan Pialang Berjangka.",
                  "Nasabah bertanggung jawab atas keamanan dan penggunaan username dan password dalam transaksi Perdagangan Berjangka, Nasabah dilarang memberitahukan, menyerahkan atau meminjamkan username dan password kepada pihak lain, termasuk kepada pegawai Pialang Berjangka.",
                ],
                "Kewajiban Memelihara Margin": [
                  "Nasabah wajib memelihara/memenuhi tingkat Margin yang harus tersedia di rekening pada Pialang Berjangka sesuai dengan jumlah yang telah ditetapkan baik diminta ataupun tidak oleh Pialang Berjangka.",
                  "Apabila jumlah Margin memerlukan penambahan maka Pialang Berjangka wajib memberitahukan dan memintakan kepada Nasabah untuk menambah Margin segera.",
                  "Apabila jumlah Margin memerlukan tambahan (Call Margin) maka Nasabah wajib melakukan penyerahan Call Margin selambat-lambatnya sebelum dimulai hari perdagangan berikutnya. Kewajiban Nasabah sehubungan dengan penyerahan Call Margin tidak terbatas pada jumlah Margin awal.",
                  "Pialang Berjangka tidak berkewajiban melaksanakan amanat untuk melakukan transaksi yang baru dari Nasabah sebelum Call Margin dipenuhi.",
                  "Untuk memenuhi kewajiban Call Margin dan keuangan lainnya dari Nasabah, Pialang Berjangka dapat mencairkan dana Nasabah yang ada di Pialang Berjangka."
                ],
                "Hak Pialang Berjangka Melikuidasi Posisi Nasabah": [
                  "Nasabah bertanggung jawab memantau/mengetahui posisi terbukanya secara terus- menerus dan memenuhi kewajibannya. Apabila dalam jangka waktu tertentu dana pada rekening Nasabah kurang dari yang dipersyaratkan, Pialang Berjangka dapat menutup posisi terbuka Nasabah secara keseluruhan atau sebagian, membatasi transaksi, atau tindakan lain untuk melindungi diri dalam pemenuhan Margin tersebut dengan terlebih dahulu memberitahu atau tanpa memberitahu Nasabah dan Pialang Berjangka tidak bertanggung jawab atas kerugian yang timbul akibat tindakan tersebut."
                ],
                "Penggantian Kerugian Tidak Adanya Penutupan Posisi": [
                  "Apabila Nasabah tidak mampu melakukan penutupan atas transaksi yang jatuh tempo, Pialang Berjangka dapat melakukan penutupan atas transaksi Nasabah yang terjadi. Nasabah wajib membayar biaya-biaya, termasuk biaya kerugian dan premi yang telah dibayarkan oleh Pialang Berjangka, dan apabila Nasabah lalai untuk membayar biaya-biaya tersebut, Pialang Berjangka berhak untuk mengambil pembayaran dari dana Nasabah."
                ],
                "Pialang Berjangka Dapat Membatasi Posisi": [
                  "Nasabah mengakui hak Pialang Berjangka untuk membatasi posisi terbuka Kontrak dan Nasabah tidak melakukan transaksi melebihi batas yang telah ditetapkan tersebut."
                ],
                "Tidak Ada Jaminan atas Informasi atau Rekomendasi": [
                  "Informasi dan rekomendasi yang diberikan oleh Pialang Berjangka kepada Nasabah tidak selalu lengkap dan perlu diverifikasi.",
                  "Pialang Berjangka tidak menjamin bahwa informasi dan rekomendasi yang diberikan merupakan informasi yang akurat dan lengkap.",
                  "Informasi dan rekomendasi yang diberikan oleh Wakil Pialang Berjangka yang satu dengan yang lain mungkin berbeda karena perbedaan analisis fundamental atau teknikal. Nasabah menyadari bahwa ada kemungkinan Pialang Berjangka dan pihak terafiliasinya memiliki posisi di pasar dan memberikan rekomendasi tidak konsisten kepada Nasabah."
                ],
                "Pembatasan Tanggung Jawab Pialang Berjangka.": [
                  "Pialang Berjangka tidak bertanggung jawab untuk memberikan penilaian kepada Nasabah mengenai iklim, pasar, keadaan politik dan ekonomi nasional dan internasional, nilai Kontrak Derivatif, kolateral, atau memberikan nasihat mengenai keadaan pasar. Pialang Berjangka hanya memberikan pelayanan untuk melakukan transaksi secara jujur serta memberikan laporan atas transaksi tersebut.",
                  "Perdagangan sewaktu-waktu dapat dihentikan oleh pihak yang memiliki otoritas (Bappebti/Bursa Berjangka) tanpa pemberitahuan terlebih dahulu kepada Nasabah. Atas posisi terbuka yang masih dimiliki oleh Nasabah pada saat perdagangan tersebut dihentikan, maka akan diselesaikan (likuidasi) berdasarkan pada peraturan/ketentuan yang dikeluarkan dan ditetapkan oleh pihak otoritas tersebut, dan semua kerugian serta biaya yang timbul sebagai akibat dihentikannya transaksi oleh pihak otoritas perdagangan tersebut, menjadi beban dan tanggung jawab Nasabah sepenuhnya.",
                ],
                "Transaksi Harus Mematuhi Peraturan Yang Berlaku": [
                  "Semua transaksi dilakukan sendiri oleh Nasabah dan wajib mematuhi peraturan perundang-undangan di bidang Perdagangan Berjangka, kebiasaan dan interpretasi resmi yang ditetapkan oleh Bappebti atau Bursa Berjangka.",
                ],
                "Pialang Berjangka tidak Bertanggung jawab atas Kegagalan Komunikasi": [
                  "Pialang Berjangka tidak bertanggung jawab atas keterlambatan Kegagalan Komunikasi Pialang Berjangka tidak bertanggung jawab atas keterlambatan atau tidak tepat waktunya pengiriman amanat atau informasi lainnya yang disebabkan oleh kerusakan fasilitas komunikasi atau sebab lain diluar kontrol Pialang Berjangka.",
                ],
                "Konfirmasi": [
                  "Konfirmasi dari Nasabah dapat berupa surat, telex, media lain, surat elektronik, secara tertulis ataupun rekaman suara.",
                  "Pialang Berjangka berkewajiban menyampaikan konfirmasi transaksi, laporan rekening, permintaan Call Margin, dan pemberitahuan lainnya kepada Nasabah secara akurat, benar dan secepatnya pada alamat (email) Nasabah sesuai dengan yang tertera dalam rekening Nasabah. Apabila dalam jangka waktu 2 x 24 jam setelah amanat jual atau beli disampaikan, tetapi Nasabah belum menerima konfirmasi melalui alamat email Nasabah dan/atau sistem transaksi, Nasabah segera memberitahukan hal tersebut kepada Pialang Berjangka melalui telepon dan disusul dengan pemberitahuan tertulis.",
                  "Jika dalam waktu 2 x 24 jam sejak tanggal penerimaan konfirmasi tersebut tidak ada sanggahan dari Nasabah maka konfirmasi Pialang Berjangka dianggap benar dan sah.",
                  "Kekeliruan atas konfirmasi yang diterbitkan Pialang Berjangka akan diperbaiki oleh Pialang Berjangka sesuai keadaan yang sebenarnya dan demi hukum konfirmasi yang lama batal.",
                  "Nasabah tidak bertanggung jawab atas transaksi yang dilaksanakan atas rekeningnya apabila konfirmasi tersebut tidak disampaikan secara benar dan akurat."
                ],
                "Kebenaran Informasi Nasabah": [
                  "Nasabah memberikan informasi yang benar dan akurat mengenai data Nasabah yang diminta oleh Pialang Berjangka dan akan memberitahukan paling lambat dalam waktu 3 (tiga) hari kerja setelah terjadi perubahan, termasuk perubahan kemampuan keuangannya untuk terus melaksanakan transaksi.",
                ],
                "Komisi Transaksi": [
                  "Nasabah mengetahui dan menyetujui bahwa Pialang Berjangka berhak untuk memungut komisi atas transaksi yang telah dilaksanakan, dalam jumlah sebagaimana akan ditetapkan dari waktu ke waktu oleh Pialang Berjangka. Perubahan beban (fees) dan biaya lainnya harus disetujui secara tertulis oleh Para Pihak.",
                ],
                "Pemberian Kuasa": [
                  """Nasabah memberikan kuasa kepada Pialang Berjangka untuk menghubungi bank, lembaga keuangan, Pialang Berjangka lain, atau institusi lain yang terkait untuk memperoleh keterangan atau verifikasi mengenai informasi yang diterima dari Nasabah. Nasabah mengerti bahwa penelitian mengenai data hutang pribadi dan bisnis dapat dilakukan oleh Pialang Berjangka apabila diperlukan. Nasabah diberikan kesempatan untuk memberitahukan secara tertulis dalam jangka waktu yang telah disepakati untuk melengkapi persyaratan yang diperlukan.
    Nasabah dapat juga memberikan kuasa kepada pihak lain (bukan Pengurus Pialang Berjangka, bukan Wakil Pialang Berjangka yang menanda-tangani perjanjian ini dan bukan pegawai Pialang Berjangka yang jabatannya satu tingkat di bawah Direksi) yang ditunjuk oleh Nasabah untuk menjalankan hak-hak yang timbul atas rekening, termasuk memberikan instruksi kepada Pialang Berjangka atas rekening yang dimiliki Nasabah, berdasarkan surat kuasa dalam bentuk dan isi yang tidak bertentangan dengan ketentuan Peraturan Perundang-undangan.""",
                ],
                "Pemindahan Dana": [
                  "Pialang Berjangka dapat setiap saat mengalihkan dana dari satu rekening ke rekening lainnya berkaitan dengan kegiatan transaksi yang dilakukan Nasabah seperti pembayaran komisi, pembayaran biaya transaksi, kliring dan keterlambatan dalam memenuhi kewajibannya, tanpa terlebih dahulu memberitahukan kepada Nasabah. Transfer yang telah dilakukan akan segera diberitahukan secara tertulis kepada Nasabah",
                ],
                "Dokumen Pemberitahuan Adanya Risiko": [
                  "Nasabah mengakui menerima dan mengerti Dokumen Pemberitahuan Adanya Risiko.",
                ],
                "Jangka Waktu Perjanjian dan Pengakhiran": [
                  "Perjanjian ini mulai berlaku terhitung sejak tanggal dilakukannya konfirmasi oleh Pialang Berjangka dengan diterimanya Bukti Konfirmasi Penerimaan Nasabah dari Pialang Berjangka oleh Nasabah.",
                  "Nasabah dapat mengakhiri Perjanjian ini hanya jika Nasabah sudah tidak lagi memiliki posisi terbuka dan tidak ada kewajiban Nasabah yang diemban oleh atau terhutang kepada Pialang Berjangka.",
                  "Pengakhiran tidak membebaskan salah satu Pihak dari tanggung jawab atau kewajiban yang terjadi sebelum pemberitahuan tersebut."
                ],
                "Berakhirnya Perjanjian": [
                  "Dinyatakan pailit, memiliki hutang yang sangat besar, dalam proses peradilan, menjadi hilang ingatan, mengundurkan diri atau meninggal;",
                  "Tidak dapat memenuhi atau mematuhi perjanjian ini dan/atau melakukan pelanggaran terhadapnya.",
                  {
                    "Berkaitan dengan butir (1) dan (2) tersebut diatas, Pialang Berjangka dapat:": [
                      "Meneruskan atau menutup posisi Nasabah tersebut setelah mempertimbangkannya secara cermat dan jujur",
                      "Menolak transaksi dari Nasabah."
                    ]
                  },
                  "Pengakhiran Perjanjian sebagaimana dimaksud dengan angka (1) dan (2) tersebut di atas tidak melepaskan kewajiban dari Para Pihak yang berhubungan dengan penerimaan atau kewajiban pembayaran atau pertanggungjawaban kewajiban lainnya yang timbul dari Perjanjian."
                ],
                "Force Majeur": [
                  """Tidak ada satupun pihak di dalam Perjanjian dapat diminta pertanggungjawabannya untuk suatu keterlambatan atau terhalangnya memenuhi kewajiban berdasarkan Perjanjian yang diakibatkan oleh suatu sebab yang berada di luar kemampuannya atau kekuasaannya (force majeur), sepanjang pemberitahuan tertulis mengenai sebab itu disampaikannya kepada pihak lain dalam Perjanjian dalam waktu tidak lebih dari 24 (dua puluh empat) jam sejak timbulnya sebab itu.
    Yang dimaksud dengan Force Majeur dalam Perjanjian adalah peristiwa kebakaran, bencana alam (seperti gempa bumi, banjir, angin topan, petir), pemogokan umum, huru hara, peperangan, perubahan terhadap peraturan perundang-undangan yang berlaku dan kondisi di bidang ekonomi, keuangan dan Perdagangan Berjangka, pembatasan yang dilakukan oleh otoritas Perdagangan Berjangka dan Bursa Berjangka serta terganggunya sistem perdagangan, kliring dan penyelesaian transaksi Kontrak Berjangka di mana transaksi dilaksanakan yang secara langsung mempengaruhi pelaksanaan pekerjaan berdasarkan Perjanjian.""",
                ],
                "Perubahan atas Isian dalam Perjanjian Pemberian Amanat": [
                  "Perubahan atas isian dalam Perjanjian ini hanya dapat dilakukan atas persetujuan Para Pihak, atau Pialang Berjangka telah memberitahukan secara tertulis perubahan yang diinginkan, dan Nasabah tetap memberikan perintah untuk transaksi dengan tanpa memberikan tanggapan secara tertulis atas usul perubahan tersebut. Tindakan Nasabah tersebut dianggap setuju atas usul perubahan tersebut.",
                ],
                "Tanggung Jawab Kepada Nasabah": [
                  "Penyelenggara Sistem Perdagangan Alternatif yang merupakan pihak yang menguasai dan/atau memiliki sistem perdagangan elektronik bertanggung jawab atas pelanggaran penyalahgunaan sistem perdagangan elektronik sesuai dengan ketentuan yang diatur dalam Perjanjian Kerjasama (PKS) dan peraturan perdagangan (trading rules) antara Penyelenggara Sistem Perdagangan Alternatif dan Peserta Sistem Perdagangan Alternatif yang mengakibatkan kerugian Nasabah.",
                  "Peserta Sistem Perdagangan Alternatif yang merupakan pihak yang menggunakan sistem perdagangan elektronik bertanggung jawab atas pelanggaran penyalahgunaan sistem perdagangan elektronik sebagaimana dimaksud pada angka 22 huruf (a) yang mengakibatkan kerugian Nasabah.",
                  "Dalam pemanfaatan sistem perdagangan elektronik, Penyelenggara Sistem Perdagangan Alternatif dan/atau Peserta Sistem Perdagangan Alternatif tidak bertanggung jawab atas kerugian Nasabah diluar hal-hal yang telah diatur pada angka 22 huruf (a) dan (b), antara lain: kerugian yang diakibatkan oleh risiko-risiko yang di sebutkan di dalam Dokumen Pemberitahuan Adanya Risiko yang telah dimengerti dan disetujui oleh Nasabah."
                ],
                "Bahasa": [
                  "Perjanjian ini dibuat dalam Bahasa Indonesia.",
                ],
              },
            ),
            AgreementDisputeSection(
              onChanged: (value) {
                print("🧾 Data dipilih: $value");
                selectedPerselisihan = value['penyelesaian_perselisihan']!;
                selecterdKantorPerselisihan = value['daftar_kantor']!;
              },
            ),
            AgreementSectionWithTable(
              sectionNumber: 24,
              title: "Pemberitahuan",
              subItems: [
                "Semua komunikasi, uang, surat berharga, dan kekayaan lainnya harus dikirimkan ...",
                "Semua uang, harus disetor atau ditransfer langsung oleh Nasabah ke Rekening Terpisah (Segregated Account) Pialang Berjangka:",
              ],
              details: {
                "Nama": "PT RRFX Investasi Berjangka",
                "Alamat": "Ruko Soho Rodeo Drive Blok. A No. 20 (SRD-020), Desa/Kelurahan Kamal Muara, Kec. Penjaringan, Kota Adm. Jakarta Utara, Provinsi DKI Jakarta 14470",
              },
              table: [
                {"name": "PT BANK CENTRAL ASIA Tbk", "currency": "IDR", "account": "0353118673"},
                {"name": "PT BANK MANDIRI (PERSERO) Tbk", "currency": "IDR", "account": "1220013916724"},
                {"name": "PT BANK CENTRAL ASIA Tbk", "currency": "USD", "account": "0353288111"},
                {"name": "PT BANK MANDIRI (PERSERO) Tbk", "currency": "USD", "account": "1220013916773"},
                {"name": "Bank CCB", "currency": "USD", "account": "1010862333"},
              ],
            ),
            StatementWidget.perjanjainPemberianAmanat(),
            const SizedBox(height: 15.0),
            Align(
              alignment: Alignment.centerRight,
              child: Obx(() => TextButton.icon(
                onPressed: agreementController.checkAll,
                icon: Icon(
                  agreementController.allChecked ? Icons.clear_all : Icons.done_all,
                  color: CustomColor.secondaryColor,
                ),
                label: Text(
                  agreementController.allChecked
                      ? "Hapus Centang Semua"
                      : "Centang Semua",
                  style: const TextStyle(
                    color: CustomColor.secondaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )),
            ),
            const SizedBox(height: 10.0),
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
          bool result = await _regolRepository.step11A(kantorPenyelesaian: selecterdKantorPerselisihan, kotaPenyelesaian: selectedPerselisihan);
          if(result) {
            Get.to(() => const Step12());
            return;
          }
          CustomScaffoldMessanger.showAppSnackBar(context, message: _regolRepository.responseMessage.value, type: SnackBarType.error);
        },
      )
    );
  }
}