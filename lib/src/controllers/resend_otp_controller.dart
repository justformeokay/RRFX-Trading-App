import 'dart:async';
import 'package:get/get.dart';

class OtpTimerController extends GetxController {
  RxInt seconds = 60.obs; // default 30 detik
  Timer? _timer;

  bool get isFinished => seconds.value == 0;

  void startTimer({int duration = 60}) {
    seconds.value = duration;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds.value > 0) {
        seconds.value--;
      } else {
        timer.cancel();
      }
    });
  }

  void resetTimer([int duration = 60]) {
    startTimer(duration: duration);
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
