import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/views/no_auth_view/settings/about_company_page.dart';
import 'package:rrfx/src/views/no_auth_view/settings/faq_page.dart';
import 'package:rrfx/src/views/no_auth_view/settings/privacy_policy_setting.dart';
import 'package:rrfx/src/views/no_auth_view/settings/terms_and_conditions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SettingsNoAuth extends StatelessWidget {
  const SettingsNoAuth({super.key});

  Future<String> _getVersionInfo() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return "v${packageInfo.version}+${packageInfo.buildNumber}";
    } catch (e) {
      return "v0.0.0";
    }
  }

  Future<void> _launchMoreInfo() async {
    final Uri url = Uri.parse("https://rrfx.co.id");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF8F8F8),
      appBar: AppBar(
        forceMaterialTransparency: true,
        elevation: 0,
        title: Text(
          "Settings",
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        children: [
          const SizedBox(height: 10),

          // =====================================================
          // 🔥 AUTH INFO SECTION (Added)
          // =====================================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                  color: Colors.black.withOpacity(0.06),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.account_circle_outlined,
                  size: 40,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),

                const SizedBox(height: 14),

                Text(
                  "Belum Masuk Akun",
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Login atau buat akun RRFX untuk mengakses semua fitur dan pengaturan akun.",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.4,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.toNamed("/login"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColor.secondaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.toNamed("/signup"),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: CustomColor.secondaryColor,
                          ),
                        ),
                        child: const Text(
                          "Register",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: CustomColor.secondaryColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),

          // =====================================================
          // GENERAL SECTION
          // =====================================================
          Text(
            "General",
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          _settingsTile(
            icon: Icons.lock_outline,
            label: "Privacy Policy",
            onTap: () => Get.to(() => const PrivacyPolicyPage()),
            isDark: isDark,
          ),

          _settingsTile(
            icon: Icons.description_outlined,
            label: "Terms & Conditions",
            onTap: () => Get.to(() => const TermsConditionsPage()),
            isDark: isDark,
          ),

          _settingsTile(
            icon: Icons.business_outlined,
            label: "About Company",
            onTap: () => Get.to(() => const AboutCompanyPage()),
            isDark: isDark,
          ),

          _settingsTile(
            icon: Icons.help_outline,
            label: "FAQ",
            onTap: () => Get.to(() => const FAQPage()),
            isDark: isDark,
          ),

          _settingsTile(
            icon: Iconsax.trash_outline,
            label: "Hapus Akun",
            onTap: () => Get.to(() => _DeleteAccountWebView()),
            isDark: isDark,
          ),

          const SizedBox(height: 20),

          // =====================================================
          // ABOUT SECTION
          // =====================================================
          Text(
            "About",
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          FutureBuilder<String>(
            future: _getVersionInfo(),
            builder: (context, snapshot) {
              final version = snapshot.data ?? "Loading...";
              return _settingsTile(
                icon: Icons.info_outline_rounded,
                label: "Version",
                value: version,
                isDark: isDark,
              );
            },
          ),

          const SizedBox(height: 24),

          // =====================================================
          // MORE INFO BUTTON
          // =====================================================
          Center(
            child: TextButton(
              onPressed: _launchMoreInfo,
              child: Text(
                "More Info",
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: CustomColor.secondaryColor,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // REUSABLE TILE
  // ----------------------------------------------------------
  Widget _settingsTile({
    required IconData icon,
    required String label,
    bool isDark = false,
    String? value,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.06),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: isDark ? Colors.white70 : Colors.black87),
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        trailing: value != null
            ? Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              )
            : Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
      ),
    );
  }
}


// ════════════════════════════════════════════════════════════════════════════
// DELETE ACCOUNT WEBVIEW
// ════════════════════════════════════════════════════════════════════════════
class _DeleteAccountWebView extends StatefulWidget {
  @override
  State<_DeleteAccountWebView> createState() => _DeleteAccountWebViewState();
}

class _DeleteAccountWebViewState extends State<_DeleteAccountWebView> {
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse('https://app.rrfx.co.id/delete-account'),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Account'),
        centerTitle: true,
        elevation: 0,
        forceMaterialTransparency: true,
      ),
      body: WebViewWidget(controller: _webViewController),
    );
  }
}