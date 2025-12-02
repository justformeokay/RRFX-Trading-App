import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/views/accounts/registration_online/views/step_17.dart';

class IdentityVerificationController extends GetxController {
  var selfie = Rx<File?>(null);
  var ktp = Rx<File?>(null);

  final picker = ImagePicker();

  Future<void> pickImage({required bool isSelfie}) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (isSelfie) {
        selfie.value = File(picked.path);
      } else {
        ktp.value = File(picked.path);
      }
    }
  }

  bool get isComplete => selfie.value != null && ktp.value != null;
}

class Step16 extends StatelessWidget {
  const Step16({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(IdentityVerificationController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("VERIFIKASI IDENTITAS"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Banner info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Dokumen yang telah diverifikasi, tidak dapat diubah",
                style: TextStyle(color: Colors.black87),
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 Dua foto sejajar
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildImageBox(
                    context,
                    title: "Foto Terbaru (Selfie) *",
                    isSelfie: true,
                    controller: controller,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildImageBox(
                    context,
                    title: "Foto KTP *",
                    isSelfie: false,
                    controller: controller,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 🔹 Info ukuran & dimensi
            const Text(
              "*Foto Selfie\n"
              "- Minimal ukuran file 100KB dan Maksimal 4MB\n"
              "- Minimal dimensi file 480x640 (p x l)\n",
              style: TextStyle(fontSize: 14),
            ),
            const Text(
              "*Foto KTP\n"
              "- Minimal ukuran file 100KB dan Maksimal 2MB\n"
              "- Minimal dimensi file 480x320 (p x l)",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),

            // 🔹 Tombol navigasi bawah
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[400],
                  ),
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text("Previous", style: TextStyle(color: Colors.black),),
                ),
                Obx(() {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor:
                          controller.isComplete ? CustomColor.secondaryColor: Colors.grey,
                    ),
                    onPressed: controller.isComplete
                        ? () {
                            Get.snackbar(
                              "Berhasil",
                              "Data berhasil dikirim ke halaman berikutnya",
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            Get.to(() => Step17());
                          }
                        : null,
                    child: const Text("Next", style: TextStyle(color: Colors.black),),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageBox(BuildContext context,
      {required String title,
      required bool isSelfie,
      required IdentityVerificationController controller}) {
    return Obx(() {
      final file = isSelfie ? controller.selfie.value : controller.ktp.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => controller.pickImage(isSelfie: isSelfie),
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: file == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.camera_alt_outlined, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text("Ambil Foto", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(file, fit: BoxFit.cover, width: double.infinity),
                    ),
            ),
          ),
        ],
      );
    });
  }
}
