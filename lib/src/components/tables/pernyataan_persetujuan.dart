import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/product_controller.dart';

class StatementWidget {
  static Container pernyataanTelahMembaca({String? dynamicTitlePart, String? title}){
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Center align the column content
        children: [
          // Title
          title == null ? const SizedBox() : Text(
            'PERNYATAAN TELAH MEMBACA $dynamicTitlePart',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          title == null ? const SizedBox() : const SizedBox(height: 15.0), // Space between title and main text
          // Main statement text
          Text.rich(
            TextSpan(
              text: 'Dengan mengisi kolom "YA" di bawah, saya menyatakan bahwa saya telah membaca dan menerima informasi ',
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14.0,
                height: 1.5, // Line height for better readability
              ),
              children: [
                TextSpan(
                  text: '$dynamicTitlePart,', // Dynamic part, make it bold if needed
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, // Make dynamic title bold in the statement
                  ),
                ),
                const TextSpan(
                  text: '\nmengerti dan memahami isinya.', // New line for "mengerti..."
                ),
              ],
            ),
            textAlign: TextAlign.center, // Center align the entire statement
          ),
        ],
      ),
    );
  }

  static Container pernyataanKebenaranDanTanggungJawab(){
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Center align the column content
        children: [
          // Title
          Text(
            'PERNYATAAN KEBENARAN DAN TANGGUNG JAWAB',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          const SizedBox(height: 15.0), // Space between title and main text
          // Main statement text
          Text.rich(
            TextSpan(
              text: 'Dengan mengisi kolom “YA” di bawah, saya menyatakan bahwa semua informasi dan semua dokumen yang saya lampirkan dalam ',
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14.0,
                height: 1.5, // Line height for better readability
              ),
              children: [
                TextSpan(
                  text: 'APLIKASI PEMBUKAAN REKENING TRANSAKSI SECARA ELEKTRONIK ONLINE ', // Dynamic part, make it bold if needed
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, // Make dynamic title bold in the statement
                  ),
                ),
                const TextSpan(
                  text: 'adalah benar dan tepat, Saya akan bertanggung jawab penuh apabila dikemudian hari terjadi sesuatu hal sehubungan dengan ketidakbenaran data yang saya berikan', // New line for "mengerti..."
                ),
              ],
            ),
            textAlign: TextAlign.center, // Center align the entire statement
          ),
        ],
      ),
    );
  }

  static Container pernyataanMenerimaPemberitahuanResiko(){
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Center align the column content
        children: [
          // Title
          Text(
            'PERNYATAAN MENERIMA PEMBERITAHUAN ADANYA RISIKO',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          const SizedBox(height: 15.0), // Space between title and main text
          // Main statement text
          Text.rich(
            TextSpan(
              text: 'Dengan mengisi kolom “YA” di bawah, saya menyatakan bahwa saya telah menerima ',
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14.0,
                height: 1.5, // Line height for better readability
              ),
              children: [
                TextSpan(
                  text: 'DOKUMEN PEMBERITAHUAN ADANYA RISIKO ', // Dynamic part, make it bold if needed
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, // Make dynamic title bold in the statement
                  ),
                ),
                const TextSpan(
                  text: 'mengerti dan menyetujui isinya.', // New line for "mengerti..."
                ),
              ],
            ),
            textAlign: TextAlign.center, // Center align the entire statement
          ),
        ],
      ),
    );
  }

  static Column pernyataanTelahMelakukanSimulasi({String? dynamicTitlePart}){
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Center align the column content
        children: [
          const SizedBox(height: 15.0), // Space between title and main text
          // Main statement text
          Text.rich(
            TextSpan(
              text: 'Dengan mengisi kolom "YA" di bawah, saya menyatakan bahwa saya telah melakukan simulasi bertransaksi di bidang Perdagangan di bidang kontrak derivatif sistem perdagangan alternatif pada ',
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14.0,
                height: 1.5, // Line height for better readability
              ),
              children: [
                TextSpan(
                  text: '$dynamicTitlePart,', // Dynamic part, make it bold if needed
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, // Make dynamic title bold in the statement
                  ),
                ),
                const TextSpan(
                  text: ' dan telah memahami tentang tata cara bertransaksi di bidang Perdagangan di bidang kontrak derivatif sistem perdagangan alternatif .', // New line for "mengerti..."
                ),
              ],
            ),
            textAlign: TextAlign.justify, // Center align the entire statement
          ),
          const SizedBox(height: 20),
          Text("Demikian Pernyataan ini dibuat dengan sebenarnya dalam keadaan sadar, sehat jasmani dan rohani serta tanpa paksaan apapun dari pihak manapun.", textAlign: TextAlign.justify, style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14.0,
            height: 1.5, // Line height for better readability
          ),)
        ],
    );
  }

  static Column aplikasiPembukaanRekeningTransaksi(){
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Center align the column content
        children: [
          const SizedBox(height: 15.0), // Space between title and main text
          // Main statement text
          Text.rich(
            TextSpan(
              text: 'Dengan mengisi kolom “YA” di bawah ini, saya menyatakan bahwa semua informasi dan semua dokumen yang saya lampirkan dalam ',
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14.0,
                height: 1.5, // Line height for better readability
              ),
              children: [
                TextSpan(
                  text: 'APLIKASI PEMBUKAAN REKENING TRANSAKSI SECARA ELEKTRONIK ONLINE ', // Dynamic part, make it bold if needed
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, // Make dynamic title bold in the statement
                  ),
                ),
                const TextSpan(
                  text: 'adalah benar dan tepat, Saya akan bertanggung jawab penuh apabila dikemudian hari terjadi sesuatu hal sehubungan dengan ketidakbenaran data yang saya berikan.', // New line for "mengerti..."
                ),
              ],
            ),
            textAlign: TextAlign.justify, // Center align the entire statement
          ),
        ],
    );
  }

  static Column danaSendiri(){
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Center align the column content
        children: [
          const SizedBox(height: 15.0), // Space between title and main text
          // Main statement text
          Text.rich(
            TextSpan(
              text: 'Dengan mengisi kolom “YA” di bawah ini, Bersama ini saya menyatakan bahwa dana yang saya gunakan untuk bertransaksi di ',
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14.0,
                height: 1.5, // Line height for better readability
              ),
              children: [
                TextSpan(
                  text: 'PT. RRFX Investasi Berjangka ', // Dynamic part, make it bold if needed
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, // Make dynamic title bold in the statement
                  ),
                ),
                const TextSpan(
                  text: 'adalah milik saya pribadi dan bukan dana pihak lain, serta tidak diperoleh dari hasil kejahatan, penipuan, penggelapan, tindak pidana korupsi, tindak pidan narkotika, tindak pidana di bidang kehutanan, hasil pencucian uang, dan perbuatan melawan hukum lainnya serta tidak dimaksudkan untuk melakukan pencucian uang dan/atau pendanaan terorisme.', // New line for "mengerti..."
                ),
              ],
            ),
            textAlign: TextAlign.justify, // Center align the entire statement
          ),
        ],
    );
  }

  static Column suratPernyataan(){
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Center align the column content
        children: [
          const SizedBox(height: 15.0), // Space between title and main text
          // Main statement text
          Text.rich(
            TextSpan(
              text: 'Bersama ini saya menyatakan bahwa dana yang saya gunakan untuk bertransaksi di ',
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14.0,
                height: 1.5, // Line height for better readability
              ),
              children: [
                TextSpan(
                  text: 'PT. RRFX Investasi Berjangka ', // Dynamic part, make it bold if needed
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, // Make dynamic title bold in the statement
                  ),
                ),
                const TextSpan(
                  text: 'adalah milik saya pribadi dan bukan dana pihak lain, serta tidak d iperoleh dari hasil kejahatan, penipuan, penggelapan, tindak pidana korupsi, tindak pidana narkotika , tindak pidana di bidang kehutanan, hasil pencucian uang, dan perbuatan melawan hukum lainnya serta tidak dimaksudkan untuk melakukan pencucian uang dan/atau pendanaan terorisme.', // New line for "mengerti..."
                ),
              ],
            ),
            textAlign: TextAlign.justify, // Center align the entire statement
          ),
        ],
    );
  }

  static Column pernyataanTelahBerpengalaman({String? dynamicTitlePart}){
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Center align the column content
        children: [
          const SizedBox(height: 15.0), // Space between title and main text
          // Main statement text
          Text('Dengan mengisi kolom "YA" di bawah, saya menyatakan bahwa saya telah memiliki pengalamann yang mencukupi dalam melaksanakan transaksi Perdaganan Berjangka karena pernah bertransaksi pada Perusahaan Pialang Berjangka dan telah memahami tentang cara bertransaksi Perdaganan Berjangka.', textAlign: TextAlign.justify, style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14.0,
            height: 1.5, // Line height for better readability
          ),),
          const SizedBox(height: 20),
          Text("Demikian Pernyataan ini dibuat dengan sebenarnya dalam keadaan sadar, sehat jasmani dan rohani serta tanpa paksaan apapun dari pihak manapun.", textAlign: TextAlign.justify, style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14.0,
            height: 1.5, // Line height for better readability
          ),)
        ],
    );
  }

  static Column perjanjainPemberianAmanat({String? dynamicTitlePart}){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // Center align the column content
      children: [
        const SizedBox(height: 15.0), // Space between title and main text
        // Main statement text
        Text('SECARA DETAIL BACA SELURUH DOKUMEN PEMBERITAHUAN ADANYA RISIKO DAN DOKUMEN PERJANJIAN PEMBERIAN AMANAT', textAlign: TextAlign.justify, style: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14.0,
          height: 1.5, // Line height for better readability
        ),),
        const SizedBox(height: 20),
        Text("Demikian Pernyataan ini dibuat dengan sebenarnya dalam keadaan sadar, sehat jasmani dan rohani serta tanpa paksaan apapun dari pihak manapun.", textAlign: TextAlign.justify, style: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14.0,
          height: 1.5, // Line height for better readability
        ),)
      ],
    );
  }

  static Column tradingRuleStatement({String? dynamicTitlePart}){
    final productController = Get.find<ProductController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // Center align the column content
      children: [
        const SizedBox(height: 15.0), // Space between title and main text
        // Main statement text
        Obx(
          () => Text('Biaya yang dikenakan setiap pelaksanaan transaksi: ${productController.komisiSelected.value} USD', textAlign: TextAlign.justify, style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14.0,
            height: 1.5, // Line height for better readability
          ),),
        ),
        const SizedBox(height: 20),
        Text("Dengan mengisi kolom “YA” di bawah ini, saya menyatakan bahwa saya telah membaca tentang PERATURAN PERDAGANGAN (TRADING RULES), mengerti dan menerima ketentuan dalam bertransaksi.", textAlign: TextAlign.justify, style: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14.0,
          height: 1.5, // Line height for better readability
        ),)
      ],
    );
  }

  static Widget paraPihak(context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 15,
          color: Theme.of(context).textTheme.bodySmall?.color
        ),
        children: [
          TextSpan(
              text: "Nasabah dan Pialang Berjangka secara bersama - sama selanjutnya di sebut "),
          TextSpan(
            text: "Para Pihak.",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static Widget kodeAkses(context) {
    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(
        style: TextStyle(
          fontSize: 15,
          color: Theme.of(context).textTheme.bodySmall?.color
        ),
        children: [
          TextSpan(text: "Dengan mengisi kolom “YA” di bawah, saya menyatakan bahwa saya bertanggungjawab sepenuhnya terhadap kode akses transaksi Nasabah "),
          TextSpan(
            text: "(Personal Access Password) ",
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          TextSpan(text: "dan tidak menyerahkan kode akses transaksi Nasabah "),
          TextSpan(
            text: "(Personal Access Password) ",
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          TextSpan(text: "ke pihak lain, terutama kepada pegawai Pialang Berjangka atau pihak yang memiliki kepentingan dengan Pialang Berjangka."),
        ],
      ),
    );
  }

  static Widget danaPribadi() {
    return RichText(
      textAlign: TextAlign.justify,
      text: const TextSpan(
        style: TextStyle(
          fontSize: 15,
          color: Colors.black54,
        ),
        children: [
          TextSpan(text: "Dengan di bawah "),
          TextSpan(
            text: "mengisi kolom “YA” di bawah ",
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          TextSpan(text: "bersama ini saya menyatakan bahwa dana yang saya gunakan untuk bertransaksi di PT. VIG Group Futures adalah milik saya pribadi dan bukan dana pihak lain, serta tidak diperoleh dari hasil kejahatan, penipuan, penggelapan, tindak pidana korupsi, tindak pidana narkotika, tindak pidana di bidang kehutanan, hasil pencucian uang, dan perbuatan melawan hukum lainnya serta tidak dimaksudkan untuk melakukan pencucian uang dan/atau pendanaan terorisme."),
        ],
      ),
    );
  }
}