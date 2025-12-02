import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/alerts/default.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/views/accounts/local_pdf_view.dart';
import 'package:rrfx/src/views/mainpage.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/containers/utilities.dart';
import 'package:rrfx/src/components/languages/language_variable.dart';
import 'package:rrfx/src/controllers/company_controller.dart';
import 'package:rrfx/src/controllers/regol.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/views/accounts/step_16_success.dart';
import 'components/step_position.dart';

class Step14KelengkapanDokumenPerusahaan extends StatefulWidget {
  const Step14KelengkapanDokumenPerusahaan({super.key});

  @override
  State<Step14KelengkapanDokumenPerusahaan> createState() => _Step14KelengkapanDokumenPerusahaan();
}

class _Step14KelengkapanDokumenPerusahaan extends State<Step14KelengkapanDokumenPerusahaan> {
  CompanyController companyController = Get.put(CompanyController());
  RegolController regolController = Get.put(RegolController());
  final _formKey = GlobalKey<FormState>();
  RxString selectedAccountTrading = "".obs;
  RxBool selectedStatement = false.obs;
  RxInt selectedIndexAccountTrading = 0.obs;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, (){
      regolController.progressAccount().then((result){
        if(result){
          selectedAccountTrading(regolController.accountModel.value?.response?.idHash);
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: CustomAppBar.defaultAppBar(
          autoImplyLeading: true,
          title: "Peraturan",
          actions: [
            CupertinoButton(
              onPressed: () async {
                CustomAlert.alertDialogCustomInfo(
                  title: "Confirmation",
                  message: "Are you sure you want to cancel? All data will be lost.",
                  moreThanOneButton: true,
                  onTap: () {
                    Get.offAll(() => const Mainpage());
                  },
                  textButton: "Yes",
                );
              },
              child: Text(LanguageGlobalVar.CANCEL.tr, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: CustomColor.defaultColor)),
            ),
          ]
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                UtilitiesWidget.titleContent(
                    title: "Dokumen Persetujuan",
                    subtitle: "Saya menyatakan telah membaca dan menyetujui masing masing dokumen yang dikeluarkan oleh ${GlobalVariable.namaPerusahaan} sebagai berikut:",
                    children: [
                      CheckboxListTile(
                        activeColor: CustomColor.secondaryColor,
                        contentPadding: EdgeInsets.zero,
                        title: Text('Profile Perusahaan Pialang Berjangka', style: GoogleFonts.inter(fontSize: 16.0)),
                        value: true,
                        onChanged:(bool? value) {
                          Get.to(() => LocalPdfViewer(
                            pdfUrl: companyController.profilePerusahaan(acc: selectedAccountTrading.value),
                            title: "Profil Perusahaan Pialang Berjangka",
                          ));
                          // Get.to(() => WebPdfViewer(pdfUrl: companyController.profilePerusahaan(acc: selectedAccountTrading.value), title: "Profil Perusahaan Pialang Berjangka"));
                        },
                      ),
                      CheckboxListTile(
                        activeColor: CustomColor.secondaryColor,
                        contentPadding: EdgeInsets.zero,
                        title: Text('Pernyataan Simulasi', style: GoogleFonts.inter(fontSize: 16.0)),
                        value: true,
                        onChanged:(bool? value) {
                          Get.to(() => LocalPdfViewer(pdfUrl: companyController.pernyataanSimulasi(acc: selectedAccountTrading.value), title: "Pernyataan Simulasi"));
                        },
                      ),
                      CheckboxListTile(
                        activeColor: CustomColor.secondaryColor,
                        contentPadding: EdgeInsets.zero,
                        title: Text('Pernyataaan Telah Berpengalaman', style: GoogleFonts.inter(fontSize: 16.0)),
                        value: true,
                        onChanged:(bool? value) {
                          Get.to(() => LocalPdfViewer(pdfUrl: companyController.pernyataanPengalaman(acc: selectedAccountTrading.value), title: "Pernyataan Pengalaman"));
                        },
                      ),
                      CheckboxListTile(
                        activeColor: CustomColor.secondaryColor,
                        contentPadding: EdgeInsets.zero,
                        title: Text('Pernyataaan Pengungkapan', style: GoogleFonts.inter(fontSize: 16.0)),
                        value: true,
                        onChanged:(bool? value) {
                          Get.to(() => LocalPdfViewer(pdfUrl: companyController.suratPernyataanPenerimaanNasabah(acc: selectedAccountTrading.value), title: "Pernyataaan Pengungkapan"));
                        },
                      ),
                      CheckboxListTile(
                        activeColor: CustomColor.secondaryColor,
                        contentPadding: EdgeInsets.zero,
                        title: Text('Aplikasi Pembukaaan Rekening Transaksi', style: GoogleFonts.inter(fontSize: 16.0)),
                        value: true,
                        onChanged:(bool? value) {
                          Get.to(() => LocalPdfViewer(pdfUrl: companyController.aplikasiPembukaanRekening(acc: selectedAccountTrading.value), title: "Aplikasi Pembukaaan Rekening Transaksi"));
                        },
                      ),
                      CheckboxListTile(
                        activeColor: CustomColor.secondaryColor,
                        contentPadding: EdgeInsets.zero,
                        title: Text('Dokumen Pemberitahuan Adanya Resiko', style: GoogleFonts.inter(fontSize: 16.0)),
                        value: true,
                        onChanged:(bool? value) {
                          Get.to(() => LocalPdfViewer(pdfUrl: companyController.dokumenPemberitahuanAdanyaResiko(acc: selectedAccountTrading.value), title: "Dokumen Pemberitahuan Adanya Resiko"));
                        },
                      ),
                      CheckboxListTile(
                        activeColor: CustomColor.secondaryColor,
                        contentPadding: EdgeInsets.zero,
                        title: Text('Peraturan Perdagangan (Trading Rules)', style: GoogleFonts.inter(fontSize: 16.0)),
                        value: true,
                        onChanged:(bool? value) {
                          Get.to(() => LocalPdfViewer(pdfUrl: companyController.tradingRules(acc: selectedAccountTrading.value), title: "Trading Rules"));
                        },
                      ),
                      CheckboxListTile(
                        activeColor: CustomColor.secondaryColor,
                        contentPadding: EdgeInsets.zero,
                        title: Text('Kode Akses', style: GoogleFonts.inter(fontSize: 16.0)),
                        value: true,
                        onChanged:(bool? value) {
                          Get.to(() => LocalPdfViewer(pdfUrl: companyController.personalAccessPassword(acc: selectedAccountTrading.value), title: "Kode Akses"));
                        },
                      ),
                      CheckboxListTile(
                        activeColor: CustomColor.secondaryColor,
                        contentPadding: EdgeInsets.zero,
                        title: Text('Pernyataan Sumber Dana Milik Sendiri', style: GoogleFonts.inter(fontSize: 16.0)),
                        value: true,
                        onChanged:(bool? value) {
                          Get.to(() => LocalPdfViewer(pdfUrl: companyController.pernyataanDanaNasabah(acc: selectedAccountTrading.value), title: "Pernyataan Sumber Dana Milik Sendiri"));
                        },
                      ),
                      CheckboxListTile(
                        activeColor: CustomColor.secondaryColor,
                        contentPadding: EdgeInsets.zero,
                        title: Text('Pernytaan Penerimaan Nasabah', style: GoogleFonts.inter(fontSize: 16.0)),
                        value: true,
                        onChanged:(bool? value) {
                          Get.to(() => LocalPdfViewer(pdfUrl: companyController.suratPernyataanPenerimaanNasabah(acc: selectedAccountTrading.value), title: "Pernytaan Penerimtaan Nasabah"));
                        },
                      ),
                      CheckboxListTile(
                        activeColor: CustomColor.secondaryColor,
                        contentPadding: EdgeInsets.zero,
                        title: Text('Formulir Verifikasi Kelengkapan', style: GoogleFonts.inter(fontSize: 16.0)),
                        value: true,
                        onChanged:(bool? value) {
                          Get.to(() => LocalPdfViewer(pdfUrl: companyController.formulirVerifikasiKelengkapan(acc: selectedAccountTrading.value), title: "Formulir Verifikasi Kelengkapan"));
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
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
                      )
                    ]
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Obx(
          () => StepUtilities.stepOnlineRegister(
            size: size,
            title: regolController.isLoading.value ? "Processing..." : "Dokumen Persetujuan",
            onPressed: regolController.isLoading.value ? null : (){
              regolController.kelengkapanDokumen(pernyataan: selectedStatement.value ? "ya" : "tidak").then((result){
                if(!result){
                  CustomScaffoldMessanger.showAppSnackBar(context, message: "Please check all the documents", type: SnackBarType.error);
                  return;
                }
                Get.to(() => const SuccessSubmit());
              });
            },
            progressEnd: 4,
            currentAllPageStatus: 3,
            progressStart: 4
          ),
        ),
      ),
    );
  }
}

