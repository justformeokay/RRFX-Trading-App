import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/tables/pernyataan_persetujuan.dart';
import 'package:rrfx/src/components/textstyles/default.dart';
import 'package:rrfx/src/controllers/company_controller.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:rrfx/src/views/accounts/registration_online/components/button_next_previous.dart';
import 'package:rrfx/src/views/accounts/registration_online/components/time_and_statement.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/product_controller.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/progress_account_controller.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/statement_controller.dart';
import 'package:rrfx/src/views/accounts/registration_online/repository/regol_repository.dart';
import 'package:rrfx/src/views/accounts/registration_online/views/step_13.dart';

class Step12 extends StatefulWidget {
  const Step12({super.key});

  @override
  State<Step12> createState() => _Step12State();
}

class _Step12State extends State<Step12> {

  RxBool selectedStatement = false.obs;
  DateTime now = DateTime.now();
  RxString selectedAccountTrading = "".obs;
  
  TradingController tradingController = Get.find();
  final progressController = Get.find<ProgressAccountController>();
  CompanyController controller = Get.put(CompanyController());
  final RegolRepository _regolRepository = Get.find<RegolRepository>();

  Stream<DateTime> timeStream() {
    return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
  }

  String? localPath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _downloadFile(url: progressController.progressData.value?.response?.urlTradingRules ?? '');
  }

  Future<void> _downloadFile({String? url}) async {
    try {
      final response = await http.get(Uri.parse(url ?? ''));
      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/temp.pdf");
      await file.writeAsBytes(response.bodyBytes);
      setState(() {
        localPath = file.path;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StatementController());
    return Scaffold(
      appBar: CustomAppBar.defaultAppBar(
        autoImplyLeading: true,
        title: "Step 12"
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Center(
                  child: CustomText.titleHeadingPage(
                    context,
                    text: "PERATURAN PERDAGANGAN\n(TRADING RULES)",
                  ),
                ),
              ),
          
              // konten utama
              Expanded(
                child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: CustomColor.secondaryColor,
                      ),
                    )
                  : localPath == null
                    ? const Center(child: Text("Failed to load PDF"))
                    : PDFView(
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      filePath: localPath!,
                      enableSwipe: true,
                      swipeHorizontal: false,
                      autoSpacing: false,
                      pageFling: true,
                    ),
              ),
          
              StatementWidget.tradingRuleStatement(),
              const SizedBox(height: 10.0),
              TimeAndStatement(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ButtonNextPrevious(
        onPressed: () async {
          if(!controller.selectedStatement.value){
            CustomScaffoldMessanger.showAppSnackBar(context, message: "Mohon centang \"YA\" pada checkbox persetujuan profil perusahaan berjangka", type: SnackBarType.error);
            return;
          }
          bool result = await _regolRepository.step12();
          if(result) {
            Get.to(() => const Step13());
            return;
          }
          CustomScaffoldMessanger.showAppSnackBar(context, message: _regolRepository.responseMessage.value, type: SnackBarType.error);
        },
      )
    );
  }
}