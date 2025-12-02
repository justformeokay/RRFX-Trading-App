import 'package:get/get.dart';

class AgreementController extends GetxController {
  /// Menyimpan status setiap checkbox
  var checkedList = <bool>[].obs;

  /// Inisialisasi berdasarkan jumlah item
  void initList(int length) {
    if (checkedList.isEmpty) {
      checkedList.value = List.generate(length, (_) => false);
    }
  }

  /// Update salah satu checkbox
  void toggleCheck(int index, bool? value) {
    if (index >= 0 && index < checkedList.length) {
      checkedList[index] = value ?? false;
      checkedList.refresh();
    }
  }

  /// Centang / hapus semua
  void toggleAll(bool value) {
    checkedList.value = List.generate(checkedList.length, (_) => value);
  }

  /// Cek apakah semua sudah dicentang
  bool get allChecked => checkedList.isNotEmpty && checkedList.every((e) => e);

  /// Cek apakah ada yang belum dicentang
  bool get hasUnchecked => checkedList.any((e) => !e);
}
