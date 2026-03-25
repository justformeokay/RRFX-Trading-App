import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/textstyles/default.dart';
import 'package:rrfx/src/views/accounts/registration_online/components/button_next_previous.dart';
import 'package:rrfx/src/views/accounts/registration_online/components/numbered_aggrement_list.dart';
import 'package:rrfx/src/views/accounts/registration_online/components/time_and_statement.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/agreement_controller.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/statement_controller.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/step_controller.dart';
import 'package:rrfx/src/views/accounts/registration_online/repository/regol_repository.dart';
import 'package:rrfx/src/views/accounts/registration_online/views/step_10.dart';

class Step9 extends StatefulWidget {
  const Step9({super.key});

  @override
  State<Step9> createState() => _Step9State();
}

class _Step9State extends State<Step9> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _scrollAnimController;
  StepController stepController = Get.find();
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
    final StatementController statementController = Get.find();
    final RegolRepository _regolRepository = Get.find<RegolRepository>();
    final AgreementController agreementController = Get.put(AgreementController());

    final List<String> itemsSPA = [
      'Perdagangan Kontrak Derivatif Dalam Sistem Perdagangan Alternatif belum tentu layak bagi semua investor. Anda dapat menderita kerugian dalam jumlah besar dan dalam jangka waktu singkat. Jumlah kerugian uang dimungkinkan dapat melebihi jumlah uang yang pertama kali Anda setor (Margin awal) ke Pialang Berjangka Anda. Anda mungkin menderita kerugian seluruh Margin dan Margin tambahan yang ditempatkan pada Pialang Berjangka untuk mempertahankan posisi Kontrak Derivatif Dalam Sistem Perdagangan Alternatif Anda. Hal ini disebabkan Perdagangan Berjangka sangat dipengaruhi oleh mekanisme leverage, dimana dengan jumlah investasi dalam bentuk yang relatif kecil dapat digunakan untuk membuka posisi dengan aset yang bernilai jauh lebih tinggi. Apabila Anda tidak siap dengan risiko seperti ini, sebaiknya Anda tidak melakukan perdagangan Kontrak Derivatif Dalam Sistem Perdagangan Alternatif.',
      'Perdagangan Kontrak Derivatif Dalam Sistem Perdagangan Alternatif mempunyai risiko dan mempunyai kemungkinan kerugian yang tidak terbatas yang jauh lebih besar dari jumlah uang yang disetor (Margin) ke Pialang Berjangka. Kontrak Derivatif Dalam Sistem Perdagangan Alternatif sama dengan produk keuangan lainnya yang mempunyai risiko tinggi, Anda sebaiknya tidak menaruh risiko terhadap dana yang Anda tidak siap untuk menderita rugi, seperti tabungan pensiun, dana kesehatan atau dana untuk keadaan darurat, dana yang disediakan untuk pendidikan atau kepemilikan rumah, dana yang diperoleh dari pinjaman pendidikan atau gadai, atau dana yang digunakan untuk memenuhi kebutuhan sehari-hari.',
      'Berhati-hatilah terhadap pernyataan bahwa Anda pasti mendapatkan keuntungan besar dari perdagangan Kontrak Derivatif Dalam Sistem Perdagangan Alternatif. Meskipun perdagangan Kontrak Derivatif Dalam Sistem Perdagangan Alternatif dapat memberikan keuntungan yang besar dan cepat, namun hal tersebut tidak pasti, bahkan dapat menimbulkan kerugian yang besar dan cepat juga. Seperti produk keuangan lainnya, tidak ada yang dinamakan "pasti untung".',
      'Disebabkan adanya mekanisme leverage dan sifat dari transaksi Kontrak Derivatif Dalam Sistem Perdagangan Alternatif, Anda dapat merasakan dampak bahwa Anda menderita kerugian dalam waktu cepat. Keuntungan maupun kerugian dalam transaksi akan langsung dikredit atau didebet ke rekening Anda, paling lambat secara harian. Apabila pergerakan di pasar terhadap Kontrak Derivatif Dalam Sistem Perdagangan Alternatif menurunkan nilai posisi Anda dalam Kontrak Derivatif Dalam Sistem Perdagangan Alternatif, dengan kata lain berlawanan dengan posisi yang Anda ambil, Anda diwajibkan untuk menambah dana untuk pemenuhan kewajiban Margin ke perusahaan Pialang Berjangka. Apabila rekening Anda berada dibawah minimum Margin yang telah ditetapkan Lembaga Kliring Berjangka atau Pialang Berjangka, maka posisi Anda dapat dilikuidasi pada saat rugi, dan Anda wajib menyelesaikan defisit (jika ada) dalam rekening Anda.',
      'Pada saat pasar dalam keadaan tertentu, Anda mungkin akan sulit atau tidak mungkin melikuidasi posisi. Pada umumnya Anda harus melakukan transaksi mengambil posisi yang berlawanan dengan maksud melikuidasi posisi (offset) jika ingin melikuidasi posisi dalam Kontrak Derivatif Dalam Sistem Perdagangan Alternatif. Apabila Anda tidak dapat melikuidasi posisi Kontrak Derivatif Dalam Sistem Perdagangan Alternatif, Anda tidak dapat merealisasikan keuntungan pada nilai posisi tersebut atau mencegah kerugian yang lebih tinggi. Kemungkinan tidak dapat melikuidasi dapat terjadi, antara lain: jika perdagangan berhenti dikarenakan aktivitas perdagangan yang tidak lazim pada Kontrak Derivatif atau subjek Kontrak Derivatif, atau terjadi kerusakan sistem pada Pialang Berjangka Peserta Sistem Perdagangan Alternatif atau Pedagang Berjangka Penyelenggara Sistem Perdagangan Alternatif. Bahkan apabila Anda dapat melikuidasi posisi tersebut, Anda mungkin terpaksa melakukannya pada harga yang menimbulkan kerugian besar.',
      'Pada saat pasar dalam keadaan tertentu, Anda mungkin akan sulit atau tidak mungkin mengelola risiko atas posisi terbuka Kontrak Derivatif Dalam Sistem Perdagangan Alternatif dengan cara membuka posisi dengan nilai yang sama namun dengan posisi yang berlawanan dalam kontrak bulan yang berbeda, dalam pasar yang berbeda atau dalam “subjek Kontrak Derivatif Dalam Sistem Perdagangan Alternatif” yang berbeda. Kemungkinan untuk tidak dapat mengambil posisi dalam rangka membatasi risiko yang timbul, contohnya: jika perdagangan dihentikan pada pasar yang berbeda disebabkan aktivitas perdagangan yang tidak lazim pada Kontrak Derivatif dalam Sistem Perdagangan Alternatif atau “Kontrak Derivatif dalam Sistem Perdagangan Alternatif”.',
      'Anda dapat menderita kerugian yang disebabkan kegagalan sistem informasi. Sebagaimana yang terjadi pada setiap transaksi keuangan, Anda dapat menderita kerugian jika amanat untuk melaksanakan transaksi Kontrak Derivatif Dalam Sistem Perdagangan Alternatif tidak dapat dilakukan karena kegagalan sistem informasi di Bursa Berjangka, Pedagang Berjangka Penyelenggara Sistem Perdagangan Alternatif, maupun sistem di Pialang Berjangka Peserta Sistem Perdagangan Alternatif yang mengelola posisi Anda. Kerugian Anda akan semakin besar jika Pialang Berjangka yang mengelola posisi Anda tidak memiliki sistem informasi cadangan atau prosedur yang layak.',
      'Semua Kontrak Derivatif Dalam Sistem Perdagangan Alternatif mempunyai risiko, dan tidak ada strategi berdagang yang dapat menjamin untuk menghilangkan risiko tersebut. Strategi dengan menggunakan kombinasi posisi seperti spread, dapat sama berisiko seperti posisi long atau short. Melakukan Perdagangan Berjangka memerlukan pengetahuan mengenai Kontrak Derivatif Dalam Sistem Perdagangan Alternatif dan pasar berjangka.',
      'Strategi perdagangan harian dalam Kontrak Derivatif Dalam Sistem Perdagangan Alternatif dan produk lainnya memiliki risiko khusus. Seperti pada produk keuangan lainnya, pihak yang ingin membeli atau menjual Kontrak Derivatif Dalam Sistem Perdagangan Alternatif yang sama dalam satu hari untuk mendapat keuntungan dari perubahan harga pada hari tersebut (“day traders”) akan memiliki beberapa risiko tertentu antara lain jumlah komisi yang besar, risiko terkena efek pengungkit (“exposure to leverage”), dan persaingan dengan pedagang profesional. Anda harus mengerti risiko tersebut dan memiliki pengalaman yang memadai sebelum melakukan perdagangan harian (“day trading”).',
      'Menetapkan amanat bersyarat, Kontrak Derivatif Dalam Sistem Perdagangan Alternatif dilikuidasi pada keadaan tertentu untuk membatasi rugi (stop loss), mungkin tidak akan dapat membatasi kerugian Anda sampai jumlah tertentu saja. Amanat bersyarat tersebut mungkin tidak dapat dilaksanakan karena terjadi kondisi pasar yang tidak memungkinkan melikuidasi Kontrak Derivatif Dalam Sistem Perdagangan Alternatif.',
      'Anda harus membaca dengan seksama dan memahami Perjanjian Pemberian Amanat Nasabah dengan Pialang Berjangka Anda sebelum melakukan transaksi Kontrak Derivatif Dalam Sistem Perdagangan Alternatif.',
      'Pernyataan singkat ini tidak dapat memuat secara rinci seluruh risiko atau aspek penting lainnya tentang Perdagangan Berjangka. Oleh karena itu Anda harus mempelajari kegiatan Perdagangan Berjangka secara cermat sebelum memutuskan melakukan transaksi.'
      'Dokumen Pemberitahuan Adanya Risiko (Risk Disclosure) ini dibuat dalam Bahasa Indonesia.'
    ];

    final List<String> itemsMulti = [
      'Perdagangan Berjangka belum tentu layak bagi semua investor. Anda dapat menderita kerugian dalam jumlah besar dan dalam jangka waktu singkat. Jumlah kerugian uang dimungkinkan dapat melebihi jumlah uang yang pertama kali Anda setor (Margin awal) ke Pialang Berjangka Anda. Anda mungkin menderita kerugian seluruh Margin dan Margin tambahan yang ditempatkan pada Pialang Berjangka untuk mempertahankan posisi Berjangka Anda. Hal ini disebabkan Perdagangan Berjangka sangat dipengaruhi oleh mekanisme leverage, dimana dengan jumlah investasi dalam bentuk yang relatif kecil dapat digunakan untuk membuka posisi dengan aset yang bernilai jauh lebih tinggi. Apabila Anda tidak siap dengan risiko seperti ini, sebaiknya Anda tidak melakukan perdagangan Berjangka.',
      'Perdagangan Berjangka mempunyai risiko dan mempunyai kemungkinan kerugian yang tidak terbatas yang jauh lebih besar dari jumlah uang yang disetor (Margin) ke Pialang Berjangka. Berjangka sama dengan produk keuangan lainnya yang mempunyai risiko tinggi, Anda sebaiknya tidak menaruh risiko terhadap dana yang Anda tidak siap untuk menderita rugi, seperti tabungan pensiun, dana kesehatan atau dana untuk keadaan darurat, dana yang disediakan untuk pendidikan atau kepemilikan rumah, dana yang diperoleh dari pinjaman pendidikan atau gadai, atau dana yang digunakan untuk memenuhi kebutuhan sehari-hari.',
      'Berhati-hatilah terhadap pernyataan bahwa Anda pasti mendapatkan keuntungan besar dari perdagangan Berjangka. Meskipun perdagangan Berjangka dapat memberikan keuntungan yang besar dan cepat, namun hal tersebut tidak pasti, bahkan dapat menimbulkan kerugian yang besar dan cepat juga. Seperti produk keuangan lainnya, tidak ada yang dinamakan "pasti untung".',
      'Disebabkan adanya mekanisme leverage dan sifat dari transaksi Berjangka, Anda dapat merasakan dampak bahwa Anda menderita kerugian dalam waktu cepat. Keuntungan maupun kerugian dalam transaksi akan langsung dikredit atau didebet ke rekening Anda, paling lambat secara harian. Apabila pergerakan di pasar terhadap Berjangka menurunkan nilai posisi Anda dalam Berjangka, dengan kata lain berlawanan dengan posisi yang Anda ambil, Anda diwajibkan untuk menambah dana untuk pemenuhan kewajiban Margin ke perusahaan Pialang Berjangka. Apabila rekening Anda berada dibawah minimum Margin yang telah ditetapkan Lembaga Kliring Berjangka atau Pialang Berjangka, maka posisi Anda dapat dilikuidasi pada saat rugi, dan Anda wajib menyelesaikan defisit (jika ada) dalam rekening Anda.',
      'Pada saat pasar dalam keadaan tertentu, Anda mungkin akan sulit atau tidak mungkin melikuidasi posisi. Pada umumnya Anda harus melakukan transaksi mengambil posisi yang berlawanan dengan maksud melikuidasi posisi (offset) jika ingin melikuidasi posisi dalam Berjangka. Apabila Anda tidak dapat melikuidasi posisi Berjangka, Anda tidak dapat merealisasikan keuntungan pada nilai posisi tersebut atau mencegah kerugian yang lebih tinggi. Kemungkinan tidak dapat melikuidasi dapat terjadi, antara lain: jika perdagangan berhenti dikarenakan aktivitas perdagangan yang tidak lazim pada Kontrak Derivatif atau subjek Kontrak Derivatif, atau terjadi kerusakan sistem pada Pialang Berjangka Peserta Sistem Perdagangan Alternatif atau Pedagang Berjangka Penyelenggara Sistem Perdagangan Alternatif. Bahkan apabila Anda dapat melikuidasi posisi tersebut, Anda mungkin terpaksa melakukannya pada harga yang menimbulkan kerugian besar.',
      'Pada saat pasar dalam keadaan tertentu, Anda mungkin akan sulit atau tidak mungkin mengelola risiko atas posisi terbuka Berjangka dengan cara membuka posisi dengan nilai yang sama namun dengan posisi yang berlawanan dalam kontrak bulan yang berbeda, dalam pasar yang berbeda atau dalam “subjek Berjangka” yang berbeda. Kemungkinan untuk tidak dapat mengambil posisi dalam rangka membatasi risiko yang timbul, contohnya: jika perdagangan dihentikan pada pasar yang berbeda disebabkan aktivitas perdagangan yang tidak lazim pada Berjangka atau “Berjangka”.',
      'Anda dapat diwajibkan untuk menyelesaikan Kontrak Berjangkaengan penyerahan fisik dari “subjek Kontrak Berjangka”. Jika Anda mempertahankan posisi penyelesaian fisik dalam Kontrak Berjangka sampai hari terakhir perdagangan berdasarkan tanggal jatuh tempo Kontrak Berjangka, Anda akan diwajibkan menyerahkan atau menerima penyerahan “subjek Kontrak Berjangka” yang dapat mengakibatkan adanya penambahan biaya. Pengertian penyelesaian dapat berbeda untuk suatu Kontrak Berjangka dengan Kontrak Berjangka lainnya atau suatu Bursa Berjangka dengan Bursa Berjangka lainnya. Anda harus melihat secara teliti mengenai penyelesaian dan kondisi penyerahan sebelum membeli atau menjual Kontrak Berjangka.',
      'Semua Berjangka mempunyai risiko, dan tidak ada strategi berdagang yang dapat menjamin untuk menghilangkan risiko tersebut. Strategi dengan menggunakan kombinasi posisi seperti spread, dapat sama berisiko seperti posisi long atau short. Melakukan Perdagangan Berjangka memerlukan pengetahuan mengenai Berjangka dan pasar berjangka.',
      'Strategi perdagangan harian dalam Berjangka dan produk lainnya memiliki risiko khusus. Seperti pada produk keuangan lainnya, pihak yang ingin membeli atau menjual Berjangka yang sama dalam satu hari untuk mendapat keuntungan dari perubahan harga pada hari tersebut (“day traders”) akan memiliki beberapa risiko tertentu antara lain jumlah komisi yang besar, risiko terkena efek pengungkit (“exposure to leverage”), dan persaingan dengan pedagang profesional. Anda harus mengerti risiko tersebut dan memiliki pengalaman yang memadai sebelum melakukan perdagangan harian (“day trading”).',
      'Menetapkan amanat bersyarat, Berjangka dilikuidasi pada keadaan tertentu untuk membatasi rugi (stop loss), mungkin tidak akan dapat membatasi kerugian Anda sampai jumlah tertentu saja. Amanat bersyarat tersebut mungkin tidak dapat dilaksanakan karena terjadi kondisi pasar yang tidak memungkinkan melikuidasi Berjangka.',
      'Anda harus membaca dengan seksama dan memahami Perjanjian Pemberian Amanat Nasabah dengan Pialang Berjangka Anda sebelum melakukan transaksi Berjangka.',
      'Pernyataan singkat ini tidak dapat memuat secara rinci seluruh risiko atau aspek penting lainnya tentang Perdagangan Berjangka. Oleh karena itu Anda harus mempelajari kegiatan Perdagangan Berjangka secara cermat sebelum memutuskan melakukan transaksi.'
      'Dokumen Pemberitahuan Adanya Risiko (Risk Disclosure) ini dibuat dalam Bahasa Indonesia.',
      "Pernyataan singkat ini tidak dapat memuat secara rinci seluruh risiko atau aspek penting lainnya tentang Perdagangan Berjangka. Oleh karena itu Anda harus mempelajari kegiatan Perdagangan Berjangka secara cermat sebelum memutuskan melakukan transaksi.",
      "Dokumen Pemberitahuan Adanya Risiko (Risk Disclosure) ini dibuat dalam Bahasa Indonesia."
    ];

    if(stepController.selectedTypeOfCDD.value == "SPA"){
      agreementController.initList(itemsSPA.length);
    } else {
      agreementController.initList(itemsMulti.length);
    }

    return Scaffold(
      appBar: CustomAppBar.defaultAppBar(
        autoImplyLeading: true,
        title: "Step 9",
        actions: [
            // Obx(() {
            //   return DropdownButton(
            //     value: stepController.selectedTypeOfCDD.value,
            //     items: stepController.typeOfCDDList.map((type) {
            //       return DropdownMenuItem(
            //         value: type,
            //         child: Text(type),
            //       );
            //     }).toList(),
            //     onChanged: (value) {
            //       stepController.selectedTypeOfCDD.value = value ?? '';
            //     },
            //   );
            // }),
        ]
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Obx(
              () => CustomText.titleHeadingPage(
                context,
                text: stepController.selectedTypeOfCDD.value == "SPA" ? "Formulir Dokumen Resiko untuk Transaksi Kontrak Derivatif Dalam Sistem Perdagangan Alternatif." : "Formulir Dokumen Kontrak Berjangka",
              ),
            ),
            const Divider(),
            Obx(
              () => CustomText.titleHeadingPage(
                context,
                text: stepController.selectedTypeOfCDD.value == "SPA" ? "DOKUMEN PEMBERITAHUAN ADANYA RISIKO YANG HARUS DISAMPAIKAN OLEH PIALANG BERJANGKA UNTUK TRANSAKSI KONTRAK DERIVATIF DALAM SISTEM PERDAGANGAN ALTERNATIF" : "DOKUMEN PEMBERITAHUAN ADANYA RISIKO YANG HARUS DISAMPAIKAN OLEH PIALANG BERJANGKA UNTUK TRANSAKSI KONTRAK BERJANGKA",
              ),
            ),
            const SizedBox(height: 10.0),
            Obx(
              () => CustomText.normal(
                context,
                text: stepController.selectedTypeOfCDD.value == "SPA" ? "Dokumen Pemberitahuan Adanya Risiko ini disampaikan kepada Anda sesuai dengan Pasal 50 ayat (2) Undang-Undang Nomor 32 Tahun 1997 tentang Perdagangan Berjangka Komoditi sebagaimana telah diubah dengan Undang-Undang Nomor 10 Tahun 2011 tentang Perubahan Atas Undang-Undang Nomor 32 Tahun 1997 Tentang Perdagangan Berjangka Komoditi. Maksud dokumen ini adalah memberitahukan bahwa kemungkinan kerugian atau keuntungan dalam perdagangan Kontrak Derivatif Dalam Sistem Perdagangan Alternatif bisa mencapai jumlah yang sangat besar. Oleh karena itu, Anda harus berhati-hati dalam memutuskan untuk melakukan transaksi, apakah kondisi keuangan Anda mencukupi." : "Dokumen Pemberitahuan Adanya Risiko ini disampaikan kepada Anda sesuai dengan Pasal 50 ayat (2) Undang-Undang Nomor 32 Tahun 1997 tentang Perdagangan Berjangka Komoditi sebagaimana telah diubah dengan Undang-Undang Nomor 10 Tahun 2011 tentang Perubahan Atas Undang-Undang Nomor 32 Tahun 1997 Tentang Perdagangan Berjangka Komoditi. Maksud dokumen ini adalah memberitahukan bahwa kemungkinan kerugian atau keuntungan dalam perdagangan Kontrak Berjangka bisa mencapai jumlah yang sangat besar. Oleh karena itu, Anda harus berhati-hati dalam memutuskan untuk melakukan transaksi, apakah kondisi keuangan Anda mencukupi.",
                align: TextAlign.justify,
              ),
            ),
            NumberedAgreementList(items: stepController.selectedTypeOfCDD.value == "SPA" ? itemsSPA : itemsMulti),
            const SizedBox(height: 10.0),
            const TimeAndStatement(),
            const SizedBox(height: 20.0),
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
          if (!statementController.selectedStatement.value) {
            CustomScaffoldMessanger.showAppSnackBar(context, message: "Mohon centang \"YA\" pada checkbox persetujuan profil perusahaan berjangka", type: SnackBarType.error);
            return;
          }
          if (!agreementController.allChecked) {
            CustomScaffoldMessanger.showAppSnackBar(context,message: "Mohon centang semua poin risiko sebelum melanjutkan.", type: SnackBarType.error);
            return;
          }
          bool result = await _regolRepository.step9A();
          if(result) {
            Get.to(() => const Step10());
            return;
          }
          CustomScaffoldMessanger.showAppSnackBar(context, message: _regolRepository.responseMessage.value, type: SnackBarType.error);
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollAnimController.dispose();
    super.dispose();
  }
}