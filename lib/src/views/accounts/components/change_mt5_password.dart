import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/account_list/account_service.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/colors/default.dart';

class ChangeMT5PasswordPage extends StatefulWidget {
  final String? mt5AccountId;

  const ChangeMT5PasswordPage({super.key, this.mt5AccountId});

  @override
  State<ChangeMT5PasswordPage> createState() => _ChangeMT5PasswordPageState();
}

class _ChangeMT5PasswordPageState extends State<ChangeMT5PasswordPage> {
  final newPass = TextEditingController();
  final confirmPass = TextEditingController();
  final accountController = Get.put(AccountController());
  RxBool isLoading = false.obs;
  AccountService accountService = Get.put(AccountService());

  // VALIDATION STATES
  bool hasUpper = false;
  bool hasLower = false;
  bool hasNumber = false;
  bool hasSymbol = false;
  bool hasMinLength = false;
  bool passwordMatch = true;

  @override
  void dispose() {
    newPass.dispose();
    confirmPass.dispose();
    super.dispose();
  }

  // VALIDATE PASSWORD
  void validatePassword(String value) {
    setState(() {
      hasUpper = value.contains(RegExp(r'[A-Z]'));
      hasLower = value.contains(RegExp(r'[a-z]'));
      hasNumber = value.contains(RegExp(r'[0-9]'));
      hasSymbol = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      hasMinLength = value.length >= 6;
    });
  }

  void validatePasswordMatch() {
    setState(() {
      passwordMatch = newPass.text == confirmPass.text;
    });
  }

  bool get isAllValid => hasUpper && hasLower && hasNumber && hasSymbol && hasMinLength && passwordMatch;


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          elevation: 0,
          forceMaterialTransparency: true,
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset('assets/images/mt5-removebg-preview.png', width: 39.0),
                    const SizedBox(width: 10.0),
                    Flexible(
                      child: Text(
                        "Ubah Password Akun MetaTrader 5",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),
                Text(
                  "Silakan masukkan password lama dan buat password baru untuk akun MetaTrader 5 Anda ID ${widget.mt5AccountId}.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),

                const SizedBox(height: 28),

                // PASSWORD BARU
                _inputField(
                  label: "Password Baru",
                  controller: newPass,
                  icon: Icons.lock_reset_outlined,
                  onChanged: (v) {
                    validatePassword(v);
                    validatePasswordMatch();
                  },
                ),

                const SizedBox(height: 15),

                // CHECKLIST VALIDASI
                _checkItem("Minimal 6 karakter", hasMinLength),
                _checkItem("Mengandung huruf besar (A-Z)", hasUpper),
                _checkItem("Mengandung huruf kecil (a-z)", hasLower),
                _checkItem("Mengandung angka (0-9)", hasNumber),
                _checkItem("Mengandung simbol (!@#\$% dll)", hasSymbol),

                const SizedBox(height: 28),

                // CONFIRM PASSWORD
                _inputField(
                  label: "Konfirmasi Password Baru",
                  controller: confirmPass,
                  icon: Icons.verified_user_outlined,
                  onChanged: (_) => validatePasswordMatch(),
                ),

                if (!passwordMatch)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: const [
                        Icon(Icons.error, color: Colors.red, size: 18),
                        SizedBox(width: 6),
                        Text("Password tidak cocok",
                            style: TextStyle(color: Colors.red, fontSize: 13)),
                      ],
                    ),
                  ),

                const SizedBox(height: 30),

                // SUBMIT BUTTON
                SizedBox(
                  width: double.infinity,
                  child: Obx(
                    () {
                      bool isEnabled = !isLoading.value && isAllValid;
                      return ElevatedButton(
                        onPressed: isEnabled ? () async{
                          print("Response Message: ${accountService.responseMessage.value}");
                          final newPassword = newPass.text.trim();
                          final changeSuccess = await accountController.changePasswordMeta5(
                            loginNumber: accountController.selectedAccount.value?.login,
                            newPassword: newPassword,
                          );

                          if(!changeSuccess){
                            String errorMessage = accountService.responseMessage.value;
                            AppSnackbar.error(
                              errorMessage.isNotEmpty ? errorMessage : "Gagal mengubah password. Silakan coba lagi.",
                            );
                            return;
                          }
                          AppSnackbar.success(
                            "Password akun ${accountController.selectedAccount.value?.login} berhasil diubah.",
                          );
                        } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isEnabled ? CustomColor.secondaryColor : Colors.grey.shade400,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isLoading.value
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2.2,
                                ),
                              )
                            : const Text(
                                "Ubah Password",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // INPUT FIELD
  Widget _inputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    Function(String)? onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: true,
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: isDark ? Colors.white70 : Colors.black54),
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade200,
            hintText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  // CHECKLIST ITEM
  Widget _checkItem(String text, bool active) {
    return Row(
      children: [
        Icon(
          active ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 18,
          color: active ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: active ? Colors.green : Colors.grey,
            fontSize: 13,
          ),
        )
      ],
    );
  }

  // SUBMIT REQUEST
  void _submitPassword() async {
    final newPassword = newPass.text.trim();

    final changeSuccess = await accountController.changePasswordMeta5(
      loginNumber: accountController.selectedAccount.value?.login,
      newPassword: newPassword,
    );

    if(!changeSuccess){
      String errorMessage = accountService.responseMessage.value;
      AppSnackbar.error(
        errorMessage.isNotEmpty ? errorMessage : "Gagal mengubah password. Silakan coba lagi.",
      );
      return;
    }

    if (changeSuccess) {
      AppSnackbar.success(
        "Password akun ${accountController.selectedAccount.value?.login} berhasil diubah.",
      );
    }
  }
}
