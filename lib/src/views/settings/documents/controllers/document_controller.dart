import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rrfx/src/components/account_list/account_controller.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/document_model.dart';
import '../views/pdf_viewer_page.dart'; // Asumsi lokasi file viewer

class DocumentController extends GetxController {
  final isLoading = false.obs;
  final documents = <Document>[].obs;
  final accountController = Get.find<AccountController>();

  // --- API Configuration ---
  String get _apiUrlWithLogin => '${GlobalVariable.mainURL}/account/documents?login=';

  Future<String?> getAccessToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('accessToken');
      if (token != null) {
        return token;
      } else {
        throw Exception('Access token tidak ditemukan di SharedPreferences.');
      }
    } catch (e) {
      throw Exception('Gagal mengambil access token: ${e.toString()}');
    }
  }

  // --- FUNGSI 1: FETCH DOKUMEN ---
  Future<void> fetchDocuments({String? loginID}) async {
    isLoading.value = true;
    String? token = await getAccessToken();
    if(token == null) {
      isLoading.value = false;
      CustomScaffoldMessanger.showAppSnackBar(Get.context!, 
        message: 'Token akses tidak tersedia. Silakan login ulang.'
      );
      return;
    }
    try {
      final response = await http.get(
        Uri.parse('$_apiUrlWithLogin${loginID ?? accountController.selectedAccount.value?.login}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Cookie': 'PHPSESSID=276msp6chb1ttn90avtdon2ldl', // Sesuaikan
        },
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == true && body['response'] is List) {
          documents.value = (body['response'] as List).map((data) => Document.fromJson(data)).toList();
        } else {
          throw Exception(body['message'] ?? 'Respons API tidak valid.');
        }
      } else {
        throw Exception('Gagal memuat dokumen: Status ${response.statusCode}');
      }
    } catch (e) {
      AppSnackbar.error('Gagal memuat data dokumen: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // --- FUNGSI 2: NAVIGASI KE PDF VIEWER ---
  void viewDocument(Document document) {
    // Navigasi ke halaman PDF Viewer dengan membawa link
    Get.to(() => PdfViewerPage(document: document));
  }
  
  Future<void> downloadDocument(Document document) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: CustomColor.secondaryColor,)),
      barrierDismissible: false,
    );

    try {
      // 1. Gunakan folder aplikasi (aman Play Store)
      final dir = await getApplicationDocumentsDirectory();

      final fileName = '${document.name.replaceAll(' ', '_')}.pdf';
      final savePath = '${dir.path}/$fileName';

      // 2. Download file
      await Dio().download(document.link, savePath);

      Get.back(); // Tutup loading
      AppSnackbar.success(
        "Dokumen \"${document.name}\" berhasil disimpan di folder aplikasi.\n\n"
        "Lokasi:\n$savePath",
      );
    } catch (e) {
      Get.back();
      AppSnackbar.error('Gagal mengunduh dokumen: ${e.toString()}');
    }
  }



  // --- FUNGSI 4: SHARE PDF ---
  Future<void> shareDocument(Document document) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/${document.name.replaceAll(' ', '_')}.pdf';

      final response = await Dio().download(document.link, path);
      
      if (response.statusCode == 200) {
        await SharePlus.instance.share(
          ShareParams(files: [XFile(path)], text: 'Cek dokumen penting ini: ${document.name}')
        );
      } else {
        throw Exception('Gagal mengunduh file sementara.');
      }
    } catch (e) {
      AppSnackbar.error('Gagal menyiapkan dokumen untuk dibagikan: ${e.toString()}');
    }
  }
}

// Widget Pembantu untuk mendapatkan path public (hanya untuk Android)
Future<Directory?> getExternalStoragePublicDirectory(String directoryName) async {
  if (Platform.isAndroid) {
    // Dapatkan nama paket aplikasi secara asinkron
    final packageInfo = await PackageInfo.fromPlatform();
    final packageName = packageInfo.packageName; 
    
    final directories = await getExternalStorageDirectories(type: StorageDirectory.downloads);
    
    if (directories != null && directories.isNotEmpty) {
      // Gunakan packageName yang didapat dari PackageInfo.fromPlatform()
      return Directory(directories.first.path.replaceAll('Android/data/$packageName/files/Download', directoryName));
    }
  }
  // Fallback untuk iOS/lainnya
  return await getApplicationDocumentsDirectory(); 
}