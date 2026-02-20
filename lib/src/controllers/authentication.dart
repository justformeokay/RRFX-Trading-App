import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/alerts/modern_alert_dialog.dart';
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
  RxInt otpResendCountdown = 0.obs;
  RxString statusAccount = "".obs;
  Rxn<CountryCodeModel> countryCodeModel = Rxn<CountryCodeModel>();
  Rxn<PersonalModels> personalModel = Rxn<PersonalModels>();
  // OTP Countdown Timer
  Timer? _otpCountdownTimer;
  // UTM Parameters storage
  final Rxn<Map<String, String>> _utmParameters = Rxn<Map<String, String>>();
  // HomeController getter - ensures controller exists before use
  HomeController get homeController {
    try {
      return Get.find<HomeController>();
    } catch (e) {
      Get.log(
        "⚠️ [AUTH] HomeController not found, creating permanent instance",
      );
      return Get.put(HomeController(), permanent: true);
    }
  }

  Map<String, String> deviceInfo = {};
  AuthService authService = Get.find();

  init() async {
    DeviceUtilitiesController.getDeviceInfo().then((value) {
      deviceInfo = value;
    });

    // Load saved UTM parameters from storage if exists
    final savedUtm = box.read('utm_parameters');
    if (savedUtm != null && savedUtm is Map) {
      _utmParameters.value = Map<String, String>.from(savedUtm);
      Get.log("📊 [AUTH] Loaded saved UTM: $_utmParameters");
    }
  }

  /// Set UTM parameters from deep link
  void setUtmParameters(Map<String, String> utmParams) {
    _utmParameters.value = utmParams;
    box.write('utm_parameters', utmParams);
    Get.log("📊 [AUTH] UTM parameters saved: $utmParams");
  }

  /// Clear UTM parameters after successful registration
  void clearUtmParameters() {
    _utmParameters.value = null;
    box.remove('utm_parameters');
    Get.log("📊 [AUTH] UTM parameters cleared");
  }

  /// Start OTP resend countdown timer
  void startOtpCountdown(int seconds) {
    _cancelOtpCountdown();
    otpResendCountdown.value = seconds;
    Get.log("⏱️ [AUTH] Starting OTP countdown: $seconds seconds");
    
    _otpCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (otpResendCountdown.value > 0) {
        otpResendCountdown.value--;
      } else {
        _cancelOtpCountdown();
        Get.log("✅ [AUTH] OTP countdown finished");
      }
    });
  }

  /// Cancel OTP countdown timer
  void _cancelOtpCountdown() {
    _otpCountdownTimer?.cancel();
    _otpCountdownTimer = null;
  }

  @override
  void onClose() {
    _cancelOtpCountdown();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    init();
  }

  Future<void> login(
    BuildContext context, {
    String? email,
    String? password,
  }) async {
    Get.log("🔵 [AUTH] login() called for email: $email");
    SharedPreferences preferences = await SharedPreferences.getInstance();
    try {
      isLoading(true);

      // ✅ Get device_id (FCM Token) from SharedPreferences
      String? deviceId = preferences.getString('deviceID');
      Get.log("📱 [AUTH] Device ID (FCM Token): $deviceId");

      Get.log("📡 [AUTH] Sending login request...");
      final response = await http
          .post(
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
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              isLoading(false);
              Get.log("❌ [AUTH] Request timeout");
              ModernAlertDialog.warning(
                title: "Koneksi Lambat",
                message:
                    "Server tidak merespons. Silakan periksa koneksi internet Anda dan coba lagi.",
                buttonText: "OK",
              );
              throw TimeoutException("Request timeout");
            },
          );
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

        // Tentukan title dan type berdasarkan pesan error
        String title = "Login Gagal";
        AlertType alertType = AlertType.error;

        if (message.contains("tidak ditemukan") || message.contains("salah")) {
          title = "Email atau Password Salah";
        }

        ModernAlertDialog.show(
          type: alertType,
          message:
              message.isNotEmpty
                  ? message
                  : "Login gagal, mohon cek ulang Email atau Password Anda apakah sudah benar",
          title: title,
          buttonText: "OK",
        );
        return;
      }

      if (response.statusCode != 200) {
        Get.log(
          "❌ [AUTH] Login failed - HTTP status code not 200: ${response.statusCode}",
        );
        responseMessage(result['message'] ?? "Login gagal");
        ModernAlertDialog.error(
          title: "Masalah Server",
          message:
              result['message'] ??
              "Terjadi kesalahan saat login. Silakan coba lagi.",
          buttonText: "OK",
        );
        return;
      }

      responseMessage(result['message'] ?? "Login berhasil");
      final status = result['response']?['status'] ?? "";
      final hasPasscode = result['response']?['passcode'] ?? false;
      statusAccount(status.toLowerCase());
      final accessToken = result['response']?['access_token'];
      final refreshToken = result['response']?['refresh_token'];
      final countdown = result['response']?['otp_expired_in'] ?? 0;
      otpResendCountdown.value = countdown;
      
      // Start countdown timer if OTP expiry is set
      if (countdown > 0) {
        startOtpCountdown(countdown);
        Get.log("⏱️ [AUTH] OTP countdown started: $countdown seconds");
      }

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
      Get.log(
        "👤 [AUTH] Profile data: ${homeController.profileModel.value?.toJson()}",
      );

      Get.log(
        "🚀 [AUTH] Routing based on status: $status and passcode: $hasPasscode",
      );
      switch (statusAccount.value) {
        case "active":
          Get.log("✅ [AUTH] Status: active - Checking passcode...");
          await preferences.setBool('loggedIn', true);

          // ✅ Check if passcode already exists on server
          if (hasPasscode) {
            Get.log(
              "✅ [AUTH] Passcode exists on server - Going to VerifyPasscodePage",
            );
            Get.offAll(() => const VerifyPasscodePage());
          } else {
            Get.log(
              "🔐 [AUTH] Passcode not set up on server - Going to SetupPasscodePage",
            );
            Get.offAll(() => const SetupPasscodePage());
          }
          break;
        case "suspend":
          Get.log("⚠️ [AUTH] Status: suspend - Going to SuspendedAccountPage");
          Get.offAll(() => const SuspendedAccountPage());
          break;
        case "otp":
          Get.log(
            "📱 [AUTH] Status: otp - Going to OtpPage (user baru, belum verifikasi OTP)",
          );
          Get.offAll(() => const OtpPage());
          break;
        case "verification":
          Get.log(
            "📧 [AUTH] Status: verification - Going to VerificationAccountPage (user baru, belum verifikasi akun)",
          );
          Get.log(
            "👤 [AUTH] Profile before navigation: ${homeController.profileModel.value?.email ?? 'NULL'}",
          );
          Get.offAll(() => const VerificationAccountPage());
          break;
        default:
          Get.log("❌ [AUTH] Unknown status: $status");
          responseMessage("Status akun tidak dikenali, silakan hubungi admin");
      }
    } catch (e) {
      isLoading(false);
      Get.log("❌ [AUTH] Exception in login(): $e");

      // Gunakan helper method untuk mendapatkan pesan error yang sesuai
      String errorMessage = _getErrorMessage(e);
      responseMessage.value = errorMessage;

      // Tentukan title berdasarkan jenis error
      String title = "Kesalahan";
      if (errorMessage.contains("Koneksi internet")) {
        title = "Koneksi Internet Terputus";
      } else if (errorMessage.contains("lambat")) {
        title = "Koneksi Lambat";
      }

      // Tampilkan popup error
      ModernAlertDialog.show(
        type: AlertType.error,
        title: title,
        message: errorMessage,
        buttonText: "OK",
      );
    }
  }

  /// Register API
  /// Helper method untuk menentukan pesan error yang sesuai
  String _getErrorMessage(Object error) {
    if (error is SocketException) {
      // Koneksi internet terputus atau host tidak ditemukan
      return "Koneksi internet terputus. Silakan periksa koneksi Anda dan coba lagi.";
    } else if (error is TimeoutException) {
      // Koneksi timeout
      return "Koneksi lambat atau server tidak merespons. Silakan coba lagi.";
    } else if (error is FormatException) {
      // Error parsing response
      return "Terjadi kesalahan saat memproses data. Silakan coba lagi.";
    } else if (error is HttpException) {
      // HTTP error
      return "Terjadi kesalahan jaringan. Silakan periksa koneksi Anda.";
    } else {
      final errorString = error.toString();

      // Deteksi berbagai pesan error jaringan
      if (errorString.contains("SocketException") ||
          errorString.contains("Failed host lookup")) {
        return "Koneksi internet terputus. Silakan periksa koneksi Anda dan coba lagi.";
      } else if (errorString.contains("TimeoutException") ||
          errorString.contains("Timeout")) {
        return "Koneksi lambat atau server tidak merespons. Silakan coba lagi.";
      } else if (errorString.contains("Connection refused")) {
        return "Tidak dapat terhubung ke server. Silakan coba lagi nanti.";
      } else if (errorString.contains("Connection reset")) {
        return "Koneksi terputus oleh server. Silakan coba lagi.";
      } else if (errorString.contains("No address associated with hostname")) {
        return "Server tidak dapat diakses. Periksa koneksi internet Anda.";
      }

      return error.toString();
    }
  }

  Future<bool> register({
    String? email,
    String? password,
    String? name,
    String? ibCode,
    String? phone,
    String? phoneCode,
    bool? agree,
  }) async {
    Get.log(
      "🟢 [AUTH] register() called for email: $email, name: $name, phone: $phone",
    );
    try {
      isLoading(true);
      Get.log("📡 [AUTH] Sending registration request...");

      // Build request body
      final Map<String, String> requestBody = {
        'fullname': name!,
        'email': email!,
        'password': password!,
        'referral': ibCode ?? '',
        'phone': phone!,
        'phone_code': phoneCode ?? '62',
        'terms': agree == true ? '1' : '0',
        'device': jsonEncode(deviceInfo),
      };

      // Tambahkan UTM hanya jika ada dari deep link/iklan
      if (_utmParameters.value != null && _utmParameters.value!.isNotEmpty) {
        requestBody['utm'] = jsonEncode(_utmParameters.value);
        Get.log("📊 [AUTH] Sending UTM to API: ${_utmParameters.value}");
      } else {
        Get.log("📊 [AUTH] No UTM parameters - user daftar langsung");
      }

      http.Response response = await http
          .post(
            Uri.tryParse("${GlobalVariable.mainURL}/auth/register")!,
            headers: {
              'x-api-key': GlobalVariable.x_api_key,
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: requestBody,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              isLoading(false);
              responseMessage.value =
                  "Koneksi lambat atau server tidak merespons. Silakan coba lagi.";
              Get.log("❌ [AUTH] Request timeout");
              throw TimeoutException("Request timeout");
            },
          );

      var result = jsonDecode(response.body);
      isLoading(false);
      Get.log("📥 [AUTH] Register response status: ${response.statusCode}");
      Get.log("📋 [AUTH] Register response: ${response.body}");

      if (response.statusCode == 200) {
        if (result['status'] != true) {
          Get.log("❌ [AUTH] Registration failed - status false");
          responseMessage.value = result['message'] ?? "Registrasi gagal";
          return false;
        }
        Get.log("✅ [AUTH] Registration successful");
        responseMessage.value = result['message'];

        // Clear UTM parameters after successful registration
        clearUtmParameters();

        return true;
      }
      Get.log("❌ [AUTH] Registration failed - status code not 200");
      responseMessage.value =
          result['message'] ?? "Terjadi kesalahan saat registrasi";
      return false;
    } catch (e) {
      Get.log("❌ [AUTH] Exception in register(): $e");
      isLoading(false);

      // Gunakan helper method untuk mendapatkan pesan error yang sesuai
      responseMessage.value = _getErrorMessage(e);
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
      responseMessage.value = result['message'];
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
      appVersion = await DeviceUtilitiesController.getAppVersion().timeout(
        const Duration(seconds: 5),
        onTimeout: () => '1.0',
      );
    } catch (e) {
      Get.log('⚠️ [AUTH] getAppVersion error: $e, using fallback version');
      appVersion = '1.0';
    }

    try {
      isLoading(true);

      // Add timeout untuk HTTP request
      http.Response response = await http
          .post(
            Uri.tryParse("${GlobalVariable.mainURL}/public/check-version")!,
            headers: {
              'x-api-key': GlobalVariable.x_api_key,
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: {'version': appVersion, 'device': jsonEncode(deviceInfo)},
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException('Version check timeout');
            },
          );

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

  // Resend OTP via selected channel (email or whatsapp)
  Future<bool> resendOTP({String type = 'email'}) async {
    try {
      isLoading(true);
      Get.log("📤 [AUTH] Resending OTP via: $type");
      
      Map<String, dynamic> result = await authService.post("auth/resend-otp", {
        'type': type,
      });
      
      Get.log("📥 [AUTH] Resend OTP raw response: $result");
      
      isLoading(false);
      
      // Safely get message
      final message = result['message']?.toString() ?? 'No message';
      responseMessage.value = message;
      
      if (result['status'] == true) {
        Get.log("✅ [AUTH] Resend OTP successful via: $type");
        
        // Extract countdown from response with better error handling
        try {
          final response = result['response'];
          Get.log("📊 [AUTH] Response data type: ${response.runtimeType}");
          Get.log("📊 [AUTH] Response data: $response");
          
          int countdown = 0;
          if (response is Map) {
            countdown = (response['otp_expired_in'] as num?)?.toInt() ?? 0;
          }
          
          Get.log("⏲️ [AUTH] Extracted countdown: $countdown seconds");
          
          if (countdown > 0) {
            otpResendCountdown.value = countdown;
            startOtpCountdown(countdown);
          }
        } catch (e) {
          Get.log("⚠️ [AUTH] Error extracting countdown: $e");
          // Continue without countdown - not critical
        }
        
        return true;
      }
      Get.log("❌ [AUTH] Resend OTP failed: $message");
      return false;
    } catch (e, stackTrace) {
      isLoading(false);
      Get.log("❌ [AUTH] Resend OTP error: $e");
      Get.log("📋 [AUTH] Stack trace: $stackTrace");
      responseMessage.value = e.toString();
      return false;
    }
  }

  // Create Demo Trading API
  Future<bool> verificationAccount({
    String? gender,
    String? address,
    String? country,
  }) async {
    try {
      isLoading(true);
      
      // DEBUG: Print data yang akan dikirim
      print('\n═══════════════════════════════════════════════════');
      print('📤 [VERIFICATION] Sending data to API (verif/step-1)');
      print('───────────────────────────────────────────────────');
      print('Gender: $gender (Type: ${gender.runtimeType})');
      print('Address: $address (Type: ${address.runtimeType})');
      print('Country: $country (Type: ${country.runtimeType})');
      print('Country (isUpperCase): ${country == country?.toUpperCase()}');
      print('Country (length): ${country?.length}');
      print('Device: ${jsonEncode(deviceInfo)}');
      print('═══════════════════════════════════════════════════\n');
      
      Map<String, dynamic> requestBody = {
        'gender': gender,
        'address': address,
        'country': country,
        'device': jsonEncode(deviceInfo),
      };
      
      print('📋 Request Body: $requestBody');
      
      Map<String, dynamic> result = await authService.post("verif/step-1", requestBody);
      
      // DEBUG: Print API response
      print('\n═══════════════════════════════════════════════════');
      print('📥 [VERIFICATION] API Response:');
      print('───────────────────────────────────────────────────');
      print('Status: ${result['status']}');
      print('Message: ${result['message']}');
      print('Full Response: $result');
      print('═══════════════════════════════════════════════════\n');
      
      isLoading(false);
      responseMessage(result['message']);
      if (result['status'] == true) {
        print('✅ [VERIFICATION] Verification successful');
        return true;
      }
      print('❌ [VERIFICATION] Verification failed');
      return false;
    } catch (e) {
      print('\n═══════════════════════════════════════════════════');
      print('❌ [VERIFICATION] Exception occurred:');
      print('───────────────────────────────────────────────────');
      print('Error: $e');
      print('Error Type: ${e.runtimeType}');
      print('═══════════════════════════════════════════════════\n');
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }

  /// Logout - Clear all stored data from login
  Future<void> logout() async {
    Get.log("🔴 [AUTH] logout() called - Clearing all login data");
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      // Clear tokens from SharedPreferences
      await preferences.remove('accessToken');
      await preferences.remove('refreshToken');
      await preferences.remove('loggedIn');
      await preferences.remove('deviceID');
      Get.log("💾 [AUTH] Cleared data from SharedPreferences");

      // Clear tokens from GetStorage
      await box.remove('token');
      await box.remove('refreshToken');
      Get.log("💾 [AUTH] Cleared data from GetStorage");

      // Clear tokens from AuthService
      authService.accessToken = null;
      authService.refreshToken = null;
      Get.log("💾 [AUTH] Cleared tokens from AuthService");

      // Clear passcode data
      await PasscodeService.deletePasscode();
      Get.log("💾 [AUTH] Cleared passcode data");

      // Clear controllers
      if (Get.isRegistered<AccountController>()) {
        Get.delete<AccountController>();
        Get.log("🎮 [AUTH] Deleted AccountController");
      }

      if (Get.isRegistered<HomeController>()) {
        Get.delete<HomeController>();
        Get.log("🎮 [AUTH] Deleted HomeController");
      }

      // Clear other cached data
      statusAccount('');
      personalModel.value = null;

      Get.log("✅ [AUTH] Logout completed successfully");
    } catch (e) {
      Get.log("❌ [AUTH] Error during logout: $e");
    }
  }
}
