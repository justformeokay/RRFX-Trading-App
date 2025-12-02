import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/buttons/elevated_button.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/languages/language_variable.dart';
import 'package:rrfx/src/components/textfields/label_textfield.dart';
import 'package:rrfx/src/components/textfields/password_textfield.dart';
import 'package:rrfx/src/controllers/trading.dart';

class ChangePasswordReal extends StatefulWidget {
  const ChangePasswordReal({super.key, this.loginID, this.tradingID});
  final String? loginID;
  final String? tradingID;

  @override
  State<ChangePasswordReal> createState() => _ChangePasswordRealState();
}

class _ChangePasswordRealState extends State<ChangePasswordReal> {
  TextEditingController passwordTextField = TextEditingController();
  TextEditingController confirmPasswordTextField = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  TradingController tradingController = Get.find();

  @override
  void dispose() {
    passwordTextField.dispose();
    confirmPasswordTextField.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.defaultAppBar(
        autoImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Change", style: GoogleFonts.inter(fontSize: 50, fontWeight: FontWeight.w700, color: CustomColor.secondaryColor, height: 1.0,)),
              Text("password Meta", style: GoogleFonts.inter(fontSize: 50, fontWeight: FontWeight.w700, color: Colors.black)),
              const SizedBox(height: 5.0),
              Text("Ubah password akun ${widget.loginID} Meta Trader 5 anda dengan menginputkan password baru.", style: TextStyle(color: CustomColor.textThemeLightSoftColor, fontSize: 15)),
              const SizedBox(height: 30.0),
              LabelTextField.labelName(
                label: LanguageGlobalVar.PASSWORD.tr,
                child: PasswordTextField(
                  fieldName: LanguageGlobalVar.PASSWORD.tr,
                  controller: passwordTextField,
                  hintText: LanguageGlobalVar.CREATE_PASSWORD.tr,
                )
              ),
              LabelTextField.labelName(
                label: LanguageGlobalVar.REPEAT_PASSWORD.tr,
                child: PasswordTextField(
                  fieldName: LanguageGlobalVar.REPEAT_PASSWORD.tr,
                  controller: confirmPasswordTextField,
                  hintText: LanguageGlobalVar.REPEAT_PASSWORD.tr,
                )
              ),
              const SizedBox(height: 10.0),
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => DefaultButton.defaultElevatedButton(
                    onPressed: (){
                      if(_formKey.currentState!.validate()){
                        if(confirmPasswordTextField.text != passwordTextField.text){
                          CustomScaffoldMessanger.showAppSnackBar(context, message: "Password tidak sama, mohon cek ulang", type: SnackBarType.error);
                        }else{
                          if(widget.tradingID != null){
                            tradingController.inputPassword(accountId: widget.tradingID!, password: confirmPasswordTextField.text).then((result){
                              if(result['status']){
                                CustomScaffoldMessanger.showAppSnackBar(context, message: result['message'], type: SnackBarType.success);
                              }
                            });
                          }else{
                            CustomScaffoldMessanger.showAppSnackBar(context, message: "Akun ID tidak ditemukan", type: SnackBarType.error);
                          }
                        }
                      }
                    },
                    title: tradingController.isLoading.value ? "Processing..." : "Change Password"
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}