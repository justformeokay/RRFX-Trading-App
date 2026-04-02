import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/buttons/elevated_button.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/languages/language_variable.dart';
import 'package:rrfx/src/components/textfields/email_textfield.dart';
import 'package:rrfx/src/components/textfields/label_textfield.dart';
import 'package:rrfx/src/components/widgets/build_version_indicator.dart';
import 'package:rrfx/src/controllers/authentication.dart';

class Forgot extends StatefulWidget {
  const Forgot({super.key});

  @override
  State<Forgot> createState() => _ForgotState();
}

class _ForgotState extends State<Forgot> {
  final _formKey = GlobalKey<FormState>();
  RxBool isLoading = false.obs;
  RxString phoneCode = "".obs;
  RxString number = "".obs;
  RxBool isEmailValid = false.obs;
  AuthController authController = Get.find();
  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Listen to email changes for real-time validation
    emailController.addListener(_validateEmail);
  }

  void _validateEmail() {
    final email = emailController.text.trim();
    final regex = RegExp(r'^[a-zA-Z0-9\.\+\-_]+@[a-zA-Z0-9\.\-]+\.[a-zA-Z]{2,}$');
    isEmailValid.value = email.isNotEmpty && regex.hasMatch(email);
  }

  Future<void> _handleForgotPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check internet connection first
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      AppSnackbar.error(
        'Tidak ada koneksi internet. Periksa koneksi WiFi atau data seluler Anda.',
      );
      return;
    }

    try {
      // Add timeout of 15 seconds
      final result = await authController
          .forgotPassword(email: emailController.text)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException('Request timeout');
            },
          );

      if (!result) {
        AppSnackbar.error(authController.responseMessage.value);
        return;
      }

      AppSnackbar.success(authController.responseMessage.value);
      Future.delayed(const Duration(seconds: 2), () {
        Get.back();
      });
    } on TimeoutException catch (_) {
      AppSnackbar.error(
        'Koneksi terlalu lambat. Proses memakan waktu lebih dari 15 detik. Silakan coba lagi.',
      );
    } on SocketException catch (_) {
      AppSnackbar.error(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } catch (e) {
      AppSnackbar.error('Terjadi kesalahan. Silakan coba lagi.');
    }
  }

  @override
  void dispose() {
    emailController.removeListener(_validateEmail);
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          forceMaterialTransparency: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 2.0, top: 8.0),
              child: SimpleVersionBadge(),
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: kIsWeb ? 480 : double.infinity,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 10.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Forgot",
                          style: GoogleFonts.inter(
                            fontSize: 50,
                            fontWeight: FontWeight.w700,
                            color: CustomColor.secondaryColor,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          "password!",
                          style: GoogleFonts.inter(
                            fontSize: 50,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          "Inputkan alamat Email yang telah didaftarkan sebelumnya, sistem akan mengirimkan kode password baru ke alamat email terkait.",
                          style: TextStyle(
                            color: CustomColor.textThemeLightSoftColor,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 30.0),
                        LabelTextField.labelName(
                          required: true,
                          label: LanguageGlobalVar.EMAIL_ADDRESS.tr,
                          child: EmailTextField(
                            fieldName: LanguageGlobalVar.EMAIL_ADDRESS.tr,
                            controller: emailController,
                            requiredField: true,
                            labelText: "Email Address",
                            useValidator: false,
                            useCustomOnchange: true,
                            onChange: (value) {
                              _validateEmail();
                            },
                            hintText: LanguageGlobalVar.INPUT_YOUR_EMAIL_ADDRESS.tr,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ), // Penutup SafeArea
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24.0,
            top: 0,
            bottom: 40,
          ),
          child: Obx(
            () => DefaultButton.defaultElevatedButton(
              onPressed: (!isEmailValid.value || authController.isLoading.value)
                  ? null
                  : _handleForgotPassword,
              title: authController.isLoading.value
                  ? "Processing..."
                  : LanguageGlobalVar.RESET_PASSWORD.tr,
            ),
          ),
        ),
      ), // Penutup Scaffold
    ); // Penutup GestureDetector
  }
}
