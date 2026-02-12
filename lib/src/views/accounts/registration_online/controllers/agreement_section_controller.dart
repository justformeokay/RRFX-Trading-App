import 'package:get/get.dart';

class AgreementSectionController extends GetxController {
  // Daftar status checkbox untuk setiap section
  RxList<bool> checkedSections = <bool>[].obs;

  // Checkbox untuk dispute section (section 23)
  RxBool disputeSectionChecked = false.obs;

  // Checkbox untuk table section (section 24)
  RxBool tableSectionChecked = false.obs;

  // Radio selection untuk section 23
  RxnString selectedPenyelesaian = RxnString(null);
  RxnString selectedKota = RxnString(null);
  
  // Default values for checkAll
  static const String defaultPenyelesaian = "Badan Arbitrase Perdagangan Berjangka Komoditi (BAKTI) berdasarkan Peraturan dan Prosedur Badan Arbitrase Perdagangan Berjangka Komoditi (BAKTI)";
  static const String defaultKota = "JAKARTA UTARA";

  // Inisialisasi jumlah section
  void initSections(int count) {
    // Only initialize if not already initialized or count changed
    if (checkedSections.isEmpty || checkedSections.length != count) {
      checkedSections.value = List.generate(count, (_) => false);
    }
  }

  // Toggle centang per section
  void toggleSection(int index, bool? value) {
    if (index >= 0 && index < checkedSections.length) {
      checkedSections[index] = value ?? false;
      checkedSections.refresh(); // Trigger reactive update
    }
  }

  // Toggle dispute section
  void toggleDisputeSection(bool? value) {
    disputeSectionChecked.value = value ?? false;
  }

  // Toggle table section
  void toggleTableSection(bool? value) {
    tableSectionChecked.value = value ?? false;
  }

  // Set penyelesaian selection
  void setSelectedPenyelesaian(String? value) {
    selectedPenyelesaian.value = value;
  }

  // Set kota selection
  void setSelectedKota(String? value) {
    selectedKota.value = value;
  }

  // Centang semua
  void checkAll() {
    final newValue = !allChecked;
    
    // Update all checkboxes in the list
    for (int i = 0; i < checkedSections.length; i++) {
      checkedSections[i] = newValue;
    }
    checkedSections.refresh(); // Trigger reactive update
    
    // Update special sections
    disputeSectionChecked.value = newValue;
    tableSectionChecked.value = newValue;
    
    // Update radio selections when checking all
    if (newValue) {
      selectedPenyelesaian.value = defaultPenyelesaian;
      selectedKota.value = defaultKota;
    } else {
      selectedPenyelesaian.value = null;
      selectedKota.value = null;
    }
  }

  // Apakah semua sudah dicentang?
  bool get allChecked =>
      checkedSections.isNotEmpty &&
      checkedSections.every((e) => e == true) &&
      disputeSectionChecked.value &&
      tableSectionChecked.value;
}
