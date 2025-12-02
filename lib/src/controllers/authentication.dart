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
import 'package:rrfx/src/views/authentications/otp_page.dart';
import 'package:rrfx/src/views/authentications/suspended_page.dart';
import 'package:rrfx/src/views/authentications/verification_account_page.dart';
import 'package:rrfx/src/views/mainpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rrfx/src/controllers/home.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/models/auth/personal_model.dart';

class AuthController extends GetxController {
  RxBool isLoading = false.obs;
  final GetStorage box = GetStorage();
  RxBool isLoadingOTP = false.obs;
  RxString responseMessage = "".obs;
  RxString statusAccount = "".obs;
  Rxn<CountryCodeModel> countryCodeModel = Rxn<CountryCodeModel>();
  Rxn<PersonalModels> personalModel = Rxn<PersonalModels>();
  HomeController homeController = Get.put(HomeController());
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
    SharedPreferences preferences = await SharedPreferences.getInstance();
    try {
      isLoading(true);

      final response = await http.post(
        Uri.tryParse("${GlobalVariable.mainURL}/auth/login")!,
        headers: {
          'x-api-key': GlobalVariable.x_api_key,
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: {
          'email': email,
          'password': password,
          'device': jsonEncode(deviceInfo),
        },
      );

      final result = jsonDecode(response.body);
      isLoading(false);

      if (response.statusCode != 200) {
        responseMessage(result['message'] ?? "Login gagal");
        return;
      }

      if(result['status'] == false){
        CustomScaffoldMessanger.showAppSnackBar(context, message: "Sign in gagal, mohon cek ulang Email atau Password anda apakah sudah benar");
        return;
      }
      responseMessage(result['message'] ?? "Login berhasil");
      final status = result['response']?['status'] ?? "";
      statusAccount(status);
      final accessToken = result['response']?['access_token'];
      final refreshToken = result['response']?['refresh_token'];
      preferences.setString('refreshToken', refreshToken);
      preferences.setString('accessToken', accessToken);
      await box.write('token', accessToken);
      await box.write('refreshToken', refreshToken);
      authService.accessToken = accessToken;
      authService.refreshToken = refreshToken;
      Get.put(AccountController());
      homeController.profile().then((refreshToken){
        if(!refreshToken){
          return;
        }
      });

      switch (status) {
        case "active":
          await preferences.setBool('loggedIn', true);
          Get.offAll(() => Mainpage());
          break;
        case "suspend":
          Get.offAll(() => const SuspendedAccountPage());
          break;
        case "otp":
          Get.to(() => const OtpPage());
          break;
        case "verification":
          Get.to(() => const VerificationAccountPage());
          break;
        default:
          responseMessage("Status akun tidak dikenali, silakan hubungi admin");
      }
    } catch (e) {
      isLoading(false);
      responseMessage.value = "Terjadi kesalahan: $e";
    }
  }

  /// Register API
  Future<bool> register({String? email, String? password, String? name, String? ibCode, String? phone, String? phoneCode, bool? agree}) async {
    try {
      isLoading(true);
      http.Response response = await http.post(
        Uri.tryParse("${GlobalVariable.mainURL}/auth/register")!,
        headers: {
          'x-api-key': GlobalVariable.x_api_key,
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: {
          'fullname': name,
          'email': email,
          'password': password,
          'refferal': ibCode ?? '',
          'phone': phone,
          'phone_code': phoneCode ?? '62',
          'terms': agree == true ? '1' : '0',
          'device': jsonEncode(deviceInfo)
        },
      );
      var result = jsonDecode(response.body);
      isLoading(false);
      if (response.statusCode == 200) {
        if(result['status'] != true) {
          responseMessage.value = result['message'];
          return false;
        }
        responseMessage.value = result['message'];
        return true;
      }
      responseMessage.value = result['message'];
      // responseMessage.value = result['message']['data']['id'];
      return false;
    } catch (e) {
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
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: {
          'phone': phone,
          'phone_code': phoneCode ?? '62',
          'device': jsonEncode(deviceInfo)
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
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: {
          'phone': phone,
          'phone_code': phoneCode ?? '62',
          'device': jsonEncode(deviceInfo)
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
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: {
          'email': email,
          'device': jsonEncode(deviceInfo)
        },
      );
      var result = jsonDecode(response.body);
      isLoading(false);
      if (response.statusCode == 200) {
        responseMessage.value = result['message'];
        return true;
      }
      responseMessage.value = result['message'];
      return false;
    } catch (e) {
      isLoading(false);
      responseMessage.value = e.toString();
      return false;
    }
  }

  /// Send OTP WhatsApp API
  Future<bool> getCountryCode() async {
    try {
      isLoading(true);
      http.Response response = await http.get(
        Uri.tryParse("${GlobalVariable.mainURL}/auth/country")!,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        }
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
  Future<bool> getVersionApp({String? version}) async {
    String? appVersion = await DeviceUtilitiesController.getAppVersion();
    try {
      isLoading(true);
      http.Response response = await http.post(
        Uri.tryParse("${GlobalVariable.mainURL}/public/check-version")!,
        headers: {
          'x-api-key': GlobalVariable.x_api_key,
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: {
          'version': appVersion,
          'device': jsonEncode(deviceInfo)
        },
      );
      var result = jsonDecode(response.body);
      isLoading(false);
      if (response.statusCode == 200) {
        responseMessage.value = result['message'];
        return true;
      }
      responseMessage.value = result['message'];
      return false;
    } catch (e) {
      isLoading(false);
      responseMessage.value = e.toString();
      return false;
    }
  }

  // Create Demo Trading API
  Future<bool> confirmOTP({String? otp}) async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.post("auth/otp-verification", {
        'otp': otp,
        'device': jsonEncode(deviceInfo)
      });
      isLoading(false);
      responseMessage(result['message']);
      if(result['status'] == true) {
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
        'device': jsonEncode(deviceInfo)
      });
      isLoading(false);
      responseMessage(result['message']);
      if(result['status'] == true) {
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
        'device': jsonEncode(deviceInfo)
      });
      isLoading(false);
      responseMessage(result['message']);
      if(result['status'] == true) {
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