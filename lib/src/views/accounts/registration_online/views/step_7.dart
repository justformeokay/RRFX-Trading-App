import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:rrfx/src/components/alerts/scaffold_messanger_alert.dart';
import 'package:rrfx/src/service/step7_cache_service.dart';
import 'package:rrfx/src/components/appbars/default.dart';
import 'package:rrfx/src/components/bottomsheets/material_bottom_sheets.dart';
import 'package:rrfx/src/components/buttons/custom_buttons.dart';
import 'package:rrfx/src/components/colors/default.dart';
import 'package:rrfx/src/components/containers/utilities.dart';
import 'package:rrfx/src/components/tables/pernyataan_persetujuan.dart';
import 'package:rrfx/src/components/textfields/descriptive_textfield.dart';
import 'package:rrfx/src/components/textfields/name_text_field_new.dart';
import 'package:rrfx/src/components/textfields/name_textfield.dart';
import 'package:rrfx/src/components/textfields/number_textfield.dart';
import 'package:rrfx/src/components/textfields/void_textfield.dart';
import 'package:rrfx/src/components/textstyles/default.dart';
import 'package:rrfx/src/controllers/home.dart';
import 'package:rrfx/src/controllers/regol.dart';
import 'package:rrfx/src/controllers/setting.dart';
import 'package:rrfx/src/controllers/utilities.dart';
import 'package:rrfx/src/controllers/wilayah_controller.dart';
import 'package:rrfx/src/helpers/handlers/image_picker.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/views/accounts/registration_online/components/agreement_bappebti.dart';
import 'package:rrfx/src/views/accounts/registration_online/components/button_next_previous.dart';
import 'package:rrfx/src/views/accounts/registration_online/components/expanded_listtile.dart';
import 'package:rrfx/src/views/accounts/registration_online/components/phone_utils.dart';
import 'package:rrfx/src/views/accounts/registration_online/components/time_and_statement.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/progress_account_controller.dart';
// import 'package:rrfx/src/views/accounts/registration_online/controllers/progress_account_controller.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/statement_controller.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/upload_controller.dart';
import 'package:rrfx/src/views/accounts/registration_online/repository/regol_repository.dart';
import 'package:rrfx/src/views/accounts/registration_online/views/step_8.dart';

class Step7 extends StatefulWidget {
  const Step7({super.key});

  @override
  State<Step7> createState() => _Step7State();
}

class _Step7State extends State<Step7> {
  // ProgressAccountController progressAccountController = Get.put(ProgressAccountController());
  final RegolRepository _regolRepository = Get.find<RegolRepository>();
  final progressController = Get.find<ProgressAccountController>();
  final uploadController = Get.put(UploadController());
  final multipleController = Get.put(MultiUploadController());

  // DATA PRIBADI
  TextEditingController nama = TextEditingController();
  TextEditingController tempatLahir= TextEditingController();
  TextEditingController tanggalLahir= TextEditingController();
  TextEditingController alamatRumah = TextEditingController();
  TextEditingController provinsi = TextEditingController();
  TextEditingController kabupatenKota = TextEditingController();
  TextEditingController kecamatan = TextEditingController();
  TextEditingController desa = TextEditingController();
  TextEditingController nomorNPWP = TextEditingController();
  TextEditingController kodePos = TextEditingController();
  TextEditingController rt = TextEditingController();
  TextEditingController rw = TextEditingController();
  TextEditingController pendidikanTerakhir = TextEditingController();
  TextEditingController negara = TextEditingController();
  TextEditingController tipeIdentitas = TextEditingController();
  TextEditingController jenisKelamin = TextEditingController();
  TextEditingController noIdentitas = TextEditingController();
  TextEditingController namaIbuKandung = TextEditingController();
  TextEditingController statusPerkawinan = TextEditingController();
  TextEditingController namaPasangan = TextEditingController();
  TextEditingController statusKepemilikanRumahController = TextEditingController();
  TextEditingController noTelpRumah = TextEditingController();
  TextEditingController noFaksimiliRumah = TextEditingController();
  TextEditingController noHandphone = TextEditingController();
  TextEditingController tujuanPembukaanRekening = TextEditingController();
  TextEditingController tujuanPembukaanRekeningIfLainnya = TextEditingController();
  TextEditingController pengalamanInvestasi = TextEditingController();
  TextEditingController bidangInvestasi = TextEditingController();


  // PIHAK YANG DAPAT DIHUBUNGI DALAM KEADAAN DARURAT
  TextEditingController namaKontakDarurat = TextEditingController();
  TextEditingController alamatRumahDarurat = TextEditingController();
  TextEditingController kodePosKontakDarurat = TextEditingController();
  TextEditingController noTelpKontakDarurat = TextEditingController();
  TextEditingController hubunganKontakDarurat = TextEditingController();

  // PEKERJAAN
  TextEditingController pekerjaanSaya = TextEditingController();
  TextEditingController namaPerusahaan = TextEditingController();
  TextEditingController bidangUsaha = TextEditingController();
  TextEditingController jabatan = TextEditingController();
  TextEditingController lamaBekerja = TextEditingController();
  TextEditingController lamaBekerjaKantorSebelumnya = TextEditingController();
  TextEditingController alamatKantor = TextEditingController();
  TextEditingController kodePosKantor = TextEditingController();
  TextEditingController noTelpKantor = TextEditingController();
  TextEditingController noFaksimiliKantor = TextEditingController();

  // DAFTAR KEKAYAAN
  TextEditingController sumberPenghasilan = TextEditingController();
  TextEditingController penghasilanPerTahun = TextEditingController();
  TextEditingController lokasiRumah = TextEditingController();
  TextEditingController nilaiNJOP = TextEditingController();
  TextEditingController depositBank = TextEditingController();
  TextEditingController kekayaanLainnya = TextEditingController();
  TextEditingController jumlahKekayaan = TextEditingController();

  // REKENING BANK
  RxBool showBank2 = false.obs;
  RxList<dynamic> daftarBank = <String>[].obs;
  TextEditingController namaBank1 = TextEditingController();
  TextEditingController namaPemilikRekening1 = TextEditingController();
  TextEditingController noRekening1 = TextEditingController();
  RxString coverBukuTabungan1 = "".obs;

  TextEditingController namaBank2 = TextEditingController();
  TextEditingController namaPemilikRekening2 = TextEditingController();
  TextEditingController noRekening2 = TextEditingController();
  RxString coverBukuTabungan2 = "".obs;

  // Controller
  RegolController regolController = Get.find();
  UtilitiesController utilitiesController = Get.put(UtilitiesController());
  WilayahController wilayahController = Get.put(WilayahController());
  HomeController userController = Get.find();
  SettingController settingController = Get.put(SettingController());

  // Variable Dokumen Dilampirkan
  RxString bukuRekeningKoran = "".obs;
  RxString rekeningListrik = "".obs;
  RxString npwp = "".obs;
  RxString dokumenLainnya1 = "".obs;
  RxString dokumenLainnya2 = "".obs;

  bool agree1 = true;
  bool agree2 = true;

  RxString simulasiAkunDemoURL = "".obs;
  RxBool isLoading = false.obs;
  RxBool selectedStatement = true.obs;
  RxBool imageLoaded = false.obs;

  // File size variables
  RxString coverBukuTabungan1Size = "".obs;
  RxString coverBukuTabungan2Size = "".obs;

  // Flag to prevent saving during initial load
  bool _isInitializing = true;

  /// Save all form data to local cache
  void _saveToCache() {
    if (_isInitializing) return; // Don't save during initialization
    
    final data = {
      // DATA PRIBADI
      'pendidikanTerakhir': pendidikanTerakhir.text,
      'nomorNPWP': nomorNPWP.text,
      'namaIbuKandung': namaIbuKandung.text,
      'statusPerkawinan': statusPerkawinan.text,
      'namaPasangan': namaPasangan.text,
      'statusKepemilikanRumah': statusKepemilikanRumahController.text,
      'noTelpRumah': noTelpRumah.text,
      'noFaksimiliRumah': noFaksimiliRumah.text,
      'noHandphone': noHandphone.text,
      'tujuanPembukaanRekening': tujuanPembukaanRekening.text,
      'tujuanPembukaanRekeningIfLainnya': tujuanPembukaanRekeningIfLainnya.text,
      'pengalamanInvestasi': pengalamanInvestasi.text,
      'bidangInvestasi': bidangInvestasi.text,
      
      // PIHAK YANG DAPAT DIHUBUNGI DALAM KEADAAN DARURAT
      'namaKontakDarurat': namaKontakDarurat.text,
      'alamatRumahDarurat': alamatRumahDarurat.text,
      'kodePosKontakDarurat': kodePosKontakDarurat.text,
      'noTelpKontakDarurat': noTelpKontakDarurat.text,
      'hubunganKontakDarurat': hubunganKontakDarurat.text,
      
      // PEKERJAAN
      'pekerjaanSaya': pekerjaanSaya.text,
      'namaPerusahaan': namaPerusahaan.text,
      'bidangUsaha': bidangUsaha.text,
      'jabatan': jabatan.text,
      'lamaBekerja': lamaBekerja.text,
      'lamaBekerjaKantorSebelumnya': lamaBekerjaKantorSebelumnya.text,
      'alamatKantor': alamatKantor.text,
      'kodePosKantor': kodePosKantor.text,
      'noTelpKantor': noTelpKantor.text,
      'noFaksimiliKantor': noFaksimiliKantor.text,
      
      // DAFTAR KEKAYAAN
      'sumberPenghasilan': sumberPenghasilan.text,
      'penghasilanPerTahun': penghasilanPerTahun.text,
      'lokasiRumah': lokasiRumah.text,
      'nilaiNJOP': nilaiNJOP.text,
      'depositBank': depositBank.text,
      'kekayaanLainnya': kekayaanLainnya.text,
      'jumlahKekayaan': jumlahKekayaan.text,
      
      // REKENING BANK
      'showBank2': showBank2.value,
      'namaBank1': namaBank1.text,
      'namaPemilikRekening1': namaPemilikRekening1.text,
      'noRekening1': noRekening1.text,
      'namaBank2': namaBank2.text,
      'namaPemilikRekening2': namaPemilikRekening2.text,
      'noRekening2': noRekening2.text,
    };
    
    Step7CacheService.saveFormData(data);
  }

  /// Load cached data into form fields
  void _loadFromCache() {
    final cachedData = Step7CacheService.loadFormData();
    if (cachedData == null) return;
    
    setState(() {
      // DATA PRIBADI
      if (cachedData['pendidikanTerakhir']?.isNotEmpty == true) {
        pendidikanTerakhir.text = cachedData['pendidikanTerakhir'];
      }
      if (cachedData['nomorNPWP']?.isNotEmpty == true) {
        nomorNPWP.text = cachedData['nomorNPWP'];
      }
      if (cachedData['namaIbuKandung']?.isNotEmpty == true) {
        namaIbuKandung.text = cachedData['namaIbuKandung'];
      }
      if (cachedData['statusPerkawinan']?.isNotEmpty == true) {
        statusPerkawinan.text = cachedData['statusPerkawinan'];
      }
      if (cachedData['namaPasangan']?.isNotEmpty == true) {
        namaPasangan.text = cachedData['namaPasangan'];
      }
      if (cachedData['statusKepemilikanRumah']?.isNotEmpty == true) {
        statusKepemilikanRumahController.text = cachedData['statusKepemilikanRumah'];
      }
      if (cachedData['noTelpRumah']?.isNotEmpty == true) {
        noTelpRumah.text = cachedData['noTelpRumah'];
      }
      if (cachedData['noFaksimiliRumah']?.isNotEmpty == true) {
        noFaksimiliRumah.text = cachedData['noFaksimiliRumah'];
      }
      if (cachedData['noHandphone']?.isNotEmpty == true) {
        noHandphone.text = cachedData['noHandphone'];
      }
      if (cachedData['tujuanPembukaanRekening']?.isNotEmpty == true) {
        tujuanPembukaanRekening.text = cachedData['tujuanPembukaanRekening'];
      }
      if (cachedData['tujuanPembukaanRekeningIfLainnya']?.isNotEmpty == true) {
        tujuanPembukaanRekeningIfLainnya.text = cachedData['tujuanPembukaanRekeningIfLainnya'];
      }
      if (cachedData['pengalamanInvestasi']?.isNotEmpty == true) {
        pengalamanInvestasi.text = cachedData['pengalamanInvestasi'];
      }
      if (cachedData['bidangInvestasi']?.isNotEmpty == true) {
        bidangInvestasi.text = cachedData['bidangInvestasi'];
      }
      
      // PIHAK YANG DAPAT DIHUBUNGI DALAM KEADAAN DARURAT
      if (cachedData['namaKontakDarurat']?.isNotEmpty == true) {
        namaKontakDarurat.text = cachedData['namaKontakDarurat'];
      }
      if (cachedData['alamatRumahDarurat']?.isNotEmpty == true) {
        alamatRumahDarurat.text = cachedData['alamatRumahDarurat'];
      }
      if (cachedData['kodePosKontakDarurat']?.isNotEmpty == true) {
        kodePosKontakDarurat.text = cachedData['kodePosKontakDarurat'];
      }
      if (cachedData['noTelpKontakDarurat']?.isNotEmpty == true) {
        noTelpKontakDarurat.text = cachedData['noTelpKontakDarurat'];
      }
      if (cachedData['hubunganKontakDarurat']?.isNotEmpty == true) {
        hubunganKontakDarurat.text = cachedData['hubunganKontakDarurat'];
      }
      
      // PEKERJAAN
      if (cachedData['pekerjaanSaya']?.isNotEmpty == true) {
        pekerjaanSaya.text = cachedData['pekerjaanSaya'];
      }
      if (cachedData['namaPerusahaan']?.isNotEmpty == true) {
        namaPerusahaan.text = cachedData['namaPerusahaan'];
      }
      if (cachedData['bidangUsaha']?.isNotEmpty == true) {
        bidangUsaha.text = cachedData['bidangUsaha'];
      }
      if (cachedData['jabatan']?.isNotEmpty == true) {
        jabatan.text = cachedData['jabatan'];
      }
      if (cachedData['lamaBekerja']?.isNotEmpty == true) {
        lamaBekerja.text = cachedData['lamaBekerja'];
      }
      if (cachedData['lamaBekerjaKantorSebelumnya']?.isNotEmpty == true) {
        lamaBekerjaKantorSebelumnya.text = cachedData['lamaBekerjaKantorSebelumnya'];
      }
      if (cachedData['alamatKantor']?.isNotEmpty == true) {
        alamatKantor.text = cachedData['alamatKantor'];
      }
      if (cachedData['kodePosKantor']?.isNotEmpty == true) {
        kodePosKantor.text = cachedData['kodePosKantor'];
      }
      if (cachedData['noTelpKantor']?.isNotEmpty == true) {
        noTelpKantor.text = cachedData['noTelpKantor'];
      }
      if (cachedData['noFaksimiliKantor']?.isNotEmpty == true) {
        noFaksimiliKantor.text = cachedData['noFaksimiliKantor'];
      }
      
      // DAFTAR KEKAYAAN
      if (cachedData['sumberPenghasilan']?.isNotEmpty == true) {
        sumberPenghasilan.text = cachedData['sumberPenghasilan'];
      }
      if (cachedData['penghasilanPerTahun']?.isNotEmpty == true) {
        penghasilanPerTahun.text = cachedData['penghasilanPerTahun'];
      }
      if (cachedData['lokasiRumah']?.isNotEmpty == true) {
        lokasiRumah.text = cachedData['lokasiRumah'];
      }
      if (cachedData['nilaiNJOP']?.isNotEmpty == true) {
        nilaiNJOP.text = cachedData['nilaiNJOP'];
      }
      if (cachedData['depositBank']?.isNotEmpty == true) {
        depositBank.text = cachedData['depositBank'];
      }
      if (cachedData['kekayaanLainnya']?.isNotEmpty == true) {
        kekayaanLainnya.text = cachedData['kekayaanLainnya'];
      }
      if (cachedData['jumlahKekayaan']?.isNotEmpty == true) {
        jumlahKekayaan.text = cachedData['jumlahKekayaan'];
      }
      
      // REKENING BANK
      if (cachedData['showBank2'] == true) {
        showBank2.value = true;
      }
      if (cachedData['namaBank1']?.isNotEmpty == true) {
        namaBank1.text = cachedData['namaBank1'];
      }
      if (cachedData['namaPemilikRekening1']?.isNotEmpty == true) {
        namaPemilikRekening1.text = cachedData['namaPemilikRekening1'];
      }
      if (cachedData['noRekening1']?.isNotEmpty == true) {
        noRekening1.text = cachedData['noRekening1'];
      }
      if (cachedData['namaBank2']?.isNotEmpty == true) {
        namaBank2.text = cachedData['namaBank2'];
      }
      if (cachedData['namaPemilikRekening2']?.isNotEmpty == true) {
        namaPemilikRekening2.text = cachedData['namaPemilikRekening2'];
      }
      if (cachedData['noRekening2']?.isNotEmpty == true) {
        noRekening2.text = cachedData['noRekening2'];
      }
    });
  }

  /// Add listeners to all controllers to auto-save on changes
  void _addCacheListeners() {
    // DATA PRIBADI
    pendidikanTerakhir.addListener(_saveToCache);
    nomorNPWP.addListener(_saveToCache);
    namaIbuKandung.addListener(_saveToCache);
    statusPerkawinan.addListener(_saveToCache);
    namaPasangan.addListener(_saveToCache);
    statusKepemilikanRumahController.addListener(_saveToCache);
    noTelpRumah.addListener(_saveToCache);
    noFaksimiliRumah.addListener(_saveToCache);
    noHandphone.addListener(_saveToCache);
    tujuanPembukaanRekening.addListener(_saveToCache);
    tujuanPembukaanRekeningIfLainnya.addListener(_saveToCache);
    pengalamanInvestasi.addListener(_saveToCache);
    bidangInvestasi.addListener(_saveToCache);
    
    // PIHAK YANG DAPAT DIHUBUNGI DALAM KEADAAN DARURAT
    namaKontakDarurat.addListener(_saveToCache);
    alamatRumahDarurat.addListener(_saveToCache);
    kodePosKontakDarurat.addListener(_saveToCache);
    noTelpKontakDarurat.addListener(_saveToCache);
    hubunganKontakDarurat.addListener(_saveToCache);
    
    // PEKERJAAN
    pekerjaanSaya.addListener(_saveToCache);
    namaPerusahaan.addListener(_saveToCache);
    bidangUsaha.addListener(_saveToCache);
    jabatan.addListener(_saveToCache);
    lamaBekerja.addListener(_saveToCache);
    lamaBekerjaKantorSebelumnya.addListener(_saveToCache);
    alamatKantor.addListener(_saveToCache);
    kodePosKantor.addListener(_saveToCache);
    noTelpKantor.addListener(_saveToCache);
    noFaksimiliKantor.addListener(_saveToCache);
    
    // DAFTAR KEKAYAAN
    sumberPenghasilan.addListener(_saveToCache);
    penghasilanPerTahun.addListener(_saveToCache);
    lokasiRumah.addListener(_saveToCache);
    nilaiNJOP.addListener(_saveToCache);
    depositBank.addListener(_saveToCache);
    kekayaanLainnya.addListener(_saveToCache);
    jumlahKekayaan.addListener(_saveToCache);
    
    // REKENING BANK
    namaBank1.addListener(_saveToCache);
    namaPemilikRekening1.addListener(_saveToCache);
    noRekening1.addListener(_saveToCache);
    namaBank2.addListener(_saveToCache);
    namaPemilikRekening2.addListener(_saveToCache);
    noRekening2.addListener(_saveToCache);
  }

  /// Remove all cache listeners
  void _removeCacheListeners() {
    // DATA PRIBADI
    pendidikanTerakhir.removeListener(_saveToCache);
    nomorNPWP.removeListener(_saveToCache);
    namaIbuKandung.removeListener(_saveToCache);
    statusPerkawinan.removeListener(_saveToCache);
    namaPasangan.removeListener(_saveToCache);
    statusKepemilikanRumahController.removeListener(_saveToCache);
    noTelpRumah.removeListener(_saveToCache);
    noFaksimiliRumah.removeListener(_saveToCache);
    noHandphone.removeListener(_saveToCache);
    tujuanPembukaanRekening.removeListener(_saveToCache);
    tujuanPembukaanRekeningIfLainnya.removeListener(_saveToCache);
    pengalamanInvestasi.removeListener(_saveToCache);
    bidangInvestasi.removeListener(_saveToCache);
    
    // PIHAK YANG DAPAT DIHUBUNGI DALAM KEADAAN DARURAT
    namaKontakDarurat.removeListener(_saveToCache);
    alamatRumahDarurat.removeListener(_saveToCache);
    kodePosKontakDarurat.removeListener(_saveToCache);
    noTelpKontakDarurat.removeListener(_saveToCache);
    hubunganKontakDarurat.removeListener(_saveToCache);
    
    // PEKERJAAN
    pekerjaanSaya.removeListener(_saveToCache);
    namaPerusahaan.removeListener(_saveToCache);
    bidangUsaha.removeListener(_saveToCache);
    jabatan.removeListener(_saveToCache);
    lamaBekerja.removeListener(_saveToCache);
    lamaBekerjaKantorSebelumnya.removeListener(_saveToCache);
    alamatKantor.removeListener(_saveToCache);
    kodePosKantor.removeListener(_saveToCache);
    noTelpKantor.removeListener(_saveToCache);
    noFaksimiliKantor.removeListener(_saveToCache);
    
    // DAFTAR KEKAYAAN
    sumberPenghasilan.removeListener(_saveToCache);
    penghasilanPerTahun.removeListener(_saveToCache);
    lokasiRumah.removeListener(_saveToCache);
    nilaiNJOP.removeListener(_saveToCache);
    depositBank.removeListener(_saveToCache);
    kekayaanLainnya.removeListener(_saveToCache);
    jumlahKekayaan.removeListener(_saveToCache);
    
    // REKENING BANK
    namaBank1.removeListener(_saveToCache);
    namaPemilikRekening1.removeListener(_saveToCache);
    noRekening1.removeListener(_saveToCache);
    namaBank2.removeListener(_saveToCache);
    namaPemilikRekening2.removeListener(_saveToCache);
    noRekening2.removeListener(_saveToCache);
  }

  // Helper function to get file size in KB
  String getFileSizeInKB(String filePath) {
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

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await progressController.fetchProgressAccount();
      nama.text = progressController.progressData.value?.response?.namaLengkap ?? userController.profileModel.value?.name ?? '';
      negara.text = userController.profileModel.value?.country ?? '';
      if(negara.text.isEmpty || negara.text == ""){
        negara.text = progressController.progressData.value?.response?.kewarganegaraan ?? 'Indonesia';
      }
      
      tipeIdentitas.text = progressController.progressData.value?.response?.idType ?? '-';
      noIdentitas.text = progressController.progressData.value?.response?.idNumber ?? '-';
      tempatLahir.text = progressController.progressData.value?.response?.placeOfBirth ?? '-';
      tanggalLahir.text = progressController.progressData.value?.response?.dateOfBirth ?? '-';
      sumberPenghasilan.text = progressController.progressData.value?.response?.sumberPenghasilan ?? '';
      pendidikanTerakhir.text = progressController.progressData.value?.response?.pendidikanTerakhir ?? '';
      regolController.isLoading(true);
      nomorNPWP.text = progressController.progressData.value?.response?.npwp ?? '';
      jenisKelamin.text = progressController.progressData.value?.response?.gender ?? '';
      namaPasangan.text = progressController.progressData.value?.response?.wifeHusbandName ?? '';
      statusPerkawinan.text = progressController.progressData.value?.response?.maritalStatus ?? '';
      statusKepemilikanRumahController.text = progressController.progressData.value?.response?.statusRumah ?? '';
      rt.text = progressController.progressData.value?.response?.rt ?? '';
      rw.text = progressController.progressData.value?.response?.rw ?? '';
      alamatRumah.text = progressController.progressData.value?.response?.address ?? "";
      provinsi.text = progressController.progressData.value?.response?.province ?? "";
      kabupatenKota.text = progressController.progressData.value?.response?.city ?? "";
      kecamatan.text = progressController.progressData.value?.response?.district ?? "";
      desa.text = progressController.progressData.value?.response?.village ?? "";
      kodePos.text = progressController.progressData.value?.response?.postalCode ?? "";
      setState(() {
        tujuanPembukaanRekening.text = progressController.progressData.value?.response?.tujuanInvestasi ?? "Spekulasi";
        if(tujuanPembukaanRekening.text != "Lindung Nilai" || tujuanPembukaanRekening.text != "Gain" || tujuanPembukaanRekening.text != "Spekulasi"){
          tujuanPembukaanRekening.text = "Lainnya";
          tujuanPembukaanRekeningIfLainnya.text = progressController.progressData.value?.response?.tujuanInvestasi ?? "";
        }
      });
      namaIbuKandung.text = progressController.progressData.value?.response?.motherName ?? "";
      noHandphone.text = userController.profileModel.value?.phone ?? "";
      noTelpRumah.text = progressController.progressData.value?.response?.phoneHome ?? "";
      noFaksimiliRumah.text = progressController.progressData.value?.response?.faxHome ?? "";
      setState(() {
        pengalamanInvestasi.text = progressController.progressData.value?.response?.pengalamanInvestasi ?? '';
        if(pengalamanInvestasi.text == "Ya" || pengalamanInvestasi.text == "ya" || pengalamanInvestasi.text == "YA"){
          bidangInvestasi.text = progressController.progressData.value?.response?.pengalamanInvestasiBidang ?? 'Forex';
        }
      });
      namaPerusahaan.text = progressController.progressData.value?.response?.kerjaNama ?? ""; 
      pekerjaanSaya.text = progressController.progressData.value?.response?.kerjaTipe ?? "";
      bidangUsaha.text = progressController.progressData.value?.response?.kerjaBidang ?? "";
      jabatan.text = progressController.progressData.value?.response?.kerjaJabatan ?? "";
      lamaBekerja.text = progressController.progressData.value?.response?.kerjaLama ?? "";
      lamaBekerjaKantorSebelumnya.text = progressController.progressData.value?.response?.kerjaLamaSebelum ?? "";
      alamatKantor.text = progressController.progressData.value?.response?.kerjaAlamat ?? "";
      kodePosKantor.text = progressController.progressData.value?.response?.kerjaZip ?? "";
      noFaksimiliKantor.text = progressController.progressData.value?.response?.kerjaFax ?? "";
      namaKontakDarurat.text = progressController.progressData.value?.response?.drrtName ?? "";
      alamatRumahDarurat.text = progressController.progressData.value?.response?.drrtAddress ?? "";
      kodePosKontakDarurat.text = progressController.progressData.value?.response?.daruratPostalCode ?? "";
      noTelpKontakDarurat.text = progressController.progressData.value?.response?.drrtPhone ?? "";
      hubunganKontakDarurat.text = progressController.progressData.value?.response?.drrtStatus ?? "";
      lokasiRumah.text = progressController.progressData.value?.response?.kekayaanRumahLokasi ?? "";
      nilaiNJOP.text = progressController.progressData.value?.response?.kekayaanNjop ?? "";
      depositBank.text = progressController.progressData.value?.response?.kekayaanDeposit ?? "";
      kekayaanLainnya.text = progressController.progressData.value?.response?.kekayaanLain ?? "";
      penghasilanPerTahun.text = progressController.progressData.value?.response?.kekayaan ?? "";
      jumlahKekayaan.text = progressController.progressData.value?.response?.kekayaanNilai ?? "";
      wilayahController.getProvinsi().then((resultProvince){
        if(!resultProvince){
          CustomScaffoldMessanger.showAppSnackBar(context, message: wilayahController.responseMessage.value, type: SnackBarType.error);
        }
      });
      utilitiesController.getBankList().then((resultGetBankList){
        for(int i = 0; i < resultGetBankList.length; i++){
          daftarBank.add(resultGetBankList[i]);
        }
      });
      namaPemilikRekening1.text = (settingController.userBankModel.value?.response?.isNotEmpty ?? false)
                ? settingController.userBankModel.value!.response![0].name ?? ''
                : nama.text = progressController.progressData.value?.response?.namaLengkap ?? '';
      settingController.getUserBank().then((responseGetBankUser){
        if(settingController.userBankModel.value?.response != null){
          namaBank1.text = (settingController.userBankModel.value?.response?.isNotEmpty ?? false) ? settingController.userBankModel.value!.response![0].name ?? '' : userController.profileModel.value?.name ?? '';
          namaPemilikRekening1.text = settingController.userBankModel.value?.response?[0].holder ?? "";
          noRekening1.text = settingController.userBankModel.value?.response?[0].account ?? "";
          coverBukuTabungan1.value = settingController.userBankModel.value?.response?[0].image ?? '';
          if(coverBukuTabungan1.value.isNotEmpty) {
            imageLoaded.value = true;
          }
          
          if(settingController.userBankModel.value!.response!.length > 1){
            showBank2.value = true;
            namaBank2.text = settingController.userBankModel.value?.response?[1].name ?? "";
            namaPemilikRekening2.text = settingController.userBankModel.value?.response?[1].holder ?? "";
            noRekening2.text = settingController.userBankModel.value?.response?[1].account ?? "";
            coverBukuTabungan2.value = settingController.userBankModel.value?.response?[1].image ?? '';
          }
        }
      });
      multipleController.initFromApi({
        'appFotoImage1': progressController.progressData.value?.response?.appFotoIdentitas, // NPWP
        'appFotoImage2': progressController.progressData.value?.response?.appFotoImage1, // KTP
        'appFotoImage3': progressController.progressData.value?.response?.appFotoTerbaru, // Selfi
        'appFotoImage4': progressController.progressData.value?.response?.appFotoImage3,
        'appFotoImage5': progressController.progressData.value?.response?.appFotoImage4,
      });
      
      // Load cached data (overrides API data if exists)
      _loadFromCache();
      
      // Add listeners for auto-save after initial load
      _addCacheListeners();
      _isInitializing = false;
      
      regolController.isLoading(false);
    });
  }

  @override
  void dispose() {
    // Remove cache listeners before disposing
    _removeCacheListeners();
    
    nama.dispose();
    tempatLahir.dispose();
    tanggalLahir.dispose();
    jenisKelamin.dispose();
    alamatRumah.dispose();
    provinsi.dispose();
    negara.dispose();
    kabupatenKota.dispose();
    kecamatan.dispose();
    desa.dispose();
    kodePos.dispose();
    rt.dispose();
    rw.dispose();
    pendidikanTerakhir.dispose();
    sumberPenghasilan.dispose();
    nomorNPWP.dispose();
    tipeIdentitas.dispose();
    noIdentitas.dispose();
    namaIbuKandung.dispose();
    statusPerkawinan.dispose();
    namaPasangan.dispose();
    noFaksimiliRumah.dispose();
    noTelpRumah.dispose();
    noHandphone.dispose();
    tujuanPembukaanRekening.dispose();
    tujuanPembukaanRekeningIfLainnya.dispose();
    statusKepemilikanRumahController.dispose();
    pengalamanInvestasi.dispose();
    bidangInvestasi.dispose();
    
    // Darurat
    namaKontakDarurat.dispose();
    alamatRumahDarurat.dispose();
    kodePosKontakDarurat.dispose();
    noTelpKontakDarurat.dispose();
    hubunganKontakDarurat.dispose();

    // Pekerjaan
    pekerjaanSaya.dispose();
    namaPerusahaan.dispose();
    bidangUsaha.dispose();
    jabatan.dispose();
    lamaBekerja.dispose();
    lamaBekerjaKantorSebelumnya.dispose();
    alamatKantor.dispose();
    kodePosKantor.dispose();
    noTelpKantor.dispose();
    noFaksimiliKantor.dispose();

    // Kekayaan
    penghasilanPerTahun.dispose();
    lokasiRumah.dispose();
    nilaiNJOP.dispose();
    depositBank.dispose();
    kekayaanLainnya.dispose();
    jumlahKekayaan.dispose();

    // Rekening Bank
    namaBank1.dispose();
    namaBank2.dispose();
    namaPemilikRekening1.dispose();
    namaPemilikRekening2.dispose();
    noRekening1.dispose();
    noRekening2.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final controller = Get.put(StatementController());
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar.defaultAppBar(
          autoImplyLeading: true,
          title: "Step 7"
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText.titleHeadingPage(context, text: "APLIKASI PEMBUKAAN TRANSAKSI SECARA ELEKTRONIK ONLINE"),
                const SizedBox(height: 10.0),
                const Divider(height: 1, thickness: 0.5),
                const SizedBox(height: 10.0),
                SmoothExpansionTile(
                  title: "DATA PRIBADI",
                  initiallyExpanded: true,
                  children: [
                    NameTextFieldNewVersion(
                      requiredField: true,
                      controller: nama,
                      readOnly: true,
                      useStringOnly: true,
                      labelText: "Nama Lengkap",
                      fieldName: "Nama Lengkap",
                      hintText: "Mohon isi Nama Lengkap",
                      maxLength: 50,
                    ),
                    
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: NameTextFieldNewVersion(
                            requiredField: true,
                            readOnly: true,
                            iconData: CupertinoIcons.placemark,
                            controller: tempatLahir,
                            labelText: "Tempat Lahir",
                            useStringOnly: true,
                            fieldName: "Tempat Lahir",
                            hintText: "Tempat Lahir",
                            maxLength: 20,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: VoidTextField(
                            requiredField: true,
                            readOnly: true,
                            iconData: Clarity.calendar_line,
                            controller: tanggalLahir,
                            labelText: "Tanggal Lahir",
                            fieldName: "Tanggal Lahir",
                            hintText: "Tanggal Lahir",
                            onPressed: (){},
                          ),
                        ),
                      ],
                    ),
                    DescriptiveTextField(
                      readOnly: true,
                      requiredField: true,
                      useValidator: false,
                      iconData: Clarity.home_line,
                      controller: alamatRumah,
                      labelText: "Alamat Rumah",
                      fieldName: "Alamat Rumah",
                      hintText: "Input Alamat Rumah",
                    ),
                    const SizedBox(height: 10.0),
                    // Negara
                    VoidTextField(requiredField: true, controller: negara, fieldName: "Negara", hintText: "Negara", labelText: "Negara", iconData: Clarity.map_line, onPressed: (){}, readOnly: true),

                    // Province
                    VoidTextField(requiredField: true, controller: provinsi, fieldName: "Provinsi", hintText: "Provinsi", labelText: "Provinsi", iconData: Clarity.map_line, onPressed: (){}, readOnly: true),

                    // Kabupaten
                    VoidTextField(requiredField: true, controller: kabupatenKota, fieldName: "Kabupaten", hintText: "Kabupaten", labelText: "Kabupaten", iconData: Clarity.map_line, onPressed: (){}, readOnly: true),

                    // Kecamatan
                    VoidTextField(requiredField: true, controller: kecamatan, fieldName: "Kecamatan", hintText: "Kecamatan", labelText: "Kecamatan", iconData: Clarity.map_line, onPressed: (){}, readOnly: true),

                    // Desa
                    VoidTextField(requiredField: true, controller: desa, fieldName: "Desa", iconData: Icons.holiday_village_rounded, hintText: "Desa", labelText: "Desa", onPressed: (){}, readOnly: true),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: NumberTextField(
                            useValidator: false,
                            readOnly: true,
                            iconData: Clarity.number_list_line,
                            controller: rt,
                            labelText: "RT",
                            fieldName: "RT",
                            hintText: "RT",
                            maxLength: 3,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: NumberTextField(
                            useValidator: false,
                            readOnly: true,
                            iconData: Clarity.number_list_line,
                            controller: rw,
                            labelText: "RW",
                            fieldName: "RW",
                            hintText: "RW",
                            maxLength: 3,
                          ),
                        ),
                      ],
                    ),

                    // Tipe Identitas
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 83,
                          width: size.width / 3,
                          child: NumberTextField(
                            requiredField: true,
                            useValidator: false,
                            readOnly: true,
                            iconData: Clarity.number_list_line,
                            controller: kodePos,
                            labelText: "Kode Pos",
                            fieldName: "Kode Pos",
                            hintText: "Kode Pos",
                            maxLength: 5,
                            minLength: 5,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: VoidTextField(requiredField: true, controller: tipeIdentitas, fieldName: "Tipe Identitas", iconData: EvaIcons.credit_card, hintText: "Tipe Identitas", labelText: "Tipe Identitas", onPressed: (){}),
                        ),
                      ],
                    ),
                     NumberTextField(
                      requiredField: true,
                      useValidator: false,
                      iconData: Clarity.number_list_line,
                      controller: noIdentitas,
                      readOnly: true,
                      labelText: "Nomor Identitas",
                      fieldName: "Nomor Identitas",
                      hintText: "Nomor Identitas",
                      maxLength: 16,
                    ),

                    VoidTextField(requiredField: true, controller: pendidikanTerakhir, fieldName: "Pendidikan Terakhir", hintText: "Pendidikan Terakhir", labelText: "Pendidikan Terakhir", readOnly: false, iconData: Iconsax.clipboard_outline, onPressed: (){
                      final listPendidikanTerakhir = progressController.progressData.value?.data?.listPendidikan ?? [];
                      CustomMaterialBottomSheets.defaultBottomSheet(context, title: "Pilih Pendidikan Terakhir", size: size, children: List.generate(listPendidikanTerakhir.length, (i){
                        return ListTile(
                          leading: Icon(Icons.check_circle, 
                            color: (pendidikanTerakhir.text == listPendidikanTerakhir[i])
                              ? CustomColor.secondaryColor
                              : Colors.grey,
                              size: 22),
                          title: Text(listPendidikanTerakhir[i]),
                          onTap: () {
                            setState(() {
                              pendidikanTerakhir.text = listPendidikanTerakhir[i];
                            });
                            Get.back();
                          },
                        );
                      }));
                    }),
                    NumberTextField(
                      requiredField: true,
                      useValidator: false,
                      iconData: Clarity.number_list_line,
                      controller: nomorNPWP,
                      readOnly: false,
                      minLength: 16,
                      maxLength: 16,
                      labelText: "Nomor NPWP",
                      fieldName: "Nomor NPWP",
                      hintText: "Nomor NPWP",
                    ),
                    NameTextFieldNewVersion(
                      requiredField: true,
                      controller: namaIbuKandung,
                      readOnly: false,
                      useStringOnly: true,
                      iconData: Iconsax.user_outline,
                      labelText: "Nama Ibu Kandung",
                      fieldName: "Nama Ibu Kandung",
                      hintText: "Nama Ibu Kandung",
                      maxLength: 20,
                    ),
                    Obx(
                      () => VoidTextField(requiredField: true, controller: jenisKelamin, readOnly: false, fieldName: "Jenis Kelamin", hintText: "Jenis Kelamin", labelText: "Jenis Kelamin", iconData: Icons.home_mini, onPressed: regolController.isLoading.value ? null : (){
                        CustomMaterialBottomSheets.defaultBottomSheet(context, title: "Pilih Jenis Kelamin", size: size, children: List.generate(GlobalVariable.genderIndo.length, (i){
                          return ListTile(
                            leading: Icon(Icons.check_circle,
                                color: (jenisKelamin.text == GlobalVariable.genderIndo[i])
                                    ? CustomColor.secondaryColor
                                    : Colors.grey,
                                size: 22),
                            title: Text(GlobalVariable.genderIndo[i]),
                            onTap: () {
                              setState(() {
                                jenisKelamin.text = GlobalVariable.genderIndo[i];
                              });
                              Get.back();
                            },
                          );
                        }));
                      }),
                    ),
                    Obx(
                      () => VoidTextField(requiredField: true, controller: statusPerkawinan, readOnly: false, fieldName: "Status Perkawinan", hintText: "Status Perkawinan", labelText: "Status Perkawinan", iconData: Icons.home_mini, onPressed: regolController.isLoading.value ? null : (){
                        CustomMaterialBottomSheets.defaultBottomSheet(context, title: "Pilih Status Perkawinan", size: size, children: List.generate(GlobalVariable.maritalIndoVersion.length, (i){
                          return ListTile(
                            leading: Icon(Icons.check_circle,
                                color: (statusPerkawinan.text == GlobalVariable.maritalIndoVersion[i])
                                    ? CustomColor.secondaryColor
                                    : Colors.grey,
                                size: 22),
                            title: Text(GlobalVariable.maritalIndoVersion[i]),
                            onTap: () {
                              setState(() {
                                statusPerkawinan.text = GlobalVariable.maritalIndoVersion[i];
                              });
                              Get.back();
                            },
                          );
                        }));
                      }),
                    ),
                    statusPerkawinan.text == "Kawin" || statusPerkawinan.text == "Menikah" ? NameTextFieldNewVersion(
                      controller: namaPasangan,
                      readOnly: false,
                      useStringOnly: true,
                      labelText: "Nama Suami/Istri",
                      fieldName: "Nama Suami/Istri",
                      hintText: "Nama Suami/Istri",
                      maxLength: 20,
                    ) : const SizedBox(),
                    NumberTextField(
                      requiredField: true,
                      iconData: Icons.phone_android_rounded,
                      controller: noHandphone,
                      readOnly: false,
                      labelText: "No. Handphone",
                      fieldName: "No. Handphone",
                      hintText: "No. Handphone",
                      maxLength: 14,
                      minLength: 10,
                    ),
                    NumberTextField(
                      iconData: Icons.phone_android_rounded,
                      controller: noTelpRumah,
                      readOnly: false,
                      labelText: "No. Telp Rumah (Opsional)",
                      fieldName: "No. Telp Rumah (Opsional)",
                      hintText: "No. Telp Rumah (Opsional)",
                      maxLength: 20,
                    ),
                    NumberTextField(
                      iconData: Icons.phone_android_rounded,
                      controller: noFaksimiliRumah,
                      readOnly: false,
                      labelText: "No. Faksimili Rumah (Opsional)",
                      fieldName: "No. Faksimili Rumah (Opsional)",
                      hintText: "No. Faksimili Rumah (Opsional)",
                      maxLength: 20,
                    ),
                    Obx(
                      () => VoidTextField(requiredField: true, controller: statusKepemilikanRumahController, readOnly: false, fieldName: "Status Kepemilikan Rumah", hintText: "Status Kepemilikan Rumah", labelText: "Status Kepemilikan Rumah", iconData: Icons.home_mini, onPressed: regolController.isLoading.value ? null : (){
                        CustomMaterialBottomSheets.defaultBottomSheet(context, title: "Pilih Status Kepemilikan Rumah", size: size, children: List.generate(GlobalVariable.statusKepemilikanRumah.length, (i){
                          return ListTile(
                            leading: Icon(Icons.check_circle,
                                color: (statusKepemilikanRumahController.text == GlobalVariable.statusKepemilikanRumah[i])
                                    ? CustomColor.secondaryColor
                                    : Colors.grey,
                                size: 22),
                            title: Text(GlobalVariable.statusKepemilikanRumah[i]),
                            onTap: () {
                              statusKepemilikanRumahController.text = GlobalVariable.statusKepemilikanRumah[i];
                              Get.back();
                            },
                          );
                        }));
                      }),
                    ),

                    Obx(
                      () => VoidTextField(requiredField: true, controller: tujuanPembukaanRekening, readOnly: false, fieldName: "Tujuan Pembukaan Rekening", hintText: "Tujuan Pembukaan Rekening", labelText: "Tujuan Pembukaan Rekening", iconData: Icons.home_mini, onPressed: regolController.isLoading.value ? null : (){
                        CustomMaterialBottomSheets.defaultBottomSheet(context, title: "Pilih Tujuan Pembukaan Rekening", size: size, children: List.generate(GlobalVariable.investmentGoalIndonesia.length, (i){
                          return ListTile(
                            leading: Icon(Icons.check_circle,
                                color: (tujuanPembukaanRekening.text == GlobalVariable.investmentGoalIndonesia[i])
                                    ? CustomColor.secondaryColor
                                    : Colors.grey,
                                size: 22),
                            title: Text(GlobalVariable.investmentGoalIndonesia[i]),
                            onTap: () {
                              setState(() {
                                tujuanPembukaanRekening.text = GlobalVariable.investmentGoalIndonesia[i];
                              });
                              Get.back();
                            },
                          );
                        }));
                      }),
                    ),

                    tujuanPembukaanRekening.text == "Lainnya" ? NameTextField(
                      requiredField: true,
                      controller: tujuanPembukaanRekeningIfLainnya,
                      readOnly: false,
                      labelText: "Tujuan Pembukaan Rekening",
                      fieldName: "Tujuan Pembukaan Rekening",
                      hintText: "Tujuan Pembukaan Rekening",
                      maxLength: 20,
                    ) : const SizedBox(),

                    Obx(
                      () => VoidTextField(requiredField: true, controller: pengalamanInvestasi, readOnly: false, fieldName: "Pengalaman Investasi", hintText: "Pengalaman Investasi", labelText: "Pengalaman Investasi", iconData: Icons.home_mini, onPressed: regolController.isLoading.value ? null : (){
                        CustomMaterialBottomSheets.defaultBottomSheet(context, title: "Pilih Pengalaman Investasi", size: size, children: List.generate(GlobalVariable.investExperienceIndo.length, (i){
                          return ListTile(
                            leading: Icon(Icons.check_circle,
                                color: (pengalamanInvestasi.text == GlobalVariable.investExperienceIndo[i])
                                    ? CustomColor.secondaryColor
                                    : Colors.grey,
                                size: 22),
                            title: Text(GlobalVariable.investExperienceIndo[i]),
                            onTap: () {
                              setState(() {
                                pengalamanInvestasi.text = GlobalVariable.investExperienceIndo[i];
                              });
                              Get.back();
                            },
                          );
                        }));
                      }),
                    ),

                    pengalamanInvestasi.text == "Ya" || pengalamanInvestasi.text == "YA" || pengalamanInvestasi.text == "ya" ? NameTextField(
                      requiredField: true,
                      controller: bidangInvestasi,
                      readOnly: false,
                      labelText: "Bidang Investasi",
                      fieldName: "Bidang Investasi",
                      hintText: "Bidang Investasi",
                      useValidator: true,
                      maxLength: 20,
                    ) : const SizedBox(),

                    AgreementCheckTile(
                      value: agree1,
                      enabled: false,
                      text: "Saya menyetujui bahwa tidak memiliki anggota keluarga yang bekerja di BAPPEBTI / Bursa Berjangka / Kliring Berjangka",
                      onChanged: (v) {
                        setState(() => agree1 = v);
                      },
                    ),

                    AgreementCheckTile(
                      value: agree2,
                      enabled: false,
                      text: "Saya menyetujui bahwa tidak dinyatakan pailit oleh Pengadilan",
                      onChanged: (v) {
                        setState(() => agree2 = v);
                      },
                    ),
                  ],
                ),
                SmoothExpansionTile(title: "PIHAK YANG DAPAT DIHUBUNGI DALAM KEADAAN DARURAT", children: [
                  NameTextFieldNewVersion(
                    requiredField: true,
                    controller: namaKontakDarurat,
                    readOnly: false,
                    useStringOnly: true,
                    labelText: "Nama Kontak Darurat",
                    fieldName: "Nama Kontak Darurat",
                    hintText: "Mohon isi Nama Kontak Darurat",
                    maxLength: 20,
                  ),
                  DescriptiveTextField(
                    readOnly: false,
                    requiredField: true,
                    useValidator: false,
                    iconData: Clarity.home_line,
                    controller: alamatRumahDarurat,
                    labelText: "Alamat Rumah Kontak Darurat",
                    fieldName: "Alamat Rumah Kontak Darurat",
                    hintText: "Input Alamat Rumah Kontak Darurat",
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 83,
                        width: size.width / 3,
                        child: NumberTextField(
                          useValidator: false,
                          readOnly: false,
                          iconData: Clarity.number_list_line,
                          controller: kodePosKontakDarurat,
                          labelText: "Kode Pos (Opsional)",
                          fieldName: "Kode Pos (Opsional)",
                          hintText: "Kode Pos (Opsional)",
                          maxLength: 5,
                          minLength: 5,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: NumberTextField(
                          requiredField: true,
                          controller: noTelpKontakDarurat, fieldName: "No. Telp Kontak Darurat", iconData: EvaIcons.credit_card, hintText: "No. Telp Kontak Darurat", labelText: "No. Telp Kontak Darurat", maxLength: 14, minLength: 10),
                      ),
                    ],
                  ),
                  Obx(() {
                    final hubunganList = progressController.progressData.value?.data?.jenisHubunganPihakDarurat ?? [];
                    final isLoading = progressController.isLoading.value;
                    return VoidTextField(
                      requiredField: true,
                      controller: hubunganKontakDarurat,
                      readOnly: false,
                      fieldName: "Hubungan Kontak Darurat",
                      hintText: hubunganList.isEmpty
                        ? "Data belum tersedia"
                        : "Pilih Hubungan Kontak Darurat",
                      labelText: "Hubungan Kontak Darurat",
                      iconData: Icons.home_mini,
                      onPressed: isLoading ? null : () {
                        if (hubunganList.isEmpty) {
                          CustomScaffoldMessanger.showAppSnackBar(
                            context,
                            message: "Data hubungan kontak darurat tidak ditemukan",
                            type: SnackBarType.info,
                          );
                          return;
                        }
                        CustomMaterialBottomSheets.defaultBottomSheet(
                          context,
                          title: "Pilih Hubungan Kontak Darurat Anda",
                          size: size,
                          children: List.generate(hubunganList.length, (i) {
                            final item = hubunganList[i];
                            return ListTile(
                              leading: Icon(Icons.check_circle,
                                  color: (hubunganKontakDarurat.text == item)
                                      ? CustomColor.secondaryColor
                                      : Colors.grey,
                                  size: 22),
                              title: Text(item),
                              onTap: () {
                                hubunganKontakDarurat.text = item;
                                Navigator.pop(context);
                                setState(() {}); // update UI lokal
                              },
                            );
                          }),
                        );
                      },
                    );
                  }),
                ]),
                SmoothExpansionTile(title: "PEKERJAAN", children: [
                  Obx(() {
                    final pekerjaan = progressController.progressData.value?.data?.listPekerjaan ?? [];
                    final isLoading = progressController.isLoading.value;
                    return VoidTextField(
                      requiredField: true,
                      controller: pekerjaanSaya,
                      readOnly: false,
                      fieldName: "Daftar Pekerjaan",
                      hintText: pekerjaan.isEmpty
                        ? "Data belum tersedia"
                        : "Pilih Pekerjaan Anda",
                      labelText: "Pilih Pekerjaan Anda",
                      iconData: Icons.home_mini,
                      onPressed: isLoading ? null : () {
                        if (pekerjaan.isEmpty) {
                          CustomScaffoldMessanger.showAppSnackBar(
                            context,
                            message: "Data pekerjaan tidak ditemukan",
                            type: SnackBarType.info,
                          );
                          return;
                        }
                        CustomMaterialBottomSheets.defaultBottomSheet(
                          context,
                          title: "Pilih Pekerjaan Anda",
                          size: size,
                          children: List.generate(pekerjaan.length, (i) {
                            final item = pekerjaan[i];
                            return ListTile(
                              leading: Icon(Icons.check_circle,
                                  color: (pekerjaanSaya.text == item)
                                      ? CustomColor.secondaryColor
                                      : Colors.grey,
                                  size: 22),
                              title: Text(item),
                              onTap: () {
                                pekerjaanSaya.text = item;
                                Navigator.pop(context);
                                setState(() {}); // update UI lokal
                              },
                            );
                          }),
                        );
                      },
                    );
                  }),
                  NameTextFieldNewVersion(
                    requiredField: true,
                    controller: namaPerusahaan,
                    readOnly: false,
                    labelText: "Nama Perusahaan",
                    fieldName: "Nama Perusahaan",
                    hintText: "Nama Perusahaan",
                    maxLength: 50,
                  ),
                  NameTextFieldNewVersion(
                    requiredField: true,
                    controller: bidangUsaha,
                    readOnly: false,
                    labelText: "Bidang Usaha",
                    fieldName: "Bidang Usaha",
                    hintText: "Bidang Usaha",
                    maxLength: 50,
                  ),
                  NameTextFieldNewVersion(
                    requiredField: true,
                    controller: jabatan,
                    readOnly: false,
                    labelText: "Jabatan",
                    fieldName: "Jabatan",
                    hintText: "Jabatan",
                    maxLength: 50,
                  ),
                  NameTextFieldNewVersion(
                    requiredField: true,
                    controller: lamaBekerja,
                    readOnly: false,
                    labelText: "Lama Bekerja",
                    fieldName: "Lama Bekerja",
                    hintText: "Lama Bekerja",
                    maxLength: 50,
                  ),
                  NameTextFieldNewVersion(
                    requiredField: true,
                    controller: lamaBekerjaKantorSebelumnya,
                    readOnly: false,
                    labelText: "Lama Bekerja (Kantor Sebelumnya)",
                    fieldName: "Lama Bekerja (Kantor Sebelumnya)",
                    hintText: "Lama Bekerja (Kantor Sebelumnya)",
                    maxLength: 50,
                  ),
                  DescriptiveTextField(
                    requiredField: true,
                    readOnly: false,
                    useValidator: false,
                    iconData: Clarity.home_line,
                    controller: alamatKantor,
                    labelText: "Alamat Kantor",
                    fieldName: "Alamat Kantor",
                    hintText: "Input Alamat Kantor",
                  ),
                  NumberTextField(
                    useValidator: false,
                    readOnly: false,
                    iconData: Clarity.number_list_line,
                    controller: kodePosKantor,
                    labelText: "Kode Pos (Opsional)",
                    fieldName: "Kode Pos (Opsional)",
                    hintText: "Kode Pos (Opsional)",
                    maxLength: 16,
                  ),
                  NumberTextField(
                    useValidator: false,
                    readOnly: false,
                    iconData: Clarity.mobile_phone_line,
                    controller: noTelpKantor,
                    labelText: "No. Telp Kantor (Opsional)",
                    fieldName: "No. Telp Kantor (Opsional)",
                    hintText: "No. Telp Kantor (Opsional)",
                    maxLength: 16,
                  ),
                  NumberTextField(
                    useValidator: false,
                    readOnly: false,
                    iconData: Icons.fax_outlined,
                    controller: noFaksimiliKantor,
                    labelText: "No. Faksimili Kantor (Opsional)",
                    fieldName: "No. Faksimili Kantor (Opsional)",
                    hintText: "No. Faksimili Kantor (Opsional)",
                    maxLength: 16,
                  ),
                ]),
                SmoothExpansionTile(title: "DAFTAR KEKAYAAN", children: [
                  Obx(() {
                    final pendapatan = progressController.progressData.value?.data?.listSumberPenghasilan ?? [];
                    final isLoading = progressController.isLoading.value;
                    return VoidTextField(
                      requiredField: true,
                      controller: sumberPenghasilan,
                      readOnly: false,
                      fieldName: "Sumber Pendapatan",
                      hintText: pendapatan.isEmpty
                        ? "Data belum tersedia"
                        : "Pilih Sumber Pendapatan Anda",
                      labelText: "Pilih Sumber Pendapatan Anda",
                      iconData: Icons.home_mini,
                      onPressed: isLoading ? null : () {
                        if (pendapatan.isEmpty) {
                          CustomScaffoldMessanger.showAppSnackBar(
                            context,
                            message: "Data sumber pendapatan tidak ditemukan",
                            type: SnackBarType.info,
                          );
                          return;
                        }
                        CustomMaterialBottomSheets.defaultBottomSheet(
                          context,
                          title: "Pilih Sumber Pendapatan Anda",
                          size: size,
                          children: List.generate(pendapatan.length, (i) {
                            final item = pendapatan[i];
                            return ListTile(
                              leading: Icon(Icons.check_circle,
                                  color: (sumberPenghasilan.text == item)
                                      ? CustomColor.secondaryColor
                                      : Colors.grey,
                                  size: 22),
                              title: Text(item),
                              onTap: () {
                                sumberPenghasilan.text = item;
                                Navigator.pop(context);
                                setState(() {}); // update UI lokal
                              },
                            );
                          }),
                        );
                      },
                    );
                  }),
                  Obx(() {
                    final pendapatan = progressController.progressData.value?.data?.listPendapatan ?? [];
                    final isLoading = progressController.isLoading.value;
                    return VoidTextField(
                      requiredField: true,
                      controller: penghasilanPerTahun,
                      readOnly: false,
                      fieldName: "Daftar Pendapatan",
                      hintText: pendapatan.isEmpty
                        ? "Data belum tersedia"
                        : "Pilih Pendapatan Anda per Tahun",
                      labelText: "Pilih Pendapatan Anda",
                      iconData: Icons.home_mini,
                      onPressed: isLoading ? null : () {
                        if (pendapatan.isEmpty) {
                          CustomScaffoldMessanger.showAppSnackBar(
                            context,
                            message: "Data pendapatan tidak ditemukan",
                            type: SnackBarType.info,
                          );
                          return;
                        }
                        CustomMaterialBottomSheets.defaultBottomSheet(
                          context,
                          title: "Pilih Pendapatan Anda per Tahun",
                          size: size,
                          children: List.generate(pendapatan.length, (i) {
                            final item = pendapatan[i];
                            return ListTile(
                              leading: Icon(Icons.check_circle,
                                  color: (penghasilanPerTahun.text == item)
                                      ? CustomColor.secondaryColor
                                      : Colors.grey,
                                  size: 22),
                              title: Text(item),
                              onTap: () {
                                penghasilanPerTahun.text = item;
                                Navigator.pop(context);
                                setState(() {}); // update UI lokal
                              },
                            );
                          }),
                        );
                      },
                    );
                  }),
                  DescriptiveTextField(
                    readOnly: false,
                    requiredField: true,
                    useValidator: false,
                    iconData: Clarity.home_line,
                    controller: lokasiRumah,
                    labelText: "Lokasi Rumah",
                    fieldName: "Lokasi Rumah",
                    hintText: "Input Lokasi Rumah",
                  ),
                  
                  Obx(() {
                    final njop = progressController.progressData.value?.data?.kekayaanNjop ?? [];
                    final isLoading = progressController.isLoading.value;
                    return VoidTextField(
                      controller: nilaiNJOP,
                      readOnly: false,
                      fieldName: "Daftar NJOP (Opsional)",
                      hintText: njop.isEmpty
                        ? "Data belum tersedia"
                        : "Pilih Pendapatan NJOP Anda per Tahun (Opsional)",
                      labelText: "Pilih Pendapatan NJOP Anda (Opsional)",
                      iconData: Icons.home_mini,
                      onPressed: isLoading ? null : () {
                        if (njop.isEmpty) {
                          CustomScaffoldMessanger.showAppSnackBar(
                            context,
                            message: "Data NJOP tidak ditemukan",
                            type: SnackBarType.info,
                          );
                          return;
                        }
                        CustomMaterialBottomSheets.defaultBottomSheet(
                          context,
                          title: "Pilih Pendapatan NJOP Anda per Tahun (Opsional)",
                          size: size,
                          children: List.generate(njop.length, (i) {
                            final item = njop[i];
                            return ListTile(
                              leading: Icon(Icons.check_circle,
                                  color: (nilaiNJOP.text == item)
                                      ? CustomColor.secondaryColor
                                      : Colors.grey,
                                  size: 22),
                              title: Text(item),
                              onTap: () {
                                nilaiNJOP.text = item;
                                Navigator.pop(context);
                                setState(() {}); // update UI lokal
                              },
                            );
                          }),
                        );
                      },
                    );
                  }),
                  Obx(() {
                    final deposito = progressController.progressData.value?.data?.kekayaanDepositBank ?? [];
                    final isLoading = progressController.isLoading.value;
                    return VoidTextField(
                      controller: depositBank,
                      readOnly: false,
                      fieldName: "Daftar Deposito Bank (Opsional)",
                      hintText: deposito.isEmpty
                        ? "Data belum tersedia"
                        : "Pilih Kekayaan Deposito Bank (Opsional)",
                      labelText: "Pilih Kekayaan Deposito Bank Anda (Opsional)",
                      iconData: Icons.home_mini,
                      onPressed: isLoading ? null : () {
                        if (deposito.isEmpty) {
                          CustomScaffoldMessanger.showAppSnackBar(
                            context,
                            message: "Data Deposito Bank tidak ditemukan",
                            type: SnackBarType.info,
                          );
                          return;
                        }
                        CustomMaterialBottomSheets.defaultBottomSheet(
                          context,
                          title: "Pilih Kekayaan Deposito Bank Anda (Opsional)",
                          size: size,
                          children: List.generate(deposito.length, (i) {
                            final item = deposito[i];
                            return ListTile(
                              leading: Icon(Icons.check_circle,
                                  color: (depositBank.text == item)
                                      ? CustomColor.secondaryColor
                                      : Colors.grey,
                                  size: 22),
                              title: Text(item),
                              onTap: () {
                                depositBank.text = item;
                                Navigator.pop(context);
                                setState(() {}); // update UI lokal
                              },
                            );
                          }),
                        );
                      },
                    );
                  }),
                  Obx(() {
                    final kekayaan = progressController.progressData.value?.data?.kekayaanLainnya ?? [];
                    final isLoading = progressController.isLoading.value;
                    return VoidTextField(
                      controller: kekayaanLainnya,
                      readOnly: false,
                      fieldName: "Daftar Kekayaan Lainnya (Opsional)",
                      hintText: kekayaan.isEmpty
                        ? "Data belum tersedia"
                        : "Pilih Kekayaan Lainnya (Opsional)",
                      labelText: "Pilih Kekayaan Lainnya (Opsional)",
                      iconData: Icons.home_mini,
                      onPressed: isLoading ? null : () {
                        if (kekayaan.isEmpty) {
                          CustomScaffoldMessanger.showAppSnackBar(
                            context,
                            message: "Data Daftar Kekayaan Lainnya ditemukan",
                            type: SnackBarType.info,
                          );
                          return;
                        }
                        CustomMaterialBottomSheets.defaultBottomSheet(
                          context,
                          title: "Pilih Kekayaan Lainnya (Opsional)",
                          size: size,
                          children: List.generate(kekayaan.length, (i) {
                            final item = kekayaan[i];
                            return ListTile(
                              leading: Icon(Icons.check_circle,
                                  color: (kekayaanLainnya.text == item)
                                      ? CustomColor.secondaryColor
                                      : Colors.grey,
                                  size: 22),
                              title: Text(item),
                              onTap: () {
                                kekayaanLainnya.text = item;
                                Navigator.pop(context);
                                setState(() {}); // update UI lokal
                              },
                            );
                          }),
                        );
                      },
                    );
                  }),
                  Obx(() {
                    final allKekayaan = progressController.progressData.value?.data?.kekayaanJumlah ?? [];
                    final isLoading = progressController.isLoading.value;
                    return VoidTextField(
                      controller: jumlahKekayaan,
                      readOnly: false,
                      fieldName: "Daftar Jumlah Kekayaan (Opsional)",
                      hintText: allKekayaan.isEmpty
                        ? "Data belum tersedia"
                        : "Pilih Jumlah Kekayaan (Opsional)",
                      labelText: "Pilih Jumlah Kekayaan (Opsional)",
                      iconData: Icons.home_mini,
                      onPressed: isLoading ? null : () {
                        if (allKekayaan.isEmpty) {
                          CustomScaffoldMessanger.showAppSnackBar(
                            context,
                            message: "Data Jumlah Kekayaan tidak ditemukan",
                            type: SnackBarType.info,
                          );
                          return;
                        }
                        CustomMaterialBottomSheets.defaultBottomSheet(
                          context,
                          title: "Pilih Jumlah Kekayaan (Opsional)",
                          size: size,
                          children: List.generate(allKekayaan.length, (i) {
                            final item = allKekayaan[i];
                            return ListTile(
                              leading: Icon(Icons.check_circle,
                                  color: (jumlahKekayaan.text == item)
                                      ? CustomColor.secondaryColor
                                      : Colors.grey,
                                  size: 22),
                              title: Text(item),
                              onTap: () {
                                jumlahKekayaan.text = item;
                                Navigator.pop(context);
                                setState(() {}); // update UI lokal
                              },
                            );
                          }),
                        );
                      },
                    );
                  }),
                ]),
                SmoothExpansionTile(title: "REKENING BANK NASABAH UNTUK PENYETORAN DAN PENARIKAN MARGIN", children: [
                  Obx(
                    () => VoidTextField(requiredField: true, controller: namaBank1, readOnly: false, fieldName: "Nama Bank", hintText: "Nama Bank", labelText: "Nama Bank", iconData: Clarity.bank_line, onPressed: regolController.isLoading.value ? null : (){
                      CustomMaterialBottomSheets.defaultBottomSheet(context, title: "Pilih Nama Bank", size: size, children: List.generate(daftarBank.length, (i){
                        return ListTile(
                          leading: Icon(Icons.check_circle,
                              color: (namaBank1.text == daftarBank[i])
                                  ? CustomColor.secondaryColor
                                  : Colors.grey,
                              size: 22),
                          title: Text(daftarBank[i]),
                          onTap: () {
                            namaBank1.text = daftarBank[i];
                            Get.back();
                          },
                        );
                      }));
                    }),
                  ),
                  NameTextFieldNewVersion(
                    requiredField: true,
                    controller: namaPemilikRekening1,
                    readOnly: false,
                    useStringOnly: true,
                    labelText: "Nama Pemilik Rekening",
                    fieldName: "Nama Pemilik Rekening",
                    hintText: "Nama Pemilik Rekening",
                    maxLength: 50,
                  ),
                  NumberTextField(
                    requiredField: true,
                    useValidator: false,
                    readOnly: false,
                    iconData: Clarity.number_list_line,
                    controller: noRekening1,
                    labelText: "Nomor Rekening",
                    fieldName: "Nomor Rekening",
                    hintText: "Nomor Rekening",
                    maxLength: 16,
                    minLength: 8,
                  ),
                  Row(
                    children: [
                      Text("Cover Buku Rekening 1", style: Get.textTheme.labelLarge),
                      Text(" *", style: Get.textTheme.labelLarge?.copyWith(color: Colors.red  ) ),
                    ],
                  ),
                  const SizedBox(height: 5.0),
                  Obx(
                    () => !isLoading.value ? Obx(
                      () => UtilitiesWidget.uploadPhotoV2(
                        context, 
                        isImageOnline: imageLoaded.value, 
                        title: "Buku Rekening Bank", 
                        urlPhoto: coverBukuTabungan1.value, 
                        ukuranFile: coverBukuTabungan1.value.isNotEmpty ? getFileSizeInKB(coverBukuTabungan1.value) : null,
                        onImageSourceSelected: (useCamera) async {
                          coverBukuTabungan1.value = await CustomImagePicker.pickImageFromCameraAndReturnUrl(useCamera: useCamera);
                          imageLoaded.value = false;
                          coverBukuTabungan1Size.value = getFileSizeInKB(coverBukuTabungan1.value);
                        },
                      ),
                    ) : const SizedBox()
                  ),

                  Obx(() => CustomButtons.buildFilledButton(onPressed: regolController.isLoading.value ? null : (){
                    showBank2.value = !showBank2.value;
                  }, text: showBank2.value ? "Hapus Tambahan Bank" : "Tambah Informasi Bank")),
                  const SizedBox(height: 10.0),

                  Obx(() => showBank2.value ? VoidTextField(controller: namaBank2, readOnly: false, fieldName: "Nama Bank 2 (Opsional)", hintText: "Nama Bank 2 (Opsional)", labelText: "Nama Bank 2 (Opsional)", iconData: Clarity.bank_line, onPressed: regolController.isLoading.value ? null : (){
                    CustomMaterialBottomSheets.defaultBottomSheet(context, title: "Pilih Nama Bank", size: size, children: List.generate(daftarBank.length, (i){
                      return ListTile(
                        title: Text(daftarBank[i]),
                        onTap: () {
                          namaBank2.text = daftarBank[i];
                          Get.back();
                        },
                      );
                    }));
                  }) : const SizedBox()),
                  Obx(() => showBank2.value ? NameTextFieldNewVersion(
                    controller: namaPemilikRekening2,
                    readOnly: false,
                    useStringOnly: true,
                    labelText: "Nama Pemilik Rekening 2 (Opsional)",
                    fieldName: "Nama Pemilik Rekening 2 (Opsional)",
                    hintText: "Nama Pemilik Rekening 2 (Opsional)",
                    maxLength: 50,
                  ) : const SizedBox()),

                  Obx(() => showBank2.value ? NumberTextField(
                    useValidator: false,
                    readOnly: false,
                    iconData: Clarity.number_list_line,
                    controller: noRekening2,
                    labelText: "Nomor Rekening 2 (Opsional)",
                    fieldName: "Nomor Rekening 2 (Opsional)",
                    hintText: "Nomor Rekening 2 (Opsional)",
                    maxLength: 16,
                  ) : const SizedBox()),
                  Text("Cover Buku Rekening 2 (Opsional)", style: Get.textTheme.labelLarge),
                  const SizedBox(height: 5.0),
                  Obx(() => showBank2.value ? UtilitiesWidget.uploadPhotoV2(
                    context, 
                    isImageOnline: imageLoaded.value, 
                    title: "Buku Rekening Bank", 
                    urlPhoto: coverBukuTabungan2.value, 
                    ukuranFile: coverBukuTabungan2.value.isNotEmpty ? getFileSizeInKB(coverBukuTabungan2.value) : null,
                    onImageSourceSelected: (useCamera) async {
                      coverBukuTabungan2.value = await CustomImagePicker.pickImageFromCameraAndReturnUrl(useCamera: useCamera);
                      imageLoaded.value = false;
                      coverBukuTabungan2Size.value = getFileSizeInKB(coverBukuTabungan2.value);
                    },
                  ) : const SizedBox())
                ]),
                SmoothExpansionTile(title: "DOKUMEN YANG DILAMPIRKAN", children: [
                  Obx(() => Column(
                    children: List.generate(multipleController.photoList.length, (index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(multipleController.photoTitles[index], style: Get.textTheme.labelLarge),
                          const SizedBox(height: 5.0),
                          UtilitiesWidget.uploadPhotoV2(
                            context,
                            title: multipleController.photoTitles[index],
                            urlPhoto: multipleController.photoList[index],
                            isImageOnline: multipleController.isOnlineList[index],
                            ukuranFile: multipleController.photoList[index].isNotEmpty && multipleController.fileSizeList.length > index
                                ? multipleController.fileSizeList[index]
                                : null,
                            onImageSourceSelected: (useCamera) => multipleController.pickNewImage(index, useCamera: useCamera),
                          ),
                        ],
                      );
                    }),
                  ))
                ]),
                StatementWidget.aplikasiPembukaanRekeningTransaksi(),
                TimeAndStatement(),
              ],
            ),
          )
        ),
        bottomNavigationBar: Obx(
          () => ButtonNextPrevious(
            onPressed: regolController.isLoading.value
              ? null
              : () async {
                  // Parse phone number
                  String? phoneCode;
                  String? phone;
                  final resultCode = extractPhoneCode(noHandphone.text);
                  if (resultCode['success'] == true) {
                    phoneCode = resultCode['countryCode'];
                    phone = resultCode['nationalNumber'];
                  }

                  // Dokumen Upload
                  final npwpRekeningKoran = multipleController.photoList[0];
                  final fotoIdentitas = multipleController.photoList[1];
                  final fotoSelfiTerbaru = multipleController.photoList[2];
                  final dokumenLainnya1Path = multipleController.photoList[3];
                  final dokumenLainnya2Path = multipleController.photoList[4];

                  // ===================================================================
                  //        📌 FIELD TEXT WAJIB DIISI — AUTO VALIDATION LIST
                  // ===================================================================
                  final requiredFields = [
                    {"value": nomorNPWP.text, "message": "Mohon inputkan NPWP Anda"},
                    {"value": sumberPenghasilan.text, "message": "Mohon inputkan sumber penghasilan"},
                    {"value": pendidikanTerakhir.text, "message": "Mohon inputkan pendidikan terakhir"},
                    {"value": jenisKelamin.text, "message": "Mohon pilih jenis kelamin"},
                    {"value": namaIbuKandung.text, "message": "Mohon inputkan Nama Ibu Kandung"},
                    {"value": statusPerkawinan.text, "message": "Mohon pilih status perkawinan"},
                    {"value": noHandphone.text, "message": "Mohon inputkan nomor HP"},
                    {"value": statusKepemilikanRumahController.text, "message": "Mohon pilih status kepemilikan rumah"},
                    {"value": tujuanPembukaanRekening.text, "message": "Mohon pilih tujuan pembukaan rekening"},
                    {"value": pengalamanInvestasi.text, "message": "Mohon pilih pengalaman investasi"},
                    {"value": namaKontakDarurat.text, "message": "Mohon inputkan nama kontak darurat"},
                    {"value": alamatRumahDarurat.text, "message": "Mohon inputkan alamat rumah kontak darurat"},
                    {"value": noTelpKontakDarurat.text, "message": "Mohon inputkan nomor telp kontak darurat"},
                    {"value": hubunganKontakDarurat.text, "message": "Mohon pilih hubungan kontak darurat"},
                    {"value": pekerjaanSaya.text, "message": "Mohon inputkan pekerjaan anda"},
                    {"value": namaPerusahaan.text, "message": "Mohon inputkan nama perusahaan"},
                    {"value": bidangUsaha.text, "message": "Mohon inputkan bidang usaha"},
                    {"value": jabatan.text, "message": "Mohon inputkan jabatan"},
                    {"value": lamaBekerja.text, "message": "Mohon inputkan lama bekerja"},
                    {"value": lamaBekerjaKantorSebelumnya.text, "message": "Mohon inputkan lama bekerja sebelumnya"},
                    {"value": alamatKantor.text, "message": "Mohon inputkan alamat kantor"},
                    {"value": penghasilanPerTahun.text, "message": "Mohon pilih penghasilan per tahun"},
                    {"value": lokasiRumah.text, "message": "Mohon isi lokasi rumah"},
                    {"value": namaBank1.text, "message": "Mohon pilih Bank Anda"},
                    {"value": namaPemilikRekening1.text, "message": "Mohon isi nama pemilik rekening"},
                    {"value": noRekening1.text, "message": "Mohon isi nomor rekening"},
                  ];

                  // Jalankan validasi tekstual
                  for (var item in requiredFields) {
                    if (item["value"] == null || item["value"].toString().trim().isEmpty) {
                      return AppSnackbar.error(item["message"].toString());
                    }
                  }

                  // if(npwp.value.length < 16){
                  //   return AppSnackbar.error("Nomor NPWP harus terdiri dari 16 digit");
                  // }

                  // ===================================================================
                  //            📌 VALIDASI FOTO / BERKAS WAJIB
                  // ===================================================================

                  if (pengalamanInvestasi.text.toLowerCase() == "ya") {
                    if (bidangInvestasi.text.trim().isEmpty) {
                      return AppSnackbar.error("Mohon isi bidang investasi karena Anda memilih pernah berpengalaman investasi.");
                    }
                  }

                  if (npwpRekeningKoran.isEmpty) {
                    return CustomScaffoldMessanger.showAppSnackBar(
                      context,
                      message: "Mohon unggah foto NPWP / Rekening Koran / Tagihan Listrik",
                    );
                  }
                  if (fotoIdentitas.isEmpty) {
                    return CustomScaffoldMessanger.showAppSnackBar(
                      context,
                      message: "Mohon unggah foto identitas Anda",
                    );
                  }
                  if (fotoSelfiTerbaru.isEmpty) {
                    return CustomScaffoldMessanger.showAppSnackBar(
                      context,
                      message: "Mohon unggah foto selfie terbaru Anda",
                    );
                  }
                  if (coverBukuTabungan1.value.isEmpty) {
                    return CustomScaffoldMessanger.showAppSnackBar(
                      context,
                      message: "Mohon unggah foto buku tabungan Bank 1",
                    );
                  }

                  // ===================================================================
                  //                   📌 VALIDASI BANK KE-2 (OPSIONAL)
                  // ===================================================================
                  if (showBank2.value) {
                    final bank2Required = [
                      {"value": namaBank2.text, "message": "Mohon pilih Bank ke-2"},
                      {"value": namaPemilikRekening2.text, "message": "Mohon isi nama pemilik rekening Bank ke-2"},
                      {"value": noRekening2.text, "message": "Mohon isi nomor rekening Bank ke-2"},
                    ];

                    for (var item in bank2Required) {
                      if (item["value"] == null || item["value"].toString().trim().isEmpty) {
                        return AppSnackbar.error(item["message"].toString());
                      }
                    }

                    if (coverBukuTabungan2.value.isEmpty) {
                      return AppSnackbar.error("Mohon unggah foto buku tabungan Bank ke-2");
                    }
                  }

                  // ===================================================================
                  //                   📌 VALIDSASI CHECKBOX STATEMENT
                  // ===================================================================
                  if (!controller.selectedStatement.value) {
                    return AppSnackbar.error("Mohon centang pernyataan aplikasi pembukaan rekening dan transaksi");
                  }

                  // ===================================================================
                  //                     📌 SUBMIT TO API
                  // ===================================================================
                  bool result = await _regolRepository.step7(
                    kewarganegaraan: negara.text,
                    pendidikanTerakhir: pendidikanTerakhir.text,
                    sumberPenghasilan: sumberPenghasilan.text,
                    alamatKantor: alamatKantor.text,
                    bankName1: namaBank1.text,
                    bankName2: namaBank2.text,
                    bankNumber1: noRekening1.text,
                    bankNumber2: noRekening2.text,
                    bidangInvestasi: bidangInvestasi.text,
                    bidangUsaha: bidangUsaha.text,
                    daruratAlamat: alamatRumahDarurat.text,
                    daruratHubungan: hubunganKontakDarurat.text,
                    daruratKodePos: kodePosKontakDarurat.text,
                    daruratNama: namaKontakDarurat.text,
                    daruratTelp: noTelpKontakDarurat.text,
                    pekerjaan: pekerjaanSaya.text,
                    tujuanPembukaanRekening: tujuanPembukaanRekening.text,
                    telpRumah: noTelpRumah.text,
                    faksimiliRumah: noFaksimiliRumah.text,
                    depositBank: depositBank.text,
                    faxKantor: noFaksimiliKantor.text,
                    jumlah: jumlahKekayaan.text,
                    kekayaanLainnya: kekayaanLainnya.text,
                    kodePosKantor: kodePosKantor.text,
                    lamaBekerja: lamaBekerja.text,
                    jabatanPekerjaan: jabatan.text,
                    lokasiRumah: lokasiRumah.text,
                    namaIbu: namaIbuKandung.text,
                    nilaiNJOP: nilaiNJOP.text,
                    kekayaanNilai: jumlahKekayaan.text,
                    lamaBekerjaSebelumnya: lamaBekerjaKantorSebelumnya.text,
                    statusKepemilikanRumah: statusKepemilikanRumahController.text,
                    penghasilan: penghasilanPerTahun.text,
                    pengalamanInvestasi: pengalamanInvestasi.text,
                    noKantor: noTelpKantor.text,
                    noHandphone: phone ?? noHandphone.text,
                    nomorNPWP: nomorNPWP.text,
                    namaPerusahaan: namaPerusahaan.text,
                    namaIstri: namaPasangan.text,
                    phoneCode: phoneCode ?? "+62",
                    statusPerkawinan: statusPerkawinan.text,
                    jenisKelamin: jenisKelamin.text,
                    appImage1: npwpRekeningKoran,
                    appFotoTerbaru: fotoSelfiTerbaru,
                    appImage3: dokumenLainnya1Path,
                    appImage4: dokumenLainnya2Path,
                    appFotoIdentitas: fotoIdentitas,
                    imagecover1: coverBukuTabungan1.value,
                    imagecover2: coverBukuTabungan2.value,
                  );

                  if (result) {
                    // Clear cached form data after successful submit
                    await Step7CacheService.clearFormData();
                    Get.to(() => const Step8());
                    return;
                  }

                  CustomScaffoldMessanger.showAppSnackBar(
                    context,
                    message: _regolRepository.responseMessage.value,
                    type: SnackBarType.error,
                  );
                },
          ),
        )
      )
    );
  }
}