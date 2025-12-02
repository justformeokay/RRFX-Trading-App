import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/buttons/custom_buttons.dart';
import 'package:rrfx/src/components/containers/utilities.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/progress_account_controller.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/statement_controller.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/step_controller.dart';
import 'package:rrfx/src/views/accounts/registration_online/repository/regol_repository.dart';
import 'package:rrfx/src/views/accounts/registration_online/views/step_2.dart';

class Step1 extends StatefulWidget {
  const Step1({super.key});

  @override
  State<Step1> createState() => _Step1State();
}

class _Step1State extends State<Step1> {
  final controller = Get.put(StepController());
  RegolRepository regolController = Get.put(RegolRepository());
  final progressController = Get.put(ProgressAccountController());
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.fetchAccounts();
      await progressController.fetchProgressAccount(); // ✅ panggil API di sini

      if (controller.accounts.isEmpty) {
        Get.log("ACCOUNTS IS NULL");
        return;
      }
      Get.log('ACCOUNTS LENGTH IS ${controller.accounts.length}');
    });
  }
  
  @override
  Widget build(BuildContext context) {
    Get.put(StatementController());
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar.defaultAppBar(
          autoImplyLeading: true,
          title: "Step 1"
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: UtilitiesWidget.titleContent(
            title: "Informasi Demo Account",
            subtitle: "Semua informasi menyangkut demo akun anda",
            children: [
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black54, width: 0.3),
                    borderRadius: BorderRadius.circular(5.0)
                  ),
                  child: Column(
                    children: [
                      Obx(() {
                        for(int i = 0; i<controller.accounts.length; i++){
                          if(controller.accounts[i].type == 'demo'){
                            return _buildRowItem(key: "Login Meta:", value: controller.accounts[i].login);
                          }
                        }
                        return const SizedBox();
                      }),
                      _buildRowItem(key: "Password Meta:", value: ""),
                      _buildRowItem(key: "Investor Meta:", value: ""),
                      _buildRowItem(key: "Phone Meta:", value: ""),
                      _buildRowItem(key: "Server Meta:", value: "RRFX-Demo"),
                    ],
                  ),
                ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: CustomButtons.buildIconButton(text: "Berikutnya", textColor: Colors.black, iconColor: Colors.black, onPressed: (){
                Get.to(() => const Step2());
              }, icon: Icons.arrow_right))
            ],
          ),
        ),
      )
    );
  }

  Widget _buildRowItem({String? key, String? value}){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Text(key ?? "Key", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 5.0),
          Text(value ?? "Value", style: TextStyle()),
        ],
      ),
    );
  }
}