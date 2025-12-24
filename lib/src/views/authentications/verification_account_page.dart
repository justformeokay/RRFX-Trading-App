import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/buttons/elevated_button.dart';
import 'package:rrfx/src/components/languages/language_variable.dart';
import 'package:rrfx/src/components/textfields/descriptive_textfield.dart';
import 'package:rrfx/src/components/textfields/email_textfield.dart';
import 'package:rrfx/src/components/textfields/label_textfield.dart';
import 'package:rrfx/src/components/textfields/name_textfield.dart';
import 'package:rrfx/src/components/textfields/phone_textfield.dart';
import 'package:rrfx/src/components/textfields/void_textfield.dart';
import 'package:rrfx/src/controllers/authentication.dart';
import 'package:rrfx/src/controllers/home.dart';
import 'package:rrfx/src/helpers/formatters/clean_phone_number.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/views/authentications/setup_passcode_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerificationAccountPage extends StatefulWidget {
  const VerificationAccountPage({super.key});

  @override
  State<VerificationAccountPage> createState() => _VerificationAccountPageState();
}

class _VerificationAccountPageState extends State<VerificationAccountPage> {
  final _formKey = GlobalKey<FormState>();
  RxBool isLoading = false.obs;
  RxString phoneCode = "".obs;
  RxString number = "".obs;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController alamatLengkapController = TextEditingController();
  TextEditingController kodePosController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  AuthController authController = Get.find();
  // HomeController getter - ensures controller exists before use
  HomeController get homeController {
    try {
      return Get.find<HomeController>();
    } catch (e) {
      Get.log("⚠️ [VERIFICATION_PAGE] HomeController not found, creating permanent instance");
      return Get.put(HomeController(), permanent: true);
    }
  }
  String originalPhoneNumber = "";
  RxBool isDataReady = false.obs;

  @override
  void initState() {
    super.initState();
    Get.log("🟢 [VERIFICATION_PAGE] initState() called");
    Get.log("🔍 [VERIFICATION_PAGE] Current profileModel: ${homeController.profileModel.value?.email ?? 'NULL'}");
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    Get.log("🟡 [VERIFICATION_PAGE] _loadProfileData() started");
    try {
      Get.log("📡 [VERIFICATION_PAGE] Calling homeController.profile()...");
      
      // Force refresh profile untuk memastikan data terbaru
      final success = await homeController.profile();
      
      Get.log("📥 [VERIFICATION_PAGE] profile() completed. Success: $success");
      Get.log("📋 [VERIFICATION_PAGE] profileModel after fetch: ${homeController.profileModel.value?.toJson()}");
      
      if (!success || homeController.profileModel.value == null) {
        Get.log("❌ [VERIFICATION_PAGE] Profile data NULL or failed");
        if (mounted) {
          CustomScaffoldMessanger.showAppSnackBar(
            context,
            message: "Gagal memuat data profil. Silakan coba lagi.",
            type: SnackBarType.error,
          );
          Get.back();
        }
        return;
      }

      // Set data setelah berhasil fetch
      if (mounted) {
        final name = homeController.profileModel.value?.name ?? '';
        final email = homeController.profileModel.value?.email ?? '';
        final phone = homeController.profileModel.value?.phone ?? '';
        
        Get.log("✅ [VERIFICATION_PAGE] Setting controllers:");
        Get.log("   - Name: $name");
        Get.log("   - Email: $email");
        Get.log("   - Phone: $phone");
        
        fullNameController.text = name;
        emailController.text = email;
        phoneController.text = phone;
        originalPhoneNumber = phoneController.text;
        phoneController.text = cleanPhoneNumber(phoneController.text);
        isDataReady.value = true;
        
        Get.log("✅ [VERIFICATION_PAGE] Data loaded successfully. isDataReady: ${isDataReady.value}");
      }
    } catch (e) {
      Get.log("❌ [VERIFICATION_PAGE] Exception in _loadProfileData: $e");
      if (mounted) {
        CustomScaffoldMessanger.showAppSnackBar(
          context,
          message: "Terjadi kesalahan saat memuat data: $e",
          type: SnackBarType.error,
        );
        Get.back();
      }
    }
  }
  
  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    kodePosController.dispose();
    genderController.dispose();
    phoneController.dispose();
    alamatLengkapController.dispose();
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
            ),
            body: SafeArea(
              child: Obx(() {
                // Loading state
                if (!isDataReady.value) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: CustomColor.secondaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Memuat data profil...",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Form content
                return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Almost", style: GoogleFonts.inter(fontSize: 50, fontWeight: FontWeight.w700, color: CustomColor.secondaryColor, height: 1.0,)),
                        Text("done!", style: GoogleFonts.inter(fontSize: 50, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.titleLarge?.color)),
                        const SizedBox(height: 5.0),
                        Text("Lengkapi identitas akun anda untuk dapat melanjutkan pembuatan akun .", style: TextStyle(color: CustomColor.textThemeLightSoftColor, fontSize: 15)),
                        const SizedBox(height: 30.0),
                        LabelTextField.labelName(
                          label: LanguageGlobalVar.FULL_NAME.tr,
                          child: NameTextField(
                            readOnly: true,
                            requiredField: true,
                            useValidator: false,
                            fieldName: "Nama Lengkap",
                            controller: fullNameController,
                            hintText: "Nama Lengkap",
                            labelText: "Nama Lengkap",
                          )
                        ),
                        LabelTextField.labelName(
                          label: LanguageGlobalVar.EMAIL_ADDRESS.tr,
                          child: EmailTextField(
                            readOnly: true,
                            requiredField: true,
                            fieldName: "Alamat Email",
                            labelText: "Alamat Email",
                            controller: emailController,
                            hintText: "name@email.com",
                          )
                        ),
                        LabelTextField.labelName(
                          label: LanguageGlobalVar.PHONE_NUMBER.tr,
                          child: PhoneTextField(
                            readOnly: true,
                            requiredField: true,
                            fieldName: "Nomor HP",
                            labelText: "Nomor HP",
                            controller: phoneController,
                            useValidator: false,
                          )
                        ),
                        const SizedBox(height: 15.0),
                        LabelTextField.labelName(
                          label: "Alamat Lengkap",
                          child: DescriptiveTextField(
                            useValidator: false,
                            labelText: "Alamat Lengkap",
                            iconData: MingCute.home_2_line,
                            fieldName: "Alamat Lengkap",
                            controller: alamatLengkapController,
                            hintText: "Inputkan alamat lengkap anda",
                          )
                        ),
                        LabelTextField.labelName(
                          label: "Gender",
                          child: VoidTextField(
                            labelText: "Jenis Kelamin",
                            iconData: Bootstrap.gender_ambiguous,
                            onPressed: (){
                              CustomMaterialBottomSheets.defaultBottomSheet(context, size: size, isScrolledController: false, title: LanguageGlobalVar.CHOOSE_YOUR_GENDER.tr, children: List.generate(GlobalVariable.genderIndo.length, (i){
                                return ListTile(
                                  leading: Icon(
                                    i == 0 ? Bootstrap.gender_male :
                                    i == 1 ? Bootstrap.gender_female : Bootstrap.gender_ambiguous,
                                  ),
                                  title: Text(GlobalVariable.genderIndo[i], style: GoogleFonts.inter()),
                                  onTap: (){
                                    Navigator.pop(context);
                                    genderController.text = GlobalVariable.genderIndo[i];
                                  },
                                );
                              }));
                            },
                            fieldName: "Gender",
                            readOnly: false,
                            controller: genderController,
                            hintText: "Pilih gender anda",
                          )
                        ),
                      ],
                    ),
                  ),
                ));
              }),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Obx(
                () => DefaultButton.defaultElevatedButton(
                  onPressed: authController.isLoading.value ? null : () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    if(_formKey.currentState!.validate()){
                      await authController.verificationAccount(
                        gender: genderController.text,
                        address: alamatLengkapController.text,
                      ).then((result){
                        if(result){
                          CustomScaffoldMessanger.showAppSnackBar(context, message: authController.responseMessage.value, type: SnackBarType.success);
                          // ✅ Navigate to OtpPage instead of VerificationSuccessPage
                          prefs.setBool('loggedIn', true);
                          Get.offAll(() => const SetupPasscodePage());
                        }else{
                          CustomScaffoldMessanger.showAppSnackBar(context, message: authController.responseMessage.value, type: SnackBarType.error);
                        }
                      });
                    }
                  },
                  title: authController.isLoading.value
                    ? "Processing..."
                    : LanguageGlobalVar.SELANJUTNYA.tr,
                )
              ),
            ),
          ),
        ],
      ),
    );
  }
}
