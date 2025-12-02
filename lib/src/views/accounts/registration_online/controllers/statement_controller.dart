import 'package:get/get.dart';

class StatementController extends GetxController {
  RxBool selectedStatement = true.obs;
  Rx<DateTime> selectedDate = DateTime.now().obs;

  Stream<DateTime> timeStream() {
    return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
  }
}