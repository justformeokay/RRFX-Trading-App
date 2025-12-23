import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/dialogs/passcode_success_dialog.dart';
import 'package:rrfx/src/controllers/passcode_controller.dart';
import 'package:rrfx/src/views/mainpage.dart';

class SetupPasscodePage extends StatefulWidget {
  const SetupPasscodePage({super.key});

  @override
  State<SetupPasscodePage> createState() => _SetupPasscodePageState();
}

class _SetupPasscodePageState extends State<SetupPasscodePage> with TickerProviderStateMixin {
  final PasscodeController controller = Get.put(PasscodeController());
  late List<AnimationController> _dotAnimationControllers;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
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
    _shakeController.forward(from: 0.0);
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.05),
                // Title
                Obx(() => Text(
                  controller.isConfirming.value
                      ? "Konfirmasi Passcode"
                      : "Buat Passcode",
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                )),
                SizedBox(height: 8),
                // Subtitle
                Obx(() => Text(
                  controller.isConfirming.value
                      ? "Masukkan passcode yang sama untuk konfirmasi"
                      : "Passcode akan melindungi akun Anda",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: CustomColor.textThemeLightSoftColor,
                  ),
                )),
                SizedBox(height: size.height * 0.08),
                // Passcode dots dengan animasi
                Obx(() {
                  final passcode = controller.isConfirming.value
                      ? controller.confirmPasscode.value
                      : controller.enteredPasscode.value;

                  // Trigger animasi saat ada perubahan
                  if (passcode.length > 0) {
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
                SizedBox(height: size.height * 0.12),
                // Keypad
                Expanded(
                  child: Obx(() {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                ),                SizedBox(height: size.height * 0.04),
                // Biometric Option (hanya tampil saat confirmation step)
                Obx(() {
                  if (!controller.isConfirming.value || !controller.biometricAvailable.value) {
                    return SizedBox.shrink();
                  }
                  
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: CustomColor.secondaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                      color: CustomColor.secondaryColor.withOpacity(0.05),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Aktifkan ${controller.biometricType.value}?',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).textTheme.titleLarge?.color,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Akses lebih cepat tanpa perlu memasukkan passcode',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: CustomColor.textThemeLightSoftColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        Obx(() => Switch(
                          value: controller.useBiometric.value,
                          onChanged: (value) {
                            controller.useBiometric.value = value;
                          },
                          activeColor: CustomColor.secondaryColor,
                        )),
                      ],
                    ),
                  );
                }),
                SizedBox(height: 16),                // Submit button
                Obx(() {
                  final passcode = controller.isConfirming.value
                      ? controller.confirmPasscode.value
                      : controller.enteredPasscode.value;

                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: passcode.length == 6
                            ? CustomColor.secondaryColor
                            : Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: passcode.length == 6
                          ? controller.isLoading.value
                              ? null
                              : () async {
                                  if (!controller.isConfirming.value) {
                                    controller.confirmStep();
                                  } else {
                                    if (controller.enteredPasscode.value ==
                                        controller.confirmPasscode.value) {
                                      final success =
                                          await controller.savePasscode(
                                            enableBiometric: controller.useBiometric.value,
                                          );
                                      if (success) {
                                        // Show success dialog
                                        await PasscodeSuccessDialog.show(context);
                                        Get.offAll(() => Mainpage());
                                      } else {
                                        _shakeAnimation();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Gagal menyimpan passcode'),
                                          ),
                                        );
                                      }
                                    } else {
                                      _shakeAnimation();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Passcode tidak cocok, coba lagi'),
                                        ),
                                      );
                                      controller.resetForNewSetup();
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
                              controller.isConfirming.value ? "Konfirmasi" : "Lanjut",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  );
                }),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyButton(int number) {
    return GestureDetector(
      onTap: () => controller.addDigit(number),
      child: Container(
        width: 70,
        height: 70,
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
      onTap: () => controller.deleteLastDigit(),
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
}
