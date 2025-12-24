import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/dialogs/passcode_error_dialog.dart';
import 'package:rrfx/src/controllers/passcode_controller.dart';
import 'package:rrfx/src/service/passcode_service.dart';
import 'package:rrfx/src/views/authentications/reset_passcode_page.dart';
import 'package:rrfx/src/views/mainpage.dart';

class VerifyPasscodePage extends StatefulWidget {
  const VerifyPasscodePage({super.key});

  @override
  State<VerifyPasscodePage> createState() => _VerifyPasscodePageState();
}

class _VerifyPasscodePageState extends State<VerifyPasscodePage>
    with TickerProviderStateMixin {
  final PasscodeController controller = Get.put(PasscodeController());
  late List<AnimationController> _dotAnimationControllers;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    controller.remainingAttempts.value = 5;
  }

  void _initializeAnimations() {
    _dotAnimationControllers = List.generate(
      6,
      (i) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  void _animateDot(int index) {
    if (index < _dotAnimationControllers.length) {
      _dotAnimationControllers[index].forward(from: 0.0);
    }
  }

  void _shakeAnimation() {
    _shakeController.forward(from: 0.0).then((_) {
      for (var i = 0; i < _dotAnimationControllers.length; i++) {
        _dotAnimationControllers[i].reverse();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _dotAnimationControllers) {
      controller.dispose();
    }
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.08),
                // Title
                Text(
                  "Masukkan Passcode",
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                SizedBox(height: 8),
                // Subtitle
                Text(
                  "Akses akun Anda dengan passcode",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: CustomColor.textThemeLightSoftColor,
                  ),
                ),
                SizedBox(height: 16),
                // Biometric Button
                Obx(() {
                  if (controller.isBiometricEnabled.value && controller.biometricAvailable.value) {
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            CustomColor.secondaryColor.withOpacity(0.1),
                            CustomColor.secondaryColor.withOpacity(0.05),
                          ],
                        ),
                        border: Border.all(
                          color: CustomColor.secondaryColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: controller.isLoading.value
                              ? null
                              : () async {
                                  final success = await controller.authenticateWithBiometric();
                                  if (success) {
                                    Get.offAll(() => Mainpage());
                                  }
                                },
                          customBorder: const CircleBorder(),
                          child: controller.isLoading.value
                              ? Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          CustomColor.secondaryColor),
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.fingerprint_rounded,
                                  color: CustomColor.secondaryColor,
                                  size: 32,
                                ),
                        ),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                }),
                SizedBox(height: size.height * 0.06),
                // Passcode dots dengan animasi
                Obx(() {
                  final passcode = controller.enteredPasscode.value;

                  if (passcode.isNotEmpty) {
                    Future.microtask(() => _animateDot(passcode.length - 1));
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      final isFilled = index < passcode.length;
                      return AnimatedBuilder(
                        animation: _dotAnimationControllers[index],
                        builder: (context, child) {
                          final scale = Tween<double>(begin: 0.5, end: 1.0)
                              .evaluate(CurvedAnimation(
                                parent: _dotAnimationControllers[index],
                                curve: Curves.elasticOut,
                              ));

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isFilled
                                      ? CustomColor.secondaryColor
                                      : Colors.grey.shade300,
                                  boxShadow: isFilled
                                      ? [
                                          BoxShadow(
                                            color: CustomColor.secondaryColor
                                                .withOpacity(0.5),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          )
                                        ]
                                      : [],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  );
                }),
                SizedBox(height: 16),
                // Remaining attempts
                Obx(() {
                  if (controller.isLocked.value) {
                    return Column(
                      children: [
                        Text(
                          "Akun Anda terkunci sementara",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Coba lagi dalam ${controller.lockTimeRemaining.value ~/ 60}:${(controller.lockTimeRemaining.value % 60).toString().padLeft(2, '0')} detik",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: CustomColor.textThemeLightSoftColor,
                          ),
                        ),
                      ],
                    );
                  }

                  if (controller.remainingAttempts.value <= 2) {
                    return Text(
                      "Sisa ${controller.remainingAttempts.value} percobaan",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }

                  return SizedBox.shrink();
                }),
                SizedBox(height: 30),
                // Keypad
                Obx(() {
                  if (controller.isLocked.value) {
                    return SizedBox(
                      height: 300,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 64,
                              color: Colors.red.withOpacity(0.5),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Akun Terkunci",
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        // Row 1
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildKeyButton(controller.randomKeypad[0]),
                            _buildKeyButton(controller.randomKeypad[1]),
                            _buildKeyButton(controller.randomKeypad[2]),
                          ],
                        ),
                        SizedBox(height: 16),
                        // Row 2
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildKeyButton(controller.randomKeypad[3]),
                            _buildKeyButton(controller.randomKeypad[4]),
                            _buildKeyButton(controller.randomKeypad[5]),
                          ],
                        ),
                        SizedBox(height: 16),
                        // Row 3
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildKeyButton(controller.randomKeypad[6]),
                            _buildKeyButton(controller.randomKeypad[7]),
                            _buildKeyButton(controller.randomKeypad[8]),
                          ],
                        ),
                        SizedBox(height: 16),
                        // Row 4 - 0, delete, submit
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildEmptySpace(),
                            _buildKeyButton(controller.randomKeypad[9]),
                            _buildDeleteButton(),
                          ],
                        ),
                      ],
                  );
                }),
                SizedBox(height: 10),
                // Submit button
                Obx(() {
                  final passcode = controller.enteredPasscode.value;

                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: passcode.length == 6 && !controller.isLocked.value
                            ? CustomColor.secondaryColor
                            : Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: passcode.length == 6 && !controller.isLocked.value
                          ? controller.isLoading.value
                              ? null
                              : () async {
                                  final success = await controller.verifyPasscode();
                                  if (success) {
                                    Get.offAll(() => Mainpage());
                                  } else {
                                    _shakeAnimation();
                                    controller.resetForVerify();
                                    
                                    // Show custom error dialog
                                    await Future.delayed(const Duration(milliseconds: 300));
                                    if (mounted) {
                                      await PasscodeErrorDialog.show(
                                        context,
                                        message: controller.isLocked.value
                                            ? 'Akun Anda terkunci sementara karena terlalu banyak percobaan yang gagal.'
                                            : 'Passcode yang Anda masukkan tidak sesuai. Silahkan coba lagi.',
                                        remainingAttempts: controller.remainingAttempts.value,
                                        attemptCount: controller.lastAttemptCount.value,
                                        isLocked: controller.isLocked.value,
                                        lockTimeRemaining: controller.lockTimeRemaining.value,
                                      );
                                    }
                                  }
                                }
                          : null,
                      child: controller.isLoading.value
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).scaffoldBackgroundColor),
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Masuk",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black
                              ),
                            ),
                    ),
                  );
                }),
                SizedBox(height: 8),
                // Forgot Passcode Button
                Obx(() {
                  if (!controller.isLocked.value) {
                    return Center(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero
                        ),
                        onPressed: () => _showResetPasscodeDialog(context),
                        child: Text(
                          "Lupa Passcode?",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: CustomColor.secondaryColor,
                          ),
                        ),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                }),
              ],
            ),
          ),
        ),
      ),    ),    );
  }

  Widget _buildKeyButton(int number) {
    return GestureDetector(
      onTap: controller.isLocked.value
          ? null
          : () => controller.addDigit(number),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade800
              : Colors.grey.shade100,
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: controller.isLocked.value
          ? null
          : () => controller.deleteLastDigit(),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red.withOpacity(0.1),
        ),
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            color: Colors.red,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySpace() {
    return SizedBox(width: 70, height: 70);
  }

  void _showResetPasscodeDialog(BuildContext context) {
    Get.dialog(
      Dialog(
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
                    Icons.mail_outline_rounded,
                    size: 40,
                    color: CustomColor.secondaryColor,
                  ),
                ),
                SizedBox(height: 24),

                // Title
                Text(
                  "Reset Passcode?",
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
                  "Kami akan mengirimkan link reset passcode ke email Anda. Link berlaku selama 10 menit.",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: CustomColor.textThemeLightSoftColor,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
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
                        onPressed: () => Get.back(),
                        child: Text(
                          "Batal",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: CustomColor.textThemeLightSoftColor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),

                    // Confirm Button
                    Expanded(
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          bool isLoading = false;

                          return ElevatedButton(
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
                                    setState(() => isLoading = true);

                                    final result =
                                        await PasscodeService.requestPasscodeReset();

                                    setState(() => isLoading = false);

                                    if (mounted) {
                                      Get.back();

                                      if (result['status']) {
                                        Get.dialog(
                                          Dialog(
                                            backgroundColor: Colors.transparent,
                                            elevation: 0,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 20,
                                                    spreadRadius: 5,
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(24.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    // Success Icon
                                                    Container(
                                                      width: 80,
                                                      height: 80,
                                                      decoration:
                                                          BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.green
                                                            .withOpacity(0.1),
                                                      ),
                                                      child: Icon(
                                                        Icons.check_circle,
                                                        size: 40,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                    SizedBox(height: 24),
                                                    Text(
                                                      "Berhasil!",
                                                      style: GoogleFonts.inter(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .titleLarge
                                                            ?.color,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    SizedBox(height: 12),
                                                    Text(
                                                      result['message'] ??
                                                          'Link reset passcode telah dikirim ke email Anda.',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: CustomColor
                                                            .textThemeLightSoftColor,
                                                        height: 1.5,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    SizedBox(height: 28),
                                                    SizedBox(
                                                      width: double.infinity,
                                                      child: ElevatedButton(
                                                        style:
                                                            ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              CustomColor
                                                                  .secondaryColor,
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 14),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                          ),
                                                          elevation: 0,
                                                        ),
                                                        onPressed: () =>
                                                            Get.back(),
                                                        child: Text(
                                                          "Tutup",
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          barrierDismissible: false,
                                        );
                                      } else {
                                        Get.snackbar(
                                          '❌ Gagal',
                                          result['message'] ??
                                              'Gagal mengirim request reset passcode.',
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white,
                                          duration:
                                              const Duration(seconds: 3),
                                        );
                                      }
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
                                    "Ya, Reset Passcode",
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
