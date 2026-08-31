import 'package:get/get.dart';
import 'package:rrfx/src/models/databases/account.dart';
import 'package:rrfx/src/models/trades/product_models.dart';
import 'package:rrfx/src/service/auth_service.dart';

class RegolController extends GetxController {
  AuthService authService = Get.find();
  RxString responseMessage = "".obs;
  RxBool isLoading = false.obs;
  Rxn<ProductModels> productModels = Rxn<ProductModels>();
  // DatabaseService databaseService = DatabaseService.instance;
  Rxn<AccountModel> accountModel = Rxn<AccountModel>();


  // Create Demo Trading API
  Future<bool> getProducts() async {
    Get.log("FUNGSI GET PRODUCT DIJALANKAN");
    try {
      Map<String, dynamic> result = await authService.get("regol_old/product");
      responseMessage(result['message']);
      productModels(ProductModels.fromJson(result));
      return true;
    } catch (e) {
      responseMessage(e.toString());
      return false;
    }
  }

  // Create Demo Trading API
  Future<bool> createDemoAccount() async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.post("regol/createDemo", {});
      responseMessage(result['message']);
      isLoading(false);
      if(result['status'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }

  // Future<bool> progressAccount() async {
  //   try {
  //     Map<String, dynamic> result = await authService.get("regol_old/progressAccount");
  //     responseMessage(result['message']);
  //     print("INI RESPONSE PROGRESS ACCOUNT => $result");

  //     if(result['status'] != true) {
  //       return false;
  //     }
  //     accountModel(AccountModel.fromJson(result));
  //     return true;
  //   } catch (e) {
  //     isLoading(false);
  //     responseMessage("progressAccount error: $e");
  //     throw Exception("progressAccount error: $e");
  //   }
  // }

  Future<bool> progressAccount() async {
    try {
      Map<String, dynamic> result = await authService.get("regol_old/progressAccount");

      responseMessage(result['message']);

      if (result['status'] != true) {
        return false;
      }

      // parse ke model
      accountModel(AccountModel.fromJson(result));

      return true;
    } catch (e) {
      isLoading(false);
      responseMessage("progressAccount error: $e");
      throw Exception("progressAccount error: $e");
    }
  }



  // Create Demo Trading API
  Future<bool> postStepZero({String? accountType, String? cddType}) async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.post("regol_old/accountType", {
        'account-type' : accountType,
        'cdd-type': cddType
      });
      isLoading(false);
      responseMessage(result['message']);
      if (result['status'] != true) {
        return false;
      }

      /** Assign new value to Database */
      accountModel.value?.response?.type = accountType;
      // accountModel.value?.response?.typeAcc = accountSuffix;
      
      return true;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }


  Future<bool> postStepOne({String? appFotoTerbaru, String? appFotoIdentitas, required String country, required String idType, required String idTypeNumber}) async {
    try {
      isLoading(true);
      Map<String, String> body = {
        'country': country,
        'id_type': idType,
        'number': idTypeNumber,
      };

      Map<String, String> file = {};
      if(appFotoTerbaru != null) {
        file['app_foto_terbaru'] = appFotoTerbaru;
      }

      if(appFotoIdentitas != null) {
        file['app_foto_identitas'] = appFotoIdentitas;
      }

      Map<String, dynamic> result = await authService.multipart("regol_old/verifikasiIdentitas", body, file);
      isLoading(false);
      responseMessage(result['message']);
      if(result['status'] != true) {
        return false;
      }

      accountModel.value?.response?.idType = idType;
      accountModel.value?.response?.idNumber = idTypeNumber;
      accountModel.value?.response?.country = country;

      return true;
      
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }


  // Create Demo Trading API
  Future<bool> postStepTwo({String? birthPlace, String? dateOfBirth, String? gender, String? taxNumber, String? name, String? phone, String? phoneCode, String? motherName}) async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.post("regol_old/apr_pengumpulan_data", {
        'app_fullname': name,
        'app_phone_code': phoneCode,
        'app_phone': phone,
        'app_npwp': taxNumber,
        'app_date_of_birth': dateOfBirth,
        'app_place_of_birth': birthPlace,
        'app_gender': gender,
        'app_nama_ibu' : motherName
      });

      isLoading(false);
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

  // Create Demo Trading API
  Future<bool> postStepThree({String? maritalStatus, String? wifeName, String? motherName, String? faxNumber, String? phoneHome}) async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.post("regol_old/apr_status_perkawinan", {
        'app_status_perkawinan': maritalStatus,
        'app_nama_istri': wifeName,
        // 'app_nama_ibu': motherName,
        'app_nomor_tlp_rumah': phoneHome,
        'app_nomor_fax': faxNumber
      });
      isLoading(false);
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

  // Create Demo Trading API
  Future<bool> postStepFour({String? emergencyName, String? emergencyRelation, String? emergencyContact, String? emergencyAddress, String? postalCode}) async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.post("regol_old/apr_pihak_darurat", {
        'app_darurat_nama': emergencyName,
        'app_darurat_hubungan': emergencyRelation,
        'app_darurat_telepon': emergencyContact,
        'app_darurat_alamat': emergencyAddress,
        'app_darurat_kodepos': postalCode
      });

      isLoading(false);
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


  // Create Demo Trading API
  Future<bool> postStepFive({String? investmentGoal}) async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.post("regol_old/apr_tujuan_investasi", {
        'app_tujuan_investasi': investmentGoal
      });

      isLoading(false);
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

  // Create Demo Trading API
  Future<bool> postStepSix({String? experience, String? companyName}) async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.post("regol_old/apr_pengalaman_investasi", {
        'app_pengalaman_investasi': experience,
        'app_nama_perusahaan': companyName
      });

      isLoading(false);
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


  // Create Demo Trading API
  Future<bool> postStepSeven({String? experience}) async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.post("regol_old/apr_pengalaman_investasi", {
        'app_pengalaman_investasi': experience,
      });

      isLoading(false);
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

  // Create Demo Trading API
  Future<bool> postStepEight({
    String? namaPekerjaan,
    String? namaPerusahaan,
    String? bidangUsaha,
    String? jabatanPekerjaan,
    String? lamaBekerja,
    String? alamatKantor,
    String? lamaBekerjaSebelumnya
  }) async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.post("regol_old/apr_informasi_pekerjaan", {
        'nama_pekerjaan': namaPekerjaan,
        'nama_perusahaan': namaPerusahaan,
        'bidang_usaha': bidangUsaha,
        'jabatan_pekerjaan': jabatanPekerjaan,
        'lama_bekerja': '${lamaBekerja ?? 0}',
        'alamat_kantor': alamatKantor,
        'lama_bekerja_sebelumnya': '${lamaBekerjaSebelumnya ?? 0}'
      });

      isLoading(false);
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


  // Create Demo Trading API
  Future<bool> postStepNinePernyataanSimulasi({
    String? appProvince,
    String? appCity,
    String? appDistrict,
    String? appVillage,
    String? appZipcode,
    String? appRT,
    String? appRW,
    String? appAddress,
    String? appAgree,
  }) async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.post("regol_old/pernyataan_simulasi", {
        'app_province': appProvince!,
        'app_city': appCity!,
        'app_district': appDistrict!,
        'app_village': appVillage!,
        'app_zipcode': appZipcode!,
        'app_rt': appRT!,
        'app_rw': appRW!,
        'app_address': appAddress!,
        'app_agree': appAgree!
      });

      isLoading(false);
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

  // Pernataan Pailit
  Future<bool> postPernytaanPailit({
    String? keluargaBappebti,
    String? pailit
  }) async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.post("regol_old/apr_keterangan_pailit", {
        'app_keterangan_pailit': pailit,
        'app_keluarga_bursa': keluargaBappebti
      });

      isLoading(false);
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

  // Pernataan Pailit
  Future<bool> postPenyelasaianMasalah({
    String? kantorPenyelesaianMasalah,
    String? kotaPenyelesaianMasalah
  }) async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.post("regol_old/apr_perjanjian_amanat", {
        'app_kantor_penyelesaian': kantorPenyelesaianMasalah,
        'app_kota_penyelesaian': kotaPenyelesaianMasalah ?? 'JAKARTA UTARA'
      });
      isLoading(false);
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

  // Pernataan Pailit
  Future<bool> postKekayaan({
    String? annualIncome,
    String? lokasiRumah,
    String? njop,
    String? deposito,
    String? lainnya
  }) async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.post("regol_old/apr_daftar_kekayaan", {
        'annual_income': annualIncome,
        'lokasi_rumah': lokasiRumah,
        'njop': njop,
        'deposito': deposito,
        'lainnya': lainnya
      });

      isLoading(false);
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

  Future<bool> stepDokumenPendukung({String? dokumenPendukung1, String? dokumenPendukung2, String? dokumenPendukung3}) async {
    try {
      Map<String, String> file = {};
      isLoading(true);

      if(dokumenPendukung1 != null) {
        file['app_image_1'] = dokumenPendukung1;
      }

      if(dokumenPendukung2 != null) {
        file['app_image_2'] = dokumenPendukung2;
      }

      if(dokumenPendukung3 != null) {
        file['app_image_npwp'] = dokumenPendukung3;
      }

      var result = await authService.multipart("regol_old/apr_dokumen_pendukung", {}, file);
      isLoading(false);
      responseMessage(result['message']);
      if(result['status'] == false){
        return false;
      }
      return true;

    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }

  Future<bool> kelengkapanDokumen({String? pernyataan}) async {
    try {
      isLoading(true);
      Map<String, dynamic> result = await authService.post("regol_old/kelengkapanFormulir", {
        'aggree': pernyataan
      });
      isLoading(false);
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
}