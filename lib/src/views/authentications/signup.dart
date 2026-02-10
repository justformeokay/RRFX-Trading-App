import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/alerts/modern_alert_dialog.dart';
import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/buttons/elevated_button.dart';
import 'package:rrfx/src/components/languages/language_variable.dart';
import 'package:rrfx/src/components/textfields/email_textfield.dart';
import 'package:rrfx/src/components/textfields/label_textfield.dart';
import 'package:rrfx/src/components/textfields/name_text_field_new.dart';
import 'package:rrfx/src/components/textfields/password_textfield.dart';
import 'package:rrfx/src/components/utilities/utilities.dart';
import 'package:rrfx/src/components/widgets/build_version_indicator.dart';
import 'package:rrfx/src/controllers/authentication.dart';
import 'package:rrfx/src/views/authentications/signin.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  RxBool checkedRead = false.obs;
  RxBool isLoading = false.obs;
  RxString phoneCode = "+62".obs;
  RxString phoneNumber = "".obs;
  RxBool isButtonEnabled = false.obs;
  RxBool isEmailValid = false.obs;
  RxString number = "".obs;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController referalController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  AuthController authController = Get.find();
  String? referalCode;

  bool _validateEmail(String email) {
    final regex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$');
    return regex.hasMatch(email.trim());
  }

  void _onEmailChanged(String value) {
    isEmailValid.value = _validateEmail(value);
    updateButtonState();
  }

  void updateButtonState() {
    isButtonEnabled.value =
        !authController.isLoading.value &&
        checkedRead.value &&
        isEmailValid.value &&
        fullNameController.text.isNotEmpty &&
        phoneNumber.value.isNotEmpty &&
        passwordController.text.isNotEmpty;
  }

  // signup.dart (di dalam _SignupState)
  @override
  void initState() {
    super.initState();
    authController.getCountryCode();

    // Listen to form changes for real-time validation
    emailController.addListener(() => _onEmailChanged(emailController.text));
    fullNameController.addListener(updateButtonState);
    phoneController.addListener(updateButtonState);
    passwordController.addListener(updateButtonState);

    // ⬇️ Ambil referral code dari arguments (deeplink)
    final args = Get.arguments;
    print('📋 [Signup] Arguments received: $args');
    
    if (args != null && args['code'] != null) {
      referalCode = args['code'];
      print('✅ [Signup] Referral code set: $referalCode');
      // Optional: auto-fill ke textfield jika mau
      // referalController.text = referalCode ?? '';
    } else {
      print('⚠️ [Signup] No referral code in arguments');
    }
  }

  @override
  void dispose() {
    emailController.removeListener(() => _onEmailChanged(emailController.text));
    fullNameController.removeListener(updateButtonState);
    phoneController.removeListener(updateButtonState);
    passwordController.removeListener(updateButtonState);

    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    referalController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
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
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello",
                          style: GoogleFonts.inter(
                            fontSize: 50,
                            fontWeight: FontWeight.w700,
                            color: CustomColor.secondaryColor,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          "there!",
                          style: GoogleFonts.inter(
                            fontSize: 50,
                            fontWeight: FontWeight.w700,
                            color:
                                Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          "Lihat pergerakan harga pasar global secara langsung, dengan chart interaktif dan analisis teknikal lengkap.",
                          style: TextStyle(
                            color: CustomColor.textThemeLightSoftColor,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 30.0),
                        LabelTextField.labelName(
                          label: "Nama Lengkap",
                          required: true,
                          child: NameTextFieldNewVersion(
                            useValidator: true,
                            requiredField: true,
                            labelText: "Nama Lengkap",
                            fieldName: LanguageGlobalVar.FULL_NAME.tr,
                            controller: fullNameController,
                            hintText: LanguageGlobalVar.FULL_NAME.tr,
                          ),
                        ),
                        LabelTextField.labelName(
                          label: "Alamat Email",
                          required: true,
                          child: EmailTextField(
                            requiredField: true,
                            useValidator: false,
                            useCustomOnchange: true,
                            labelText: "Alamat Email",
                            fieldName: "Alamat Email",
                            controller: emailController,
                            hintText: "name@email.com",
                            onChange: (value) {
                              _onEmailChanged(value);
                            },
                          ),
                        ),
                        LabelTextField.labelName(
                          required: true,
                          label: "Nomor HP",
                          child: TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            maxLength: 13,
                            inputFormatters: [
                              FilteringTextInputFormatter
                                  .digitsOnly, // hanya angka
                            ],
                            decoration: InputDecoration(
                              hintText: "81xxxx",
                              hintStyle: GoogleFonts.inter(
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.color,
                              ),
                              label: RichText(
                                text: TextSpan(
                                  text: "Nomor Hp",
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.color,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: "",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              prefixIcon: GestureDetector(
                                onTap: () {
                                  CustomMaterialBottomSheets.defaultBottomSheet(
                                    context,
                                    size: size,
                                    title: "Pilih Kode Negara",
                                    children: List.generate(
                                      authController
                                              .countryCodeModel
                                              .value
                                              ?.response
                                              ?.length ??
                                          0,
                                      (index) {
                                        final country =
                                            authController
                                                .countryCodeModel
                                                .value
                                                ?.response?[index];
                                        return ListTile(
                                          leading: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: CustomColor
                                                  .secondaryBackground
                                                  .withValues(alpha: 0.3),
                                            ),
                                            child: Center(
                                              child: Text(
                                                "${index + 1}",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            country?.name ?? "",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          subtitle: Text(
                                            country?.phoneCode ?? "",
                                            style: TextStyle(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.bodySmall?.color,
                                            ),
                                          ),
                                          onTap: () {
                                            phoneCode(country?.phoneCode);
                                            phoneController.clear();
                                            phoneNumber("");
                                            Get.back();
                                          },
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 80,
                                  alignment: Alignment.center,
                                  child: Text(
                                    phoneCode.value,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color: CustomColor.secondaryColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color: CustomColor.textThemeDarkSoftColor,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color: CustomColor.textThemeDarkSoftColor,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Mohon isikan Nomor HP';
                              } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return 'Nomor HP hanya boleh berisi angka';
                              }
                              return null;
                            },
                            onChanged: (val) {
                              String clean = val;
                              if (phoneCode.value == "+62") {
                                if (clean.startsWith("0")) {
                                  clean = clean.substring(1);
                                  phoneController.value = TextEditingValue(
                                    text: clean,
                                    selection: TextSelection.collapsed(
                                      offset: clean.length,
                                    ),
                                  );
                                }
                              }
                              phoneNumber.value = clean;
                              updateButtonState();
                            },
                          ),
                        ),
                        LabelTextField.labelName(
                          required: true,
                          label: "Kata Sandi",
                          child: PasswordTextField(
                            requiredField: true,
                            labelText: "Kata Sandi",
                            fieldName: "Kata Sandi",
                            controller: passwordController,
                            hintText: "Buat Password",
                          ),
                        ),
                        UtilitiesComponents.checkBoxAgreement(
                          context,
                          checkedRead: checkedRead,
                        ),
                        const SizedBox(height: 10.0),
                        SizedBox(
                          width: double.infinity,
                          child: Obx(
                            () => DefaultButton.defaultElevatedButton(
                              onPressed:
                                  authController.isLoading.value ||
                                          !checkedRead.value ||
                                          !isEmailValid.value ||
                                          fullNameController.text.isEmpty ||
                                          phoneNumber.value.isEmpty ||
                                          passwordController.text.isEmpty
                                      ? null
                                      : () {
                                        if (_formKey.currentState!.validate() !=
                                            true) {
                                          return;
                                        }
                                        if (emailController.text == "") {
                                          return CustomScaffoldMessanger.showAppSnackBar(
                                            context,
                                            message: "Email tidak boleh kosong",
                                            type: SnackBarType.error,
                                          );
                                        }
                                        
                                        // Debug: print semua data sebelum register
                                        final finalReferralCode = referalCode ?? referalController.text;
                                        print('📤 [Signup] Submitting registration:');
                                        print('   Name: ${fullNameController.text}');
                                        print('   Email: ${emailController.text.toLowerCase()}');
                                        print('   Phone: ${phoneCode.value}${phoneNumber.value}');
                                        print('   Referral Code: $finalReferralCode');
                                        
                                        authController
                                            .register(
                                              phoneCode: phoneCode.value,
                                              phone: phoneNumber.value,
                                              agree: checkedRead.value,
                                              password: passwordController.text,
                                              email:
                                                  emailController.text
                                                      .toLowerCase(),
                                              name: fullNameController.text,
                                              ibCode: finalReferralCode,
                                            )
                                            .then((result) {
                                              if (result) {
                                                CustomScaffoldMessanger.showAppSnackBar(
                                                  context,
                                                  message:
                                                      authController
                                                          .responseMessage
                                                          .value,
                                                  type: SnackBarType.success,
                                                );
                                                Get.off(() => const SignIn());
                                              } else {
                                                // Tentukan title dan type berdasarkan pesan error
                                                String title =
                                                    "Registrasi Gagal";
                                                String message =
                                                    authController
                                                        .responseMessage
                                                        .value;
                                                AlertType alertType =
                                                    AlertType.error;

                                                // Deteksi jenis error
                                                if (message.contains(
                                                  "Koneksi internet",
                                                )) {
                                                  title =
                                                      "Koneksi Internet Terputus";
                                                  alertType = AlertType.error;
                                                } else if (message.contains(
                                                      "lambat",
                                                    ) ||
                                                    message.contains(
                                                      "timeout",
                                                    )) {
                                                  title = "Koneksi Lambat";
                                                  alertType = AlertType.warning;
                                                } else if (message.contains(
                                                  "server",
                                                )) {
                                                  title = "Masalah Server";
                                                  alertType = AlertType.error;
                                                }

                                                // Tampilkan popup error yang sesuai
                                                ModernAlertDialog.show(
                                                  type: alertType,
                                                  title: title,
                                                  message: message,
                                                  buttonText: "Coba Lagi",
                                                  onPressed: () {
                                                    // Hanya tutup dialog, jangan navigate
                                                    Navigator.of(context).pop();
                                                  },
                                                );
                                              }
                                            });
                                      },
                              title:
                                  authController.isLoading.value
                                      ? "Processing..."
                                      : LanguageGlobalVar.REGIST_NOW.tr,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
