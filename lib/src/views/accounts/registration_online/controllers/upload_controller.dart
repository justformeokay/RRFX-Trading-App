import 'dart:io';
import 'package:get/get.dart';
import 'package:rrfx/src/helpers/handlers/image_picker.dart';

class UploadController extends GetxController {
  var rekeningKoran = ''.obs; // path atau url foto
  var isImageOnline = false.obs; // true jika dari API (URL), false jika dari device
  var isLoading = false.obs;

  void initFromApi(String? apiImageUrl) {
    if (apiImageUrl != null && apiImageUrl.isNotEmpty) {
      rekeningKoran.value = apiImageUrl;
      isImageOnline.value = true;
    } else {
      rekeningKoran.value = '';
      isImageOnline.value = false;
    }
  }

  Future<void> pickNewImage() async {
    final newImagePath = await CustomImagePicker.pickImageFromCameraAndReturnUrl(useCamera: false);
    if (newImagePath.isNotEmpty) {
      rekeningKoran.value = newImagePath;
      isImageOnline.value = false; // sudah jadi image lokal
    }
  }
}


class MultiUploadController extends GetxController {
  var photoList = <String>[].obs;
  var isOnlineList = <bool>[].obs;
  var fileSizeList = <String>[].obs; // List untuk menyimpan ukuran file

  final List<String> photoDescriptions = [
    "NPWP / Rekening Koran / Rekening Listrik / Tagihan Kartu Kredit",
    "Foto KTP",
    "Foto Selfi",
    "Dokumen Lainnya 1 (Opsional)",
    "Dokumen Lainnya 2 (Opsional)",
  ];
  
  final List<String> photoTitles = [
    "NPWP / Rekening Koran / Rekening Listrik / Tagihan Kartu Kredit *",
    "Foto KTP *",
    "Foto Selfi *",
    "Dokumen Lainnya 1 (Opsional)",
    "Dokumen Lainnya 2 (Opsional)",
  ];

  // Helper function to get file size in KB
  String _getFileSizeInKB(String filePath) {
    if (filePath.isEmpty) return "";
    try {
      final file = File(filePath);
      final bytes = file.lengthSync();
      final kb = (bytes / 1024).toStringAsFixed(2);
      return kb;
    } catch (e) {
      return "";
    }
  }

  void initFromApi(Map<String, dynamic> apiData) {
    photoList.clear();
    isOnlineList.clear();
    fileSizeList.clear();

    List<String?> apiUrls = [
      apiData['appFotoImage1'], // NPWP / Rekening Koran / Rekening Listrik
      apiData['appFotoImage2'], // "Foto KTP",
      apiData['appFotoImage3'], // "Foto Selfi",
      apiData['appFotoImage4'], // Dokumen Lainnya 1
      apiData['appFotoImage5'], // Dokumen Lainnya 2
    ];

    for (var url in apiUrls) {
      if (url != null && url.isNotEmpty) {
        photoList.add(url);
        isOnlineList.add(true);
        fileSizeList.add(""); // Tidak ada size untuk online image
      } else {
        photoList.add('');
        isOnlineList.add(false);
        fileSizeList.add("");
      }
    }
  }

  /// Saat user klik untuk mengganti gambar tertentu
  Future<void> pickNewImage(int index, {bool useCamera = false}) async {
    final newImagePath = await CustomImagePicker.pickImageFromCameraAndReturnUrl(useCamera: useCamera);
    if (newImagePath.isNotEmpty) {
      photoList[index] = newImagePath;
      isOnlineList[index] = false;
      fileSizeList[index] = _getFileSizeInKB(newImagePath); // Hitung ukuran file
      photoList.refresh();
      isOnlineList.refresh();
      fileSizeList.refresh();
    }
  }
}
