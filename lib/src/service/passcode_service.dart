import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rrfx/src/models/auth/passcode_model.dart';
import 'package:rrfx/src/service/auth_service.dart';

class PasscodeService {
  static const String _passcodeKey = 'app_passcode';
  static const String _passcodeSetupKey = 'passcode_setup_complete';

  /// Save passcode to local storage
  static Future<bool> savePasscode(
    String passcode, {
    bool useBiometric = false,
    String? biometricType,
  }) async {
    try {
      final box = GetStorage();
      final model = PasscodeModel(
        passcode: passcode,
        createdAt: DateTime.now(),
        isSetup: true,
        useBiometric: useBiometric,
        biometricType: biometricType,
      );

      final jsonData = model.toJson();

      
      await box.write(_passcodeKey, jsonData);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_passcodeSetupKey, true);

      // Verify it was saved
      final saved = box.read(_passcodeKey);


      return true;
    } catch (e) {

      return false;
    }
  }

  /// Get saved passcode from local storage
  static Future<PasscodeModel?> getPasscode() async {
    try {
      final box = GetStorage();
      final data = box.read(_passcodeKey);

      if (data != null) {
        return PasscodeModel.fromJson(data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {

      return null;
    }
  }

  /// Check if passcode is already set up
  static Future<bool> isPasscodeSetup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_passcodeSetupKey) ?? false;
    } catch (e) {

      return false;
    }
  }

  /// Check if biometric is enabled
  static Future<bool> isBiometricEnabled() async {
    try {
      final passcode = await getPasscode();
      return passcode?.useBiometric ?? false;
    } catch (e) {

      return false;
    }
  }

  /// Get biometric type
  static Future<String?> getBiometricType() async {
    try {
      final passcode = await getPasscode();
      return passcode?.biometricType;
    } catch (e) {

      return null;
    }
  }

  /// Update biometric status
  static Future<bool> updateBiometricStatus(
    bool enabled, {
    String? biometricType,
  }) async {
    try {

      
      final passcode = await getPasscode();

      
      // Jika passcode tidak ada di local storage, buat model baru dengan placeholder
      // (ini terjadi karena passcode disimpan di server, bukan local)
      final PasscodeModel updatedModel;
      
      if (passcode == null) {

        updatedModel = PasscodeModel(
          passcode: 'SERVER_STORED', // Placeholder karena disimpan di server
          createdAt: DateTime.now(),
          isSetup: true,
          useBiometric: enabled,
          biometricType: biometricType,
        );
      } else {
        updatedModel = passcode.copyWith(
          useBiometric: enabled,
          biometricType: biometricType,
        );
      }



      final box = GetStorage();

      
      await box.write(_passcodeKey, updatedModel.toJson());


      // Verify it was saved
      final saved = box.read(_passcodeKey);


      if (saved != null) {
        final verifiedModel = PasscodeModel.fromJson(saved as Map<String, dynamic>);

      }

      return true;
    } catch (e) {


      return false;
    }
  }

  /// Verify passcode
  static Future<bool> verifyPasscode(String inputPasscode) async {
    try {

      
      final savedPasscode = await getPasscode();
      if (savedPasscode == null) {

        return false;
      }



      
      return savedPasscode.passcode == inputPasscode;
    } catch (e) {

      return false;
    }
  }

  /// Delete passcode (for testing or reset)
  static Future<bool> deletePasscode() async {
    try {
      final box = GetStorage();
      await box.remove(_passcodeKey);

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_passcodeSetupKey);

      return true;
    } catch (e) {

      return false;
    }
  }

  /// Update/change passcode
  static Future<bool> updatePasscode(String newPasscode) async {
    try {
      final box = GetStorage();
      final existingModel = await getPasscode();

      final model = PasscodeModel(
        passcode: newPasscode,
        createdAt: DateTime.now(),
        isSetup: true,
        useBiometric: existingModel?.useBiometric ?? false,
        biometricType: existingModel?.biometricType,
      );

      await box.write(_passcodeKey, model.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Store passcode to server API
  static Future<bool> storePasscodeToServer(String passcode, String passcodeConfirm) async {
    try {
      
      // Get AuthService instance
      final authService = Get.find<AuthService>();
      
      // Prepare body
      final body = {
        'passcode': passcode,
        'passcode_confirm': passcodeConfirm,
      };
      
      
      // Make POST request
      final response = await authService.post('passcode/create', body);
      
      
      // Check if response is successful
      if (response['status'] == true) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Verify passcode with server API
  /// Returns a Map with 'status' (bool) and 'attempt' (int from API response)
  static Future<Map<String, dynamic>> verifyPasscodeWithServer(String passcode) async {
    try {
      
      // Get AuthService instance
      final authService = Get.find<AuthService>();
      
      // Prepare body
      final body = {
        'passcode': passcode,
      };
      
      
      // Make POST request
      final response = await authService.post('passcode/verify', body);
      
      
      // Check if response is successful
      if (response['status'] == true) {
        return {
          'status': true,
          'attempt': 0,
        };
      } else {
        
        // Extract attempt from response
        int attempt = 1;
        if (response['response'] != null && response['response']['attempt'] != null) {
          attempt = response['response']['attempt'];
        }
        
        return {
          'status': false,
          'attempt': attempt,
        };
      }
    } catch (e) {
      return {
        'status': false,
        'attempt': 0,
      };
    }
  }

  /// Request passcode reset via email
  static Future<Map<String, dynamic>> requestPasscodeReset() async {
    try {
      
      // Get AuthService instance
      final authService = Get.find<AuthService>();
      
      // Make POST request (no body needed, only Bearer token)
      final response = await authService.post('passcode/request-reset', {});
      
      
      // Return the full response
      return {
        'status': response['status'] == true,
        'message': response['message'] ?? 'Unknown error',
        'statusCode': response['statusCode'] ?? 0,
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'Gagal mengirim request reset: $e',
        'statusCode': 0,
      };
    }
  }

  /// Send OTP for passcode change
  static Future<Map<String, dynamic>> sendOTPForPasscodeChange() async {
    try {
      
      // Get AuthService instance
      final authService = Get.find<AuthService>();
      
      
      // Make POST request (no body needed, only Bearer token)
      final response = await authService.post('passcode/send-otp', {});
      
      
      // Return the full response
      return {
        'status': response['status'] == true,
        'message': response['message'] ?? 'Unknown error',
        'statusCode': response['statusCode'] ?? 0,
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'Gagal mengirim OTP: $e',
        'statusCode': 0,
      };
    }
  }

  /// Change passcode with OTP
  static Future<Map<String, dynamic>> changePasscode({
    required String currentPasscode,
    required String newPasscode,
    required String newPasscodeConfirm,
    required String otp,
  }) async {
    try {
      
      // Get AuthService instance
      final authService = Get.find<AuthService>();
      
      // Prepare body
      final body = {
        'passcode': currentPasscode,
        'new_passcode': newPasscode,
        'new_passcode_confirm': newPasscodeConfirm,
        'otp': otp,
      };
      
      
      // Make POST request
      final response = await authService.post('passcode/change-passcode', body);
      
      
      // Return the full response
      return {
        'status': response['status'] == true,
        'message': response['message'] ?? 'Unknown error',
        'statusCode': response['statusCode'] ?? 0,
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'Gagal mengubah passcode: $e',
        'statusCode': 0,
      };
    }
  }
}
