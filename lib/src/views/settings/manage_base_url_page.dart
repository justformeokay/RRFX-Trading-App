import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/controllers/home.dart';
import 'package:rrfx/src/controllers/trading.dart';
import 'package:rrfx/src/controllers/trading_account_controller.dart';
import 'package:rrfx/src/controllers/user_controller.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/service/account_credentials_service.dart';
import 'package:rrfx/src/views/no_auth_view/mainpage_no_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManageBaseUrlPage extends StatefulWidget {
  const ManageBaseUrlPage({super.key});

  @override
  State<ManageBaseUrlPage> createState() => _ManageBaseUrlPageState();
}

class _ManageBaseUrlPageState extends State<ManageBaseUrlPage> {
  late String _selectedMainUrl;
  late String _selectedTradingUrl;
  bool _isCustomTrading = false;
  bool _hasChanges = false;
  bool _isSaving = false;
  final _customTradingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedMainUrl = GlobalVariable.mainURL;
    _selectedTradingUrl = GlobalVariable.tradingApiBase;

    // Cek apakah trading URL saat ini bukan salah satu preset
    final isPreset = _selectedTradingUrl == GlobalVariable.tradingUrlProduction ||
        _selectedTradingUrl == GlobalVariable.tradingUrlStaging;
    if (!isPreset) {
      _isCustomTrading = true;
      _customTradingController.text = _selectedTradingUrl;
    }
  }

  @override
  void dispose() {
    _customTradingController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    // Validasi custom URL
    if (_isCustomTrading) {
      final customUrl = _customTradingController.text.trim();
      if (customUrl.isEmpty) {
        _showError('Custom URL tidak boleh kosong');
        return;
      }
      if (!customUrl.startsWith('https://') && !customUrl.startsWith('http://')) {
        _showError('URL harus diawali dengan https:// atau http://');
        return;
      }
      _selectedTradingUrl = customUrl;
    }

    // Tampilkan konfirmasi logout
    _showLogoutConfirmation();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showLogoutConfirmation() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Konfirmasi Perubahan URL',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Text(
          'Setelah menyimpan perubahan URL, semua sesi akan ditutup dan Anda harus login ulang agar token trading baru bisa didapatkan.\n\nLanjutkan?',
          style: GoogleFonts.inter(fontSize: 13.5, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Batal',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _doSaveAndLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text(
              'Simpan & Logout',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _doSaveAndLogout() async {
    setState(() => _isSaving = true);

    // 1. Simpan URL baru
    await GlobalVariable.setMainUrl(_selectedMainUrl);
    await GlobalVariable.setTradingUrl(_selectedTradingUrl);

    // 2. Clear cached MT5 tokens
    await AccountCredentialsService.clearCache();

    // 3. Clear SharedPreferences (session data)
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('accessToken');
    prefs.remove('refreshToken');
    prefs.remove('loggedIn');
    prefs.remove('accountAccountIndex');
    prefs.remove('selectedLogin');
    prefs.remove('selectedType');
    prefs.remove('selectedCurrency');
    prefs.remove('selectedLeverage');

    // 4. Clear GetStorage tapi preserve passcode + dev URLs
    final storage = GetStorage();
    final savedPasscodeData = storage.read('app_passcode');
    final savedMainUrl = storage.read<String>('dev_main_url');
    final savedTradingUrl = storage.read<String>('dev_trading_url');
    final savedExecSpeed = storage.read<bool>('dev_show_exec_speed');

    await storage.erase();

    if (savedPasscodeData != null) {
      await storage.write('app_passcode', savedPasscodeData);
    }
    if (savedMainUrl != null) {
      await storage.write('dev_main_url', savedMainUrl);
    }
    if (savedTradingUrl != null) {
      await storage.write('dev_trading_url', savedTradingUrl);
    }
    if (savedExecSpeed != null) {
      await storage.write('dev_show_exec_speed', savedExecSpeed);
    }

    // 5. Dispose controllers
    try {
      final ac = Get.find<AccountController>();
      ac.clearDefaultAccount();
      ac.resetAccountsState();
    } catch (_) {}
    Get.delete<AccountController>(force: true);
    Get.delete<TradingAccountController>(force: true);
    Get.delete<TradingController>(force: true);
    Get.delete<UserController>(force: true);
    Get.delete<HomeController>(force: true);

    // 6. Navigate ke login
    Get.offAll(() => const MainpageWithoutLogin());
  }

  void _checkChanges() {
    final effectiveTradingUrl = _isCustomTrading
        ? _customTradingController.text.trim()
        : _selectedTradingUrl;
    setState(() {
      _hasChanges = _selectedMainUrl != GlobalVariable.mainURL ||
          effectiveTradingUrl != GlobalVariable.tradingApiBase;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : CustomColor.secondaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Developer Options',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Mengubah URL akan mempengaruhi koneksi API. Pastikan URL yang dipilih sudah benar.',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: colorScheme.onSurface.withOpacity(0.7),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── MAIN API URL ──
            _buildUrlSection(
              context, isDark, colorScheme,
              title: 'Main API URL',
              subtitle: 'URL utama untuk login, profile, akun, dll.',
              icon: Iconsax.global_outline,
              iconColor: Colors.blue,
              currentValue: _selectedMainUrl,
              options: [
                _UrlOption(
                  url: GlobalVariable.mainUrlProduction,
                  label: 'Production',
                  tag: 'DEFAULT',
                  tagColor: Colors.orange,
                ),
                _UrlOption(
                  url: GlobalVariable.mainUrlStaging,
                  label: 'Staging / Development',
                  tag: 'STG',
                  tagColor: Colors.purple,
                ),
              ],
              onChanged: (url) {
                _selectedMainUrl = url;
                _checkChanges();
              },
              showUrl: true,
            ),
            const SizedBox(height: 20),

            // ── TRADING API URL ──
            _buildUrlSection(
              context, isDark, colorScheme,
              title: 'Trading API URL',
              subtitle: 'URL untuk OrderSend, OrderModify, OrderClose, Connect.',
              icon: Iconsax.chart_outline,
              iconColor: Colors.green,
              currentValue: _isCustomTrading ? '__custom__' : _selectedTradingUrl,
              options: [
                _UrlOption(
                  url: GlobalVariable.tradingUrlProduction,
                  label: 'Production',
                  tag: 'DEFAULT',
                  tagColor: Colors.orange,
                ),
                _UrlOption(
                  url: GlobalVariable.tradingUrlStaging,
                  label: 'Staging / Development',
                  tag: 'STG',
                  tagColor: Colors.purple,
                ),
                _UrlOption(
                  url: '__custom__',
                  label: 'Custom URL',
                  tag: 'CUSTOM',
                  tagColor: Colors.red,
                ),
              ],
              onChanged: (url) {
                if (url == '__custom__') {
                  _isCustomTrading = true;
                  _selectedTradingUrl = _customTradingController.text.trim();
                } else {
                  _isCustomTrading = false;
                  _selectedTradingUrl = url;
                }
                _checkChanges();
              },
              customWidget: _isCustomTrading ? _buildCustomTradingInput(isDark, colorScheme) : null,
            ),
            const SizedBox(height: 24),

            // ── CURRENT STATUS ──
            _buildStatusCard(context, isDark, colorScheme),

            const SizedBox(height: 32),

            // ── SAVE BUTTON ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _hasChanges && !_isSaving ? _saveChanges : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColor.secondaryColor,
                  disabledBackgroundColor: isDark
                      ? Colors.grey.shade800
                      : Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Simpan Perubahan',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: _hasChanges ? Colors.white : Colors.grey,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrlSection(
    BuildContext context,
    bool isDark,
    ColorScheme colorScheme, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String currentValue,
    required List<_UrlOption> options,
    required ValueChanged<String> onChanged,
    Widget? customWidget,
    bool showUrl = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Options
          ...options.map((option) {
            final isSelected = currentValue == option.url;
            return InkWell(
              onTap: () => onChanged(option.url),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? CustomColor.secondaryColor.withOpacity(isDark ? 0.15 : 0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? CustomColor.secondaryColor.withOpacity(0.5)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    // Radio indicator
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? CustomColor.secondaryColor
                              : colorScheme.onSurface.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: CustomColor.secondaryColor,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),

                    // Label + URL
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                option.label,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.5,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: option.tagColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  option.tag,
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: option.tagColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (option.url != '__custom__' && showUrl) ...[
                            const SizedBox(height: 3),
                            Text(
                              option.url,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                color: colorScheme.onSurface.withOpacity(0.45),
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 3),
                            Text(
                              'Masukkan URL sendiri',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: colorScheme.onSurface.withOpacity(0.4),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    if (isSelected)
                      const Icon(Icons.check_circle, color: CustomColor.secondaryColor, size: 20),
                  ],
                ),
              ),
            );
          }),
          if (customWidget != null) customWidget,
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildCustomTradingInput(bool isDark, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      child: TextField(
        controller: _customTradingController,
        onChanged: (val) {
          _selectedTradingUrl = val.trim();
          _checkChanges();
        },
        style: GoogleFonts.jetBrainsMono(
          fontSize: 13,
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'https://your-mt5-api.com',
          hintStyle: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            color: colorScheme.onSurface.withOpacity(0.3),
          ),
          prefixIcon: Icon(
            Iconsax.link_circle_outline,
            size: 18,
            color: Colors.red.withOpacity(0.6),
          ),
          filled: true,
          fillColor: isDark
              ? Colors.red.withOpacity(0.08)
              : Colors.red.withOpacity(0.04),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.red.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.red.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
        ),
        keyboardType: TextInputType.url,
        autocorrect: false,
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, bool isDark, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.info_circle_outline, size: 16, color: colorScheme.onSurface.withOpacity(0.5)),
              const SizedBox(width: 8),
              Text(
                'Status Aktif',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatusRow('Main API', GlobalVariable.mainURL, isDark, colorScheme, showUrl: false),
          const SizedBox(height: 8),
          _buildStatusRow('Trading API', GlobalVariable.tradingApiBase, isDark, colorScheme, showUrl: true),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String url, bool isDark, ColorScheme colorScheme, {bool showUrl = true}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        if (showUrl)
          Expanded(
            child: Text(
              url,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: CustomColor.secondaryColor,
              ),
            ),
          ),
      ],
    );
  }
}

class _UrlOption {
  final String url;
  final String label;
  final String tag;
  final Color tagColor;

  _UrlOption({
    required this.url,
    required this.label,
    required this.tag,
    required this.tagColor,
  });
}
