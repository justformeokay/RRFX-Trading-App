import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkController extends GetxController {
  var hasConnection = true.obs;

  @override
  void onInit() {
    super.onInit();

    // cek koneksi pertama kali
    _checkConnection();

    // listen perubahan koneksi
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      hasConnection.value = !results.contains(ConnectivityResult.none);
    });
  }

  Future<void> _checkConnection() async {
    final results = await Connectivity().checkConnectivity();
    hasConnection.value = !results.contains(ConnectivityResult.none);
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
