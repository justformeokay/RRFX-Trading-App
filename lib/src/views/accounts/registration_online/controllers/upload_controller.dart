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
  final List<String> photoTitles = [
    "NPWP / Rekening Koran / Rekening Listrik / Tagihan Kartu Kredit *",
    "Foto KTP *",
    "Foto Selfi *",
    "Dokumen Lainnya 1 (Opsional)",
    "Dokumen Lainnya 2 (Opsional)",
  ];

  void initFromApi(Map<String, dynamic> apiData) {
    photoList.clear();
    isOnlineList.clear();

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
      } else {
        photoList.add('');
        isOnlineList.add(false);
      }
    }
  }

  /// Saat user klik untuk mengganti gambar tertentu
  Future<void> pickNewImage(int index, {bool useCamera = false}) async {
    final newImagePath = await CustomImagePicker.pickImageFromCameraAndReturnUrl(useCamera: useCamera);
    if (newImagePath.isNotEmpty) {
      photoList[index] = newImagePath;
      isOnlineList[index] = false;
      photoList.refresh();
      isOnlineList.refresh();
    }
  }
}
