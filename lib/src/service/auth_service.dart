import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rrfx/src/controllers/device_utilities_controller.dart';
import 'package:rrfx/src/views/no_auth_view/mainpage_no_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:http_parser/http_parser.dart';

class AuthService extends GetxController {
  String? accessToken;
  String? refreshToken;
  Map<String, String> deviceInfo = {};

  final Map<String, String> headers = {
    'Content-Type': 'application/x-www-form-urlencoded'
  };

  @override
  void onInit() {
    super.onInit();
    init();
    DeviceUtilitiesController.getDeviceInfo().then((value) {
      deviceInfo = value;
    });
  }

  Future<bool> init() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    accessToken = preferences.getString('accessToken');
    refreshToken = preferences.getString('refreshToken');
  
    return true;
  }



  // Future<Map<String, dynamic>> post(String url, Map<String, dynamic> body, {int maxReload = 0}) async {
  //   try {
  //     await init();
  //     headers['Authorization'] = 'Bearer $accessToken';
  //     headers['Content-Type'] = 'application/json';

  //     final cleanUrl = "${GlobalVariable.mainURL}/$url".replaceAll('//', '/');
  //     final uri = Uri.parse(cleanUrl);

  //     print("🚀 POST to: $uri");
  //     print("📦 Headers: $headers");
  //     print("📨 Body (JSON): ${jsonEncode(body)}");

  //     http.Response response = await http.post(
  //       uri,
  //       headers: headers,
  //       body: jsonEncode(body),
  //     );

  //     print("📥 Status Code: ${response.statusCode}");
  //     print("📩 Response Body: ${response.body.isEmpty ? '[EMPTY]' : response.body}");

  //     if (response.statusCode >= 500) {
  //       throw Exception("Server error ${response.statusCode}: response kosong");
  //     }

  //     if (response.statusCode == 300) {
  //       if (maxReload > 3) {
  //         throw Exception("Telah mencapai max reload, silahkan login kembali");
  //       }
  //       final refreshTokenResponse = await refreshingToken(body: {
  //         'refresh_token': refreshToken ?? "",
  //       });
  //       accessToken = refreshTokenResponse['response']['access_token'];
  //       refreshToken = refreshTokenResponse['response']['refresh_token'];
  //       final preferences = await SharedPreferences.getInstance();
  //       preferences.setString('accessToken', accessToken!);
  //       preferences.setString('refreshToken', refreshToken!);
  //       return await post(url, body, maxReload: maxReload + 1);
  //     }

  //     if (response.body.isEmpty) {
  //       throw Exception("Response body kosong dari server (status ${response.statusCode})");
  //     }

  //     Map<String, dynamic> respBody = jsonDecode(response.body);
  //     return {
  //       'status': respBody['status'],
  //       'statusCode': response.statusCode,
  //       'message': respBody['message'],
  //       'response': respBody['response'],
  //     };
  //   } catch (e, stack) {
  //     print("🔥 ERROR di authService.post(): $e");
  //     print(stack);
  //     throw Exception("authService post error: $e");
  //   }
  // }

  Future<Map<String, dynamic>> post(String url, Map<String, dynamic> body, {int maxReload = 0}) async {
    // body['device'] = deviceInfo;
    try {
      await init();
      headers['Authorization'] = 'Bearer $accessToken';

      http.Response response = await http.post(
        Uri.parse("${GlobalVariable.mainURL}/$url"), 
        headers: headers,
        body: body
      );

      print("POST ${GlobalVariable.mainURL}/$url");

      if (response.statusCode == 300) {
        if(maxReload > 3) {
          throw Exception("Telah mencapai max reload, silahkan login kembali");
        }
        
        Map<String, dynamic> refreshTokenResponse = await refreshingToken(body: {
          'refresh_token': refreshToken ?? "",
        });

        // Initialize new access & refresh token from response
        accessToken = refreshTokenResponse['response']['access_token'];
        refreshToken = refreshTokenResponse['response']['refresh_token'];

        // Set new access & refresh token to SharedPreferences
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString('accessToken', accessToken!);
        preferences.setString('refreshToken', refreshToken!);

        return await post(url, body, maxReload: maxReload + 1);
      }

      Map<String, dynamic> respBody = jsonDecode(response.body);
      return {
        'status': respBody['status'],
        'statusCode': response.statusCode,
        'message': respBody['message'],
        'response': respBody['response'],
      };

    } catch (e) {
      throw Exception("authService post error: $e");
    }
  }

  Future<Map<String, dynamic>> multipart(
    String url,
    Map<String, String> body,
    Map<String, String> file, {
    int maxReload = 0,
  }) async {
    try {
      // 🔹 Anggap init() sudah handle token/headers
      await init();
      headers['Authorization'] = 'Bearer $accessToken';

      // 🔹 Buat request multipart
      http.MultipartRequest request =
          http.MultipartRequest('POST', Uri.parse("${GlobalVariable.mainURL}/$url"));
      request.headers.addAll(headers);
      request.fields.addAll(body);

      // 🔹 Tambahkan file (kalau ada)
      for (var key in file.keys) {
        if (file[key] != "" && file[key] != null) {
          request.files.add(await http.MultipartFile.fromPath(
            key,
            file[key]!,
            contentType: MediaType('image', 'jpeg'),
          ));
        }
      }

      // 🔹 Kirim request
      http.StreamedResponse response = await request.send();

      // 🔹 Ambil response string
      String responseString = await response.stream.bytesToString();

      Get.log("Multipart Response: $responseString");

      // 🔹 Safe JSON decode
      Map<String, dynamic>? respBody;
      try {
        if (responseString.trim().startsWith("{")) {
          respBody = jsonDecode(responseString);
        } else {
          // print("⚠️ Response bukan JSON, mungkin error dari server.");
        }
      } catch (e) {
        // print("⚠️ JSON Decode Error: $e");
      }

      // 🔹 Kalau status 300 → refresh token
      if (response.statusCode == 300) {
        if (maxReload > 3) {
          throw Exception("Telah mencapai max reload, silahkan login kembali");
        }

        Map<String, dynamic> refreshTokenResponse = await refreshingToken(body: {
          'refresh_token': refreshToken ?? "",
        });

        // 🔹 Update token baru
        accessToken = refreshTokenResponse['response']['access_token'];
        refreshToken = refreshTokenResponse['response']['refresh_token'];

        // 🔹 Simpan token ke SharedPreferences
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString('accessToken', accessToken!);
        preferences.setString('refreshToken', refreshToken!);

        // 🔁 Ulangi request dengan token baru
        return await multipart(url, body, file, maxReload: maxReload + 1);
      }

      // 🔹 Return hasil
      return {
        'status': respBody != null ? respBody['status'] ?? false : false,
        'statusCode': response.statusCode,
        'message': respBody != null
            ? respBody['message'] ?? "Server mengembalikan response non-JSON"
            : "Server mengembalikan response non-JSON",
        'response': respBody != null ? respBody['response'] ?? {} : responseString,
      };
    } catch (e) {
      // print("authService multipart error: $e");
      // print(stack);
      throw "authService multipart error: $e";
    }
  }



  Future<Map<String, dynamic>> get(String url, {int maxReload = 0}) async {
    try {
      await init();
      headers['Authorization'] = 'Bearer $accessToken';

      http.Response response = await http.get(
        Uri.parse("${GlobalVariable.mainURL}/$url"), 
        headers: headers,
      );

      if (response.statusCode == 300) {
        if(maxReload > 3) {
          throw Exception("Telah mencapai max reload, silahkan login kembali");
        }
        
        Map<String, dynamic> refreshTokenResponse = await refreshingToken(body: {
          'refresh_token': refreshToken ?? "",
        });

        // Initialize new access & refresh token from response
        accessToken = refreshTokenResponse['response']['access_token'];
        refreshToken = refreshTokenResponse['response']['refresh_token'];

        // Set new access & refresh token to SharedPreferences
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString('accessToken', accessToken!);
        preferences.setString('refreshToken', refreshToken!);

        return await get(url, maxReload: maxReload + 1);
      }

      Map<String, dynamic> respBody = jsonDecode(response.body);
      return {
        'status': respBody['status'],
        'statusCode': response.statusCode,
        'message': respBody['message'],
        'response': respBody['response'],
      };
    } catch (e) {
      final message = e.toString();
      print("❌ Exception di AuthService.get(): $message");
      if (message.contains("Session Expired") || message.contains("invalid_token")) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('accessToken');
        await prefs.remove('refreshToken');
        Future.microtask(() {
          Get.offAll(() => const MainpageWithoutLogin());
        });
        return {
          'status': false,
          'statusCode': 401,
          'message': 'Session expired, please login again',
          'response': {},
        };
      }
      throw Exception("Exception Auth Service: $e");
    }
  }

  Future<Map<String, dynamic>> getCustomURL(String url, {int maxReload = 0}) async {
    try {
      await init();
      headers['Authorization'] = 'Bearer $accessToken';

      http.Response response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 300) {
        if(maxReload > 3) {
          throw Exception("Telah mencapai max reload, silahkan login kembali");
        }

        Map<String, dynamic> refreshTokenResponse = await refreshingToken(body: {
          'refresh_token': refreshToken ?? "",
        });

        // Initialize new access & refresh token from response
        accessToken = refreshTokenResponse['response']['access_token'];
        refreshToken = refreshTokenResponse['response']['refresh_token'];

        // Set new access & refresh token to SharedPreferences
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString('accessToken', accessToken!);
        preferences.setString('refreshToken', refreshToken!);

        return await get(url, maxReload: maxReload + 1);
      }

      Map<String, dynamic> respBody = jsonDecode(response.body);
      return {
        'status': respBody['status'],
        'statusCode': response.statusCode,
        'message': respBody['message'],
        'response': respBody['response'],
      };

    } catch (e) {
      throw Exception(e);
    }
  }

  Future<Map<String, dynamic>> refreshingToken({required Map<String, dynamic> body}) async {
    try {
      // print("Token expired, refreshing token with: $refreshToken ");
      http.Response response = await http.post(
        Uri.parse("${GlobalVariable.mainURL}/auth/refresh"),
        headers: headers,
        body: body, // Tidak perlu jsonEncode untuk form-urlencoded
      );

      Map<String, dynamic> refreshTokenResponse = jsonDecode(response.body);
      if(refreshTokenResponse['status'] != true) {
        throw Exception("Session Expired, please re-login");
      }

      if(!refreshTokenResponse.containsKey("response")) {
        throw Exception("Invalid Response");
      }

      if(!refreshTokenResponse['response'].containsKey("access_token") || !refreshTokenResponse['response'].containsKey("refresh_token")) {
        throw Exception("Failed to refresh token, please re-login");
      }

      return refreshTokenResponse;

    } catch (e) {
      throw Exception(e);
    }
  }

  // Method khusus untuk withdrawal dengan multipart form-data
  Future<Map<String, dynamic>> withdrawalMultipart(
    String url,
    Map<String, String> body, {
    int maxReload = 0,
  }) async {
    try {
      await init();
      headers['Authorization'] = 'Bearer $accessToken';

      print("=== Withdrawal Multipart Request ===");
      print("URL: ${GlobalVariable.mainURL}/$url");
      print("Headers: $headers");
      print("Body: $body");

      // Buat request multipart
      http.MultipartRequest request =
          http.MultipartRequest('POST', Uri.parse("${GlobalVariable.mainURL}/$url"));
      request.headers.addAll(headers);
      request.fields.addAll(body);

      // Kirim request
      http.StreamedResponse response = await request.send();

      // Ambil response string
      String responseString = await response.stream.bytesToString();

      print("=== Withdrawal Multipart Response ===");
      print("Status Code: ${response.statusCode}");
      print("Response String: $responseString");

      // Parse JSON
      Map<String, dynamic> respBody;
      try {
        respBody = jsonDecode(responseString);
      } catch (e) {
        print("JSON Decode Error: $e");
        return {
          'status': false,
          'statusCode': response.statusCode,
          'message': 'Failed to parse server response',
          'response': [],
        };
      }

      // Handle token refresh
      if (response.statusCode == 300) {
        if (maxReload > 3) {
          throw Exception("Telah mencapai max reload, silahkan login kembali");
        }

        Map<String, dynamic> refreshTokenResponse = await refreshingToken(body: {
          'refresh_token': refreshToken ?? "",
        });

        accessToken = refreshTokenResponse['response']['access_token'];
        refreshToken = refreshTokenResponse['response']['refresh_token'];

        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString('accessToken', accessToken!);
        preferences.setString('refreshToken', refreshToken!);

        return await withdrawalMultipart(url, body, maxReload: maxReload + 1);
      }

      // Return dengan struktur yang benar
      return {
        'status': respBody['status'] ?? false,
        'statusCode': response.statusCode,
        'message': respBody['message'] ?? 'Unknown error',
        'response': respBody['response'] ?? [],
      };
    } catch (e) {
      print("Withdrawal Multipart Exception: $e");
      throw Exception("authService withdrawalMultipart error: $e");
    }
  }
}
