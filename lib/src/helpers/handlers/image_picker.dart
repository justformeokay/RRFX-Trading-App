import 'dart:io';
import 'package:flutter/foundation.dart';
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
        imageQuality: 100, // Ambil kualitas tinggi dulu, nanti di-compress
      );
      
      if(imagePicked == null) {
        throw Exception("Pengambilan gambar dibatalkan oleh pengguna.");
      }

      final File imageFile = File(imagePicked.path);
      if (await imageFile.exists() == false) {
        throw Exception("Gambar tidak ditemukan di path: ${imagePicked.path}");
      }

      // Auto-compress semua gambar menjadi 50% dari ukuran asli
      return await _compressImage(imageFile.path);
     
    } catch (e) {
      // Jika user cancel atau error, return empty string bukan error message
      return '';
    }
  }

  /// Compress image otomatis dengan target 50% dari ukuran asli
  static Future<String> _compressImage(String originalPath) async {
    try {
      final File originalFile = File(originalPath);
      final int originalSize = await originalFile.length();
      
      // Jika ukuran sudah kecil (< 500 KB), skip compress
      if (originalSize < 500 * 1024) {
        return originalPath;
      }

      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.path,
        "compressed_${DateTime.now().millisecondsSinceEpoch}.jpg",
      );

      // Mulai dengan quality 50 untuk target 50% size reduction
      int quality = 50;
      XFile? compressedFile;

      // Coba compress dengan quality 50
      compressedFile = await FlutterImageCompress.compressAndGetFile(
        originalFile.absolute.path,
        targetPath,
        quality: quality,
      );

      if (compressedFile == null) {
        // Jika gagal compress, return original
        return originalPath;
      }

      final int compressedSize = await File(compressedFile.path).length();
      final double compressionRatio = (compressedSize / originalSize) * 100;

      debugPrint("📸 Image compressed: ${(originalSize / 1024).toStringAsFixed(2)} KB → ${(compressedSize / 1024).toStringAsFixed(2)} KB (${compressionRatio.toStringAsFixed(1)}%)");

      // Jika masih > 2MB, compress lebih agresif
      if (compressedSize > 2 * 1024 * 1024) {
        quality = 30;
        final targetPath2 = path.join(
          dir.path,
          "compressed_v2_${DateTime.now().millisecondsSinceEpoch}.jpg",
        );
        
        final compressedFile2 = await FlutterImageCompress.compressAndGetFile(
          originalFile.absolute.path,
          targetPath2,
          quality: quality,
        );

        if (compressedFile2 != null) {
          final size2 = await File(compressedFile2.path).length();
          if (size2 < compressedSize) {
            debugPrint("📸 Further compressed to: ${(size2 / 1024).toStringAsFixed(2)} KB");
            return compressedFile2.path;
          }
        }
      }

      return compressedFile.path;
    } catch (e) {
      debugPrint("⚠️ Compression error: $e");
      // Jika error saat compress, return original path
      return originalPath;
    }
  }

  static Future<String> pickImageFromCameraAndReturnUrlV2({bool useCamera = false}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? imagePicked = await picker.pickImage(
        source: useCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 100, // Ambil kualitas tinggi dulu, nanti di-compress
      );

      if (imagePicked == null) {
        throw Exception("Pengambilan gambar dibatalkan oleh pengguna.");
      }

      final File imageFile = File(imagePicked.path);
      if (!await imageFile.exists()) {
        throw Exception("Gambar tidak ditemukan di path: ${imagePicked.path}");
      }

      // Auto-compress semua gambar
      return await _compressImage(imageFile.path);

    } catch (e) {
      return e.toString();
    }
  }
}
