import 'package:get/get.dart';

class AgreementSectionController extends GetxController {
  // Daftar status checkbox untuk setiap section
  RxList<bool> checkedSections = <bool>[].obs;

  // Checkbox untuk dispute section (section 23)
  RxBool disputeSectionChecked = false.obs;

  // Checkbox untuk table section (section 24)
  RxBool tableSectionChecked = false.obs;

  // Inisialisasi jumlah section
  void initSections(int count) {
    checkedSections.value = List.generate(count, (_) => false);
  }

  // Toggle centang per section
  void toggleSection(int index, bool? value) {
    checkedSections[index] = value ?? false;
  }

  // Toggle dispute section
  void toggleDisputeSection(bool? value) {
    disputeSectionChecked.value = value ?? false;
  }

  // Toggle table section
  void toggleTableSection(bool? value) {
    tableSectionChecked.value = value ?? false;
  }

  // Centang semua
  void checkAll() {
    final newValue = !allChecked;
    checkedSections.value = List.generate(
      checkedSections.length,
      (_) => newValue,
    );
    disputeSectionChecked.value = newValue;
    tableSectionChecked.value = newValue;
  }

  // Apakah semua sudah dicentang?
  bool get allChecked =>
      checkedSections.every((e) => e == true) &&
      disputeSectionChecked.value &&
      tableSectionChecked.value;
}
