import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

Future<List<Map<String, dynamic>>> readJsonFile(String assetPath) async {
  try {
    final String jsonString = await rootBundle.loadString(assetPath);
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return List<Map<String, dynamic>>.from(jsonMap['result']);
  } catch (e) {
    throw Exception('Failed to load asset: $e');
  }
}
