import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rrfx/src/service/network_speed_service.dart';
import 'package:rrfx/src/components/popups/network_speed_dialog.dart';

class NetworkController extends GetxController {
  var hasConnection = true.obs;
  var networkSpeed = 0.obs;
  var isCheckingSpeed = false.obs;

  // Debounce timer — prevents burst checks when signal fluctuates
  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();

    // cek koneksi pertama kali
    _checkConnection();

    // listen perubahan koneksi
    try {
      Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
        hasConnection.value = !results.contains(ConnectivityResult.none);
        
        // Debounce: wait 3s after last event before checking speed.
        // Prevents burst of checks when signal fluctuates rapidly.
        if (hasConnection.value) {
          _debounceTimer?.cancel();
          _debounceTimer = Timer(const Duration(seconds: 3), () {
            checkNetworkSpeed();
          });
        }
      });
    } catch (e) {
      Get.log('⚠️ [NETWORK] Connectivity listener error: $e');
      // Assume connected if listener fails
      hasConnection.value = true;
    }
  }

  Future<void> _checkConnection() async {
    try {
      final results = await Connectivity().checkConnectivity()
          .timeout(const Duration(seconds: 5), onTimeout: () => [ConnectivityResult.wifi]);
      hasConnection.value = !results.contains(ConnectivityResult.none);
      
      // Cek network speed setelah koneksi terdeteksi
      if (hasConnection.value) {
        await Future.delayed(const Duration(milliseconds: 500));
        checkNetworkSpeed();
      }
    } catch (e) {
      Get.log('⚠️ [NETWORK] Connection check error: $e');
      // Assume connected if check fails
      hasConnection.value = true;
    }
  }

  /// Mengecek network speed dan menampilkan dialog jika > 300ms
  Future<void> checkNetworkSpeed() async {
    if (kIsWeb || isCheckingSpeed.value) return;
    
    isCheckingSpeed.value = true;
    
    try {
      // measureNetworkSpeedWithRetry already performs its own warm-up internally,
      // so no duplicate warm-up here.
      final speed = await NetworkSpeedService.measureNetworkSpeedWithRetry(
        retryCount: 3,
      );
      
      if (speed != null) {
        networkSpeed.value = speed;
        // Jika network speed > 800ms, tampilkan warning dialog
        if (speed > 800) {
          await Future.delayed(const Duration(milliseconds: 300));
          NetworkSpeedDialog.showUnstableConnectionDialog(speed);
        }
      }
    } catch (e) {
      Get.log('Error checking network speed: $e');
    } finally {
      isCheckingSpeed.value = false;
    }
  }

  /// Manual check network speed tanpa dialog loading
  Future<int?> getNetworkSpeed() async {
    if (kIsWeb) return null;
    try {
      final speed = await NetworkSpeedService.measureNetworkSpeedWithRetry(
        retryCount: 3,
      );
      
      if (speed != null) {
        networkSpeed.value = speed;
      }
      
      return speed;
    } catch (e) {
      Get.log('Error getting network speed: $e');
      return null;
    }
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }
}


class NetworkMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final networkController = Get.find<NetworkController>();
    if (!networkController.hasConnection.value) {
      return const RouteSettings(name: '/no-network');
    }
    return null;
  }
}
