import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/buttons/elevated_button.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/languages/language_variable.dart';
import 'package:rrfx/src/components/textfields/label_textfield.dart';
import 'package:rrfx/src/components/textfields/otp_textfield.dart';
import 'package:rrfx/src/controllers/authentication.dart';
import 'package:rrfx/src/controllers/home.dart';
import 'package:rrfx/src/controllers/resend_otp_controller.dart';
import 'package:rrfx/src/helpers/formatters/masking_email.dart';
import 'package:rrfx/src/views/authentications/verification_account_page.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _formKey = GlobalKey<FormState>();
  final OtpTimerController otpTimerController = Get.put(OtpTimerController());
  RxBool isLoading = false.obs;
  RxString phoneCode = "".obs;
  RxString number = "".obs;
  AuthController authController = Get.find();
  TextEditingController otpController = TextEditingController();
  HomeController homeController = Get.find();

  @override
  void initState() {    
    super.initState();
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    otpTimerController.startTimer(duration: 60);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          forceMaterialTransparency: true,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent, // biar transparan
            statusBarIconBrightness: Brightness.light, // untuk Android → ikon putih
            statusBarBrightness: Brightness.dark, // untuk iOS → ikon putih
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Almost", style: GoogleFonts.inter(fontSize: 50, fontWeight: FontWeight.w700, color: CustomColor.secondaryColor, height: 1.0,)),
                      Text("Done!", style: GoogleFonts.inter(fontSize: 50, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.titleLarge?.color)),
                      const SizedBox(height: 5.0),
                      Obx(
                        () => isLoading.value ? const SizedBox() : Text(
                          "Inputkan kode OTP yang telah dikirim ke alamat email ${maskEmail(homeController.profileModel.value?.email ?? 'example@email.com')} yang telah didaftarkan sebelumnya.",
                          style: TextStyle(
                            color: CustomColor.textThemeLightSoftColor,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      LabelTextField.labelName(
                        label: "Kode OTP",
                        child: OTPTextField(
                          requiredField: true,
                          labelText: "Kode OTP",
                          fieldName: "Kode OTP",
                          controller: otpController,
                          hintText: "Masukkan Kode OTP",
                        )
                      ),
                      const SizedBox(height: 20.0),
                      Obx(() => ResendOtpText(
                        isResendAvailable: otpTimerController.isFinished,
                        secondsRemaining: otpTimerController.seconds.value,
                        onResend: () {
                          // Jalankan resend OTP API
                          // print("Resend OTP dipanggil");
                          // contoh call
                          authController.resendOTP().then((result){
                            if(result){
                              CustomScaffoldMessanger.showAppSnackBar(context, message: authController.responseMessage.value, type: SnackBarType.success);
                              otpTimerController.resetTimer(300);
                            }else{
                              CustomScaffoldMessanger.showAppSnackBar(context, message: authController.responseMessage.value, type: SnackBarType.error);
                            }
                          });
                        },
                      )),
                    ],
                  ),
                )
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Obx(
            () => DefaultButton.defaultElevatedButton(
              onPressed: authController.isLoading.value ? null : (){
                if(_formKey.currentState!.validate()){
                  authController.confirmOTP(otp: otpController.text).then((result){
                    if(result){
                      CustomScaffoldMessanger.showAppSnackBar(context, message: authController.responseMessage.value, type: SnackBarType.success);
                      
                      // ✅ After OTP verification, status changed to "active"
                      // Navigate to SetupPasscodePage (assuming no passcode yet)
                      Get.offAll(() => const VerificationAccountPage());
                    }else{
                      CustomScaffoldMessanger.showAppSnackBar(context, message: authController.responseMessage.value, type: SnackBarType.error);
                    }
                  });
                }
              },
              title: authController.isLoading.value ? "Processing..." : LanguageGlobalVar.SEND_OTP.tr
            ),
          ),
        ),
      ),
    );
  }
}

class ResendOtpText extends StatelessWidget {
  final VoidCallback onResend;
  final bool isResendAvailable;
  final int secondsRemaining;

  const ResendOtpText({
    super.key,
    required this.onResend,
    required this.isResendAvailable,
    this.secondsRemaining = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 14,
            color: CustomColor.textThemeLightSoftColor,
          ),
          children: [
            const TextSpan(text: "Tidak menerima kode OTP? "),
            isResendAvailable
                ? TextSpan(
                    text: "Kirim Ulang",
                    style: TextStyle(
                      color: CustomColor.secondaryColor,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = onResend,
                  )
                : TextSpan(
                    text: "Tunggu $secondsRemaining detik",
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

