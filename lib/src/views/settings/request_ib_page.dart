import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/components/alerts/popup.dart';
import 'package:rrfx/src/components/colors/default.dart';

class RequestIBPage extends StatefulWidget {
  const RequestIBPage({super.key});

  @override
  State<RequestIBPage> createState() => _RequestIBPageState();
}

class _RequestIBPageState extends State<RequestIBPage> {
  bool agree = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF9F9F9),
      appBar: AppBar(
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        title: const Text("Request IB"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ICON HEADER STYLED LIKE POPUP
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.05),
              ),
              child: Icon(
                Icons.handshake_rounded,
                size: 46,
                color: isDark ? CustomColor.secondaryColor.withOpacity(0.7) : CustomColor.secondaryColor,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Menjadi Introducing Broker",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "Dapatkan komisi, bangun jaringan, dan undang trader lain "
              "melalui program Introducing Broker (IB).",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),

            const SizedBox(height: 25),

            // BUTTON "Apa itu IB?"
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.info_outline, size: 20, color: Colors.blue),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                label: Text(
                  "Apa itu Introducing Broker?",
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: _showWhatIsIBPopup,
              ),
            ),

            const SizedBox(height: 28),

            // REQUIREMENTS CARD
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                border: Border.all(
                  color: isDark ? Colors.white24 : Colors.black12,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Persyaratan Menjadi IB",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 14),

                  _requireItem("Memiliki Akun Trading Real"),
                  _requireItem("Memiliki Free Margin Minimal \$100"),
                  _requireItem("Setuju dengan Kebijakan & Privasi RRFX"),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // CHECKBOX AGREEMENT
            Row(
              children: [
                Checkbox(
                  value: agree,

                  // BORDER
                  side: BorderSide(
                    color: isDark ? Colors.white24 : Colors.black26,
                    width: 1.3,
                  ),

                  // WARNA BACKGROUND CHECKBOX
                  fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return CustomColor.secondaryColor; // warna saat dicentang
                    }
                    return Colors.transparent; // saat TIDAK dicentang
                  }),

                  checkColor: Colors.white, // warna centang

                  overlayColor: WidgetStatePropertyAll(
                    isDark ? Colors.white10 : Colors.black12,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),

                  onChanged: (v) => setState(() => agree = v ?? false),
                ),

                Expanded(
                  child: GestureDetector(
                    onTap: _showPolicyBottomSheet,
                    child: Text.rich(
                      TextSpan(
                        text: "Saya telah membaca dan menyetujui ",
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                        children: [
                          TextSpan(
                            text: "Kebijakan Privasi",
                            style: TextStyle(
                              color: CustomColor.secondaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const TextSpan(text: " & "),
                          TextSpan(
                            text: "Syarat Ketentuan",
                            style: TextStyle(
                              color: CustomColor.secondaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),

            // SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: agree ? _submitIBRequest : null,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: agree
                      ? CustomColor.secondaryColor
                      : (isDark ? Colors.white10 : Colors.black12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  "Submit Request IB",
                  style: TextStyle(
                    fontSize: 16,
                    color: agree
                        ? (Colors.black)
                        : (isDark ? Colors.white54 : Colors.black45),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _requireItem(String text) {
    final isDark = Get.isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle,
              size: 18,
              color: isDark ? Colors.greenAccent : Colors.green.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // POPUP EXPLANATION
  void _showWhatIsIBPopup() {
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
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.handshake_rounded,
                  size: 46,
                  color: isDark ? CustomColor.secondaryColor.withOpacity(0.7) : CustomColor.secondaryColor),
              const SizedBox(height: 20),
              Text(
                "Apa itu Introducing Broker?",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 14),
              Text(
                "IB (Introducing Broker) adalah mitra resmi broker "
                "yang memperkenalkan trader baru dan mendapatkan "
                "komisi dari aktivitas trading mereka.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: 1.45,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColor.secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  "Mengerti",
                  style: TextStyle(
                      color: isDark ? Colors.black : Colors.white,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // POLICY BOTTOMSHEET
  void _showPolicyBottomSheet() {
    final isDark = Get.isDarkMode;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 5,
              width: 50,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(50),
              ),
            ),

            Text(
              "Kebijakan Privasi & Syarat",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              "Dengan mendaftar sebagai IB, Anda menyetujui aturan penggunaan "
              "serta kebijakan privasi RRFX.",
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1.45,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),

            const SizedBox(height: 26),

            ElevatedButton(
              onPressed: () {
                setState(() => agree = true);
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColor.secondaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                "Saya Setuju",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // SUBMIT LOGIC
  void _submitIBRequest() {
    FeatureUnderDevPopup.show();
  }
}
