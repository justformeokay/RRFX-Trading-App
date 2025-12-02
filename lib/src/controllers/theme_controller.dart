import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  var isDark = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadTheme();
  }

  void toggleTheme(bool value) {
    isDark.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    saveTheme(value);
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    isDark.value = prefs.getBool("isDarkTheme") ?? true;
    Get.changeThemeMode(isDark.value ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> saveTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isDarkTheme", value);
  }
}
