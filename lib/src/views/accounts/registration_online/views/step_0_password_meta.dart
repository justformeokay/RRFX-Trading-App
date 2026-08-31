import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/views/accounts/registration_online/repository/regol_repository.dart';
import 'package:rrfx/src/views/accounts/registration_online/views/step_2A.dart';

class CreateMT5PasswordPage extends StatefulWidget {
  const CreateMT5PasswordPage({super.key});

  @override
  State<CreateMT5PasswordPage> createState() => _CreateMT5PasswordPageState();
}

class _CreateMT5PasswordPageState extends State<CreateMT5PasswordPage> {
  RegolRepository regolRepository = Get.put(RegolRepository());
  final TextEditingController passC = TextEditingController();
  final TextEditingController confirmC = TextEditingController();

  // Reactive states
  final RxBool showPass = false.obs;
  final RxBool showConfirm = false.obs;
  final RxBool loading = false.obs;

  // Validation states
  final RxBool hasUpper = false.obs;
  final RxBool hasLower = false.obs;
  final RxBool hasNumber = false.obs;
  final RxBool hasSymbol = false.obs;
  final RxBool hasMinChar = false.obs;

  // Confirm password match
  final RxBool confirmMatch = false.obs;
  final RxBool confirmTouched = false.obs; // Track if user has interacted with confirm field

  RxBool get passwordValid => RxBool(
    hasUpper.value &&
    hasLower.value &&
    hasNumber.value &&
    hasSymbol.value &&
    hasMinChar.value,
  );

  @override
  void initState() {
    super.initState();

    passC.addListener(() {
      final value = passC.text;
      hasUpper.value = value.contains(RegExp(r'[A-Z]'));
      hasLower.value = value.contains(RegExp(r'[a-z]'));
      hasNumber.value = value.contains(RegExp(r'[0-9]'));
      hasSymbol.value = value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=]'));
      hasMinChar.value = value.length >= 6;

      // recheck confirm
      confirmMatch.value = confirmC.text == value;
    });

    confirmC.addListener(() {
      confirmTouched.value = true; // Mark as touched when user starts typing
      confirmMatch.value = confirmC.text == passC.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF111111) : Colors.white,
        appBar: AppBar(
          elevation: 0,
          forceMaterialTransparency: true,
          iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
          title: Text(
            "Buat Password MT5",
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Icon Header
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? Colors.white.withOpacity(0.07)
                        : Colors.black.withOpacity(0.05),
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    size: 42,
                    color: CustomColor.secondaryColor,
                  ),
                ),
              ),
      
              const SizedBox(height: 22),
      
              Center(
                child: Text(
                  "Atur Password MetaTrader 5",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
      
              const SizedBox(height: 14),
      
              Center(
                child: Text(
                  "Password digunakan untuk login ke akun MT5 Anda.\nHarus kuat dan memenuhi syarat keamanan.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    height: 1.45,
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
      
              const SizedBox(height: 30),
      
              /// PASSWORD FIELD
              Text(
                "Password Baru",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
      
              Obx(() => TextField(
                    controller: passC,
                    obscureText: !showPass.value,
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withOpacity(0.06)
                          : Colors.black.withOpacity(0.04),
                      hintText: "Masukkan password MT5...",
                      hintStyle: TextStyle(
                          color: isDark ? Colors.white38 : Colors.black38),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPass.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                        onPressed: () => showPass.value = !showPass.value,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                    ),
                  )),
      
              const SizedBox(height: 16),
      
              /// REQUIREMENTS
              Obx(() => Column(
                children: [
                  _buildRequirement(isDark, hasUpper.value, "Ada huruf kapital (A-Z)"),
                  _buildRequirement(isDark, hasLower.value, "Ada huruf kecil (a-z)"),
                  _buildRequirement(isDark, hasNumber.value, "Ada angka (0-9)"),
                  _buildRequirement(isDark, hasSymbol.value, "Ada simbol (!@#...)"),
                  _buildRequirement(isDark, hasMinChar.value, "Minimal 6 karakter"),
                ],
              )),
      
              const SizedBox(height: 30),
      
              /// CONFIRM PASSWORD
              Text(
                "Konfirmasi Password",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
      
              Obx(() => TextField(
                  controller: confirmC,
                  obscureText: !showConfirm.value,
                  style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.03),
                    hintText: "Ulangi password...",
                    hintStyle: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showConfirm.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                      onPressed: () =>
                          showConfirm.value = !showConfirm.value,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                )
              ),
      
              const SizedBox(height: 8),
      
              /// CONFIRM VALIDATION TEXT
              Obx(() => (confirmTouched.value && confirmC.text.length >= 6 && !confirmMatch.value)
                  ? Text(
                      "Password tidak cocok!",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.redAccent,
                      ),
                    )
                  : const SizedBox()),
      
              const SizedBox(height: 40),
      
              /// SUBMIT BUTTON
              Obx(() {
                final canSubmit = passwordValid.value && confirmMatch.value && !loading.value;
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: !canSubmit
                        ? null
                        : () async {
                            loading.value = true;
                            await Future.delayed(const Duration(seconds: 2));
                            loading.value = false;
                            AppSnackbar.success("Password MT5 berhasil dibuat.");
                            regolRepository.passwordMeta5 = passC.text;
                            Get.to(() => const ProductView());
                          },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: !canSubmit
                          ? (isDark ? Colors.white10 : Colors.black12)
                          : CustomColor.secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: loading.value
                      ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.3,
                            color: isDark ? Colors.grey : Colors.white,
                          ),
                        )
                      : Text(
                          "Buat Password",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: !canSubmit
                                ? (isDark
                                    ? Colors.white38
                                    : Colors.black38)
                                : Colors.black,
                          ),
                        ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(bool isDark, bool active, String text) {
    return Row(
      children: [
        Icon(
          active ? Icons.check_circle : Icons.circle_outlined,
          size: 18,
          color: active
              ? (isDark ? Colors.greenAccent : Colors.green)
              : (isDark ? Colors.white38 : Colors.black38),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: active
                ? (isDark ? Colors.white : Colors.black87)
                : (isDark ? Colors.white54 : Colors.black54),
          ),
        )
      ],
    );
  }
}
