import 'dart:convert';
import 'package:get_storage/get_storage.dart';

/// Service to cache Step 7 registration form data locally
/// Data is saved automatically on field changes and cleared after successful submit
class Step7CacheService {
  static const String _cacheKey = 'step7_form_cache';
  static final GetStorage _storage = GetStorage();

  /// Save all form data to local storage
  static Future<void> saveFormData(Map<String, dynamic> data) async {
    try {
      final jsonData = jsonEncode(data);
      await _storage.write(_cacheKey, jsonData);
    } catch (e) {
      print('❌ [Step7Cache] Error saving form data: $e');
    }
  }

  /// Load saved form data from local storage
  static Map<String, dynamic>? loadFormData() {
    try {
      final jsonData = _storage.read<String>(_cacheKey);
      if (jsonData != null && jsonData.isNotEmpty) {
        return jsonDecode(jsonData) as Map<String, dynamic>;
      }
    } catch (e) {
      print('❌ [Step7Cache] Error loading form data: $e');
    }
    return null;
  }

  /// Clear cached form data (after successful submit)
  static Future<void> clearFormData() async {
    try {
      await _storage.remove(_cacheKey);
      print('✅ [Step7Cache] Form data cleared');
    } catch (e) {
      print('❌ [Step7Cache] Error clearing form data: $e');
    }
  }

  /// Check if there is cached form data
  static bool hasCachedData() {
    try {
      final jsonData = _storage.read<String>(_cacheKey);
      return jsonData != null && jsonData.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
