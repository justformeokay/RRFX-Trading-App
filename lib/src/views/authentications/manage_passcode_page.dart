import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/controllers/passcode_controller.dart';
import 'package:rrfx/src/service/passcode_service.dart';
import 'package:rrfx/src/views/authentications/change_passcode_page.dart';

class ManagePasscodePage extends StatefulWidget {
  const ManagePasscodePage({super.key});

  @override
  State<ManagePasscodePage> createState() => _ManagePasscodePageState();
}

class _ManagePasscodePageState extends State<ManagePasscodePage>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late PasscodeController passcodeController;
  bool isBiometricEnabled = false;
  String? biometricType;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    passcodeController = Get.put(PasscodeController());

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _loadPasscodeSettings();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _slideController.forward();
      }
    });
  }

  Future<void> _loadPasscodeSettings() async {
    try {
      final enabled = await PasscodeService.isBiometricEnabled();
      final type = await PasscodeService.getBiometricType();

      // Sinkronisasi dengan controller state
      passcodeController.isBiometricEnabled.value = enabled;
      if (type != null) {
        passcodeController.biometricType.value = type;
      }

      setState(() {
        isBiometricEnabled = enabled;
        biometricType = type;
      });
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (!passcodeController.biometricAvailable.value) {
      _showError('Biometric tidak tersedia di device ini');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (value) {
        // Enable biometric
        print('[ManagePasscode] Starting biometric authentication...');
        final isAuthenticated =
            await passcodeController.authenticateWithBiometric(forSetup: true);
        
        print('[ManagePasscode] Authentication result: $isAuthenticated');
        
        if (isAuthenticated) {
          // Get biometric type from controller
          final biometricTypeName = passcodeController.biometricType.value.isNotEmpty
              ? passcodeController.biometricType.value
              : 'Biometric';
          
          print('[ManagePasscode] Attempting to update biometric status with type: $biometricTypeName');
          
          final success = await PasscodeService.updateBiometricStatus(
            true,
            biometricType: biometricTypeName,
          );

          print('[ManagePasscode] updateBiometricStatus result: $success');

          if (success) {
            // Update controller state juga
            passcodeController.isBiometricEnabled.value = true;
            
            setState(() {
              isBiometricEnabled = true;
              biometricType = biometricTypeName;
              isLoading = false;
            });

            _showSuccess('Biometric berhasil diaktifkan');
            print('[ManagePasscode] Biometric status updated in storage and controller');
          } else {
            setState(() {
              isLoading = false;
            });
            _showError('Gagal menyimpan status biometric');
          }
        } else {
          setState(() {
            isLoading = false;
          });
          // Show more helpful message for iOS users
          _showError('Autentikasi biometric dibatalkan. Pastikan Face ID atau Touch ID sudah diaktifkan di Settings iPhone.');
        }
      } else {
        // Disable biometric - tidak perlu verifikasi, langsung disable
        final success = await PasscodeService.updateBiometricStatus(false);

        if (success) {
          // Update controller state juga
          passcodeController.isBiometricEnabled.value = false;
          
          setState(() {
            isBiometricEnabled = false;
            biometricType = null;
            isLoading = false;
          });

          _showSuccess('Biometric berhasil dinonaktifkan');
          print('[ManagePasscode] Biometric status disabled in storage and controller');
        } else {
          setState(() {
            isLoading = false;
          });
          _showError('Gagal menonaktifkan biometric');
        }
      }
    } catch (e) {
      print('[ManagePasscode] Error: $e');
      setState(() {
        isLoading = false;
      });
      // Show the actual error message from biometric service
      String errorMsg = e.toString();
      if (errorMsg.contains('Exception:')) {
        errorMsg = errorMsg.replaceAll('Exception:', '').trim();
      }
      _showError(errorMsg);
    }
  }

  Future<void> _changePasscode() async {
    // Verify current passcode first
    _showPasscodeVerificationDialog();
  }

  void _showPasscodeVerificationDialog() {
    TextEditingController currentPasscodeController = TextEditingController();
    bool isLoading = false;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: CustomColor.secondaryColor.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        size: 40,
                        color: CustomColor.secondaryColor,
                      ),
                    ),
                    SizedBox(height: 24),

                    // Title
                    Text(
                      'Verifikasi Passcode',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),

                    // Description
                    Text(
                      'Masukkan passcode saat ini untuk melanjutkan ke pengubahan passcode',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: CustomColor.textThemeLightSoftColor,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 28),

                    // Input Field
                    TextField(
                      controller: currentPasscodeController,
                      enabled: !isLoading,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2,
                      ),
                      decoration: InputDecoration(
                        hintText: '••••••',
                        hintStyle: GoogleFonts.inter(
                          color: CustomColor.textThemeLightSoftColor,
                          letterSpacing: 2,
                        ),
                        prefixIcon: Icon(
                          Icons.lock_rounded,
                          color: CustomColor.secondaryColor,
                          size: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.1),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.1),
                          ),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.black.withOpacity(0.05),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: CustomColor.secondaryColor,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        counterText: '',
                      ),
                    ),
                    SizedBox(height: 28),

                    // Buttons
                    Row(
                      children: [
                        // Cancel Button
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(
                                color: CustomColor.textThemeLightSoftColor.withOpacity(0.3),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: isLoading ? null : () => Get.back(),
                            child: Text(
                              'Batal',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: CustomColor.textThemeLightSoftColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),

                        // Verify Button
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CustomColor.secondaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: isLoading
                                ? null
                                : () async {
                                    if (currentPasscodeController.text.length != 6) {
                                      _showError('Passcode harus 6 digit');
                                      return;
                                    }

                                    setState(() => isLoading = true);

                                    final response = await PasscodeService
                                        .verifyPasscodeWithServer(
                                          currentPasscodeController.text,
                                        );

                                    setState(() => isLoading = false);

                                    final isValid = response['status'] == true;
                                    
                                    if (isValid) {
                                      Get.back();
                                      // Navigate to change passcode page
                                      Get.to(
                                        () => ChangePasscodePage(
                                          currentPasscode: currentPasscodeController.text,
                                        ),
                                      );
                                    } else {
                                      _showError('Passcode tidak sesuai');
                                    }
                                  },
                            child: isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Lanjutkan',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
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
        },
      ),
      barrierDismissible: !isLoading,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: isDark ? Colors.white : Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Kelola Passcode',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              // Info Box
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
                ),
                child: FadeTransition(
                  opacity: _slideController,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CustomColor.secondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: CustomColor.secondaryColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: CustomColor.secondaryColor,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Passcode melindungi akun Anda. Kelola pengaturan keamanan di sini.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.white.withOpacity(0.8)
                                  : Colors.black.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.06),
              // Change Passcode Section
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
                ),
                child: FadeTransition(
                  opacity: _slideController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ubah Passcode',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.1),
                            width: 1,
                          ),
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.02),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Passcode saat ini',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Colors.white.withOpacity(0.8)
                                            : Colors.black.withOpacity(0.8),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '••••••',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: isDark
                                            ? Colors.white.withOpacity(0.6)
                                            : Colors.black.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                                ElevatedButton.icon(
                                  onPressed: _changePasscode,
                                  icon: Icon(Icons.edit_rounded, size: 16),
                                  label: Text('Ubah'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: CustomColor.secondaryColor,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.06),
              // Biometric Section
              Obx(() => passcodeController.biometricAvailable.value
                ? SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
                  ),
                  child: FadeTransition(
                    opacity: _slideController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Keamanan Biometric',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.1),
                              width: 1,
                            ),
                            color: isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.black.withOpacity(0.02),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.fingerprint_rounded,
                                        color: CustomColor.secondaryColor,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        biometricType ?? 'Biometric',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    isBiometricEnabled
                                        ? 'Diaktifkan'
                                        : 'Dinonaktifkan',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: isBiometricEnabled
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: isBiometricEnabled,
                                onChanged: isLoading
                                    ? null
                                    : (value) => _toggleBiometric(value),
                                activeColor: CustomColor.secondaryColor,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          isBiometricEnabled
                              ? 'Gunakan ${biometricType ?? "fingerprint"} untuk akses cepat tanpa memasukkan passcode.'
                              : 'Aktifkan untuk menggunakan ${biometricType ?? "fingerprint"} sebagai alternatif passcode.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? Colors.white.withOpacity(0.6)
                                : Colors.black.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                : SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
