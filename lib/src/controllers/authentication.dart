import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/controllers/device_utilities_controller.dart';
import 'package:rrfx/src/models/auth/country_code_model.dart';
import 'package:rrfx/src/service/auth_service.dart';
import 'package:rrfx/src/service/passcode_service.dart';
import 'package:rrfx/src/views/authentications/locked_page.dart';
import 'package:rrfx/src/views/authentications/otp_page.dart';
import 'package:rrfx/src/views/authentications/setup_passcode_page.dart';
import 'package:rrfx/src/views/authentications/suspended_page.dart';
import 'package:rrfx/src/views/authentications/verification_account_page.dart';
import 'package:rrfx/src/views/authentications/verify_passcode_page.dart';
import 'package:rrfx/src/views/mainpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rrfx/src/controllers/home.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/models/auth/personal_model.dart';
import 'dart:async';

class AuthController extends GetxController {
  RxBool isLoading = false.obs;
  final GetStorage box = GetStorage();
  RxBool isLoadingOTP = false.obs;
  RxString responseMessage = "".obs;
  RxString statusAccount = "".obs;
  Rxn<CountryCodeModel> countryCodeModel = Rxn<CountryCodeModel>();
  Rxn<PersonalModels> personalModel = Rxn<PersonalModels>();
  // HomeController getter - ensures controller exists before use
  HomeController get homeController {
    try {
      return Get.find<HomeController>();
    } catch (e) {
      Get.log("⚠️ [AUTH] HomeController not found, creating permanent instance");
      return Get.put(HomeController(), permanent: true);
    }
  }
  Map<String, String> deviceInfo = {};
  AuthService authService = Get.find();

  init() async {
    DeviceUtilitiesController.getDeviceInfo().then((value) {
      deviceInfo = value;
    });
  }

  @override
  void onInit() {
    super.onInit();
    init();
  }

  Future<void> login(BuildContext context, {String? email, String? password}) async {
    Get.log("🔵 [AUTH] login() called for email: $email");
    SharedPreferences preferences = await SharedPreferences.getInstance();
    try {
      isLoading(true);

      // ✅ Get device_id (FCM Token) from SharedPreferences
      String? deviceId = preferences.getString('deviceID');
      Get.log("📱 [AUTH] Device ID (FCM Token): $deviceId");

      Get.log("📡 [AUTH] Sending login request...");
      final response = await http.post(
        Uri.tryParse("${GlobalVariable.mainURL}/auth/login")!,
        headers: {
          'x-api-key': GlobalVariable.x_api_key,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'email': email,
          'password': password,
          'device': jsonEncode(deviceInfo),
          'device_id': deviceId ?? '', // ✅ Send FCM Token to API
        },
      );
      print(response.body);
      print(response.statusCode);
      Get.log("Device Information Sent: ${jsonEncode(deviceInfo)}");
      Get.log("Device ID Sent: ${deviceId ?? 'NULL'}");
      Get.log("📥 [AUTH] Login response status: ${response.statusCode}");
      Get.log("📋 [AUTH] Login response body: ${response.body}");

      final result = jsonDecode(response.body);
      isLoading(false);

      // ✅ Check API response status first (regardless of HTTP status code)
      if (result['status'] == false) {
        Get.log("❌ [AUTH] Login failed - API status false");
        
        // Check if account is locked
        final message = result['message'] ?? "";
        if (message.toLowerCase().contains("locked")) {
          Get.log("🔒 [AUTH] Account is locked - Going to LockedPage");
          Get.offAll(() => const LockedPage());
          return;
        }
        
        CustomScaffoldMessanger.showAppSnackBar(
          context,
          message: message.isNotEmpty 
              ? message
              : "Sign in gagal, mohon cek ulang Email atau Password anda apakah sudah benar",
        );
        return;
      }

      if (response.statusCode != 200) {
        Get.log("❌ [AUTH] Login failed - HTTP status code not 200: ${response.statusCode}");
        responseMessage(result['message'] ?? "Login gagal");
        return;
      }
      
      responseMessage(result['message'] ?? "Login berhasil");
      final status = result['response']?['status'] ?? "";
      final hasPasscode = result['response']?['passcode'] ?? false;
      statusAccount(status.toLowerCase());
      final accessToken = result['response']?['access_token'];
      final refreshToken = result['response']?['refresh_token'];
      
      Get.log("✅ [AUTH] Login successful");
      Get.log("🔐 [AUTH] Account status: $status");
      Get.log("📋 [AUTH] Has passcode on server: $hasPasscode");
      Get.log("🎫 [AUTH] Access token: ${accessToken?.substring(0, 20)}...");
      
      preferences.setString('refreshToken', refreshToken);
      preferences.setString('accessToken', accessToken);
      await box.write('token', accessToken);
      await box.write('refreshToken', refreshToken);
      authService.accessToken = accessToken;
      authService.refreshToken = refreshToken;
      
      Get.log("💾 [AUTH] Tokens saved successfully");
      Get.log("🎮 [AUTH] Initializing controllers...");
      Get.put(AccountController());
      // Ensure HomeController exists and is permanent (won't be deleted on navigation)
      if (!Get.isRegistered<HomeController>()) {
        Get.log("🎮 [AUTH] Creating HomeController as permanent...");
        Get.put(HomeController(), permanent: true);
      }

      Get.log("📡 [AUTH] Fetching user profile...");
      // Tunggu profile selesai di-fetch sebelum routing
      final profileSuccess = await homeController.profile();
      Get.log("📥 [AUTH] Profile fetch completed. Success: $profileSuccess");
      Get.log("👤 [AUTH] Profile data: ${homeController.profileModel.value?.toJson()}");

      Get.log("🚀 [AUTH] Routing based on status: $status and passcode: $hasPasscode");
      switch (statusAccount.value) {
        case "active":
          Get.log("✅ [AUTH] Status: active - Checking passcode...");
          await preferences.setBool('loggedIn', true);
          
          // ✅ Check if passcode already exists on server
          if (hasPasscode) {
            Get.log("✅ [AUTH] Passcode exists on server - Going to VerifyPasscodePage");
            Get.offAll(() => const VerifyPasscodePage());
          } else {
            Get.log("🔐 [AUTH] Passcode not set up on server - Going to SetupPasscodePage");
            Get.offAll(() => const SetupPasscodePage());
          }
          break;
        case "suspend":
          Get.log("⚠️ [AUTH] Status: suspend - Going to SuspendedAccountPage");
          Get.offAll(() => const SuspendedAccountPage());
          break;
        case "otp":
          Get.log("📱 [AUTH] Status: otp - Going to OtpPage (user baru, belum verifikasi OTP)");
          Get.offAll(() => const OtpPage());
          break;
        case "verification":
          Get.log("📧 [AUTH] Status: verification - Going to VerificationAccountPage (user baru, belum verifikasi akun)");
          Get.log("👤 [AUTH] Profile before navigation: ${homeController.profileModel.value?.email ?? 'NULL'}");
          Get.offAll(() => const VerificationAccountPage());
          break;
        default:
          Get.log("❌ [AUTH] Unknown status: $status");
          responseMessage("Status akun tidak dikenali, silakan hubungi admin");
      }
    } catch (e) {
      isLoading(false);
      print("❌ [AUTH] Exception in login(): $e");
      responseMessage.value = "Terjadi kesalahan: $e";
    }
  }

  /// Register API
  Future<bool> register({
    String? email,
    String? password,
    String? name,
    String? ibCode,
    String? phone,
    String? phoneCode,
    bool? agree,
  }) async {
    Get.log("🟢 [AUTH] register() called for email: $email, name: $name, phone: $phone");
    try {
      isLoading(true);
      Get.log("📡 [AUTH] Sending registration request...");
      http.Response response = await http.post(
        Uri.tryParse("${GlobalVariable.mainURL}/auth/register")!,
        headers: {
          'x-api-key': GlobalVariable.x_api_key,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'fullname': name,
          'email': email,
          'password': password,
          'refferal': ibCode ?? '',
          'phone': phone,
          'phone_code': phoneCode ?? '62',
          'terms': agree == true ? '1' : '0',
          'device': jsonEncode(deviceInfo),
        },
      );
      var result = jsonDecode(response.body);
      isLoading(false);
      Get.log("📥 [AUTH] Register response status: ${response.statusCode}");
      Get.log("📋 [AUTH] Register response: ${response.body}");
      
      if (response.statusCode == 200) {
        if (result['status'] != true) {
          Get.log("❌ [AUTH] Registration failed - status false");
          responseMessage.value = result['message'];
          return false;
        }
        Get.log("✅ [AUTH] Registration successful");
        responseMessage.value = result['message'];
        return true;
      }
      Get.log("❌ [AUTH] Registration failed - status code not 200");
      responseMessage.value = result['message'];
      // responseMessage.value = result['message']['data']['id'];
      return false;
    } catch (e) {
      Get.log("❌ [AUTH] Exception in register(): $e");
      isLoading(false);
      responseMessage.value = e.toString();
      return false;
    }
  }

  /// Send OTP API
  Future<bool> sendOTPSMS({String? phone, String? phoneCode}) async {
    try {
      isLoadingOTP(true);
      http.Response response = await http.post(
        Uri.tryParse("${GlobalVariable.mainURL}/auth/send-otp")!,
        headers: {
          'x-api-key': GlobalVariable.x_api_key,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'phone': phone,
          'phone_code': phoneCode ?? '62',
          'device': jsonEncode(deviceInfo),
        },
      );
      var result = jsonDecode(response.body);
      isLoadingOTP(false);
      if (response.statusCode == 200) {
        responseMessage.value = result['message'];
        return true;
      }
      responseMessage.value = result['message'];
      return false;
    } catch (e) {
      isLoadingOTP(false);
      responseMessage.value = e.toString();
      return false;
    }
  }

  /// Send OTP WhatsApp API
  Future<bool> sendOTPWA({String? phone, String? phoneCode}) async {
    try {
      isLoadingOTP(true);
      http.Response response = await http.post(
        Uri.tryParse("${GlobalVariable.mainURL}/auth/send-otp-wa")!,
        headers: {
          'x-api-key': GlobalVariable.x_api_key,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'phone': phone,
          'phone_code': phoneCode ?? '62',
          'device': jsonEncode(deviceInfo),
        },
      );
      var result = jsonDecode(response.body);
      isLoadingOTP(false);
      if (response.statusCode == 200) {
        responseMessage.value = result['message'];
        return true;
      }
      responseMessage.value = result['message'];
      return false;
    } catch (e) {
      isLoadingOTP(false);
      responseMessage.value = e.toString();
      return false;
    }
  }

  /// Send OTP WhatsApp API
  Future<bool> forgotPassword({String? email}) async {
    try {
      isLoading(true);
      http.Response response = await http.post(
        Uri.tryParse("${GlobalVariable.mainURL}/auth/forget")!,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'email': email},
      );
      var result = jsonDecode(response.body);
      print("INI RESULT FORGOT PASSWORD: $result");
      responseMessage.value = result['message'];
      print("INI RESPONSE MESSAGE: ${result['message']}");
      isLoading(false);
      if (result['status'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      isLoading(false);
      return false;
    }
  }

  /// Send OTP WhatsApp API
  Future<bool> getCountryCode() async {
    try {
      isLoading(true);
      http.Response response = await http.get(
        Uri.tryParse("${GlobalVariable.mainURL}/auth/country")!,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );
      var result = jsonDecode(response.body);
      isLoading(false);
      responseMessage.value = result['message'];
      if (response.statusCode == 200 && result['status']) {
        countryCodeModel(CountryCodeModel.fromJson(result));
        return true;
      }
      return false;
    } catch (e) {
      isLoading(false);
      responseMessage.value = e.toString();
      return false;
    }
  }

  /// Send OTP WhatsApp API
  Future<Map<String, dynamic>> getVersionApp({String? version}) async {
    String? appVersion = '1.0'; // Default fallback (format: major.minor)
    
    try {
      // Add timeout untuk getAppVersion karena package_info_plus bisa hang
      appVersion = await DeviceUtilitiesController.getAppVersion()
          .timeout(const Duration(seconds: 5), onTimeout: () => '1.0');
    } catch (e) {
      print('⚠️ [AUTH] getAppVersion error: $e, using fallback version');
      appVersion = '1.0';
    }

    try {
      isLoading(true);
      
      // Add timeout untuk HTTP request
      http.Response response = await http.post(
        Uri.tryParse("${GlobalVariable.mainURL}/public/check-version")!,
        headers: {
          'x-api-key': GlobalVariable.x_api_key,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'version': appVersion, 'device': jsonEncode(deviceInfo)},
      ).timeout(const Duration(seconds: 15), onTimeout: () {
        throw TimeoutException('Version check timeout');
      });

      isLoading(false);

      // Check for server errors (5xx)
      if (response.statusCode >= 500) {
        responseMessage.value = 'Server error: ${response.statusCode}';
        return {
          'success': false,
          'isServerError': true,
          'message': 'Server sedang mengalami gangguan',
        };
      }

      // Check for timeout or other network errors
      if (response.statusCode == 524 || response.statusCode == 408) {
        responseMessage.value = 'Server timeout';
        return {
          'success': false,
          'isServerError': true,
          'message': 'Server timeout, silakan coba lagi',
        };
      }

      var result = jsonDecode(response.body);

      if (response.statusCode == 200) {
        responseMessage.value = result['message'];
        return {
          'success': true,
          'isServerError': false,
          'message': result['message'],
        };
      }

      // Version mismatch or other API error
      responseMessage.value = result['message'];
      return {
        'success': false,
        'isServerError': false,
        'message': result['message'],
      };
    } catch (e) {
      isLoading(false);
      responseMessage.value = e.toString();

      // Network error atau parsing error = server error
      return {
        'success': false,
        'isServerError': true,
        'message': 'Tidak dapat terhubung ke server',
      };
    }
  }

  // Create Demo Trading API
  Future<bool> confirmOTP({String? otp}) async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.post(
        "auth/otp-verification",
        {'otp': otp, 'device': jsonEncode(deviceInfo)},
      );
      isLoading(false);
      Get.log("Response Confirm OTP: $result");
      responseMessage(result['message']);
      if (result['status'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }

  // Create Demo Trading API
  Future<bool> resendOTP() async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.post("auth/resend-otp", {
        'device': jsonEncode(deviceInfo),
      });
      isLoading(false);
      responseMessage(result['message']);
      if (result['status'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }

  // Create Demo Trading API
  Future<bool> verificationAccount({String? gender, String? address}) async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.post("verif/step-1", {
        'gender': gender,
        'address': address,
        'device': jsonEncode(deviceInfo),
      });
      isLoading(false);
      responseMessage(result['message']);
      if (result['status'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }
}
