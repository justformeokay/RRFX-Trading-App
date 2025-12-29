import 'dart:convert';
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
      print('[PasscodeService] Saving passcode: length=${passcode.length}, value=$passcode');
      
      final box = GetStorage();
      final model = PasscodeModel(
        passcode: passcode,
        createdAt: DateTime.now(),
        isSetup: true,
        useBiometric: useBiometric,
        biometricType: biometricType,
      );

      final jsonData = model.toJson();
      print('[PasscodeService] JSON data before save: $jsonData');
      
      await box.write(_passcodeKey, jsonData);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_passcodeSetupKey, true);

      // Verify it was saved
      final saved = box.read(_passcodeKey);
      print('[PasscodeService] Saved and verified: $saved');

      return true;
    } catch (e) {
      print('Error saving passcode: $e');
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
      print('Error getting passcode: $e');
      return null;
    }
  }

  /// Check if passcode is already set up
  static Future<bool> isPasscodeSetup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_passcodeSetupKey) ?? false;
    } catch (e) {
      print('Error checking passcode setup: $e');
      return false;
    }
  }

  /// Check if biometric is enabled
  static Future<bool> isBiometricEnabled() async {
    try {
      final passcode = await getPasscode();
      return passcode?.useBiometric ?? false;
    } catch (e) {
      print('Error checking biometric status: $e');
      return false;
    }
  }

  /// Get biometric type
  static Future<String?> getBiometricType() async {
    try {
      final passcode = await getPasscode();
      return passcode?.biometricType;
    } catch (e) {
      print('Error getting biometric type: $e');
      return null;
    }
  }

  /// Update biometric status
  static Future<bool> updateBiometricStatus(
    bool enabled, {
    String? biometricType,
  }) async {
    try {
      print('[PasscodeService] updateBiometricStatus called with enabled=$enabled, biometricType=$biometricType');
      
      final passcode = await getPasscode();
      print('[PasscodeService] Current passcode model: $passcode');
      
      // Jika passcode tidak ada di local storage, buat model baru dengan placeholder
      // (ini terjadi karena passcode disimpan di server, bukan local)
      final PasscodeModel updatedModel;
      
      if (passcode == null) {
        print('[PasscodeService] Passcode not found, creating new model with biometric flags only');
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

      print('[PasscodeService] Updated model: useBiometric=${updatedModel.useBiometric}, biometricType=${updatedModel.biometricType}');

      final box = GetStorage();
      print('[PasscodeService] GetStorage initialized');
      
      await box.write(_passcodeKey, updatedModel.toJson());
      print('[PasscodeService] Data written to storage');

      // Verify it was saved
      final saved = box.read(_passcodeKey);
      print('[PasscodeService] Verification read from storage: $saved');

      if (saved != null) {
        final verifiedModel = PasscodeModel.fromJson(saved as Map<String, dynamic>);
        print('[PasscodeService] Verified saved model: useBiometric=${verifiedModel.useBiometric}, biometricType=${verifiedModel.biometricType}');
      }

      return true;
    } catch (e) {
      print('[PasscodeService] ERROR updating biometric status: $e');
      print('[PasscodeService] Error type: ${e.runtimeType}');
      return false;
    }
  }

  /// Verify passcode
  static Future<bool> verifyPasscode(String inputPasscode) async {
    try {
      print('[PasscodeService] Verifying passcode: input=$inputPasscode, length=${inputPasscode.length}');
      
      final savedPasscode = await getPasscode();
      if (savedPasscode == null) {
        print('[PasscodeService] No saved passcode found');
        return false;
      }

      print('[PasscodeService] Saved passcode: ${savedPasscode.passcode}, length=${savedPasscode.passcode.length}');
      print('[PasscodeService] Match result: ${savedPasscode.passcode == inputPasscode}');
      
      return savedPasscode.passcode == inputPasscode;
    } catch (e) {
      print('Error verifying passcode: $e');
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
      print('Error deleting passcode: $e');
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
      print('Error updating passcode: $e');
      return false;
    }
  }

  /// Store passcode to server API
  static Future<bool> storePasscodeToServer(String passcode, String passcodeConfirm) async {
    try {
      print('[PasscodeService] Storing passcode to server...');
      
      // Get AuthService instance
      final authService = Get.find<AuthService>();
      
      // Prepare headers with Authorization
      final headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${authService.accessToken}',
      };
      
      print('[PasscodeService] Headers: $headers');
      
      // Prepare body
      final body = {
        'passcode': passcode,
        'passcode_confirm': passcodeConfirm,
      };
      
      print('[PasscodeService] Body: $body');
      
      // Make POST request
      final response = await authService.post('passcode/create', body);
      
      print('[PasscodeService] Response: $response');
      
      // Check if response is successful
      if (response['status'] == true) {
        print('[PasscodeService] ✅ Passcode stored to server successfully');
        return true;
      } else {
        print('[PasscodeService] ❌ Failed to store passcode: ${response['message']}');
        return false;
      }
    } catch (e) {
      print('[PasscodeService] ❌ Error storing passcode to server: $e');
      return false;
    }
  }

  /// Verify passcode with server API
  /// Returns a Map with 'status' (bool) and 'attempt' (int from API response)
  static Future<Map<String, dynamic>> verifyPasscodeWithServer(String passcode) async {
    try {
      print('[PasscodeService] Verifying passcode with server...');
      
      // Get AuthService instance
      final authService = Get.find<AuthService>();
      
      // Prepare body
      final body = {
        'passcode': passcode,
      };
      
      print('[PasscodeService] Verifying passcode: $passcode');
      
      // Make POST request
      final response = await authService.post('passcode/verify', body);
      
      print('[PasscodeService] Verification response: $response');
      
      // Check if response is successful
      if (response['status'] == true) {
        print('[PasscodeService] ✅ Passcode verified successfully');
        return {
          'status': true,
          'attempt': 0,
        };
      } else {
        print('[PasscodeService] ❌ Passcode verification failed: ${response['message']}');
        
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
      print('[PasscodeService] ❌ Error verifying passcode with server: $e');
      return {
        'status': false,
        'attempt': 0,
      };
    }
  }

  /// Request passcode reset via email
  static Future<Map<String, dynamic>> requestPasscodeReset() async {
    try {
      print('[PasscodeService] Requesting passcode reset...');
      
      // Get AuthService instance
      final authService = Get.find<AuthService>();
      
      print('[PasscodeService] Using Bearer token: ${authService.accessToken?.substring(0, 20)}...');
      
      // Make POST request (no body needed, only Bearer token)
      final response = await authService.post('passcode/request-reset', {});
      
      print('[PasscodeService] Reset request response: $response');
      
      // Return the full response
      return {
        'status': response['status'] == true,
        'message': response['message'] ?? 'Unknown error',
        'statusCode': response['statusCode'] ?? 0,
      };
    } catch (e) {
      print('[PasscodeService] ❌ Error requesting passcode reset: $e');
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
      print('[PasscodeService] Sending OTP for passcode change...');
      
      // Get AuthService instance
      final authService = Get.find<AuthService>();
      
      print('[PasscodeService] Using Bearer token: ${authService.accessToken?.substring(0, 20)}...');
      
      // Make POST request (no body needed, only Bearer token)
      final response = await authService.post('passcode/send-otp', {});
      
      print('[PasscodeService] OTP send response: $response');
      
      // Return the full response
      return {
        'status': response['status'] == true,
        'message': response['message'] ?? 'Unknown error',
        'statusCode': response['statusCode'] ?? 0,
      };
    } catch (e) {
      print('[PasscodeService] ❌ Error sending OTP: $e');
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
      print('[PasscodeService] Changing passcode...');
      
      // Get AuthService instance
      final authService = Get.find<AuthService>();
      
      // Prepare body
      final body = {
        'passcode': currentPasscode,
        'new_passcode': newPasscode,
        'new_passcode_confirm': newPasscodeConfirm,
        'otp': otp,
      };
      
      print('[PasscodeService] Change passcode body: $body');
      
      // Make POST request
      final response = await authService.post('passcode/change-passcode', body);
      
      print('[PasscodeService] Change passcode response: $response');
      
      // Return the full response
      return {
        'status': response['status'] == true,
        'message': response['message'] ?? 'Unknown error',
        'statusCode': response['statusCode'] ?? 0,
      };
    } catch (e) {
      print('[PasscodeService] ❌ Error changing passcode: $e');
      return {
        'status': false,
        'message': 'Gagal mengubah passcode: $e',
        'statusCode': 0,
      };
    }
  }
}
