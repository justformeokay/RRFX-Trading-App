import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class CustomImagePicker {
  static Future<String> pickImageFromCameraAndReturnUrl({bool useCamera = false}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? imagePicked = await picker.pickImage(
        source: useCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 10,
      );
      
      if(imagePicked == null) {
        throw Exception("Pengambilan gambar dibatalkan oleh pengguna.");
      }

      final File imageFile = File(imagePicked.path);
      if (await imageFile.exists() == false) {
        throw Exception("Gambar tidak ditemukan di path: ${imagePicked.path}");
      }

      return imageFile.path;
     
    } catch (e) {
      return e.toString();
      // throw Exception("Terjadi kesalahan saat mengambil gambar: $e");
    }
  }

  static Future<String> pickImageFromCameraAndReturnUrlV2({bool useCamera = false}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? imagePicked = await picker.pickImage(
        source: useCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 10, // ambil kualitas tinggi dulu, nanti di-compress
      );

      if (imagePicked == null) {
        throw Exception("Pengambilan gambar dibatalkan oleh pengguna.");
      }

      final File imageFile = File(imagePicked.path);
      if (!await imageFile.exists()) {
        throw Exception("Gambar tidak ditemukan di path: ${imagePicked.path}");
      }

      int fileSize = await imageFile.length();
      const int maxSize = 2 * 1024 * 1024; // 2 MB

      if (fileSize > maxSize) {
        // ✅ compress gambar
        final dir = await getTemporaryDirectory();
        final targetPath = path.join(
          dir.path,
          "compressed_${DateTime.now().millisecondsSinceEpoch}.jpg",
        );

        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          imageFile.absolute.path,
          targetPath,
          quality: 85, // coba kualitas 85 dulu
        );

        if (compressedFile == null) {
          throw Exception("Gagal mengompres gambar.");
        }

        fileSize = await compressedFile.length();
        if (fileSize > maxSize) {
          throw Exception("Ukuran gambar masih terlalu besar setelah kompres (maksimal 2 MB).");
        }

        return compressedFile.path;
      }

      return imageFile.path;

    } catch (e) {
      return e.toString();
    }
  }
}
