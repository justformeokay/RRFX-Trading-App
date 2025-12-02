import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/views/accounts/registration_online/components/button_next_previous.dart';
import 'package:rrfx/src/views/accounts/registration_online/components/time_and_statement.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/statement_controller.dart';
import 'package:rrfx/src/views/accounts/registration_online/repository/regol_repository.dart';
import 'package:rrfx/src/views/accounts/registration_online/views/registrasi_sukses.dart';

class Step17 extends StatelessWidget {
  const Step17({super.key});

  @override
  Widget build(BuildContext context) {
    final StatementController statementController = Get.find();
    final RegolRepository _regolRepository = Get.find<RegolRepository>();
    final processes = [
      "PROFILE PERUSAHAAN PIALANG BERJANGKA",
      "PERNYATAAN TELAH MELAKUKAN SIMULASI PERDAGANGAN BERJANGKA ATAU PERNYATAAN TELAH BERPENGALAMAN DALAM MELAKSANAKAN TRANSAKSI PERDAGANGAN BERJANGKA",
      "PERNYATAAN PENGUNGKAPAN (DISCLOSURE STATEMENT)",
      "APLIKASI PEMBUKAAN REKENING TRANSAKSI",
      "PERNYATAAN PENGUNGKAPAN (DISCLOSURE STATEMENT)",
      "DOKUMEN PEMBERITAHUAN ADANYA RISIKO",
      "PERNYATAAN PENGUNGKAPAN (DISCLOSURE STATEMENT)",
      "PERJANJIAN PEMBERIAN AMANAT",
      "DAFTAR KONTRAK BERJANGKA, KONTRAK DERIVATIF DAN KONTRAK DERIVATIF LAINNYA BESERTA PERATURAN PERDAGANGAN (TRADING RULES)",
      "PERNYATAAN BERTANGGUNG JAWAB ATAS KODE AKSES TRANSAKSI NASABAH (PERSONAL ACCESS PASSWORD)",
      "PERNYATAAN BAHWA DANA YANG DIGUNAKAN SEBAGAI MARGIN MERUPAKAN DANA MILIK NASABAH SENDIRI",
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    final headerColor = isDark ? Colors.grey.shade900 : Colors.grey.shade100;
    final rowAltColor = isDark ? Colors.grey.shade800 : Colors.grey.shade50;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text(
          "Step 16",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("VERIFIKASI KELENGKAPAN PROSES PENERIMAAN NASABAH SECARA ELEKTRONIK ONLINE", textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                color: headerColor,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 40,
                      child: Text("No", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: Text("Proses",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: textColor)),
                    ),
                    const SizedBox(
                      width: 70,
                      child: Text("Status",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              Divider(height: 0, color: borderColor),

              // List
              Expanded(
                child: ListView.separated(
                  itemCount: processes.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 0, color: borderColor),
                  itemBuilder: (context, index) {
                    return Container(
                      color: index.isEven ? Colors.transparent : rowAltColor,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 40,
                            child: Text(
                              "${index + 1}",
                              style: TextStyle(fontSize: 14, color: textColor),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              processes[index],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                                height: 1.3,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 70,
                            child: Icon(
                              Icons.check,
                              color: Colors.amber[600],
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: const TimeAndStatement(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ButtonNextPrevious(
        onPressed: () async {
          if (!statementController.selectedStatement.value) {
            CustomScaffoldMessanger.showAppSnackBar(context, message: "Mohon centang \"YA\" pada checkbox persetujuan profil perusahaan berjangka", type: SnackBarType.error);
            return;
          }
          bool result = await _regolRepository.step16();
          if(result) {
            Get.to(() => RegistrationSuccessPage());
            return;
          }
          CustomScaffoldMessanger.showAppSnackBar(context, message: _regolRepository.responseMessage.value, type: SnackBarType.error);
        },
      ),
    );
  }
}
