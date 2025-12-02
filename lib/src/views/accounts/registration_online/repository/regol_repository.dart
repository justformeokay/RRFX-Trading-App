import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/service/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegolRepository extends GetxController {
  RxBool isLoading = false.obs;
  RxString responseMessage = "".obs;
  final AuthService authService = Get.find<AuthService>();
  String passwordMeta5 = "";
  static const String _step2 = 'regol/accountType';
  static const String _step3 = 'regol/profilePerusahaan';
  static const String _step4 = 'regol/pernyataanSimulasi';
  static const String _step5 = 'regol/pernyataanPengalaman';
  static const String _step6 = 'regol/pernyataanPengungkapan_1';
  static const String _step7 = 'regol/aplikasiPembukaanRekening';
  static const String _step8 = 'regol/pernyataanPengungkapan_2';
  static const String _step9 = 'regol/formulirDokumenResiko';
  static const String _step10 = 'regol/pernyataanPengungkapan_3';
  static const String _step11 = 'regol/perjanjianPemberianAmanat';
  static const String _step12 = 'regol/peraturanPerdagangan';
  static const String _step13 = 'regol/pernyataanBertanggungJawab';
  static const String _step14 = 'regol/pernyataanDanaNasabah';
  static const String _step15 = 'regol/pernyataanPengungkapan_4';
  static const String _step16 = 'regol/kelengkapanFormulir';
  DateTime now = DateTime.now();
  String? formattedDate;

  // Create Demo Trading API
  Future<bool> step2({String? accountType, String? cddType, int? skipRegol}) async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.post(_step2, {
        'account-type' : accountType,
        'cdd-type': cddType,
        'skip_regol': skipRegol.toString(),
        'password': passwordMeta5,
      });
      isLoading(false);
      print(accountType);
      print(cddType);
      print(passwordMeta5);
      print(result);
      responseMessage(result['message']);
      if (result['status'] != true) {
        return false;
      }
      return true;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }

  Future<bool> step3() async {
    try {
      isLoading(true);
      formattedDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(now);
      Map<String, dynamic> result = await authService.post(_step3, {
        'aggree' : 'Ya',
        'agg_date': formattedDate
      });
      print(formattedDate);
      isLoading(false);
      responseMessage(result['message']);
      print(result);
      // responseMessage(result['alert']['title']);
      if (result['status']) {
        return true;
      }
      return false;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }

  Future<bool> step4({
    String? statement,
    String? namaLengkap,
    String? tempatLahir,
    String? tanggalLahir,
    String? alamatRumah,
    String? provinsi,
    String? kabupatenKota,
    String? kecamatan,
    String? desa,
    String? kodePos,
    String? rw,
    String? rt,
    String? tipeIdentitas,
    String? nomorIdentitas,
  }) async {
    try {
      final requiredFields = {
        'Nama Lengkap': namaLengkap,
        'Tempat Lahir': tempatLahir,
        'Tanggal Lahir': tanggalLahir,
        'Alamat Rumah': alamatRumah,
        'Provinsi': provinsi,
        'Kabupaten/Kota': kabupatenKota,
        'Kecamatan': kecamatan,
        'Desa': desa,
        'Tipe Identitas': tipeIdentitas,
        'Nomor Identitas': nomorIdentitas,
      };
      final emptyFields = requiredFields.entries.where((entry) => (entry.value ?? '').trim().isEmpty).map((e) => e.key).toList();
      if (emptyFields.isNotEmpty) {
        responseMessage('Harap isi semua kolom berikut: ${emptyFields.join(', ')}');
        return false;
      }
      final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      isLoading(true);
      final result = await authService.post(_step4, {
        'aggree': 'Ya',
        'agg_date': formattedDate,
        'smls_namleng': namaLengkap,
        'smls_tmptlhr': tempatLahir,
        'smls_tgllhr': tanggalLahir,
        'smls_almtrmh': alamatRumah,
        'smls_almtrmh_prov': provinsi,
        'smls_almtrmh_kabkot': kabupatenKota,
        'smls_almtrmh_kcmtn': kecamatan,
        'smls_almtrmh_desa': desa,
        'smls_kodepos': kodePos,
        'smls_almtrmh_rw': rw,
        'smls_almtrmh_rt': rt,
        'smls_tipeidt': tipeIdentitas,
        'smls_nomidt': nomorIdentitas,
      });
      isLoading(false);
      Get.log(result.toString());
      responseMessage(result['message'] ?? 'Terjadi kesalahan');
      // responseMessage(result['alert']?['title'] ?? 'Terjadi kesalahan');
      return result['status'] == true;
    } catch (e) {
      isLoading(false);
      responseMessage('Terjadi error: $e');
      return false;
    }
  }

  Future<bool> step5({String? namaPerusahaan, String? pengalamanInvestasi}) async {
    try {
      isLoading(true);
      formattedDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(now);
      Map<String, dynamic> result = await authService.post(_step5, {
        'aggree': 'Ya',
        'agg_date': formattedDate,
        'pengalaman': pengalamanInvestasi,
        'perusahaan': pengalamanInvestasi == "Ya" || pengalamanInvestasi == "YA" || pengalamanInvestasi == "ya" ? namaPerusahaan : ""
      });
      isLoading(false);
      responseMessage(result['message']);
      Get.log(result.toString());
      // responseMessage(result['alert']['title']);
      if (result['status']) {
        return true;
      }
      return false;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }

  Future<bool> step6() async {
    try {
      isLoading(true);
      formattedDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(now);
      Map<String, dynamic> result = await authService.post(_step6, {
        'aggree' : 'Ya',
        'agg_date': formattedDate
      });
      Get.log(result.toString());
      isLoading(false);
      responseMessage(result['message']);
      // responseMessage(result['alert']['title']);
      if (result['status']) {
        return true;
      }
      return false;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }

  Future<bool> step7({
  String? imagecover1,
  String? imagecover2, // opsional
  String? appImage1, // NPWP / Rekening Koran / Rekening Listrik
  String? appFotoTerbaru, // Selfi
  String? appImage3, // opsional
  String? appImage4, // opsional
  String? appFotoIdentitas, // KTP
  String? nomorNPWP,
  String? jenisKelamin,
  String? namaIbu,
  String? statusPerkawinan,
  String? namaIstri,
  String? telpRumah,
  String? faksimiliRumah,
  String? phoneCode,
  String? noHandphone,
  String? statusKepemilikanRumah,
  String? tujuanPembukaanRekening,
  String? pengalamanInvestasi,
  String? bidangInvestasi,
  String? daruratNama,
  String? daruratAlamat,
  String? daruratKodePos,
  String? daruratTelp,
  String? daruratHubungan,
  String? pekerjaan,
  String? namaPerusahaan,
  String? bidangUsaha,
  String? jabatanPekerjaan,
  String? lamaBekerja,
  String? lamaBekerjaSebelumnya,
  String? alamatKantor,
  String? kodePosKantor,
  String? noKantor,
  String? faxKantor,
  String? penghasilan,
  String? lokasiRumah,
  String? nilaiNJOP,
  String? depositBank,
  String? kekayaanLainnya,
  String? kekayaanNilai,
  String? jumlah,
  String? bankName1,
  String? bankName2,
  String? bankNumber1,
  String? bankNumber2,
}) async {
  try {
    final requiredFields = {
      'Nomor NPWP': nomorNPWP,
      'Jenis Kelamin': jenisKelamin,
      'Nama Ibu': namaIbu,
      'Status Perkawinan': statusPerkawinan,
      'Nomor Handphone': noHandphone,
      'Status Kepemilikan Rumah': statusKepemilikanRumah,
      'Tujuan Pembukaan Rekening': tujuanPembukaanRekening,
      'Nama Darurat': daruratNama,
      'Pekerjaan': pekerjaan,
      'Nama Perusahaan': namaPerusahaan,
      'Bidang Usaha': bidangUsaha,
      'Jabatan': jabatanPekerjaan,
      'Lama Bekerja': lamaBekerja,
      'Alamat Kantor': alamatKantor,
      'Penghasilan': penghasilan,
      'Foto Identitas': appFotoIdentitas,
      'NPWP / Rekening Koran / Rekening Listrik': appImage1,
      'Foto Selfi': appFotoTerbaru,
    };
    final emptyFields = requiredFields.entries.where((e) => (e.value ?? '').trim().isEmpty).map((e) => e.key).toList();
    if (emptyFields.isNotEmpty) {
      responseMessage(
        'Harap isi semua kolom berikut: ${emptyFields.join(', ')}',
      );
      return false;
    }
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final Map<String, String?> rawData = {
      'aggree': 'Ya',
      'agg_date': formattedDate,
      'app_npwp': nomorNPWP,
      'app_gender': jenisKelamin,
      'app_nama_ibu': namaIbu,
      'app_status_perkawinan': statusPerkawinan,
      'acc_app_nama_istri': namaIstri ?? '',
      'app_telepon_rumah': telpRumah ?? '',
      'app_faksimili_rumah': faksimiliRumah ?? '',
      'phone_code': phoneCode ?? '+62',
      'app_no_handphone': noHandphone,
      'app_status_rumah': statusKepemilikanRumah,
      'app_tujuan_pembukaan_rek': tujuanPembukaanRekening,
      'app_pengalaman_investasi': pengalamanInvestasi ?? 'Tidak',
      'bidang_investasi': bidangInvestasi ?? 'Forex',
      'app_darurat_nama': daruratNama,
      'app_darurat_alamat': daruratAlamat,
      'app_darurat_kodepos': daruratKodePos ?? '',
      'app_darurat_telepon': daruratTelp ?? '',
      'app_darurat_hubungan': daruratHubungan ?? '-',
      'app_pekerjaan': pekerjaan,
      'app_nama_perusahaan': namaPerusahaan,
      'app_bidang_usaha': bidangUsaha,
      'app_jabatan_pekerjaan': jabatanPekerjaan,
      'app_lama_bekerja': lamaBekerja,
      'app_lama_bekerja_sebelumnya': lamaBekerjaSebelumnya ?? '',
      'app_alamat_kantor': alamatKantor,
      'app_kodepos_kantor': kodePosKantor,
      'app_nomor_kantor': noKantor ?? '',
      'app_nomor_fax_kantor': faxKantor ?? '',
      'app_penghasilan': penghasilan,
      'app_lokasi_rumah': lokasiRumah ?? '',
      'app_nilai_njop': nilaiNJOP ?? '',
      'app_deposit_bank': depositBank ?? '',
      'app_kekayaan_lainnya': kekayaanLainnya ?? '',
      'app_jumlah': jumlah ?? '',
      'bank_name1': bankName1 ?? '',
      'bank_name2': bankName2 ?? '',
      'bank_number1': bankNumber1 ?? '',
      'bank_number2': bankNumber2 ?? '',
    };
    final data = rawData.map((key, value) => MapEntry(key, value ?? ''));
    final Map<String, String> files = {};
    void addFile(String key, String? path) {
      if (path == null || path.isEmpty) return;
      if (path.startsWith('http')) {
        data[key] = path;
      } else {
        files[key] = path;
      }
    }
    addFile('imagecover1', imagecover1);
    addFile('imagecover2', imagecover2); // opsional
    addFile('app_image_1', appImage1);
    addFile('app_foto_terbaru', appFotoTerbaru); // SELFI
    addFile('app_image_3', appImage3); // opsional
    addFile('app_image_4', appImage4); // opsional
    addFile('app_foto_identitas', appFotoIdentitas); // KTP

    print('Files yang dikirim: $files');

    // 🔹 Kirim request ke API
    isLoading(true);
    final result = await authService.multipart(_step7, data, files);
    print(result);
    isLoading(false);

    // 🔹 Pesan hasil dari server
    responseMessage(result['message'] ?? result['alert']?['title'] ?? 'Terjadi kesalahan');

    return result['status'] == true;
  } catch (e) {
    isLoading(false);
    print(e.toString());
    responseMessage('Terjadi error: $e');
    return false;
  }
}


  Future<bool> step8() async {
    try {
      isLoading(true);
      formattedDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(now);
      Map<String, dynamic> result = await authService.post(_step8, {
        'aggree' : 'Ya',
        'agg_date': formattedDate
      });
      isLoading(false);
      responseMessage(result['message']);
      // responseMessage(result['alert']['title']);
      if (result['status']) {
        return true;
      }
      return false;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }

  Future<bool> step9() async {
    try {
      isLoading(true);
      formattedDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(now);
      Map<String, dynamic> result = await authService.post(_step9, {
        'aggree' : 'Ya',
        'agg_date': formattedDate,
        'agreement': "Ya",
      });
      responseMessage(result['message']);
      if (result['status']) {
        return true;
      }
      return false;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }

  Future<bool> step9A({
    String? kantorPenyelesaian,
    String? kotaPenyelesaian,
  }) async {
    try {
      isLoading(true);
      final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');
      if (accessToken == null) {
        Get.log("Access Token NULL");
        isLoading(false);
        return false;
      }
      var uri = Uri.parse("${GlobalVariable.mainURL}/$_step9");
      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll({
        'x-api-key': GlobalVariable.x_api_key,
        'Authorization': 'Bearer $accessToken',
      });
      request.fields.addAll({
        'aggree': 'YA',
        'agg_date': formattedDate,
        'agreement': 'true', // dikirim sebagai string, bukan boolean
      });
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var result = jsonDecode(responseBody);
      Get.log(result.toString());
      isLoading(false);
      responseMessage(result['message'] ?? '');
      if (result['status'] == true) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      Get.log("Error step11A: $e");
      return false;
    }
  }

  Future<bool> step10() async {
    try {
      isLoading(true);
      formattedDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(now);
      Map<String, dynamic> result = await authService.post(_step10, {
        'aggree' : 'Ya',
        'agg_date': formattedDate
      });
      isLoading(false);
      responseMessage(result['message']);
      // responseMessage(result['alert']['title']);
      if (result['status']) {
        return true;
      }
      return false;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }

  Future<bool> step11({String? kantorPenyelesaian, String? kotaPenyelesaian}) async {
    try {
      isLoading(true);
      formattedDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(now);
      Map<String, dynamic> result = await authService.post(_step11, {
        'aggree' : 'Ya',
        'agg_date': formattedDate,
        'agreement': "Ya",
        'step07_kotapenyelesaian': kotaPenyelesaian,
        'step07_kantorpenyelesaian': kantorPenyelesaian
      });
      isLoading(false);
      responseMessage(result['message']);
      if (result['status']) {
        return true;
      }
      return false;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }

  Future<bool> step11A({
    String? kantorPenyelesaian,
    String? kotaPenyelesaian,
  }) async {
    try {
      isLoading(true);
      final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');
      if (accessToken == null) {
        Get.log("Access Token NULL");
        isLoading(false);
        return false;
      }
      var uri = Uri.parse("${GlobalVariable.mainURL}/$_step11");
      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll({
        'x-api-key': GlobalVariable.x_api_key,
        'Authorization': 'Bearer $accessToken',
      });
      request.fields.addAll({
        'aggree': 'YA',
        'agg_date': formattedDate,
        'agreement': 'true', // dikirim sebagai string, bukan boolean
        'step07_kotapenyelesaian': kotaPenyelesaian ?? '',
        'step07_kantorpenyelesaian': kantorPenyelesaian ?? '',
      });
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var result = jsonDecode(responseBody);
      Get.log(result.toString());
      isLoading(false);
      responseMessage(result['message'] ?? '');
      if (result['status'] == true) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      Get.log("Error step11A: $e");
      return false;
    }
  }


  Future<bool> step12() async {
    try {
      isLoading(true);
      formattedDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(now);
      Map<String, dynamic> result = await authService.post(_step12, {
        'aggree' : 'Ya',
        'agg_date': formattedDate
      });
      isLoading(false);
      responseMessage(result['message']);
      if (result['status']) {
        return true;
      }
      return false;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }

  Future<bool> step13() async {
    try {
      isLoading(true);
      formattedDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(now);
      Map<String, dynamic> result = await authService.post(_step13, {
        'aggree' : 'Ya',
        'agg_date': formattedDate
      });
      isLoading(false);
      responseMessage(result['message']);
      Get.log(result.toString());
      if (result['status']) {
        return true;
      }
      return false;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }

  Future<bool> step14() async {
    try {
      isLoading(true);
      formattedDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(now);
      Map<String, dynamic> result = await authService.post(_step14, {
        'aggree' : 'Ya',
        'agg_date': formattedDate
      });
      isLoading(false);
      responseMessage(result['message']);
      // responseMessage(result['alert']['title']);
      if (result['status']) {
        return true;
      }
      return false;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }

  Future<bool> step15() async {
    try {
      isLoading(true);
      formattedDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(now);
      Map<String, dynamic> result = await authService.post(_step15, {
        'aggree' : 'Ya',
        'agg_date': formattedDate
      });
      isLoading(false);
      responseMessage(result['message']);
      // responseMessage(result['alert']['title']);
      if (result['status']) {
        return true;
      }
      return false;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }

  Future<bool> step16() async {
    try {
      isLoading(true);
      formattedDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(now);
      Map<String, dynamic> result = await authService.post(_step16, {
        'aggree' : 'Ya',
        'agg_date': formattedDate
      });
      isLoading(false);
      responseMessage(result['message']);
      // responseMessage(result['alert']['title']);
      if (result['status']) {
        return true;
      }
      return false;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }
}