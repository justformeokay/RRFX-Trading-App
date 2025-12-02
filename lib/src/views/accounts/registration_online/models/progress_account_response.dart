// progress_account_model.dart
class ProgressAccountResponse {
  final bool status;
  final String message;
  final AccountResponse? response;
  final AccountData? data;

  ProgressAccountResponse({
    required this.status,
    required this.message,
    this.response,
    this.data,
  });

  factory ProgressAccountResponse.fromJson(Map<String, dynamic> json) {
    return ProgressAccountResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      response: (json['response'] is Map<String, dynamic>)
          ? AccountResponse.fromJson(json['response'])
          : null,
      data: json['data'] != null ? AccountData.fromJson(json['data']) : null,
    );
  }
}

class AccountResponse {
  final int id;
  final String idHash;
  final String type;
  final String typeAcc;
  final String? idType;
  final String? idNumber;
  final String? appFotoIdentitas;
  final String? appFotoSimulasi;
  final String? appFotoTerbaru;
  final String? appFotoImage1;
  final String? appFotoImage2;
  final String? appFotoImage3;
  final String? appFotoImage4;
  final String? npwp;
  final String? dateOfBirth;
  final String? placeOfBirth;
  final String? gender;
  final String? statusRumah;
  final String? province;
  final String? city;
  final String? district;
  final String? village;
  final String? rt;
  final String? rw;
  final String? address;
  final String? faxHome;
  final String? kerjaFax;
  final String? postalCode;
  final String? maritalStatus;
  final String? motherName;
  final String? phoneNumber;
  final String? phoneHome;
  final String? tujuanInvestasi;
  final String? pengalamanInvestasi;
  final String? pengalamanInvestasiBidang;
  final String? wifeHusbandName;
  final String? pernyataanPailit;
  final String? drrtName;
  final String? drrtStatus;
  final String? drrtPhone;
  final String? drrtAddress;
  final String? kerjaNama;
  final String? keluargaBursa;
  final String? kerjaTipe;
  final String? kerjaBidang;
  final String? kerjaJabatan;
  final String? daruratPostalCode;
  final String? kerjaLamaSebelum;
  final String? kerjaAlamat;
  final String? kerjaLama;
  final String? kerjaZip;
  final String? kerjaTelepon;
  final String? kekayaan;
  final String? kekayaanRumahLokasi;
  final String? kekayaanNjop;
  final String? kekayaanDeposit;
  final String? kekayaanNilai;
  final String? kekayaanLain;
  final String? urlTradingRules;

  AccountResponse({
    required this.id,
    required this.idHash,
    required this.type,
    required this.typeAcc,
    this.urlTradingRules,
    this.idType,
    this.idNumber,
    this.kerjaFax,
    this.appFotoIdentitas,
    this.keluargaBursa,
    this.appFotoSimulasi,
    this.appFotoTerbaru,
    this.appFotoImage1,
    this.appFotoImage2,
    this.appFotoImage3,
    this.appFotoImage4,
    this.npwp,
    this.dateOfBirth,
    this.daruratPostalCode,
    this.wifeHusbandName,
    this.placeOfBirth,
    this.gender,
    this.province,
    this.city,
    this.district,
    this.village,
    this.rt,
    this.rw,
    this.address,
    this.postalCode,
    this.maritalStatus,
    this.statusRumah,
    this.motherName,
    this.phoneNumber,
    this.phoneHome,
    this.tujuanInvestasi,
    this.pengalamanInvestasi,
    this.pengalamanInvestasiBidang,
    this.pernyataanPailit,
    this.drrtName,
    this.kerjaTelepon,
    this.drrtStatus,
    this.drrtPhone,
    this.drrtAddress,
    this.kerjaNama,
    this.kerjaTipe,
    this.kerjaZip,
    this.faxHome,
    this.kerjaBidang,
    this.kerjaLamaSebelum,
    this.kerjaJabatan,
    this.kerjaLama,
    this.kerjaAlamat,
    this.kekayaan,
    this.kekayaanRumahLokasi,
    this.kekayaanNjop,
    this.kekayaanDeposit,
    this.kekayaanNilai,
    this.kekayaanLain,
  });

  factory AccountResponse.fromJson(Map<String, dynamic> json) {
    return AccountResponse(
      id: json['id'] ?? 0,
      idHash: json['id_hash'] ?? '',
      type: json['type'] ?? '',
      typeAcc: json['type_acc'] ?? '',
      idType: json['id_type'],
      idNumber: json['id_number'],
      kerjaFax: json['kerja_fax'],
      kerjaTelepon: json['kerja_telepon'],
      urlTradingRules: json['url_trading_rules'],
      appFotoSimulasi: json['app_foto_simulasi'],
      appFotoIdentitas: json['app_foto_identitas'],
      appFotoTerbaru: json['app_foto_terbaru'],
      appFotoImage1: json['app_foto_image1'],
      appFotoImage2: json['app_foto_image2'],
      appFotoImage3: json['app_foto_image3'],
      appFotoImage4: json['app_foto_image4'],
      npwp: json['npwp'],
      faxHome: json['fax_home'],
      dateOfBirth: json['date_of_birth'],
      placeOfBirth: json['place_of_birth'],
      gender: json['gender'],
      province: json['province'],
      wifeHusbandName: json['wife_husband_name'],
      city: json['city'],
      district: json['district'],
      village: json['village'],
      rt: json['rt'],
      rw: json['rw'],
      address: json['address'],
      postalCode: json['postal_code'],
      maritalStatus: json['marital_status'],
      motherName: json['mother_name'],
      phoneNumber: json['phone_number'],
      phoneHome: json['phone_home'],
      tujuanInvestasi: json['tujuan_investasi'],
      pengalamanInvestasi: json['pengalaman_investasi'],
      pengalamanInvestasiBidang: json['pengalaman_investasi_bidang'],
      pernyataanPailit: json['pernyataan_pailit'],
      drrtName: json['drrt_name'],
      drrtStatus: json['drrt_status'],
      drrtPhone: json['drrt_phone'],
      drrtAddress: json['drrt_address'],
      daruratPostalCode: json['drrt_postal_code'],
      kerjaNama: json['kerja_nama'],
      statusRumah: json['status_rumah'],
      kerjaTipe: json['kerja_tipe'],
      kerjaAlamat: json['kerja_alamat'],
      kerjaLamaSebelum: json['kerja_lama_sebelum'],
      keluargaBursa: json['keluarga_bursa'],
      kerjaBidang: json['kerja_bidang'],
      kerjaJabatan: json['kerja_jabatan'],
      kerjaLama: json['kerja_lama'],
      kerjaZip: json['kerja_zip'],
      kekayaan: json['kekayaan'],
      kekayaanRumahLokasi: json['kekayaan_rumah_lokasi'],
      kekayaanNjop: json['kekayaan_njop'],
      kekayaanDeposit: json['kekayaan_deposit'],
      kekayaanNilai: json['kekayaan_nilai'],
      kekayaanLain: json['kekayaan_lain'],
    );
  }
}

class AccountData {
  List<String>? listPekerjaan;
  List<String>? listPendapatan;
  List<Map<String, String>>? cddTipe;
  Map<String, String>? listKantorPenyelesaian;
  List<String>? listKotaPenyelesaian;
  List<String>? tipeIdentitas;
  List<String>? jenisHubunganPihakDarurat;
  List<String>? kekayaanNjop;
  List<String>? kekayaanDepositBank;
  List<String>? kekayaanLainnya;
  List<String>? kekayaanJumlah;
  bool? alreadyHaveAccount;

  AccountData({
    this.listPekerjaan,
    this.listPendapatan,
    this.cddTipe,
    this.listKantorPenyelesaian,
    this.listKotaPenyelesaian,
    this.tipeIdentitas,
    this.jenisHubunganPihakDarurat,
    this.kekayaanNjop,
    this.kekayaanDepositBank,
    this.kekayaanLainnya,
    this.kekayaanJumlah,
    this.alreadyHaveAccount
  });

  factory AccountData.fromJson(Map<String, dynamic> json) {
    return AccountData(
      listPekerjaan: List<String>.from(json['list_pekerjaan'] ?? []),
      listPendapatan: List<String>.from(json['list_pendapatan'] ?? []),
      cddTipe: (json['cdd_tipe'] as List?)?.map((e) => Map<String, String>.from(e)).toList() ?? [],
      listKantorPenyelesaian: Map<String, String>.from(json['list_kantor_penyelesaian'] ?? {}),
      listKotaPenyelesaian: List<String>.from(json['list_kota_penyelesaian'] ?? []),
      tipeIdentitas: (json['tipe_identitas'] as List?)?.map((e) => e.toString()).toList(),
      jenisHubunganPihakDarurat: (json['jenis_hubungan_pihak_darurat'] as List?)?.map((e) => e.toString()).toList() ?? [],
      kekayaanNjop: List<String>.from(json['kekayaan_njop'] ?? []),
      kekayaanDepositBank: List<String>.from(json['kekayaan_deposit_bank'] ?? []),
      kekayaanLainnya: List<String>.from(json['kekayaan_lainnya'] ?? []),
      kekayaanJumlah: List<String>.from(json['kekayaan_jumlah'] ?? []),
      alreadyHaveAccount: json['already_have_account']
    );
  }
}
