import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/service/biometric_service.dart';
import 'package:rrfx/src/service/passcode_service.dart';

class PasscodeController extends GetxController {
  RxString enteredPasscode = ''.obs;
  RxString confirmPasscode = ''.obs;
  RxBool isConfirming = false.obs;
  RxBool isLoading = false.obs;
  RxInt remainingAttempts = 5.obs;
  RxBool isLocked = false.obs;
  RxInt lockTimeRemaining = 0.obs;
  RxInt lastAttemptCount = 0.obs; // Track attempt count from API
  
  // Biometric
  RxBool useBiometric = false.obs;
  RxString biometricType = ''.obs;
  RxBool biometricAvailable = false.obs;
  RxBool isBiometricEnabled = false.obs;
  
  // Randomized keypad
  RxList<int> randomKeypad = <int>[].obs;
  
  // Animation controllers
  late List<AnimationController> controllers;
  
  final BiometricService _biometricService = BiometricService();
  
  @override
  void onInit() {
    super.onInit();
    generateRandomKeypad();
    _initBiometric();
  }
  
  /// Initialize biometric check
  Future<void> _initBiometric() async {
    try {
      // Check if biometric is available on device
      final canCheck = await _biometricService.canCheckBiometrics();
      final isDeviceSupported = await _biometricService.deviceSupportsBiometric();
      biometricAvailable.value = canCheck && isDeviceSupported;
      
      // Check if user has biometric enabled
      isBiometricEnabled.value = await PasscodeService.isBiometricEnabled();
      biometricType.value = await PasscodeService.getBiometricType() ?? 'Biometric';
    } catch (e) {
      biometricAvailable.value = false;
    }
  }

  /// Refresh biometric status (digunakan ketika kembali dari halaman setup)
  Future<void> refreshBiometricStatus() async {
    try {
      final canCheck = await _biometricService.canCheckBiometrics();
      final isDeviceSupported = await _biometricService.deviceSupportsBiometric();
      biometricAvailable.value = canCheck && isDeviceSupported;
      isBiometricEnabled.value = await PasscodeService.isBiometricEnabled();
      biometricType.value = await PasscodeService.getBiometricType() ?? 'Biometric';
    } catch (e) {
      Get.log('[PasscodeController] Error refreshing biometric status: $e');
    }
  }
  
  /// Generate randomized keypad (0-9)
  void generateRandomKeypad() {
    final keypad = List.generate(10, (i) => i);
    keypad.shuffle();
    randomKeypad.value = keypad;
  }
  
  /// Add digit ke passcode
  void addDigit(int digit) {
    if (isLocked.value) return;
    
    if (isConfirming.value) {
      if (confirmPasscode.value.length < 6) {
        confirmPasscode.value += digit.toString();
      }
    } else {
      if (enteredPasscode.value.length < 6) {
        enteredPasscode.value += digit.toString();
      }
    }
  }
  
  /// Delete last digit
  void deleteLastDigit() {
    if (isLocked.value) return;
    
    if (isConfirming.value) {
      if (confirmPasscode.value.isNotEmpty) {
        confirmPasscode.value = confirmPasscode.value.substring(0, confirmPasscode.value.length - 1);
      }
    } else {
      if (enteredPasscode.value.isNotEmpty) {
        enteredPasscode.value = enteredPasscode.value.substring(0, enteredPasscode.value.length - 1);
      }
    }
  }
  
  /// Clear passcode
  void clearPasscode() {
    if (isConfirming.value) {
      confirmPasscode.value = '';
    } else {
      enteredPasscode.value = '';
    }
  }
  
  /// Go to confirm step
  void confirmStep() {
    if (enteredPasscode.value.length == 6) {
      isConfirming.value = true;
      confirmPasscode.value = '';
      generateRandomKeypad(); // Randomize keypad again
    }
  }
  
  /// Verify confirm passcode
  Future<bool> savePasscode({bool enableBiometric = false}) async {
    if (confirmPasscode.value.length != 6) {
      return false;
    }
    
    if (enteredPasscode.value == confirmPasscode.value) {
      isLoading.value = true;
      
      if (enableBiometric && biometricAvailable.value) {
        try {
          // Authenticate with biometric first
          final isAuthenticated = await _biometricService.authenticate(
            reason: 'Verifikasi biometric untuk mengaktifkan fingerprint',
            useErrorDialogs: false,
          );
          
          if (isAuthenticated) {
            await _biometricService.getBiometricTypeName();
            useBiometric.value = true;
          }
        } catch (e) {
          Get.log('Error during biometric setup: $e');
        }
      }
      
      // Store passcode to server only (no local storage)
      final serverSuccess = await PasscodeService.storePasscodeToServer(
        enteredPasscode.value,
        confirmPasscode.value,
      );
      
      isLoading.value = false;
      return serverSuccess;
    } else {
      // Passcodes don't match
      Get.log('[PasscodeController] Passcodes do NOT match!');
      return false;
    }
  }
  
  /// Verify passcode (uses server API - no local storage)
  Future<bool> verifyPasscode() async {
    
    if (enteredPasscode.value.length != 6) {
      Get.log('[PasscodeController] enteredPasscode length is not 6, returning false');
      return false;
    }
    
    isLoading.value = true;
    final response = await PasscodeService.verifyPasscodeWithServer(enteredPasscode.value);
    isLoading.value = false;
    
    Get.log('[PasscodeController] verifyPasscode response: $response');
    
    final success = response['status'] == true;
    final attempt = response['attempt'] ?? 0;
    
    // Store the attempt count from API response
    lastAttemptCount.value = attempt;
    
    Get.log('[PasscodeController] Success: $success, Attempt from API: $attempt');
    
    if (!success) {
      remainingAttempts.value--;
      if (remainingAttempts.value <= 0) {
        lockAccount();
      }
    }
    
    return success;
  }
  
  /// Authenticate using biometric
  /// Authenticate using biometric for login/verification
  /// @param forSetup: true jika untuk setup biometric pertama kali
  Future<bool> authenticateWithBiometric({bool forSetup = false}) async {
    try {
      
      if (!biometricAvailable.value) {
        Get.log('[PasscodeController] Biometric not available');
        throw Exception('Biometric tidak tersedia di device ini');
      }

      // Jika tidak untuk setup, check apakah sudah enabled
      if (!forSetup && !isBiometricEnabled.value) {
        Get.log('[PasscodeController] Biometric not enabled (and not for setup)');
        throw Exception('Biometric belum diaktifkan');
      }
      
      isLoading.value = true;
      Get.log('[PasscodeController] Calling _biometricService.authenticate()...');
      
      final isAuthenticated = await _biometricService.authenticate(
        reason: forSetup 
            ? 'Verifikasi biometric untuk mengaktifkan fingerprint'
            : 'Verifikasi fingerprint untuk akses aplikasi',
        useErrorDialogs: false,
      );
      
      Get.log('[PasscodeController] authenticate() returned: $isAuthenticated');
      
      if (isAuthenticated) {
        remainingAttempts.value = 5;
        isLocked.value = false;
        isLoading.value = false;
        return true;
      }
      
      isLoading.value = false;
      return false;
    } catch (e) {
      isLoading.value = false;
      Get.log('[PasscodeController] Error during biometric authentication: $e');
      return false;
    }
  }
  
  /// Lock account after failed attempts
  void lockAccount() {
    isLocked.value = true;
    lockTimeRemaining.value = 300; // 5 minutes
    _startLockTimer();
  }
  
  /// Start lock timer
  void _startLockTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (lockTimeRemaining.value > 0) {
        lockTimeRemaining.value--;
        _startLockTimer();
      } else {
        isLocked.value = false;
        remainingAttempts.value = 5;
      }
    });
  }
  
  /// Reset untuk setup baru
  void resetForNewSetup() {
    enteredPasscode.value = '';
    confirmPasscode.value = '';
    isConfirming.value = false;
    remainingAttempts.value = 5;
    isLocked.value = false;
    useBiometric.value = false;
    generateRandomKeypad();
  }
  
  /// Reset untuk verify
  void resetForVerify() {
    enteredPasscode.value = '';
    generateRandomKeypad();
  }
}
