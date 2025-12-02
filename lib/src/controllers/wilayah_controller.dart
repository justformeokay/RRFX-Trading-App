// import 'package:get/get.dart';
// import 'package:rrfx/src/controllers/device_utilities_controller.dart';
// import 'package:rrfx/src/models/utilities/list_desa_model.dart';
// import 'package:rrfx/src/models/utilities/list_kabupaten_model.dart';
// import 'package:rrfx/src/models/utilities/list_kecamatan_model.dart';
// import 'package:rrfx/src/models/utilities/list_province_model.dart';
// import 'package:rrfx/src/service/auth_service.dart';

// class WilayahController extends GetxController{
//   RxBool isLoading = false.obs;
//   RxString responseMessage = "".obs;
//   RxString selectedProvince = "".obs;
//   RxString selectedCity = "".obs;
//   RxString selectedDistrict = "".obs;
//   RxString selectedSubDistrict = "".obs;
//   Rxn<ListProvinsiModel> listProvinsiModel = Rxn<ListProvinsiModel>();
//   Rxn<ListKabupatenModel> listKotaModel = Rxn<ListKabupatenModel>();
//   Rxn<ListKecamatanModel> listKecamatanModel = Rxn<ListKecamatanModel>();
//   Rxn<ListDesaModel> listDesaModel = Rxn<ListDesaModel>();
//   Map<String, String> deviceInfo = {};
//   AuthService authService = Get.find();

//   init() async {
//     DeviceUtilitiesController.getDeviceInfo().then((value) {
//       deviceInfo = value;
//     });
//   }

//   @override
//   void onInit() {
//     super.onInit();
//     init();
//   }

//   // Provinsi
//   Future<bool> getProvinsi() async {
//     try {
//       isLoading(true);
//       Map<String, dynamic> result = await authService.get("wilayah/province");
//       isLoading(false);
//       responseMessage(result['message']);
//       if(result['status'] == true) {
//         listProvinsiModel(ListProvinsiModel.fromJson(result));
//         return true;
//       }
//       return false;
//     } catch (e) {
//       isLoading(false);
//       responseMessage(e.toString());
//       return false;
//     }
//   }

//   // Kabupaten / Kota
//   Future<bool> getKabupatenKota() async {
//     try {
//       isLoading(true);
//       Map<String, dynamic> result = await authService.get("wilayah/regency?province=$selectedProvince");
//       isLoading(false);
//       responseMessage(result['message']);
//       if(result['status'] == true) {
//         listKotaModel(ListKabupatenModel.fromJson(result));
//         return true;
//       }
//       return false;
//     } catch (e) {
//       isLoading(false);
//       responseMessage(e.toString());
//       return false;
//     }
//   }

//   // Kabupaten / Kota
//   Future<bool> getKecamatan() async {
//     try {
//       isLoading(true);
//       Map<String, dynamic> result = await authService.get("wilayah/district?regency=$selectedCity");
//       isLoading(false);
//       responseMessage(result['message']);
//       if(result['status'] == true) {
//         listKecamatanModel(ListKecamatanModel.fromJson(result));
//         return true;
//       }
//       return false;
//     } catch (e) {
//       isLoading(false);
//       responseMessage(e.toString());
//       return false;
//     }
//   }

//   // Kabupaten / Kota
//   Future<bool> getDesa() async {
//     try {
//       isLoading(true);
//       Map<String, dynamic> result = await authService.get("wilayah/villages?district=$selectedDistrict");
//       isLoading(false);
//       responseMessage(result['message']);
//       if(result['status'] == true) {
//         listDesaModel(ListDesaModel.fromJson(result));
//         return true;
//       }
//       return false;
//     } catch (e) {
//       isLoading(false);
//       responseMessage(e.toString());
//       return false;
//     }
//   }
// }


import 'package:get/get.dart';
import 'package:rrfx/src/controllers/device_utilities_controller.dart';
import 'package:rrfx/src/models/utilities/list_desa_model.dart';
import 'package:rrfx/src/models/utilities/list_kabupaten_model.dart';
import 'package:rrfx/src/models/utilities/list_kecamatan_model.dart';
import 'package:rrfx/src/models/utilities/list_province_model.dart';
import 'package:rrfx/src/service/auth_service.dart';

class WilayahController extends GetxController {
  // Loader global
  RxBool isLoading = false.obs;

  // Captured response
  RxString responseMessage = "".obs;

  // Selected wilayah
  RxString selectedProvince = "".obs;
  RxString selectedCity = "".obs;
  RxString selectedDistrict = "".obs;
  RxString selectedSubDistrict = "".obs;

  // Data models
  Rxn<ListProvinsiModel> listProvinsiModel = Rxn<ListProvinsiModel>();
  Rxn<ListKabupatenModel> listKotaModel = Rxn<ListKabupatenModel>();
  Rxn<ListKecamatanModel> listKecamatanModel = Rxn<ListKecamatanModel>();
  Rxn<ListDesaModel> listDesaModel = Rxn<ListDesaModel>();

  AuthService authService = Get.find();
  Map<String, String> deviceInfo = {};

  @override
  void onInit() {
    super.onInit();
    init();
  }

  init() async {
    DeviceUtilitiesController.getDeviceInfo().then((value) {
      deviceInfo = value;
    });
  }

  // ===============================
  // 🔥 GETTERS (Digunakan di View)
  // ===============================

  bool get hasProvince => selectedProvince.isNotEmpty;
  bool get hasCity => selectedCity.isNotEmpty;
  bool get hasDistrict => selectedDistrict.isNotEmpty;
  bool get hasSubDistrict => selectedSubDistrict.isNotEmpty;

  // ===============================
  // 🔥 Reset helper
  // ===============================

  void resetCity() {
    selectedCity.value = "";
    selectedDistrict.value = "";
    selectedSubDistrict.value = "";
    listKotaModel.value = null;
    listKecamatanModel.value = null;
    listDesaModel.value = null;
  }

  void resetDistrict() {
    selectedDistrict.value = "";
    selectedSubDistrict.value = "";
    listKecamatanModel.value = null;
    listDesaModel.value = null;
  }

  void resetSubDistrict() {
    selectedSubDistrict.value = "";
    listDesaModel.value = null;
  }

  // ===============================
  // 🔥 API: Provinsi
  // ===============================

  Future<bool> getProvinsi() async {
    try {
      isLoading(true);
      Map<String, dynamic> res = await authService.get("wilayah/province");
      isLoading(false);

      responseMessage(res['message']);

      if (res['status'] == true) {
        listProvinsiModel(ListProvinsiModel.fromJson(res));
        return true;
      }
      return false;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }

  // ===============================
  // 🔥 API: Kabupaten/Kota
  // ===============================

  Future<bool> getKabupatenKota() async {
    try {
      isLoading(true);
      Map<String, dynamic> res = await authService.get(
        "wilayah/regency?province=$selectedProvince",
      );
      isLoading(false);

      responseMessage(res['message']);

      if (res['status'] == true) {
        listKotaModel(ListKabupatenModel.fromJson(res));
        return true;
      }
      return false;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }

  // ===============================
  // 🔥 API: Kecamatan
  // ===============================

  Future<bool> getKecamatan() async {
    try {
      isLoading(true);
      Map<String, dynamic> res = await authService.get(
        "wilayah/district?regency=$selectedCity",
      );
      isLoading(false);

      responseMessage(res['message']);

      if (res['status'] == true) {
        listKecamatanModel(ListKecamatanModel.fromJson(res));
        return true;
      }
      return false;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }

  // ===============================
  // 🔥 API: Desa/Kelurahan
  // ===============================

  Future<bool> getDesa() async {
    try {
      isLoading(true);
      Map<String, dynamic> res = await authService.get(
        "wilayah/villages?district=$selectedDistrict",
      );
      isLoading(false);

      responseMessage(res['message']);

      if (res['status'] == true) {
        listDesaModel(ListDesaModel.fromJson(res));
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
