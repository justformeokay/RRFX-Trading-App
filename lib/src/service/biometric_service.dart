import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();

  factory BiometricService() {
    return _instance;
  }

  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if device has biometric sensors
  Future<bool> canCheckBiometrics() async {
    try {
      // For iOS, use isDeviceSupported() which is more reliable
      if (Platform.isIOS) {
        return await _localAuth.isDeviceSupported();
      }
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      Get.log('Error checking biometrics: $e');
      return false;
    }
  }

  /// Check if device has biometric authentication available
  Future<bool> deviceSupportsBiometric() async {
    try {
      // For iOS, isDeviceSupported() is more reliable than canCheckBiometrics
      final isSupported = await _localAuth.isDeviceSupported();
      
      if (Platform.isIOS) {
        // On iOS, isDeviceSupported returns true if device has Face ID or Touch ID capability
        // Even if no biometrics are enrolled, we still want to show the option
        Get.log('[BiometricService] iOS - isDeviceSupported: $isSupported');
        return isSupported;
      }
      
      // For Android, check both
      final canCheck = await _localAuth.canCheckBiometrics;
      final biometrics = await _localAuth.getAvailableBiometrics();
      Get.log('[BiometricService] Android - canCheck: $canCheck, biometrics: $biometrics');
      return canCheck && biometrics.isNotEmpty;
    } catch (e) {
      Get.log('Error checking device support: $e');
      return false;
    }
  }

  /// Get available biometric types on device
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();
      Get.log('[BiometricService] Available biometrics: $biometrics');
      return biometrics;
    } catch (e) {
      Get.log('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Authenticate using fingerprint/biometric
  Future<bool> authenticate({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      
      // Check if device supports biometric
      final isDeviceSupported = await deviceSupportsBiometric();
      
      if (!isDeviceSupported) {
        // Untuk iOS, coba tetap authenticate meskipun check gagal
        // Karena kadang check bisa false tapi authenticate bisa jalan
        if (!Platform.isIOS) {
          throw Exception('Device tidak mendukung biometric authentication');
        }
        Get.log('[BiometricService] iOS device - attempting anyway...');
      }

      // Get available biometrics
      final availableBiometrics = await getAvailableBiometrics();
      
      // Untuk Android, jika tidak ada biometric terdaftar, throw error
      // Untuk iOS, kita tetap lanjut karena iOS akan handle dengan prompt Face ID/Touch ID setup
      if (availableBiometrics.isEmpty && !Platform.isIOS) {
        throw Exception('Tidak ada biometric terdaftar di device');
      }
      
      // iOS memerlukan localizedReason yang lebih spesifik
      final localizedReason = Platform.isIOS 
          ? 'Autentikasi diperlukan untuk mengakses aplikasi'
          : reason;
      
      // Untuk iOS: jika tidak ada biometric terdaftar, gunakan biometricOnly: false
      // agar iOS bisa fallback ke device passcode dan prompt setup biometric
      final bool useBiometricOnly = Platform.isIOS 
          ? availableBiometrics.isNotEmpty  // false jika tidak ada biometric enrolled
          : false;  // Android selalu allow fallback
      
      Get.log('[BiometricService] Authenticating with biometricOnly: $useBiometricOnly');
      
      // Authenticate dengan opsi berbeda untuk iOS dan Android
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
          biometricOnly: useBiometricOnly,
          useErrorDialogs: useErrorDialogs,
          sensitiveTransaction: false,
        ),
      );

      Get.log('[BiometricService] Authentication result: $isAuthenticated');
      return isAuthenticated;
    } on PlatformException catch (e) {
      Get.log('[BiometricService] PlatformException: ${e.code} - ${e.message}');
      
      // Handle specific errors
      if (e.code == 'NotAvailable') {
        throw Exception('Biometric tidak tersedia di device ini');
      } else if (e.code == 'NotEnrolled') {
        // Untuk iOS, ini berarti user belum setup Face ID/Touch ID
        if (Platform.isIOS) {
          throw Exception('Silakan setup Face ID atau Touch ID di Settings iPhone terlebih dahulu');
        }
        throw Exception('Tidak ada biometric terdaftar di device');
      } else if (e.code == 'LockedOut' || e.code == 'LockedOutTemporarily') {
        throw Exception('Terlalu banyak percobaan gagal. Coba lagi nanti');
      } else if (e.code == 'PermanentlyLockedOut') {
        throw Exception('Biometric terkunci permanen. Gunakan passcode');
      } else if (e.code == 'UserCanceled' || e.code == 'PasscodeNotSet' || e.code == 'AuthenticationCanceled') {
        return false;
      } else if (e.code == 'BiometricOnlyNotSupported') {
        // iOS specific - retry with biometricOnly: false
        try {
          final retryAuth = await _localAuth.authenticate(
            localizedReason: reason,
            options: const AuthenticationOptions(
              stickyAuth: true,
              biometricOnly: false,
              useErrorDialogs: true,
              sensitiveTransaction: false,
            ),
          );
          return retryAuth;
        } catch (retryError) {
          Get.log('[BiometricService] Retry failed: $retryError');
          return false;
        }
      }
      
      throw Exception('Autentikasi biometric gagal: ${e.message}');
    } catch (e) {
      Get.log('[BiometricService] Error during authentication: $e');
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  /// Check if fingerprint is enrolled
  Future<bool> isEnrolled() async {
    try {
      final canCheck = await canCheckBiometrics();
      if (!canCheck) return false;

      final availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.contains(BiometricType.fingerprint);
    } catch (e) {
      Get.log('Error checking enrollment: $e');
      return false;
    }
  }

  /// Get biometric type name
  Future<String> getBiometricTypeName() async {
    try {
      final availableBiometrics = await getAvailableBiometrics();
      
      Get.log('[BiometricService] Getting biometric type name, available: $availableBiometrics');
      
      // Check for Face ID (iOS) or face recognition (Android)
      if (availableBiometrics.contains(BiometricType.face)) {
        return Platform.isIOS ? 'Face ID' : 'Face Recognition';
      }
      
      // Check for Touch ID (iOS) or fingerprint (Android)
      if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return Platform.isIOS ? 'Touch ID' : 'Fingerprint';
      }
      
      // Check for strong biometric (Android 10+)
      if (availableBiometrics.contains(BiometricType.strong)) {
        return 'Biometric';
      }
      
      // Check for weak biometric
      if (availableBiometrics.contains(BiometricType.weak)) {
        return 'Biometric';
      }
      
      if (availableBiometrics.contains(BiometricType.iris)) {
        return 'Iris Recognition';
      }
      
      // If no specific type found but device supports biometric
      if (Platform.isIOS) {
        // Try to determine iOS biometric type from device capability
        final isSupported = await _localAuth.isDeviceSupported();
        if (isSupported) {
          // iPhone X and later use Face ID, earlier devices use Touch ID
          // This is a fallback - actual type should be detected from availableBiometrics
          return 'Face ID / Touch ID';
        }
      }
      
      return 'Biometric';
    } catch (e) {
      Get.log('Error getting biometric type: $e');
      return 'Biometric';
    }
  }
}
