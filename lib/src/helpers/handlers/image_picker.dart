import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Result class untuk image picking dengan status detail
class ImagePickResult {
  final String path;
  final bool success;
  final String? errorMessage;
  final String? originalFormat;
  final int? originalSizeKB;
  final int? finalSizeKB;

  ImagePickResult({
    required this.path,
    required this.success,
    this.errorMessage,
    this.originalFormat,
    this.originalSizeKB,
    this.finalSizeKB,
  });
}

class CustomImagePicker {
  /// Supported image formats
  static const List<String> _supportedFormats = [
    'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp',
    'heic', 'heif', // iOS formats - akan dikonversi ke JPEG
  ];

  /// Check if file extension is supported
  static bool _isSupportedFormat(String filePath) {
    final ext = path.extension(filePath).toLowerCase().replaceAll('.', '');
    return _supportedFormats.contains(ext);
  }

  /// Get file extension
  static String _getFileExtension(String filePath) {
    return path.extension(filePath).toLowerCase().replaceAll('.', '');
  }

  /// Check if format needs conversion (HEIC/HEIF)
  static bool _needsConversion(String filePath) {
    final ext = _getFileExtension(filePath);
    return ext == 'heic' || ext == 'heif';
  }

  static Future<String> pickImageFromCameraAndReturnUrl({bool useCamera = false}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? imagePicked = await picker.pickImage(
        source: useCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 100, // Ambil kualitas tinggi dulu, nanti di-compress
      );
      
      if (imagePicked == null) {
        debugPrint("📸 [ImagePicker] User cancelled image selection");
        return '';
      }

      final File imageFile = File(imagePicked.path);
      if (!await imageFile.exists()) {
        debugPrint("❌ [ImagePicker] File not found: ${imagePicked.path}");
        return '';
      }

      // Log original file info
      final originalSize = await imageFile.length();
      final originalExt = _getFileExtension(imagePicked.path);
      debugPrint("📸 [ImagePicker] Original file: ${imagePicked.path}");
      debugPrint("📸 [ImagePicker] Format: $originalExt, Size: ${(originalSize / 1024).toStringAsFixed(2)} KB");

      // Validate format
      if (!_isSupportedFormat(imagePicked.path)) {
        debugPrint("❌ [ImagePicker] Unsupported format: $originalExt");
        debugPrint("📸 [ImagePicker] Supported formats: ${_supportedFormats.join(', ')}");
        return '';
      }

      // Auto-compress dan convert gambar
      final result = await _processAndCompressImage(imageFile.path);
      
      if (result.isEmpty) {
        debugPrint("❌ [ImagePicker] Failed to process image");
        return '';
      }

      // Verify final file exists and is readable
      final finalFile = File(result);
      if (!await finalFile.exists()) {
        debugPrint("❌ [ImagePicker] Processed file not found: $result");
        return '';
      }

      final finalSize = await finalFile.length();
      debugPrint("✅ [ImagePicker] Final file: $result");
      debugPrint("✅ [ImagePicker] Final size: ${(finalSize / 1024).toStringAsFixed(2)} KB");

      return result;
     
    } catch (e, stackTrace) {
      debugPrint("❌ [ImagePicker] Error: $e");
      debugPrint("❌ [ImagePicker] StackTrace: $stackTrace");
      return '';
    }
  }

  /// Process image: convert if needed (HEIC → JPEG) then compress
  static Future<String> _processAndCompressImage(String originalPath) async {
    try {
      final File originalFile = File(originalPath);
      final int originalSize = await originalFile.length();
      final String originalExt = _getFileExtension(originalPath);

      debugPrint("🔄 [ImagePicker] Processing image...");
      debugPrint("🔄 [ImagePicker] Format: $originalExt");

      final dir = await getTemporaryDirectory();
      
      // Step 1: Convert HEIC/HEIF to JPEG first
      String workingPath = originalPath;
      if (_needsConversion(originalPath)) {
        debugPrint("🔄 [ImagePicker] Converting $originalExt to JPEG...");
        
        final convertedPath = path.join(
          dir.path,
          "converted_${DateTime.now().millisecondsSinceEpoch}.jpg",
        );

        try {
          // Use flutter_image_compress to convert HEIC to JPEG
          final converted = await FlutterImageCompress.compressAndGetFile(
            originalFile.absolute.path,
            convertedPath,
            quality: 95, // High quality for conversion
            format: CompressFormat.jpeg,
          );

          if (converted != null && await File(converted.path).exists()) {
            workingPath = converted.path;
            final convertedSize = await File(converted.path).length();
            debugPrint("✅ [ImagePicker] Converted to JPEG: ${(convertedSize / 1024).toStringAsFixed(2)} KB");
          } else {
            debugPrint("⚠️ [ImagePicker] HEIC conversion failed, trying alternative method...");
            // Fallback: try with different settings
            final convertedAlt = await FlutterImageCompress.compressAndGetFile(
              originalFile.absolute.path,
              convertedPath,
              quality: 100,
              format: CompressFormat.jpeg,
              keepExif: false, // Sometimes EXIF causes issues
            );
            
            if (convertedAlt != null && await File(convertedAlt.path).exists()) {
              workingPath = convertedAlt.path;
              debugPrint("✅ [ImagePicker] Converted with fallback method");
            } else {
              debugPrint("❌ [ImagePicker] Cannot convert $originalExt format");
              return ''; // Return empty if can't convert
            }
          }
        } catch (conversionError) {
          debugPrint("❌ [ImagePicker] Conversion error: $conversionError");
          return ''; // Return empty if conversion fails
        }
      }

      // Step 2: Check if compression needed
      final File workingFile = File(workingPath);
      final int workingSize = await workingFile.length();
      
      // Jika ukuran sudah kecil (< 500 KB) dan format sudah JPEG/PNG, skip compress
      if (workingSize < 500 * 1024 && !_needsConversion(originalPath)) {
        debugPrint("✅ [ImagePicker] File small enough, skipping compression");
        return workingPath;
      }

      // Step 3: Compress image
      final targetPath = path.join(
        dir.path,
        "compressed_${DateTime.now().millisecondsSinceEpoch}.jpg",
      );

      int quality = 50;
      XFile? compressedFile;

      try {
        compressedFile = await FlutterImageCompress.compressAndGetFile(
          workingFile.absolute.path,
          targetPath,
          quality: quality,
          format: CompressFormat.jpeg,
        );
      } catch (compressError) {
        debugPrint("⚠️ [ImagePicker] First compression attempt failed: $compressError");
        // Try with PNG format as fallback
        try {
          final pngTargetPath = path.join(
            dir.path,
            "compressed_${DateTime.now().millisecondsSinceEpoch}.png",
          );
          compressedFile = await FlutterImageCompress.compressAndGetFile(
            workingFile.absolute.path,
            pngTargetPath,
            quality: quality,
            format: CompressFormat.png,
          );
        } catch (pngError) {
          debugPrint("⚠️ [ImagePicker] PNG fallback also failed: $pngError");
        }
      }

      if (compressedFile == null) {
        debugPrint("⚠️ [ImagePicker] Compression failed, returning working file");
        return workingPath;
      }

      // Verify compressed file
      if (!await File(compressedFile.path).exists()) {
        debugPrint("⚠️ [ImagePicker] Compressed file not created, returning working file");
        return workingPath;
      }

      final int compressedSize = await File(compressedFile.path).length();
      final double compressionRatio = (compressedSize / originalSize) * 100;

      debugPrint("📸 [ImagePicker] Compressed: ${(originalSize / 1024).toStringAsFixed(2)} KB → ${(compressedSize / 1024).toStringAsFixed(2)} KB (${compressionRatio.toStringAsFixed(1)}%)");

      // Step 4: If still > 2MB, compress more aggressively
      if (compressedSize > 2 * 1024 * 1024) {
        debugPrint("🔄 [ImagePicker] File still > 2MB, compressing more...");
        quality = 30;
        final targetPath2 = path.join(
          dir.path,
          "compressed_v2_${DateTime.now().millisecondsSinceEpoch}.jpg",
        );
        
        try {
          final compressedFile2 = await FlutterImageCompress.compressAndGetFile(
            workingFile.absolute.path,
            targetPath2,
            quality: quality,
            format: CompressFormat.jpeg,
          );

          if (compressedFile2 != null && await File(compressedFile2.path).exists()) {
            final size2 = await File(compressedFile2.path).length();
            if (size2 < compressedSize) {
              debugPrint("📸 [ImagePicker] Further compressed to: ${(size2 / 1024).toStringAsFixed(2)} KB");
              return compressedFile2.path;
            }
          }
        } catch (e) {
          debugPrint("⚠️ [ImagePicker] Second compression failed: $e");
        }
      }

      return compressedFile.path;
    } catch (e, stackTrace) {
      debugPrint("❌ [ImagePicker] Process error: $e");
      debugPrint("❌ [ImagePicker] StackTrace: $stackTrace");
      return originalPath;
    }
  }

  static Future<String> pickImageFromCameraAndReturnUrlV2({bool useCamera = false}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? imagePicked = await picker.pickImage(
        source: useCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 100,
      );

      if (imagePicked == null) {
        throw Exception("Pengambilan gambar dibatalkan oleh pengguna.");
      }

      final File imageFile = File(imagePicked.path);
      if (!await imageFile.exists()) {
        throw Exception("Gambar tidak ditemukan di path: ${imagePicked.path}");
      }

      // Validate format
      if (!_isSupportedFormat(imagePicked.path)) {
        final ext = _getFileExtension(imagePicked.path);
        throw Exception("Format gambar tidak didukung: $ext. Gunakan JPG, PNG, atau WEBP.");
      }

      return await _processAndCompressImage(imageFile.path);

    } catch (e) {
      return e.toString();
    }
  }

  /// Pick image with detailed result (for better error handling)
  static Future<ImagePickResult> pickImageWithResult({bool useCamera = false}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? imagePicked = await picker.pickImage(
        source: useCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 100,
      );

      if (imagePicked == null) {
        return ImagePickResult(
          path: '',
          success: false,
          errorMessage: 'Pemilihan gambar dibatalkan',
        );
      }

      final File imageFile = File(imagePicked.path);
      if (!await imageFile.exists()) {
        return ImagePickResult(
          path: '',
          success: false,
          errorMessage: 'File gambar tidak ditemukan',
        );
      }

      final originalExt = _getFileExtension(imagePicked.path);
      final originalSize = await imageFile.length();

      if (!_isSupportedFormat(imagePicked.path)) {
        return ImagePickResult(
          path: '',
          success: false,
          errorMessage: 'Format $originalExt tidak didukung. Gunakan JPG, PNG, WEBP, atau HEIC.',
          originalFormat: originalExt,
        );
      }

      final result = await _processAndCompressImage(imageFile.path);

      if (result.isEmpty) {
        return ImagePickResult(
          path: '',
          success: false,
          errorMessage: 'Gagal memproses gambar. Coba gambar lain.',
          originalFormat: originalExt,
          originalSizeKB: (originalSize / 1024).round(),
        );
      }

      final finalSize = await File(result).length();

      return ImagePickResult(
        path: result,
        success: true,
        originalFormat: originalExt,
        originalSizeKB: (originalSize / 1024).round(),
        finalSizeKB: (finalSize / 1024).round(),
      );

    } catch (e) {
      return ImagePickResult(
        path: '',
        success: false,
        errorMessage: 'Error: $e',
      );
    }
  }
}
