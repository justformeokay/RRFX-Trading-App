// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:rrfx/src/models/auth/country_code_model.dart';

// /// --- CONTROLLER ---
// class CountryController extends GetxController {
//   var countries = <CountryCodeModel>[].obs;
//   var selectedCode = "+62".obs; // default misal Indonesia
//   var phoneNumber = "".obs;

//   final phoneController = TextEditingController();

//   /// simulasi ambil data dari API
//   Future<void> fetchCountries() async {
//     // contoh hardcode, Anda bisa pakai http dio dll
//     final response = {
//       "status": true,
//       "message": "Berhasil",
//       "response": [
//         {
//           "name": "Afrika Selatan",
//           "code": "en-ZA",
//           "phone_code": "+27"
//         },
//         {
//           "name": "Amerika Serikat",
//           "code": "en-US",
//           "phone_code": "+1"
//         }
//       ]
//     };

//     if (response['status'] == true) {
//       var list = (response['response'] as List)
//           .map((e) => CountryCodeModel.fromJson(e))
//           .toList();
//       countries.assignAll(list);
//     }
//   }

//   void setSelected(CountryCodeModel country) {
//     selectedCode.value = country.response.;
//     Get.back(); // close bottomsheet
//   }
// }

// /// --- VIEW / WIDGET ---
// class PhoneNumberField extends StatelessWidget {
//   final CountryController controller = Get.put(CountryController());

//   PhoneNumberField({super.key}) {
//     controller.fetchCountries();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return 
//   }
// }