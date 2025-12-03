import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/controllers/regol.dart';
import 'package:rrfx/src/views/accounts/registration_online/views/step_0_password_meta.dart';

class FeatureUnderDevPopup {
  static void show() {
    final isDark = Get.isDarkMode;

    Get.dialog(
      Dialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark ? Colors.white24 : Colors.black12,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(22),
          width: Get.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ICON
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.05),
                ),
                child: Icon(
                  Icons.construction_rounded,
                  size: 42,
                  color: isDark ? Colors.amber.shade300 : Colors.amber.shade700,
                ),
              ),

              const SizedBox(height: 20),

              // TITLE
              Text(
                "Fitur Dalam Pengembangan",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),

              const SizedBox(height: 12),

              // DESCRIPTION
              Text(
                "Fitur ini belum tersedia saat ini. "
                "Kami sedang mengerjakannya agar dapat segera kamu gunakan.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),

              const SizedBox(height: 24),

              // BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: isDark
                        ? Colors.amber.shade400
                        : Colors.amber.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Get.back(),
                  child: Text(
                    "Mengerti",
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.black : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      barrierColor:
          isDark ? Colors.black54 : Colors.black.withOpacity(0.35), // blur bg
    );
  }
}


class AuthDirectionPopup {
  static void show() {
    final isDark = Get.isDarkMode;
    Get.dialog(
      Dialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: isDark ? Colors.white24 : Colors.black12,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(22),
          width: Get.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ICON HEAD
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                ),
                child: Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 42,
                  color: CustomColor.secondaryColor,
                ),
              ),

              const SizedBox(height: 20),

              // TITLE
              Text(
                "Akses Lebih Banyak Fitur",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),

              const SizedBox(height: 12),

              // DESCRIPTION
              Text(
                "Untuk melanjutkan, silakan masuk ke akun Anda "
                "atau buat akun baru jika belum punya.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),

              const SizedBox(height: 26),

              // BUTTON: LOGIN
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: CustomColor.secondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Get.back();
                    Get.toNamed('/login');
                  },
                  child: Text(
                    "Masuk",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // BUTTON: REGISTER
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: CustomColor.secondaryColor
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Get.back();
                    Get.toNamed('/signup');
                  },
                  child: Text(
                    "Buat Akun",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CustomColor.secondaryColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      barrierColor:
          isDark ? Colors.black54 : Colors.black.withOpacity(0.35),
    );
  }
}

class ChangeMT5PasswordPopup extends StatefulWidget {
  final String mt5AccountId;
  const ChangeMT5PasswordPopup({super.key, required this.mt5AccountId});

  @override
  State<ChangeMT5PasswordPopup> createState() => _ChangeMT5PasswordPopupState();
}

class _ChangeMT5PasswordPopupState extends State<ChangeMT5PasswordPopup> {
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();

  bool showNew = false;
  bool showConfirm = false;

  @override
  void dispose() {
    newPassword.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark ? Colors.white24 : Colors.black12,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 40,
                spreadRadius: -5,
                color: isDark ? Colors.black54 : Colors.black26,
              ),
            ],
          ),
          width: Get.width * 0.88,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  "Ganti Password MT5",
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Silakan input password baru untuk akun MetaTrader 5 dengan ID ${widget.mt5AccountId} Anda.",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.4,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),

                const SizedBox(height: 22),

                _inputField(
                  label: "Password Baru",
                  controller: newPassword,
                  obscure: !showNew,
                  toggle: () => setState(() => showNew = !showNew),
                  isDark: isDark,
                ),
                const SizedBox(height: 18),

                _inputField(
                  label: "Konfirmasi Password",
                  controller: confirmPassword,
                  obscure: !showConfirm,
                  toggle: () => setState(() => showConfirm = !showConfirm),
                  isDark: isDark,
                ),

                const SizedBox(height: 26),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          "Batal",
                          style: GoogleFonts.inter(
                            color: isDark ? Colors.white60 : Colors.black54,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          if (newPassword.text != confirmPassword.text) {
                            Get.snackbar(
                              "Gagal",
                              "Password tidak cocok.",
                              margin: const EdgeInsets.all(12),
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 2),
                            );
                            return;
                          }

                          Get.back();
                          Get.snackbar(
                            "Berhasil",
                            "Password MT5 anda berhasil diubah.",
                            margin: const EdgeInsets.all(12),
                            backgroundColor: Colors.greenAccent.shade400,
                            colorText: Colors.black,
                            duration: const Duration(seconds: 2),
                          );
                        },
                        child: Text(
                          "Simpan",
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================
  // INPUT FIELD WIDGET
  // ===========================

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback toggle,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white12 : Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 14,
              ),
              border: InputBorder.none,
              suffixIcon: GestureDetector(
                onTap: toggle,
                child: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


class ChangePasswordBottomSheet extends StatefulWidget {
  const ChangePasswordBottomSheet({super.key});

  @override
  State<ChangePasswordBottomSheet> createState() =>
      _ChangePasswordBottomSheetState();
}

class _ChangePasswordBottomSheetState extends State<ChangePasswordBottomSheet> {
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();

  @override
  void dispose() {
    newPassword.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 25,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            Text(
              "Ganti Password MT5",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _buildInput(
              label: "Password Baru",
              controller: newPassword,
              obscure: true,
              icon: Icons.lock_reset_outlined,
            ),
            const SizedBox(height: 16),

            _buildInput(
              label: "Konfirmasi Password Baru",
              controller: confirmPassword,
              obscure: true,
              icon: Icons.verified_user_outlined,
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  if (newPassword.text != confirmPassword.text) {
                    Get.snackbar(
                      "Gagal",
                      "Konfirmasi password tidak sama",
                      backgroundColor: Colors.red.withOpacity(.7),
                      colorText: Colors.white,
                    );
                    return;
                  }

                  // TODO: proses API ganti password
                  Get.back();
                  Get.snackbar(
                    "Berhasil",
                    "Password berhasil diubah",
                    backgroundColor: Colors.green.withOpacity(.7),
                    colorText: Colors.white,
                  );
                },
                child: const Text(
                  "Ubah Password",
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

// void showMt5PasswordPopup(
//   BuildContext context, {
//   required String login,
//   required Function(String password, String otp) onSubmit,
//   required Future<bool> Function() onSendOtp,
// }) {
//   final isDark = Get.isDarkMode;

//   final TextEditingController pwdCtrl = TextEditingController();
//   final TextEditingController otpCtrl = TextEditingController();

//   final RxBool obscure = true.obs;
//   final RxBool isUpper = false.obs;
//   final RxBool isLower = false.obs;
//   final RxBool isNumber = false.obs;
//   final RxBool isLength = false.obs;
//   final RxBool isSymbol = false.obs;
//   final RxString otpValue = ''.obs;
//   final RxBool isSending = false.obs;

//   // VALIDASI PASSWORD REALTIME
//   pwdCtrl.addListener(() {
//     final text = pwdCtrl.text;
//     isUpper.value = text.contains(RegExp(r'[A-Z]'));
//     isLower.value = text.contains(RegExp(r'[a-z]'));
//     isNumber.value = text.contains(RegExp(r'[0-9]'));
//     isSymbol.value = text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=~`/\[\]\\]'));
//     isLength.value = text.length >= 6;
//   });

//   otpCtrl.addListener(() {
//     otpValue.value = otpCtrl.text;
//   });

//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (context) {
//       return BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
//         child: Dialog(
//           backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           insetPadding: const EdgeInsets.symmetric(horizontal: 26),
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [

//                 /// TITLE
//                 Text(
//                   "Masukkan Password MT5",
//                   style: GoogleFonts.inter(
//                     fontSize: 19,
//                     fontWeight: FontWeight.w700,
//                     color: isDark ? Colors.white : Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   "Akun MT5: $login",
//                   style: GoogleFonts.inter(
//                     fontSize: 14,
//                     color: isDark ? Colors.white60 : Colors.black54,
//                   ),
//                 ),

//                 const SizedBox(height: 22),

//                 /// PASSWORD FIELD
//                 Obx(() {
//                   return TextField(
//                     controller: pwdCtrl,
//                     obscureText: obscure.value,
//                     style: TextStyle(
//                       color: isDark ? Colors.white : Colors.black87,
//                     ),
//                     decoration: InputDecoration(
//                       labelText: "Password Baru",
//                       labelStyle: TextStyle(
//                         color: isDark ? Colors.white54 : Colors.black54,
//                       ),
//                       filled: true,
//                       fillColor: isDark ? Colors.white12 : Colors.grey.shade100,
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(14),
//                         borderSide: BorderSide(
//                           color: isDark ? Colors.white24 : Colors.black12,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(14),
//                         borderSide: BorderSide(
//                           color: isDark ? Colors.blue.shade300 : Colors.blue,
//                           width: 1.3,
//                         ),
//                       ),
//                       suffixIcon: GestureDetector(
//                         onTap: () => obscure.value = !obscure.value,
//                         child: Icon(
//                           obscure.value ? Icons.visibility_off : Icons.visibility,
//                           color: isDark ? Colors.white54 : Colors.black54,
//                         ),
//                       ),
//                     ),
//                   );
//                 }),

//                 const SizedBox(height: 14),

//                 /// VALIDASI PASSWORD (real time)
//                 Obx(() {
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildValidateItem("Minimal 6 karakter", isLength.value),
//                       _buildValidateItem("Mengandung huruf besar (A-Z)", isUpper.value),
//                       _buildValidateItem("Mengandung huruf kecil (a-z)", isLower.value),
//                       _buildValidateItem("Mengandung simbol (!@#\$% dll)", isSymbol.value),
//                       _buildValidateItem("Mengandung angka (0-9)", isNumber.value),
//                     ],
//                   );
//                 }),

//                 const SizedBox(height: 20),

//                 /// OTP FIELD + SEND OTP BUTTON
//                 Row(
//                   children: [
//                     Expanded(
//                       flex: 2,
//                       child: TextField(
//                         controller: otpCtrl,
//                         keyboardType: TextInputType.number,
//                         decoration: InputDecoration(
//                           labelText: "OTP",
//                           labelStyle: TextStyle(
//                             color: isDark ? Colors.white54 : Colors.black38,
//                           ),
//                           filled: true,
//                           fillColor: isDark ? Colors.white12 : Colors.grey.shade100,
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(14),
//                             borderSide: BorderSide(
//                               color: isDark ? Colors.white24 : Colors.black12,
//                             ),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(14),
//                             borderSide: BorderSide(
//                               color: isDark ? Colors.blue.shade300 : Colors.blue,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 10),

//                     /// SEND OTP BUTTON
//                     Expanded(
//                       flex: 1,
//                       child: Obx(() {
//                         final sending = isSending.value;

//                         return GestureDetector(
//                           onTap: sending
//                             ? null
//                             : () async {
//                               isSending.value = true;
//                               await onSendOtp();
//                               await Future.delayed(const Duration(milliseconds: 300));
//                               isSending.value = false;
//                             },
//                           child: Container(
//                             height: 48,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(14),
//                               gradient: sending
//                                   ? LinearGradient(
//                                       colors: [
//                                         (isDark ? Colors.white24 : Colors.black26),
//                                         (isDark ? Colors.white24 : Colors.black26),
//                                       ],
//                                     )
//                                   : LinearGradient(
//                                       colors: isDark
//                                           ? [Color(0xFF3D7BFF), Color(0xFF5CA0FF)]
//                                           : [Color(0xFF4A8CFF), Color(0xFF73B2FF)],
//                                     ),
//                             ),
//                             alignment: Alignment.center,
//                             child: sending
//                                 ? SizedBox(
//                                     height: 18,
//                                     width: 18,
//                                     child: CircularProgressIndicator(
//                                       strokeWidth: 2,
//                                       valueColor: AlwaysStoppedAnimation(Colors.white),
//                                     ),
//                                   )
//                                 : Text(
//                                     "Kirim",
//                                     style: GoogleFonts.inter(
//                                       color: Colors.white,
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w700,
//                                     ),
//                                   ),
//                           ),
//                         );
//                       }),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 26),

//                 /// ACTION BUTTONS
//                 Row(
//                   children: [
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: () => Navigator.pop(context),
//                         child: Container(
//                           height: 48,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(14),
//                             color: isDark ? Colors.white12 : Colors.grey.shade200,
//                           ),
//                           alignment: Alignment.center,
//                           child: Text(
//                             "Batal",
//                             style: GoogleFonts.inter(
//                               color: isDark ? Colors.white70 : Colors.black87,
//                               fontSize: 15,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 14),

//                     Expanded(
//                       child: Obx(() {
//                         final isValid = isUpper.value &&
//                           isLower.value &&
//                           isNumber.value &&
//                           isSymbol.value &&
//                           isLength.value &&
//                           otpValue.value.length > 3;

//                         return GestureDetector(
//                           onTap: isValid ? () {
//                                   Navigator.pop(context);
//                                   onSubmit(pwdCtrl.text, otpCtrl.text);
//                                 }: null,
//                           child: Container(
//                             height: 48,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(14),
//                               gradient: LinearGradient(
//                                 colors: isValid ? (isDark ? [Color(0xFF2F7AF7), Color(0xFF4DA4FF)] : [Color(0xFF4A8CFF), Color(0xFF73B2FF)]) : [
//                                         Colors.grey.shade400,
//                                         Colors.grey.shade500,
//                                       ],
//                               ),
//                             ),
//                             alignment: Alignment.center,
//                             child: Text(
//                               "Lanjut",
//                               style: GoogleFonts.inter(
//                                 color: Colors.white,
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                           ),
//                         );
//                       }),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }

void showMt5PasswordPopup(
  BuildContext context, {
  required String login,
  required Function(String password) onSubmit,
}) {
  final isDark = Get.isDarkMode;

  final TextEditingController pwdCtrl = TextEditingController();
  final TextEditingController confirmCtrl = TextEditingController();

  final RxBool obscure = true.obs;
  final RxBool obscureConfirm = true.obs;

  final RxBool isUpper = false.obs;
  final RxBool isLower = false.obs;
  final RxBool isNumber = false.obs;
  final RxBool isLength = false.obs;
  final RxBool isSymbol = false.obs;

  final RxBool isConfirmMatch = false.obs;

  // VALIDASI PASSWORD REALTIME
  pwdCtrl.addListener(() {
    final text = pwdCtrl.text;
    isUpper.value = text.contains(RegExp(r'[A-Z]'));
    isLower.value = text.contains(RegExp(r'[a-z]'));
    isNumber.value = text.contains(RegExp(r'[0-9]'));
    isSymbol.value = text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=~`/\[\]\\]'));
    isLength.value = text.length >= 6;

    isConfirmMatch.value = text == confirmCtrl.text;
  });

  confirmCtrl.addListener(() {
    isConfirmMatch.value = pwdCtrl.text == confirmCtrl.text;
  });

  final Widget? passwordLabel = RichText(
    text: TextSpan(
      text: "Konfirmasi Password",
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyMedium?.color,
        fontSize: 14,
      ),
      children: [
        const TextSpan(
          text: " *",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );

  final Widget? konfirmasiLabel = RichText(
    text: TextSpan(
      text: "Konfirmasi Password",
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyMedium?.color,
        fontSize: 14,
      ),
      children: [
        const TextSpan(
          text: " *",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Dialog(
          backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 26),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                
                /// TITLE
                Text(
                  "Ganti Password MT5",
                  style: GoogleFonts.inter(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Akun MT5: $login",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),

                const SizedBox(height: 22),

                /// PASSWORD FIELD
                Obx(() {
                  return TextField(
                    controller: pwdCtrl,
                    obscureText: obscure.value,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      label: passwordLabel,
                      fillColor: isDark ? Colors.white12 : Colors.grey.shade100,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () => obscure.value = !obscure.value,
                        child: Icon(
                          obscure.value ? Icons.visibility_off : Icons.visibility,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 14),

                /// VALIDASI PASSWORD
                Obx(() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildValidateItem("Minimal 6 karakter", isLength.value),
                      _buildValidateItem("Mengandung huruf besar (A-Z)", isUpper.value),
                      _buildValidateItem("Mengandung huruf kecil (a-z)", isLower.value),
                      _buildValidateItem("Mengandung simbol (!@#\$% dll)", isSymbol.value),
                      _buildValidateItem("Mengandung angka (0-9)", isNumber.value),
                    ],
                  );
                }),

                const SizedBox(height: 18),

                /// CONFIRM PASSWORD
                Obx(() {
                  return TextField(
                    controller: confirmCtrl,
                    obscureText: obscureConfirm.value,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      label: konfirmasiLabel, // <- ⬅ memakai RichText untuk tanda *
                      fillColor: isDark ? Colors.white12 : Colors.grey.shade100,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () =>
                            obscureConfirm.value = !obscureConfirm.value,
                        child: Icon(
                          obscureConfirm.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 10),

                /// KONFIRMASI STATUS
                Obx(() {
                  return Row(
                    children: [
                      Icon(
                        isConfirmMatch.value
                            ? Icons.check_circle
                            : Icons.cancel,
                        size: 16,
                        color: isConfirmMatch.value
                            ? Colors.green
                            : Colors.redAccent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isConfirmMatch.value
                            ? "Password cocok"
                            : "Password tidak cocok",
                        style: TextStyle(
                          color: isConfirmMatch.value
                              ? Colors.green
                              : Colors.redAccent,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 26),

                /// ACTION BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color:
                                isDark ? Colors.white12 : Colors.grey.shade200,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Batal",
                            style: GoogleFonts.inter(
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Obx(() {
                        final valid = isUpper.value &&
                            isLower.value &&
                            isNumber.value &&
                            isSymbol.value &&
                            isLength.value &&
                            isConfirmMatch.value;

                        return GestureDetector(
                          onTap: valid
                              ? () {
                                  Navigator.pop(context);
                                  onSubmit(pwdCtrl.text);
                                }
                              : null,
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: LinearGradient(
                                colors: valid
                                    ? [
                                        Color(0xFF4A8CFF),
                                        Color(0xFF73B2FF)
                                      ]
                                    : [
                                        Colors.grey.shade400,
                                        Colors.grey.shade500
                                      ],
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Simpan",
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

void showNoRealAccountPopup() {
  final isDark = Get.isDarkMode;
  final regolController = Get.put(RegolController());
  final accountController = Get.put(AccountController());
  Get.bottomSheet(
    ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E1E1E).withOpacity(0.92)
                : Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ---------- ICON ----------
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.05),
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 40,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),

              const SizedBox(height: 16),

              // ---------- TITLE ----------
              Text(
                "Akses Dibatasi",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              // ---------- DESCRIPTION ----------
              Text(
                "Halaman ini hanya dapat diakses oleh pengguna dengan akun trading real. "
                "Silakan buka akun real terlebih dahulu untuk melanjutkan.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.45,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),

              const SizedBox(height: 24),

              // ---------- BUTTON CTA ----------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: CustomColor.secondaryColor
                  ),
                  onPressed: () async {
                    if(accountController.demoAccounts.isEmpty){
                      await regolController.createDemoAccount().then((result) async {
                        if (result) {
                          showDemoAccountSuccessPopup();
                          await accountController.fetchAccountInfo().then((result){
                            accountController.selectAccount(accountController.allAccounts.firstWhere((acc) => acc.type == 'demo', orElse: () => accountController.allAccounts.first));
                          });
                        }else{
                          AppSnackbar.error('Gagal membuat akun demo. Silakan coba lagi atau buat akun demo atau real melalui halaman RRFX versi Web');
                        }
                      });
                      return;
                    }
                    Get.to(() => CreateMT5PasswordPage());
                  },
                  child: const Text(
                    "Buka Akun Real",
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ---------- SECONDARY BUTTON ----------
              GestureDetector(
                onTap: () => Get.back(),
                child: Text(
                  "Nanti saja",
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    ),
    isScrollControlled: true,
    enableDrag: true,
  );
}

/// Widget kecil untuk item validasi
Widget _buildValidateItem(String text, bool valid) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        Icon(
          valid ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: valid ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: valid ? Colors.green : Colors.grey,
          ),
        ),
      ],
    ),
  );
}

void showDemoAccountSuccessPopup() {
  Get.dialog(
    Center(
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.85, end: 1),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) => Transform.scale(
          scale: scale,
          child: child,
        ),
        child: Container(
          width: Get.width * 0.8,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Theme.of(Get.context!).cardColor.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CustomColor.secondaryColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  EvaIcons.checkmark_circle_2,
                  size: 48,
                  color: CustomColor.secondaryColor,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                "Akun Demo Berhasil Dibuat!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(Get.context!).textTheme.titleLarge?.color,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "Selamat! Akun demo kamu sudah siap digunakan. "
                "Silakan mulai berlatih trading tanpa risiko.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(Get.context!)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.8),
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColor.secondaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "OK, Mengerti",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: false,
    barrierColor: Colors.black54,
  );
}

void showRealAccountOnlyPopup(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  Get.dialog(
    Center(
      child: Container(
        width: Get.width * 0.85,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.4)
                  : Colors.grey.shade300,
              blurRadius: 20,
              spreadRadius: 1,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ICON
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                color: (isDark ? Colors.redAccent.shade100 : Colors.redAccent)
                    .withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Bootstrap.exclamation_triangle_fill,
                size: 36,
                color: isDark ? Colors.redAccent.shade100 : Colors.redAccent,
              ),
            ),
            const SizedBox(height: 18),

            // TITLE
            Text(
              "Akses Ditolak",
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black,
                decoration: TextDecoration.none,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // DESCRIPTION (NO UNDERLINE)
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text:
                        "Halaman ini hanya dapat dibuka menggunakan akun trading REAL.\n\n",
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      height: 1.5,
                      color: isDark ? Colors.white70 : Colors.black87,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  TextSpan(
                    text: "Untuk mengganti akun, buka tab ",
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      height: 1.5,
                      color: isDark ? Colors.white70 : Colors.black87,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  TextSpan(
                    text: "Explore",
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                      color: isDark ? Colors.white : Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  TextSpan(
                    text:
                        ", lalu tekan ikon di pojok kanan atas dan pilih akun REAL.",
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      height: 1.5,
                      color: isDark ? Colors.white70 : Colors.black87,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // BUTTON
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColor.secondaryColor,
                  elevation: 0,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  "Mengerti",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    barrierColor: Colors.black.withOpacity(0.35),
    barrierDismissible: true,
  );
}
