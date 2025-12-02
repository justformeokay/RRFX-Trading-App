import 'package:get/get.dart';

class AgreementSectionController extends GetxController {
  // Daftar status checkbox untuk setiap section
  RxList<bool> checkedSections = <bool>[].obs;

  // Inisialisasi jumlah section
  void initSections(int count) {
    checkedSections.value = List.generate(count, (_) => false);
  }

  // Toggle centang per section
  void toggleSection(int index, bool? value) {
    checkedSections[index] = value ?? false;
  }

  // Centang semua
  void checkAll() {
    checkedSections.value = List.generate(checkedSections.length, (_) => true);
  }

  // Apakah semua sudah dicentang?
  bool get allChecked => checkedSections.every((e) => e == true);
}
