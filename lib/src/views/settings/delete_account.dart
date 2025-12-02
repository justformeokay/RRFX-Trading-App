import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrfx/src/components/alerts/popup.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  bool agree = false;
  bool loading = false;

  final List<String> reasons = [
    "Ingin menutup akun trading",
    "Masalah keamanan / privasi",
    "Banyak akun aktif",
    "Tidak ingin melanjutkan trading",
    "Lainnya",
  ];

  String? selectedReason;

  final TextEditingController descC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111111) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ICON HEADER
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withOpacity(0.07)
                    : Colors.black.withOpacity(0.05),
              ),
              child: Icon(
                Icons.delete_forever_rounded,
                size: 42,
                color: isDark ? Colors.red.shade300 : Colors.red.shade600,
              ),
            ),

            const SizedBox(height: 20),

            // TITLE
            Text(
              "Hapus Akun",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            // DESCRIPTION
            Text(
              "Menghapus akun bersifat permanen dan tidak dapat dipulihkan. "
              "Pastikan Anda benar-benar memahami konsekuensinya sebelum melanjutkan.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),

            const SizedBox(height: 30),

            // REASON DROPDOWN
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Alasan penghapusan akun",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.white24 : Colors.black12,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedReason,
                  hint: Text(
                    "Pilih alasan",
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                  dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  items: reasons.map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => selectedReason = v),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // DESCRIPTION TEXTFIELD
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Deskripsi tambahan (opsional)",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: descC,
              maxLines: 4,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                filled: true,
                fillColor:
                    isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                hintText: "Tuliskan detail tambahan bila perlu...",
                hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : Colors.black12,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 26),

            // CHECKBOX AGREEMENT
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: agree,
                  side: BorderSide(
                    color: isDark ? Colors.white24 : Colors.black26,
                    width: 1,
                  ),
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return isDark ? Colors.blue.shade300 : Colors.blue.shade600;
                    }
                    return Colors.transparent;
                  }),
                  checkColor: isDark ? Colors.black : Colors.white,
                  onChanged: (v) => setState(() => agree = v ?? false),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => agree = !agree),
                    child: Text(
                      "Saya memahami bahwa penghapusan akun bersifat permanen dan "
                      "saya menyetujui kebijakan privasi.",
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),

            // DELETE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (!agree || loading)
                    ? null
                    : () async {
                      FeatureUnderDevPopup.show();
                        // setState(() => loading = true);

                        // await Future.delayed(const Duration(seconds: 2));

                        // setState(() => loading = false);

                        // Get.back(); // Close page
                        // Get.snackbar(
                        //   "Akun Dihapus",
                        //   "Akun Anda telah berhasil dihapus.",
                        //   snackPosition: SnackPosition.BOTTOM,
                        // );
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  elevation: 0,
                  backgroundColor: (!agree)
                      ? (isDark
                          ? Colors.white12
                          : Colors.black12)
                      : (isDark
                          ? Colors.red.shade300
                          : Colors.red.shade600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: loading
                    ? SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: isDark ? Colors.black : Colors.white,
                        ),
                      )
                    : Text(
                        "Hapus Akun",
                        style: TextStyle(
                          fontSize: 16,
                          color: (!agree)
                              ? (isDark ? Colors.white38 : Colors.black38)
                              : (isDark ? Colors.black : Colors.white),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
