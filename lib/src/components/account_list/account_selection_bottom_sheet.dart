import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/alerts/popup.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'account_controller.dart';
import 'account_model.dart';
const Color customSecondaryColor = Colors.orange; 

class AccountSelectionBottomSheet {
  static void show() {
    final AccountController controller = Get.find<AccountController>();
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor, 
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container( // Drag Handle
              margin: const EdgeInsets.symmetric(vertical: 10), height: 4, width: 40,
              decoration: BoxDecoration(color: Get.theme.dividerColor, borderRadius: BorderRadius.circular(2)),
            ),
            Padding( // Header
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Pilih Akun Utama', style: Get.theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            ),
            Divider(height: 0.2, color: Get.theme.dividerColor.withOpacity(0.2)),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: Get.height * 0.7),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(padding: EdgeInsets.all(40.0), child: Center(child: CircularProgressIndicator()));
                }
                if (controller.allAccounts.isEmpty) {
                  return const Padding(padding: EdgeInsets.all(20.0), child: Center(child: Text('Tidak ada akun untuk dipilih.')));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.allAccounts.length, // ✅ Menggunakan RxList
                  itemBuilder: (context, index) {
                    final account = controller.allAccounts[index]; // ✅ Menggunakan RxList
                    return GestureDetector(
                      onTap: () async {
                        Get.back();
                        await Future.delayed(const Duration(milliseconds: 250));
                        controller.selectAccount(account);
                        controller.connectToMeta5(loginNumber: account.login).then((success) {
                          if (success) {
                            AppSnackbar.success('Akun ${account.login} berhasil dihubungkan ke MetaTrader 5.');
                          } else {
                            showMt5PasswordPopup(
                              Get.context!,
                              login: account.login ?? "",
                              onSubmit: (password) async {

                                final changeSuccess = await controller.changePasswordMeta5(
                                  loginNumber: account.login,
                                  newPassword: password,
                                );

                                if (changeSuccess) {
                                  AppSnackbar.success("Password akun ${account.login} berhasil diubah.");

                                  final reconnect = await controller.connectToMeta5(
                                    loginNumber: account.login,
                                  );

                                  if (reconnect) {
                                    AppSnackbar.success(
                                      "Akun ${account.login} berhasil dihubungkan ke MetaTrader 5."
                                    );
                                  } else {
                                    AppSnackbar.error(
                                      "Gagal menghubungkan akun ${account.login} setelah mengubah password."
                                    );
                                  }

                                } else {
                                  AppSnackbar.error(
                                    "Gagal mengubah password akun ${account.login}."
                                  );
                                }
                              },
                            );
                          }
                        });
                      },
                      child: _buildAccountCard(context, account, controller),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
    );
  }

  static Widget _buildAccountCard(BuildContext context, AccountDetailModel account, AccountController controller) {
    final bool isSelected = controller.isSelected(account);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    final primaryColor = account.type == 'real' ? Colors.green.shade600 : customSecondaryColor;
    final cardColor = isSelected ? primaryColor.withOpacity(isDarkMode ? 0.1 : 0.08) : theme.cardColor;
    final icon = account.type == 'real' ? FontAwesome.dollar_sign_solid : FontAwesome.laptop_code_solid;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: primaryColor, width: 2) : null,
        boxShadow: isSelected
            ? [BoxShadow(color: primaryColor.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3))]
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, color: primaryColor, size: 28),
        title: Text(
          '${account.namaTipeAkun ?? 'Akun'} (${account.type?.toUpperCase()})',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? primaryColor : theme.textTheme.titleMedium?.color,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Login ID: ${account.login ?? 'N/A'}'),
            Text('Balance: ${account.accountCurrency} ${account.balance ?? '0.00'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: isSelected ? Icon(Bootstrap.check_circle_fill, color: primaryColor) : const Icon(Bootstrap.arrow_right_circle_fill, color: Colors.grey),
      ),
    );
  }
}