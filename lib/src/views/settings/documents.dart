import 'dart:io';
import 'package:dio/dio.dart';
// import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rrfx/src/helpers/formatters/number_formatter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/containers/utilities.dart';
import 'package:rrfx/src/controllers/company_controller.dart';
import 'package:rrfx/src/controllers/trading.dart';

class Documents extends StatefulWidget {
  const Documents({super.key, this.loginID});
  final String? loginID;

  @override
  State<Documents> createState() => _DocumentsState();
}

class _DocumentsState extends State<Documents> {
  CompanyController companyController = Get.put(CompanyController());

  final RxList<Map<String, String>> documents = <Map<String, String>>[].obs;
  RxInt selectedIndexAccountTrading = 0.obs;
  RxString selectedAccountTrading = "".obs;
  RxString selectedAccountTradingHash = "".obs;
  TradingController tradingController = Get.put(TradingController());

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, (){
      tradingController.getTradingAccount().then((result){
        if(tradingController.tradingAccountModels.value?.response.real?.isNotEmpty == true){
          selectedAccountTradingHash(tradingController.tradingAccountModels.value?.response.real?[0].id);
          selectedAccountTrading(tradingController.tradingAccountModels.value?.response.real?[0].login);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final data = [
      {
        "name": "Profile Perusahaan",
        "url": "https://client-rrfx.luxurymatrix.com/export/profile-perusahaan?acc=$selectedAccountTradingHash"
      },
      {
        "name": "Pernyataan Simulasi / PERNYATAAN TELAH MELAKUKAN SIMULASI PERDAGANGAN BERJANGKA KOMODITI",
        "url": "https://client-rrfx.luxurymatrix.com/export/pernyataan-simulasi?acc=$selectedAccountTradingHash"
      },
      {
        "name": "Pernyataan Pengalaman / SURAT PERNYATAAN TELAH BERPENGALAMAN MELAKSANAKAN TRANSAKS",
        "url": "https://client-rrfx.luxurymatrix.com/export/pernyataan-pengalaman?acc=$selectedAccountTradingHash"
      },
      {
        "name": "Pernyataan Pengungkapan / Disclosure Statement",
        "url": "https://client-rrfx.luxurymatrix.com/export/pernyataan-pengungkapan?acc=$selectedAccountTradingHash"
      },
      {
        "name": "Aplikasi Pembukaan Rekening / APLIKASI PEMBUKAAN REKENING TRANSAKSI SECARA ELEKTRONIK ONLINE",
        "url": "https://client-rrfx.luxurymatrix.com/export/aplikasi-pembukaan-rekening?acc=$selectedAccountTradingHash"
      },
      {
        "name": "Dokumen Pemberitahuan Adanya resiko / DOKUMEN PEMBERITAHUAN ADANYA RISIKO YANG HARUS DISAMPAIKAN OLEH PIALANG BERJANGKA UNTUK TRANSAKSI KONTRAK DERIVATIF DALAM SISTEM PERDAGANGAN ALTERNATIF",
        "url": "https://client-rrfx.luxurymatrix.com/export/pemberitahuan-adanya-risiko?acc=$selectedAccountTradingHash"
      },
      {
        "name": "Perjanjian Pemberian Amanat / PERJANJIAN PEMBERIAN AMANAT SECARA ELEKTRONIK ONLINE UNTUK TRANSAKSI KONTRAK DERIVATIF DALAM SISTEM PERDAGANGAN ALTERNATIF",
        "url": "https://client-rrfx.luxurymatrix.com/export/perjanjian-pemberian-amanat?acc=$selectedAccountTradingHash"
      },
      {
        "name": "Personal Access Password / PERNYATAAN BERTANGGUNG JAWAB ATAS KODE AKSES TRANSAKSI NASABAH",
        "url": "https://client-rrfx.luxurymatrix.com/export/personal-access-password?acc=$selectedAccountTradingHash"
      },
      {
        "name": "Pernyataan Dana Nasabah / PERNYATAAN BAHWA DANA YANG DIGUNAKAN SEBAGAI MARGIN MERUPAKAN DANA MILIK NASABAH SENDIR",
        "url": "https://client-rrfx.luxurymatrix.com/export/pernyataan-dana-nasabah?acc=$selectedAccountTradingHash"
      },
      {
        "name": "Kelengkapan Formulir",
        "url": "https://client-rrfx.luxurymatrix.com/export/kelengkapan-formulir?acc=$selectedAccountTradingHash"
      },
      {
        "name": "Surat Pernyataan Diterima",
        "url": "https://client-rrfx.luxurymatrix.com/export/surat-pernyataan?acc=$selectedAccountTradingHash"
      },
    ];
    return Scaffold(
      appBar: CustomAppBar.defaultAppBar(
        title: "Dokumen",
        autoImplyLeading: true,
        actions: [
          tradingController.tradingAccountModels.value?.response.real?.isNotEmpty == true ? CupertinoButton(
            onPressed: (){
              CustomMaterialBottomSheets.defaultBottomSheet(context, title: "Pilih Akun Trading", size: size, children: List.generate(tradingController.tradingAccountModels.value?.response.real?.length ?? 0, (i){
                final account = tradingController.tradingAccountModels.value?.response.real?[i];
                return ListTile(
                  subtitle: Text("${account?.currency} - ${account?.login ?? "-"}", style: GoogleFonts.inter(fontWeight: FontWeight.w400, color: Colors.black45)),
                  title: Text("${account?.namaTipeAkun ?? "-"} (1:${NumberFormatter.cleanNumber(account?.leverage ?? '0')})", style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                  onTap: (){
                    selectedAccountTrading(tradingController.tradingAccountModels.value?.response.real?[i].login);
                    selectedIndexAccountTrading(i);
                    selectedAccountTradingHash(tradingController.tradingAccountModels.value?.response.real?[i].id);
                    Get.back();
                  },
                  leading: Icon(Icons.group, color: CustomColor.defaultColor),
                  trailing: Icon(AntDesign.arrow_right_outline, color: CustomColor.defaultColor),
                );
              }));
            },
            padding: EdgeInsets.zero,
            child: Icon(Bootstrap.person_fill_gear, color: CustomColor.defaultColor)
        ).paddingZero : const SizedBox(),
        ]
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: tradingController.tradingAccountModels.value?.response.real?.isEmpty == true ? [
            SizedBox(
              width: size.width,
              height: size.height / 1.2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber_rounded, size: 30, color: Colors.red),
                  const SizedBox(height: 10.0),
                  Text("Anda belum memiliki akun trading real")
                ],
              ),
            )
          ] : [
            Obx(
              () => UtilitiesWidget.titleContent(
                title: "Daftar Dokumen Trading",
                subtitle: "Semua dokumen mengenai akun Trading $selectedAccountTrading anda ada dalam daftar dibawah ini.",
                children: List.generate(data.length, (i){
                  return cardDocument(
                    title: data[i]['name'],
                    onDownload: (){
                      print("${data[i]['url']}$selectedAccountTradingHash");
                      Get.to(() => PdfDownloadAndViewerPage(pdfUrl: "${data[i]['url']}$selectedAccountTradingHash"));
                    }
                  );
                })
              ),
            ),
            const SizedBox(height: 60.0)
          ],
        ),
      ),
    );
  }

  Widget cardDocument({String? title, String? description, Function()? onDownload}){
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.black12)
      ),
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Bootstrap.file_earmark_pdf, size: 28, color: CustomColor.secondaryColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title ?? "Title",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (onDownload != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero
                ),
                onPressed: onDownload,
                icon: Icon(Icons.remove_red_eye, color: CustomColor.secondaryColor),
                label: Text("Lihat Dokumen", style: GoogleFonts.inter(color: CustomColor.secondaryColor, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}

class PdfDownloadAndViewerPage extends StatefulWidget {
  final String pdfUrl;
  const PdfDownloadAndViewerPage({super.key, required this.pdfUrl});

  @override
  State<PdfDownloadAndViewerPage> createState() => _PdfDownloadAndViewerPageState();
}

class _PdfDownloadAndViewerPageState extends State<PdfDownloadAndViewerPage> {
  String? _localFilePath;
  bool _isDownloading = false;
  double _downloadProgress = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _downloadPdf();
  }

  Future<void> _downloadPdf() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
      _errorMessage = null;
    });

    try {
      final dio = Dio();
      final directory = await getApplicationDocumentsDirectory();
      final fileName = widget.pdfUrl.split('/').last.split('?').first;
      final filePath = '${directory.path}/$fileName';

      await dio.download(
        widget.pdfUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      setState(() {
        _localFilePath = filePath;
        _isDownloading = false;
      });
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _errorMessage = 'Failed to download PDF: $e';
      });
    }
  }

  // /// Simpan PDF ke folder Download
  // Future<void> _saveToPublicDocuments() async {
  //   if (_localFilePath == null) return;

  //   final fileBytes = await File(_localFilePath!).readAsBytes();

  //   await FileSaver.instance.saveFile(
  //     name: _localFilePath!.split('/').last,
  //     bytes: fileBytes,
  //     mimeType: MimeType.pdf,
  //   );

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text("Berhasil disimpan ke folder Documents/Download")),
  //   );
  // }

  /// Share PDF
  Future<void> _sharePdf() async {
    if (_localFilePath != null) {
      // Pastikan nama file berakhiran .pdf
      String newPath = _localFilePath!;
      if (!newPath.toLowerCase().endsWith('.pdf')) {
        newPath = "${_localFilePath!}.pdf"; // Tambahkan ekstensi .pdf
        await File(_localFilePath!).copy(newPath); // Copy file ke nama baru
      }

      final pdfFile = XFile(
        newPath,
        mimeType: 'application/pdf',
        name: newPath.split('/').last, // contoh: example.pdf
      );

      await SharePlus.instance.share(
        ShareParams(
          files: [pdfFile],
          text: "Bagikan dokumen PDF",
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
        actions: [
          if (_localFilePath != null) ...[
            IconButton(
              icon: const Icon(Icons.share, color: CustomColor.secondaryColor),
              onPressed: _sharePdf,
              tooltip: "Share PDF",
            ),
          ]
        ],
      ),
      body: Center(
        child: _isDownloading
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text('Downloading: ${(_downloadProgress * 100).toStringAsFixed(1)}%'),
              ],
            )
          : Center(
            child: _errorMessage != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.error, size: 30.0, color: Colors.red),
                    SizedBox(height: 10.0),
                    Text("Gagal mendapatkan dokumen", textAlign: TextAlign.justify),
                  ],
                )
              : _localFilePath != null
                ? SfPdfViewer.file(File(_localFilePath!))
                : const Text('No PDF to display. Start download.'),
          ),
      ),
    );
  }
}
