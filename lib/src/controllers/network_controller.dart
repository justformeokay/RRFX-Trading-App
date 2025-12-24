import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rrfx/src/service/network_speed_service.dart';
import 'package:rrfx/src/components/popups/network_speed_dialog.dart';

class NetworkController extends GetxController {
  var hasConnection = true.obs;
  var networkSpeed = 0.obs;
  var isCheckingSpeed = false.obs;

  @override
  void onInit() {
    super.onInit();

    // cek koneksi pertama kali
    _checkConnection();

    // listen perubahan koneksi
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      hasConnection.value = !results.contains(ConnectivityResult.none);
      
      // Cek network speed ketika ada perubahan koneksi
      if (hasConnection.value) {
        checkNetworkSpeed();
      }
    });
  }

  Future<void> _checkConnection() async {
    final results = await Connectivity().checkConnectivity();
    hasConnection.value = !results.contains(ConnectivityResult.none);
    
    // Cek network speed setelah koneksi terdeteksi
    if (hasConnection.value) {
      await Future.delayed(const Duration(milliseconds: 500));
      checkNetworkSpeed();
    }
  }

  /// Mengecek network speed dan menampilkan dialog jika > 300ms
  Future<void> checkNetworkSpeed() async {
    if (isCheckingSpeed.value) return;
    
    // isCheckingSpeed.value = true;
    
    try {
      // Tampilkan loading dialog
      // NetworkSpeedDialog.showNetworkSpeedCheckingDialog();
      
      // Warm up - skip first request (usually slower due to DNS/connection setup)
      try {
        await NetworkSpeedService.measureLatency(url: 'https://www.google.com/favicon.ico');
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (_) {}
      
      // Measure actual network speed dengan latency check
      final speed = await NetworkSpeedService.measureNetworkSpeedWithRetry(
        retryCount: 3,
      );
      
      // Close loading dialog
      Get.back();
      
      if (speed != null) {
        networkSpeed.value = speed;
        print('🌐 Network Latency: ${speed}ms');
        
        // Jika network speed > 500ms, tampilkan warning dialog
        if (speed > 500) {
          await Future.delayed(const Duration(milliseconds: 300));
          NetworkSpeedDialog.showUnstableConnectionDialog(speed);
        }
      }
    } catch (e) {
      print('Error checking network speed: $e');
      // Close loading dialog jika ada error
      try {
        Get.back();
      } catch (_) {}
    } finally {
      // isCheckingSpeed.value = false;
    }
  }

  /// Manual check network speed tanpa dialog loading
  Future<int?> getNetworkSpeed() async {
    try {
      // Warm up
      try {
        await NetworkSpeedService.measureLatency(url: 'https://www.google.com/favicon.ico');
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (_) {}
      
      final speed = await NetworkSpeedService.measureNetworkSpeedWithRetry(
        retryCount: 3,
      );
      
      if (speed != null) {
        networkSpeed.value = speed;
      }
      
      return speed;
    } catch (e) {
      print('Error getting network speed: $e');
      return null;
    }
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
