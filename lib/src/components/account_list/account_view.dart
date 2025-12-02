import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart'; // Import icons_plus!
import 'account_controller.dart';
import 'account_model.dart';

class AccountSelectionView extends StatelessWidget {
  final AccountController controller = Get.put(AccountController());

  AccountSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Akun')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Akun Default Saat Ini:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Obx(() {
              final acc = controller.selectedAccount.value;
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (acc == null) {
                return const Text('Tidak ada akun yang tersedia.', 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
              }
              // Menggunakan widget card baru
              return _buildAccountCard(context, acc, isSelected: true);
            }),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _showAccountSelectionSheet(context),
              child: const Text('Pilih Akun Lain'),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk menampilkan detail akun (Ditingkatkan)
  Widget _buildAccountCard(BuildContext context, AccountDetailModel account, {bool isSelected = false}) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Warna yang disesuaikan untuk mode gelap/terang
    final primaryColor = account.type == 'real' ? Colors.green.shade600 : Colors.orange.shade600;
    final cardColor = isSelected 
        ? primaryColor.withOpacity(isDarkMode ? 0.1 : 0.08) // Lebih subtle di dark mode
        : theme.cardColor;
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
            Text('Login ID: #${account.login ?? 'N/A'}'),
            Text(
              'Balance: ${account.currency ?? 'USD'} ${account.balance ?? '0.00'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: isSelected 
            ? Icon(Bootstrap.check_circle_fill, color: primaryColor) 
            : const Icon(Bootstrap.arrow_right_circle_fill, color: Colors.grey),
      ),
    );
  }

  // Fungsi untuk menampilkan Bottom Sheet Pemilihan Akun (Ditingkatkan)
  void _showAccountSelectionSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        // Menggunakan warna latar belakang yang responsif terhadap mode gelap/terang
        color: Theme.of(context).scaffoldBackgroundColor, 
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Pilih Akun Utama',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),

            // Daftar Akun
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7), // Batasi tinggi
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (controller.allAccounts.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: Text('Tidak ada akun untuk dipilih.')),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.allAccounts.length,
                  itemBuilder: (context, index) {
                    final account = controller.allAccounts[index];
                    final isSelected = controller.isSelected(account);
                    
                    return GestureDetector(
                      onTap: () {
                        controller.selectAccount(account);
                        Get.back(); // Tutup bottom sheet setelah memilih
                      },
                      child: _buildAccountCard(context, account, isSelected: isSelected),
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
      shape: const RoundedRectangleBorder( // Bentuk bottom sheet yang kekinian
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
    );
  }
}