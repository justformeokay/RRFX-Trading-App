import 'package:get/get.dart';
import 'dart:async';

class DateTimeController extends GetxController {
  // Use Rx<DateTime> to make it reactive
  final Rx<DateTime> _currentDateTime = DateTime.now().obs;

  // Getter to expose the reactive DateTime
  DateTime get currentDateTime => _currentDateTime.value;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    // Start a timer to update the time every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentDateTime.value = DateTime.now();
    });
  }

  @override
  void onClose() {
    // Cancel the timer when the controller is no longer needed
    _timer?.cancel();
    super.onClose();
  }
}