import 'package:get/get.dart';
import 'package:rrfx/src/views/accounts/registration_online/controllers/step_controller.dart';

class StepBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StepController());
  }
}
