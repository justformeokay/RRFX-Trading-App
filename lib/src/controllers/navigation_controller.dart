import 'package:get/get.dart';

class NavigationController extends GetxController {
  static NavigationController get to => Get.find();

  final currentIndex = 0.obs;

  void goTo(int index) {
    currentIndex.value = index;
  }
}
