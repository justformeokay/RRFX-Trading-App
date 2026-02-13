import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rrfx/src/components/colors/default.dart';

class UtilitiesWidget {
  static Padding titleContent({required List<Widget> children, String? title, String? subtitle, TextAlign? textAlign}){
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title ?? "Title", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold), textAlign: textAlign ?? TextAlign.start),
          const SizedBox(height: 5),
          Text(subtitle ?? "", style: GoogleFonts.inter(fontSize: 16), textAlign: textAlign ?? TextAlign.start),
          const SizedBox(height: 20.0),
          Column(
            children: children,
          )
        ],
      ),
    );
  }

  static GestureDetector uploadPhoto({String? title, String? urlPhoto, Function()? onPressed, bool? isImageOnline}){
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title != null ? "Unggah $title" : 'Unggah Foto', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 10.0),
          Container(
            margin: const EdgeInsets.only(bottom: 15.0),
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: CustomColor.secondaryBackground.withValues(alpha: 0.3),
              image: (urlPhoto != null && urlPhoto.isNotEmpty) ? isImageOnline == true ? DecorationImage(image: NetworkImage(urlPhoto), fit: BoxFit.cover) : DecorationImage(
                image: FileImage(File(urlPhoto)),
                fit: BoxFit.cover
              ) : null
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white38,
                    ),
                    child: Icon(CupertinoIcons.camera_fill, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  urlPhoto == null || urlPhoto == '' ? Text("Please take photo ${title ?? ""}", style: GoogleFonts.inter(color: CustomColor.secondaryColor, fontSize: 16.0), textAlign: TextAlign.center) : const SizedBox()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static GestureDetector uploadPhotoV2(
    BuildContext context, {
    String? title,
    String? urlPhoto,
    String? ukuranFile,
    Function()? onPressed,
    Function(bool useCamera)? onImageSourceSelected,
    bool? isImageOnline,
  }) {
    // Parse file size and check if it exceeds 2MB (2048 KB)
    final fileSizeKB = ukuranFile != null ? double.tryParse(ukuranFile) ?? 0 : 0;
    final isFileTooLarge = fileSizeKB > 2048; // 2MB = 2048 KB
    
    return GestureDetector(
      onTap: onImageSourceSelected != null 
          ? () => _showImageSourceBottomSheet(context, onImageSourceSelected, title)
          : onPressed,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 15.0),
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: CustomColor.backgroundIconSoftLight.withValues(alpha: 0.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: (urlPhoto != null && urlPhoto.isNotEmpty)
                  ? (isImageOnline == true
                      ? Image.network(
                          urlPhoto,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint('❌ [uploadPhotoV2] Network image error: $error');
                            debugPrint('❌ [uploadPhotoV2] URL: $urlPhoto');
                            return buildPlaceholder(context, title);
                          },
                        )
                      : _buildLocalImage(urlPhoto, context, title))
                  : buildPlaceholder(context, title),
            ),
          ),
          // Badge ukuran file - HARUS DI POSISI TERAKHIR AGAR DI ATAS GAMBAR
          if (ukuranFile != null && ukuranFile.isNotEmpty)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isFileTooLarge 
                        ? [Colors.red.shade700, Colors.red.shade900]
                        : fileSizeKB > 1024 // > 1MB
                            ? [Colors.orange.shade600, Colors.orange.shade800]
                            : [Colors.green.shade600, Colors.green.shade800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isFileTooLarge 
                          ? Icons.warning_rounded 
                          : Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      fileSizeKB >= 1024 
                          ? '${(fileSizeKB / 1024).toStringAsFixed(2)} MB'
                          : '$ukuranFile KB',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }


  static Widget buildPlaceholder(BuildContext context, String? title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white38,
            ),
            child: Icon(
              CupertinoIcons.camera_fill,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Please take photo ${title ?? ""}",
            style: GoogleFonts.inter(
              color: CustomColor.secondaryColor,
              fontSize: 16.0,
            ),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  /// Build local image with comprehensive error handling
  static Widget _buildLocalImage(String urlPhoto, BuildContext context, String? title) {
    final file = File(urlPhoto);
    
    // Check if file exists synchronously first
    if (!file.existsSync()) {
      debugPrint('❌ [uploadPhotoV2] Local file not found: $urlPhoto');
      return buildErrorPlaceholder(context, title, 'File tidak ditemukan');
    }

    // Check file size
    try {
      final fileSize = file.lengthSync();
      if (fileSize == 0) {
        debugPrint('❌ [uploadPhotoV2] File is empty (0 bytes): $urlPhoto');
        return buildErrorPlaceholder(context, title, 'File kosong');
      }
      debugPrint('📸 [uploadPhotoV2] Loading file: $urlPhoto (${(fileSize / 1024).toStringAsFixed(2)} KB)');
    } catch (e) {
      debugPrint('❌ [uploadPhotoV2] Cannot read file size: $e');
    }

    return Image.file(
      file,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ [uploadPhotoV2] Image.file error: $error');
        debugPrint('❌ [uploadPhotoV2] File path: $urlPhoto');
        debugPrint('❌ [uploadPhotoV2] StackTrace: $stackTrace');
        return buildErrorPlaceholder(context, title, 'Format tidak didukung');
      },
    );
  }

  /// Build error placeholder with specific message
  static Widget buildErrorPlaceholder(BuildContext context, String? title, String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.red.withValues(alpha: 0.2),
            ),
            child: Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 32,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            errorMessage,
            style: GoogleFonts.inter(
              color: Colors.red,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            "Tap untuk coba lagi",
            style: GoogleFonts.inter(
              color: CustomColor.secondaryColor,
              fontSize: 12.0,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static void _showImageSourceBottomSheet(
    BuildContext context,
    Function(bool useCamera) onImageSourceSelected,
    String? title,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Pilih Sumber ${title ?? "Foto"}",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Pilih metode untuk mengambil gambar",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSourceOption(
                        context: context,
                        icon: Icons.camera_alt_rounded,
                        label: "Kamera",
                        gradient: LinearGradient(
                          colors: [
                            CustomColor.secondaryColor.withValues(alpha: 0.8),
                            CustomColor.secondaryColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          onImageSourceSelected(true);
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildSourceOption(
                        context: context,
                        icon: Icons.photo_library_rounded,
                        label: "Galeri",
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade600,
                            Colors.blue.shade800,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          onImageSourceSelected(false);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildSourceOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

}

