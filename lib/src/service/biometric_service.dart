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
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      print('Error checking biometrics: $e');
      return false;
    }
  }

  /// Check if device has biometric authentication available
  Future<bool> deviceSupportsBiometric() async {
    try {
      // Check if device can use biometrics
      final canCheck = await _localAuth.canCheckBiometrics;
      final biometrics = await _localAuth.getAvailableBiometrics();
      return canCheck && biometrics.isNotEmpty;
    } catch (e) {
      print('Error checking device support: $e');
      return false;
    }
  }

  /// Get available biometric types on device
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      print('Error getting available biometrics: $e');
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
      print('[BiometricService] Starting authentication...');
      print('[BiometricService] Platform: ${Platform.operatingSystem}');
      
      // Check if device supports biometric
      final isDeviceSupported = await deviceSupportsBiometric();
      print('[BiometricService] Device supported: $isDeviceSupported');
      
      if (!isDeviceSupported) {
        // Untuk iOS, coba tetap authenticate meskipun check gagal
        // Karena kadang check bisa false tapi authenticate bisa jalan
        if (!Platform.isIOS) {
          throw Exception('Device tidak mendukung biometric authentication');
        }
        print('[BiometricService] iOS device - attempting anyway...');
      }

      // Get available biometrics
      final availableBiometrics = await getAvailableBiometrics();
      print('[BiometricService] Available biometrics: $availableBiometrics');
      
      // Untuk iOS, kadang availableBiometrics bisa kosong tapi tetap bisa authenticate
      if (availableBiometrics.isEmpty && !Platform.isIOS) {
        throw Exception('Tidak ada biometric terdaftar di device');
      }

      print('[BiometricService] Calling authenticate with reason: $reason');
      
      // iOS memerlukan localizedReason yang lebih spesifik
      final localizedReason = Platform.isIOS 
          ? 'Autentikasi diperlukan untuk mengakses aplikasi'
          : reason;
      
      // Authenticate dengan opsi berbeda untuk iOS dan Android
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
          biometricOnly: Platform.isIOS ? true : false, // iOS: biometric only, Android: allow fallback
          useErrorDialogs: useErrorDialogs,
          sensitiveTransaction: false,
        ),
      );

      print('[BiometricService] Authentication result: $isAuthenticated');
      return isAuthenticated;
    } on PlatformException catch (e) {
      print('[BiometricService] PlatformException: ${e.code} - ${e.message}');
      print('[BiometricService] Full error details: $e');
      
      // Handle specific errors
      if (e.code == 'NotAvailable') {
        throw Exception('Biometric tidak tersedia di device ini');
      } else if (e.code == 'NotEnrolled') {
        throw Exception('Tidak ada biometric terdaftar di device');
      } else if (e.code == 'LockedOut' || e.code == 'LockedOutTemporarily') {
        throw Exception('Terlalu banyak percobaan gagal. Coba lagi nanti');
      } else if (e.code == 'PermanentlyLockedOut') {
        throw Exception('Biometric terkunci permanen. Gunakan passcode');
      } else if (e.code == 'UserCanceled' || e.code == 'PasscodeNotSet' || e.code == 'AuthenticationCanceled') {
        // Don't throw error for user cancellation
        print('[BiometricService] User canceled authentication');
        return false;
      } else if (e.code == 'BiometricOnlyNotSupported') {
        // iOS specific - retry with biometricOnly: false
        print('[BiometricService] BiometricOnly not supported, retrying...');
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
          print('[BiometricService] Retry failed: $retryError');
          return false;
        }
      }
      
      throw Exception('Autentikasi biometric gagal: ${e.message}');
    } catch (e) {
      print('[BiometricService] Error during authentication: $e');
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
      print('Error checking enrollment: $e');
      return false;
    }
  }

  /// Get biometric type name
  Future<String> getBiometricTypeName() async {
    try {
      final availableBiometrics = await getAvailableBiometrics();
      
      if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return 'Fingerprint';
      } else if (availableBiometrics.contains(BiometricType.face)) {
        return 'Face Recognition';
      } else if (availableBiometrics.contains(BiometricType.iris)) {
        return 'Iris Recognition';
      }
      
      return 'Biometric';
    } catch (e) {
      print('Error getting biometric type: $e');
      return 'Biometric';
    }
  }
}
