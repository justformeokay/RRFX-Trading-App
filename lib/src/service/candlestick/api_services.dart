import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = 'https://api-rrfx.techcrm.net';

  Future<Map<String, dynamic>> get(String endpoint) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    if(accessToken == null){
      print("Akses Token NULL");
      return {};
    }
    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.get(url, headers: {
      'Authorization': "Bearer $accessToken",
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      return {
        'status': true,
        'response': json.decode(response.body),
      };
    } else {
      print('API ERROR: ${response.statusCode} ${response.body}');
      return {'status': false, 'response': null};
    }
  }
}
