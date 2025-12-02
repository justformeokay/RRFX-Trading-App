import 'dart:math' as math; // Import with a prefix to avoid name conflicts
import 'package:flutter/material.dart';

class CustomColorPicker {
  static Color getRandomColor() {
    return Color.fromARGB(
      255, // Alpha (opacity) - 255 means fully opaque
      math.Random().nextInt(256), // Red
      math.Random().nextInt(256), // Green
      math.Random().nextInt(256), // Blue
    );
  }
}