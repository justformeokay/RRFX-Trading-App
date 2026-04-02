import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
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
import 'package:rrfx/src/views/authentications/otp_page.dart';

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
  final GetStorage _localStorage = GetStorage();

  bool _validateEmail(String email) {
    final regex = RegExp(r'^[A-Za-z0-9._+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$');
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

  @override
  void initState() {
    super.initState();
    authController.getCountryCode();

    emailController.addListener(() => _onEmailChanged(emailController.text));
    fullNameController.addListener(updateButtonState);
    phoneController.addListener(updateButtonState);
    passwordController.addListener(updateButtonState);

    final args = Get.arguments;
    if (args != null && args['code'] != null) {
      referalCode = args['code'];
    }
  }

  @override
  void dispose() {
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
      child: Scaffold(
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
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello",
                          style: GoogleFonts.inter(
                            fontSize: 35,
                            fontWeight: FontWeight.w700,
                            color: CustomColor.secondaryColor,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          "there!",
                          style: GoogleFonts.inter(
                            fontSize: 35,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          "Lihat pergerakan harga pasar global secara langsung, dengan chart interaktif dan analisis teknikal lengkap.",
                          style: TextStyle(
                            color: CustomColor.textThemeLightSoftColor,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 30.0),
                        LabelTextField.labelName(
                          label: "Nama Lengkap",
                          required: true,
                          child: NameTextFieldNewVersion(
                            useValidator: true,
                            iconData: Iconsax.user_tick_outline,
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
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              hintText: "81xxxx",
                              hintStyle: GoogleFonts.inter(
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                              prefixIcon: GestureDetector(
                                onTap: () {
                                  CustomMaterialBottomSheets.defaultBottomSheet(
                                    context,
                                    size: size,
                                    title: "Pilih Kode Negara",
                                    children: List.generate(
                                      authController.countryCodeModel.value?.response?.length ?? 0,
                                      (index) {
                                        final country = authController.countryCodeModel.value?.response?[index];
                                        return ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: CustomColor.secondaryBackground.withOpacity(0.3),
                                            child: Text("${index + 1}", style: const TextStyle(fontSize: 14)),
                                          ),
                                          title: Text(country?.name ?? "", style: const TextStyle(fontWeight: FontWeight.w700)),
                                          subtitle: Text(country?.phoneCode ?? ""),
                                          onTap: () {
                                            phoneCode.value = country?.phoneCode ?? "+62";
                                            phoneController.clear();
                                            phoneNumber.value = "";
                                            Get.back();
                                          },
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Obx(() => Container(
                                      width: 70,
                                      alignment: Alignment.center,
                                      child: Text(
                                        phoneCode.value,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    )),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(color: CustomColor.secondaryColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(color: CustomColor.textThemeDarkSoftColor),
                              ),
                            ),
                            onChanged: (val) {
                              String clean = val;
                              if (phoneCode.value == "+62" && clean.startsWith("0")) {
                                clean = clean.substring(1);
                                phoneController.value = TextEditingValue(
                                  text: clean,
                                  selection: TextSelection.collapsed(offset: clean.length),
                                );
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
                              onPressed: authController.isLoading.value ||
                                      !checkedRead.value ||
                                      !isEmailValid.value ||
                                      fullNameController.text.isEmpty ||
                                      phoneNumber.value.isEmpty ||
                                      passwordController.text.isEmpty
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate() != true) return;

                                      final finalReferralCode = referalCode ?? referalController.text;
                                      
                                      bool result = await authController.register(
                                        phoneCode: phoneCode.value,
                                        phone: phoneNumber.value,
                                        agree: checkedRead.value,
                                        password: passwordController.text,
                                        email: emailController.text.toLowerCase(),
                                        name: fullNameController.text,
                                        ibCode: finalReferralCode,
                                      );

                                      if (result) {
                                        await _localStorage.write('signup_email', emailController.text.toLowerCase());
                                        await _localStorage.write('signup_password', passwordController.text);

                                        ModernAlertDialog.show(
                                          type: AlertType.success,
                                          title: "Registrasi Berhasil!",
                                          message: authController.responseMessage.value,
                                          buttonText: "Lanjutkan",
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            await authController.login(
                                              context,
                                              email: emailController.text.toLowerCase(),
                                              password: passwordController.text,
                                            );
                                            if (authController.statusAccount.value == 'otp') {
                                              Get.off(() => const OtpPage());
                                            }
                                          },
                                        );
                                      } else {
                                        ModernAlertDialog.show(
                                          type: AlertType.error,
                                          title: "Registrasi Gagal",
                                          message: authController.responseMessage.value,
                                          buttonText: "Coba Lagi",
                                          onPressed: () => Navigator.of(context).pop(),
                                        );
                                      }
                                    },
                              title: authController.isLoading.value
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
        ),
      ),
    );
  }
}