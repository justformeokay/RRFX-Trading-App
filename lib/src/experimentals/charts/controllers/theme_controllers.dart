// controllers/theme_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeControllerExperimentals extends GetxController {
  // Asumsikan mode gelap default
  final isDark = true.obs; 

  void toggleTheme() {
    isDark.value = !isDark.value;
    // Mengubah tema aplikasi secara keseluruhan
    Get.changeThemeMode(isDark.value ? ThemeMode.dark : ThemeMode.light);
  }

  // Getter untuk skema warna
  ColorScheme get colorScheme => 
      isDark.value ? const ColorScheme.dark(
          primary: Color(0xFF1E88E5), // Blue 600
          onPrimary: Colors.white,
          secondary: Color(0xFFFFB74D), // Orange 300
          background: Color(0xFF121212), // Dark background
          surface: Color(0xFF1D1D1D),
          error: Color(0xFFCF6679),
      ) : const ColorScheme.light(
          primary: Color(0xFF2196F3), // Blue 500
          onPrimary: Colors.white,
          secondary: Color(0xFFFF9800), // Orange 500
          background: Colors.white,
          surface: Colors.white,
          error: Color(0xFFB00020),
      );

  ThemeData get themeData => ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    brightness: isDark.value ? Brightness.dark : Brightness.light,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: colorScheme.onBackground,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surface,
      elevation: 2,
    ),
    // Sesuaikan elemen UI lainnya di sini
  );
}