import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rrfx/src/helpers/variables/global_variables.dart';

class ApiService {
  static String baseUrl = GlobalVariable.mainURL;

  static Future<Map<String, dynamic>> post(String endpoint, {Map<String, String>? headers, Map<String, dynamic>? body}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: body,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? headers}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
    );
    return jsonDecode(response.body);
  }
}
