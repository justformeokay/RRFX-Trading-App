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
      print('Error initializing biometric: $e');
      biometricAvailable.value = false;
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
    print('[PasscodeController] savePasscode called');
    print('[PasscodeController] enteredPasscode=${enteredPasscode.value}, length=${enteredPasscode.value.length}');
    print('[PasscodeController] confirmPasscode=${confirmPasscode.value}, length=${confirmPasscode.value.length}');
    
    if (confirmPasscode.value.length != 6) {
      print('[PasscodeController] confirmPasscode length is not 6');
      return false;
    }
    
    if (enteredPasscode.value == confirmPasscode.value) {
      print('[PasscodeController] Passcodes match! Storing to server...');
      isLoading.value = true;
      
      String? biometricType;
      if (enableBiometric && biometricAvailable.value) {
        try {
          // Authenticate with biometric first
          final isAuthenticated = await _biometricService.authenticate(
            reason: 'Verifikasi biometric untuk mengaktifkan fingerprint',
            useErrorDialogs: false,
          );
          
          if (isAuthenticated) {
            biometricType = await _biometricService.getBiometricTypeName();
            useBiometric.value = true;
          }
        } catch (e) {
          print('Error during biometric setup: $e');
        }
      }
      
      // Store passcode to server only (no local storage)
      print('[PasscodeController] Storing passcode to server...');
      final serverSuccess = await PasscodeService.storePasscodeToServer(
        enteredPasscode.value,
        confirmPasscode.value,
      );
      
      print('[PasscodeController] Server store result: $serverSuccess');
      
      isLoading.value = false;
      return serverSuccess;
    } else {
      // Passcodes don't match
      print('[PasscodeController] Passcodes do NOT match!');
      return false;
    }
  }
  
  /// Verify passcode (uses server API - no local storage)
  Future<bool> verifyPasscode() async {
    print('[PasscodeController] verifyPasscode called');
    print('[PasscodeController] enteredPasscode=${enteredPasscode.value}, length=${enteredPasscode.value.length}');
    
    if (enteredPasscode.value.length != 6) {
      print('[PasscodeController] enteredPasscode length is not 6, returning false');
      return false;
    }
    
    isLoading.value = true;
    final success = await PasscodeService.verifyPasscodeWithServer(enteredPasscode.value);
    isLoading.value = false;
    
    print('[PasscodeController] verifyPasscode result: $success');
    
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
      print('[PasscodeController] authenticateWithBiometric called with forSetup=$forSetup');
      print('[PasscodeController] biometricAvailable=${biometricAvailable.value}');
      print('[PasscodeController] isBiometricEnabled=${isBiometricEnabled.value}');
      
      if (!biometricAvailable.value) {
        print('[PasscodeController] Biometric not available');
        throw Exception('Biometric tidak tersedia di device ini');
      }

      // Jika tidak untuk setup, check apakah sudah enabled
      if (!forSetup && !isBiometricEnabled.value) {
        print('[PasscodeController] Biometric not enabled (and not for setup)');
        throw Exception('Biometric belum diaktifkan');
      }
      
      isLoading.value = true;
      print('[PasscodeController] Calling _biometricService.authenticate()...');
      
      final isAuthenticated = await _biometricService.authenticate(
        reason: forSetup 
            ? 'Verifikasi biometric untuk mengaktifkan fingerprint'
            : 'Verifikasi fingerprint untuk akses aplikasi',
        useErrorDialogs: false,
      );
      
      print('[PasscodeController] authenticate() returned: $isAuthenticated');
      
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
      print('[PasscodeController] Error during biometric authentication: $e');
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
