import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Response;
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/buttons/elevated_button.dart';
import 'package:rrfx/src/components/languages/language_variable.dart';
import 'package:rrfx/src/components/textfields/descriptive_textfield.dart';
import 'package:rrfx/src/components/textfields/email_textfield.dart';
import 'package:rrfx/src/components/textfields/name_textfield.dart';
import 'package:rrfx/src/components/textfields/phone_textfield.dart';
import 'package:rrfx/src/components/textfields/void_textfield.dart';
import 'package:rrfx/src/controllers/authentication.dart';
import 'package:rrfx/src/controllers/home.dart';
import 'package:rrfx/src/helpers/formatters/clean_phone_number.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/views/authentications/setup_passcode_page.dart';
import 'package:rrfx/src/models/auth/country_code_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerificationAccountPage extends StatefulWidget {
  const VerificationAccountPage({super.key});

  @override
  State<VerificationAccountPage> createState() =>
      _VerificationAccountPageState();
}

class _VerificationAccountPageState extends State<VerificationAccountPage> {
  final _formKey = GlobalKey<FormState>();
  RxBool isLoading = false.obs;
  RxString phoneCode = "".obs;
  RxString number = "".obs;
  RxList<Response> countries = <Response>[].obs;
  RxBool isLoadingCountries = true.obs;
  RxString selectedCountry = "".obs;
  RxString selectedCountryCode = "".obs;
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
      Get.log(
        "⚠️ [VERIFICATION_PAGE] HomeController not found, creating permanent instance",
      );
      return Get.put(HomeController(), permanent: true);
    }
  }

  String originalPhoneNumber = "";
  RxBool isDataReady = false.obs;

  /// 🔙 Back button tracking
  int _backPressCount = 0;
  Timer? _backPressTimer;

  @override
  void initState() {
    super.initState();
    Get.log("🟢 [VERIFICATION_PAGE] initState() called");
    Get.log(
      "🔍 [VERIFICATION_PAGE] Current profileModel: ${homeController.profileModel.value?.email ?? 'NULL'}",
    );
    _loadCountries();
    _loadProfileData();
  }

  Future<void> _loadCountries() async {
    Get.log("🟡 [VERIFICATION_PAGE] _loadCountries() started");
    try {
      isLoadingCountries(true);
      final response = await http
          .get(
            Uri.parse("${GlobalVariable.mainURL}/auth/country"),
            headers: {
              'x-api-key': GlobalVariable.x_api_key,
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              isLoadingCountries(false);
              throw TimeoutException("Request timeout");
            },
          );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final countryModel = CountryCodeModel.fromJson(jsonData);
        countries.value = countryModel.response ?? [];
        Get.log("✅ [VERIFICATION_PAGE] Countries loaded: ${countries.length}");
        if (countries.isNotEmpty) {
          // Find Indonesia in the list, otherwise use first country
          final indonesiaIndex = countries.indexWhere(
            (country) => country.name?.toLowerCase().contains('indonesia') ?? false,
          );
          if (indonesiaIndex >= 0) {
            selectedCountry.value = countries[indonesiaIndex].name ?? '';
            selectedCountryCode.value = countries[indonesiaIndex].code ?? '';
            Get.log(
              "🌍 [VERIFICATION_PAGE] Default country set to: ${selectedCountry.value}",
            );
          } else {
            // Fallback to first country if Indonesia not found
            selectedCountry.value = countries[0].name ?? '';
            selectedCountryCode.value = countries[0].code ?? '';
            Get.log(
              "🌍 [VERIFICATION_PAGE] Indonesia not found, using default: ${selectedCountry.value}",
            );
          }
        }
      } else {
        Get.log(
          "❌ [VERIFICATION_PAGE] Failed to load countries: ${response.statusCode}",
        );
      }
      isLoadingCountries(false);
    } catch (e) {
      Get.log("❌ [VERIFICATION_PAGE] Exception in _loadCountries: $e");
      isLoadingCountries(false);
    }
  }

  Future<void> _loadProfileData() async {
    Get.log("🟡 [VERIFICATION_PAGE] _loadProfileData() started");
    try {
      Get.log("📡 [VERIFICATION_PAGE] Calling homeController.profile()...");

      // Force refresh profile untuk memastikan data terbaru
      final success = await homeController.profile();

      Get.log("📥 [VERIFICATION_PAGE] profile() completed. Success: $success");
      Get.log(
        "📋 [VERIFICATION_PAGE] profileModel after fetch: ${homeController.profileModel.value?.toJson()}",
      );

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

        Get.log(
          "✅ [VERIFICATION_PAGE] Data loaded successfully. isDataReady: ${isDataReady.value}",
        );
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

  /// 🔙 Handle back button press
  void _handleBackPress() {
    print('🔙 [VERIFICATION] Back pressed. Count: $_backPressCount');
    _backPressCount++;

    if (_backPressCount == 1) {
      // First back press - cancel previous timer and start new one
      _backPressTimer?.cancel();
      _backPressTimer = Timer(const Duration(seconds: 3), () {
        _backPressCount = 0;
        print('🔙 [VERIFICATION] Back press counter reset');
      });
      // Don't allow back on first press
      print('🔙 [VERIFICATION] First back press blocked');
    } else if (_backPressCount >= 2) {
      // Second back press - show exit dialog
      _backPressTimer?.cancel();
      _backPressCount = 0;
      _showExitDialog();
    }
  }

  /// 🚪 Show modern exit confirmation dialog
  void _showExitDialog() {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;

    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon dengan background gradient
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      CustomColor.secondaryColor.withOpacity(0.2),
                      CustomColor.secondaryColor.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.exit_to_app_rounded,
                  size: 40,
                  color: CustomColor.secondaryColor,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Keluar Aplikasi?',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Apakah Anda yakin ingin menutup aplikasi ini?',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Close app
                        print('🚀 [VERIFICATION] Exiting app');
                        SystemNavigator.pop();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: CustomColor.secondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Keluar',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _backPressTimer?.cancel();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBackPress();
        }
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: isDark ? null : Colors.grey[50],
        // appBar: AppBar(
        //   elevation: 0,
        //   forceMaterialTransparency: true,
        //   backgroundColor: isDark ? null : Colors.grey[50],
        //   leadingWidth: 56,
        //   leading: Padding(
        //     padding: const EdgeInsets.only(left: 8),
        //     child: Center(
        //       child: InkWell(
        //         onTap: () => Navigator.pop(context),
        //         borderRadius: BorderRadius.circular(10),
        //         child: Container(
        //           padding: const EdgeInsets.all(6),
        //           decoration: BoxDecoration(
        //             color:
        //                 isDark ? Colors.white.withOpacity(0.1) : Colors.white,
        //             borderRadius: BorderRadius.circular(10),
        //             boxShadow:
        //                 isDark
        //                     ? null
        //                     : [
        //                       BoxShadow(
        //                         color: Colors.black.withOpacity(0.04),
        //                         blurRadius: 8,
        //                         offset: const Offset(0, 2),
        //                       ),
        //                     ],
        //           ),
        //           child: Icon(
        //             Icons.arrow_back_ios_new_rounded,
        //             size: 16,
        //             color: isDark ? Colors.white : Colors.black87,
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        body: Obx(() {
          // Loading state
          if (!isDataReady.value) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color:
                          isDark ? Colors.white.withOpacity(0.1) : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: CustomColor.secondaryColor.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: CircularProgressIndicator(
                      color: CustomColor.secondaryColor,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Memuat data profil...",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Mohon tunggu sebentar",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark ? Colors.white38 : Colors.grey[400],
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
              child: Column(
                children: [
                  // Header Section with gradient
                  const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          CustomColor.secondaryColor.withOpacity(0.1),
                          CustomColor.secondaryColor.withOpacity(0.05),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Progress indicator
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: CustomColor.secondaryColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: CustomColor.secondaryColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color:
                                        isDark
                                            ? Colors.white24
                                            : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: CustomColor.secondaryColor.withOpacity(
                                    0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Bootstrap.check_circle_fill,
                                  color: CustomColor.secondaryColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Almost done!",
                                      style: GoogleFonts.inter(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        color: CustomColor.secondaryColor,
                                        height: 1.2,
                                        letterSpacing: -0.5,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Lengkapi identitas akun anda untuk melanjutkan",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: isDark ? Colors.white70 : Colors.grey[600],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Form Section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader("Informasi Pribadi", isDark),
                        const SizedBox(height: 12),

                        _buildInfoCard(
                          icon: Bootstrap.person_fill,
                          label: LanguageGlobalVar.FULL_NAME.tr,
                          child: NameTextField(
                            readOnly: true,
                            requiredField: true,
                            useValidator: false,
                            iconData: Iconsax.profile_circle_outline,
                            fieldName: "Nama Lengkap",
                            controller: fullNameController,
                            hintText: "Nama Lengkap",
                            labelText: "Nama Lengkap",
                          ),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),

                        _buildInfoCard(
                          icon: Bootstrap.envelope_fill,
                          label: LanguageGlobalVar.EMAIL_ADDRESS.tr,
                          child: EmailTextField(
                            readOnly: true,
                            requiredField: true,
                            fieldName: "Alamat Email",
                            labelText: "Alamat Email",
                            controller: emailController,
                            hintText: "name@email.com",
                          ),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),

                        _buildInfoCard(
                          icon: Bootstrap.phone_fill,
                          label: LanguageGlobalVar.PHONE_NUMBER.tr,
                          child: PhoneTextField(
                            readOnly: true,
                            requiredField: true,
                            fieldName: "Nomor HP",
                            labelText: "Nomor HP",
                            controller: phoneController,
                            useValidator: false,
                          ),
                          isDark: isDark,
                        ),

                        const SizedBox(height: 20),
                        _buildSectionHeader("Informasi Tambahan", isDark),
                        const SizedBox(height: 12),

                        _buildInfoCard(
                          icon: Bootstrap.globe,
                          label: "Negara",
                          child: Obx(() {
                            if (isLoadingCountries.value) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isDark
                                          ? Colors.white.withOpacity(0.05)
                                          : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              CustomColor.secondaryColor,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: Text(
                                        "Memuat...",
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color:
                                              isDark
                                                  ? Colors.white60
                                                  : Colors.grey[600],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return Container(
                              decoration: BoxDecoration(
                                color:
                                    isDark
                                        ? Colors.white.withOpacity(0.05)
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color:
                                      isDark
                                          ? Colors.white12
                                          : Colors.grey[200]!,
                                ),
                              ),
                              child: DropdownButtonFormField<String>(
                                value:
                                    selectedCountry.value.isNotEmpty
                                        ? selectedCountry.value
                                        : null,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 12,
                                  ),
                                  border: InputBorder.none,
                                  hintText: "Pilih Negara",
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 13,
                                    color:
                                        isDark
                                            ? Colors.white38
                                            : Colors.grey[400],
                                  ),
                                ),
                                dropdownColor:
                                    isDark ? Colors.grey[900] : Colors.white,
                                isExpanded: true,
                                items:
                                    countries.map((country) {
                                      return DropdownMenuItem<String>(
                                        value: country.name ?? '',
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _getCountryFlag(
                                                country.code ?? '',
                                              ),
                                              style: const TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                country.name ?? '',
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                selectedItemBuilder: (context) {
                                  return countries.map((country) {
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _getCountryFlag(country.code ?? ''),
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            country.name ?? '',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList();
                                },
                                onChanged: (value) {
                                  if (value != null) {
                                    selectedCountry.value = value;
                                    final selected = countries.firstWhereOrNull(
                                      (c) => c.name == value,
                                    );
                                    if (selected != null) {
                                      selectedCountryCode.value =
                                          selected.code ?? '';
                                      Get.log(
                                        "🌍 [VERIFICATION_PAGE] Country changed to: $value (${selected.code})",
                                      );
                                    }
                                  }
                                },
                                icon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: CustomColor.secondaryColor,
                                  size: 20,
                                ),
                              ),
                            );
                          }),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),

                        _buildInfoCard(
                          icon: MingCute.home_2_fill,
                          label: "Alamat Lengkap",
                          child: DescriptiveTextField(
                            useValidator: false,
                            labelText: "Alamat Lengkap",
                            iconData: MingCute.home_2_line,
                            fieldName: "Alamat Lengkap",
                            controller: alamatLengkapController,
                            hintText: "Inputkan alamat lengkap anda",
                          ),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),

                        _buildInfoCard(
                          icon: Bootstrap.gender_ambiguous,
                          label: "Jenis Kelamin",
                          child: VoidTextField(
                            labelText: "Jenis Kelamin",
                            iconData: Bootstrap.gender_ambiguous,
                            onPressed: () {
                              CustomMaterialBottomSheets.defaultBottomSheet(
                                context,
                                size: size,
                                isScrolledController: false,
                                title: LanguageGlobalVar.CHOOSE_YOUR_GENDER.tr,
                                children: List.generate(
                                  GlobalVariable.genderIndo.length,
                                  (i) {
                                    return ListTile(
                                      leading: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: CustomColor.secondaryColor
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          i == 0
                                              ? Bootstrap.gender_male
                                              : i == 1
                                              ? Bootstrap.gender_female
                                              : Bootstrap.gender_ambiguous,
                                          color: CustomColor.secondaryColor,
                                          size: 20,
                                        ),
                                      ),
                                      title: Text(
                                        GlobalVariable.genderIndo[i],
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        genderController.text =
                                            GlobalVariable.genderIndo[i];
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                            fieldName: "Gender",
                            readOnly: false,
                            controller: genderController,
                            hintText: "Pilih gender anda",
                          ),
                          isDark: isDark,
                        ),
                        const SizedBox(
                          height: 24,
                        ), // Extra space for bottom button
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: isDark ? null : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Obx(
              () => DefaultButton.defaultElevatedButton(
                onPressed:
                    authController.isLoading.value
                        ? null
                        : () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          if (_formKey.currentState!.validate()) {
                            // DEBUG: Print form data sebelum submit
                            print('\n═══════════════════════════════════════════════════');
                            print('📋 [VERIFICATION_PAGE] Form Data:');
                            print('───────────────────────────────────────────────────');
                            print('Selected Country Name: ${selectedCountry.value}');
                            print('Selected Country Code: ${selectedCountryCode.value}');
                            print('Country Code (isUpperCase): ${selectedCountryCode.value == selectedCountryCode.value.toUpperCase()}');
                            print('Country Code (length): ${selectedCountryCode.value.length}');
                            print('Gender: ${genderController.text}');
                            print('Address: ${alamatLengkapController.text}');
                            print('═══════════════════════════════════════════════════\n');
                            
                            await authController.verificationAccount(
                                  gender: genderController.text,
                                  address: alamatLengkapController.text,
                                  country: selectedCountryCode.value,
                                )
                                .then((result) {
                                  if (result) {
                                    CustomScaffoldMessanger.showAppSnackBar(
                                      context,
                                      message:
                                          authController.responseMessage.value,
                                      type: SnackBarType.success,
                                    );
                                    prefs.setBool('loggedIn', true);
                                    Get.offAll(() => const SetupPasscodePage());
                                  } else {
                                    CustomScaffoldMessanger.showAppSnackBar(
                                      context,
                                      message:
                                          authController.responseMessage.value,
                                      type: SnackBarType.error,
                                    );
                                  }
                                });
                          }
                        },
                title:
                    authController.isLoading.value
                        ? "Memproses..."
                        : LanguageGlobalVar.SELANJUTNYA.tr,
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: CustomColor.secondaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required Widget child,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
        ),
        boxShadow:
            isDark
                ? null
                : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: CustomColor.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 14, color: CustomColor.secondaryColor),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  String _getCountryFlag(String countryCode) {
    // Convert country code to flag emoji
    final Map<String, String> countryFlags = {
      'id-ID': '🇮🇩',
      'en-US': '🇺🇸',
      'en-GB': '🇬🇧',
      'ja-JP': '🇯🇵',
      'ko-KR': '🇰🇷',
      'zh-CN': '🇨🇳',
      'fr-FR': '🇫🇷',
      'de-DE': '🇩🇪',
      'es-ES': '🇪🇸',
      'it-IT': '🇮🇹',
      'pt-BR': '🇧🇷',
      'ru-RU': '🇷🇺',
      'ar-SA': '🇸🇦',
      'en-AU': '🇦🇺',
      'en-CA': '🇨🇦',
      'nl-NL': '🇳🇱',
      'tr-TR': '🇹🇷',
      'en-IN': '🇮🇳',
      'en-ZA': '🇿🇦',
      'ar-AE': '🇦🇪',
      'es-MX': '🇲🇽',
      'es-AR': '🇦🇷',
      'sv-SE': '🇸🇪',
      'no-NO': '🇳🇴',
      'da-DK': '🇩🇰',
      'fi-FI': '🇫🇮',
      'de-CH': '🇨🇭',
      'en-NZ': '🇳🇿',
    };

    return countryFlags[countryCode] ?? '🌍';
  }
}
