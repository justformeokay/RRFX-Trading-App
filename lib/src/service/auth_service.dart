import 'dart:async';
import 'dart:convert';
import 'dart:math';
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
  bool _initialized = false;

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
    if (_initialized && accessToken != null) return true;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    accessToken = preferences.getString('accessToken');
    refreshToken = preferences.getString('refreshToken');
    _initialized = true;
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

      final fullUrl = "${GlobalVariable.mainURL}/$url";
      
      // DEBUG: Log request details
      Get.log('═══════════════════════════════════════════');
      Get.log('🚀 POST REQUEST');
      Get.log('═══════════════════════════════════════════');
      Get.log('URL: $fullUrl');
      Get.log('Headers: $headers');
      Get.log('Body: $body');
      Get.log('Access Token (first 20 chars): ${accessToken?.substring(0, min(20, accessToken?.length ?? 0)) ?? 'NULL'}...');
      Get.log('───────────────────────────────────────────');

      // Add 20 second timeout to prevent indefinite hanging
      http.Response response;
      try {
        response = await http.post(
          Uri.parse(fullUrl), 
          headers: headers,
          body: body
        ).timeout(
          const Duration(seconds: 20),
          onTimeout: () => throw Exception('Request timeout - koneksi memakan waktu terlalu lama'),
        );
      } catch (e) {
        if (e.toString().contains('timeout') || e.toString().contains('terlalu lama')) {
          Get.log('⚠️ [AuthService.post] Request timeout - no response after 20 seconds');
          return {
            'status': false,
            'statusCode': 0,
            'message': 'TimeoutException: Koneksi memakan waktu terlalu lama (> 20 detik)',
            'response': {},
          };
        }
        rethrow;
      }

      // DEBUG: Log response details
      Get.log('📥 POST RESPONSE');
      Get.log('Status Code: ${response.statusCode}');
      Get.log('Response Headers: ${response.headers}');
      Get.log('Body Preview: ${response.body.length > 200 ? response.body.substring(0, 200) + '...' : response.body}');
      Get.log('Body Length: ${response.body.length} characters');
      Get.log('Body is empty: ${response.body.isEmpty}');
      Get.log('═══════════════════════════════════════════');

      // Handle server errors (5xx)
      if (response.statusCode >= 500) {
        print("❌ Server Error ${response.statusCode}");
        print("Response preview: ${response.body.substring(0, min(500, response.body.length))}");
        return {
          'status': false,
          'statusCode': response.statusCode,
          'message': 'Server error (${response.statusCode}). Please try again later.',
          'response': {},
        };
      }

      // Check if response is HTML (error page) instead of JSON
      if (response.body.trimLeft().startsWith('<') || response.body.contains('<br')) {
        print("❌ Server returned HTML instead of JSON (possibly error page)");
        print("Response preview: ${response.body.substring(0, min(500, response.body.length))}");
        return {
          'status': false,
          'statusCode': response.statusCode,
          'message': 'Server returned an error page. Please check your connection or try again later.',
          'response': {},
        };
      }

      // Handle empty response
      if (response.body.isEmpty) {
        print("❌ Server returned empty response body");
        return {
          'status': false,
          'statusCode': response.statusCode,
          'message': 'Server returned empty response',
          'response': {},
        };
      }

      if (response.statusCode == 300) {
        if(maxReload > 3) {
          return {
            'status': false,
            'statusCode': 300,
            'message': 'Max reload attempts exceeded, please login again',
            'response': {},
          };
        }
        
        Map<String, dynamic> refreshTokenResponse = await refreshingToken(body: {
          'refresh_token': refreshToken ?? "",
        });

        // Check if token refresh failed
        if (refreshTokenResponse['status'] != true) {
          print("❌ Token refresh failed: ${refreshTokenResponse['message']}");
          // Clear tokens and return error
          SharedPreferences preferences = await SharedPreferences.getInstance();
          await preferences.remove('accessToken');
          await preferences.remove('refreshToken');
          return {
            'status': false,
            'statusCode': 401,
            'message': 'Session expired, please login again',
            'response': {},
          };
        }

        // Safely access response data
        try {
          accessToken = refreshTokenResponse['response']['access_token'];
          refreshToken = refreshTokenResponse['response']['refresh_token'];
        } catch (e) {
          print("❌ Error extracting tokens from refresh response: $e");
          return {
            'status': false,
            'statusCode': 500,
            'message': 'Failed to extract tokens from refresh response',
            'response': {},
          };
        }

        // Set new access & refresh token to SharedPreferences
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString('accessToken', accessToken!);
        preferences.setString('refreshToken', refreshToken!);

        return await post(url, body, maxReload: maxReload + 1);
      }

      // Safe JSON decode
      Map<String, dynamic> respBody;
      try {
        respBody = jsonDecode(response.body);
      } catch (e) {
        print("❌ JSON Decode Error in POST: ${e.toString()}");
        print("Response preview: ${response.body.substring(0, min(500, response.body.length))}");
        print("Response Status Code: ${response.statusCode}");
        return {
          'status': false,
          'statusCode': response.statusCode,
          'message': 'Invalid server response format. Server might be down.',
          'response': {},
        };
      }
      
      // DEBUG: Log parsed response
      Get.log('✅ PARSED RESPONSE DATA');
      Get.log('Status: ${respBody['status']}');
      Get.log('Message: ${respBody['message']}');
      Get.log('Response Data: ${respBody['response']}');
      Get.log('═══════════════════════════════════════════');
      
      return {
        'status': respBody['status'],
        'statusCode': response.statusCode,
        'message': respBody['message'],
        'response': respBody['response'],
      };

    } catch (e, stackTrace) {
      final message = e.toString();
      Get.log('❌ ERROR DI AUTHSERVICE.POST: $message');
      Get.log('Stack trace: $stackTrace');
      print('❌ AuthService POST Error: $message');
      
      // Detect specific error types for better error messaging
      String errorMessage = 'Request failed: $message';
      
      if (message.contains('timeout') || message.contains('terlalu lama')) {
        errorMessage = 'TimeoutException: Koneksi memakan waktu terlalu lama (> 20 detik)';
      } else if (message.contains('Connection')) {
        errorMessage = 'SocketException: Koneksi internet terputus atau tidak tersedia';
      }
      
      // Return graceful error response instead of throwing
      return {
        'status': false,
        'statusCode': 0,
        'message': errorMessage,
        'response': {},
      };
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
          return {
            'status': false,
            'statusCode': 300,
            'message': 'Max reload attempts exceeded, please login again',
            'response': {},
          };
        }

        Map<String, dynamic> refreshTokenResponse = await refreshingToken(body: {
          'refresh_token': refreshToken ?? "",
        });

        // Check if token refresh failed
        if (refreshTokenResponse['status'] != true) {
          print("❌ Token refresh failed in multipart: ${refreshTokenResponse['message']}");
          SharedPreferences preferences = await SharedPreferences.getInstance();
          await preferences.remove('accessToken');
          await preferences.remove('refreshToken');
          return {
            'status': false,
            'statusCode': 401,
            'message': 'Session expired, please login again',
            'response': {},
          };
        }

        // Safely access response data
        try {
          accessToken = refreshTokenResponse['response']['access_token'];
          refreshToken = refreshTokenResponse['response']['refresh_token'];
        } catch (e) {
          print("❌ Error extracting tokens from refresh response in multipart: $e");
          return {
            'status': false,
            'statusCode': 500,
            'message': 'Failed to extract tokens from refresh response',
            'response': {},
          };
        }

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
    } catch (e, stackTrace) {
      print("❌ Multipart error: $e");
      print("Stack trace: $stackTrace");
      return {
        'status': false,
        'statusCode': 0,
        'message': 'Multipart request failed: ${e.toString()}',
        'response': {},
      };
    }
  }



  Future<Map<String, dynamic>> get(String url, {int maxReload = 0}) async {
    try {
      await init();
      headers['Authorization'] = 'Bearer $accessToken';

      final fullUrl = "${GlobalVariable.mainURL}/$url";
      Get.log('═══════════════════════════════════════════');
      Get.log('🚀 GET REQUEST');
      Get.log('═══════════════════════════════════════════');
      Get.log('URL: $fullUrl');
      Get.log('Headers: $headers');
      Get.log('Access Token (first 20 chars): ${accessToken?.substring(0, min(20, accessToken?.length ?? 0)) ?? 'NULL'}...');
      Get.log('───────────────────────────────────────────');

      // Add 20 second timeout to prevent indefinite hanging
      http.Response response;
      try {
        response = await http.get(
          Uri.parse(fullUrl), 
          headers: headers,
        ).timeout(
          const Duration(seconds: 20),
          onTimeout: () => throw Exception('Request timeout - koneksi memakan waktu terlalu lama'),
        );
      } catch (e) {
        if (e.toString().contains('timeout') || e.toString().contains('terlalu lama')) {
          Get.log('⚠️ [AuthService.get] Request timeout - no response after 20 seconds');
          return {
            'status': false,
            'statusCode': 0,
            'message': 'TimeoutException: Koneksi memakan waktu terlalu lama (> 20 detik)',
            'response': {},
          };
        }
        rethrow;
      }

      Get.log('📥 GET RESPONSE');
      Get.log('Status Code: ${response.statusCode}');
      Get.log('Response Headers: ${response.headers}');
      Get.log('Body Preview: ${response.body.length > 200 ? response.body.substring(0, 200) + '...' : response.body}');
      Get.log('═══════════════════════════════════════════');

      // Handle server errors (5xx) dan Cloudflare errors
      if (response.statusCode >= 500) {
        print("❌ Server Error ${response.statusCode}");
        print("Response Body: ${response.body.substring(0, min(500, response.body.length))}");
        return {
          'status': false,
          'statusCode': response.statusCode,
          'message': 'Server error (${response.statusCode}). Please try again later.',
          'response': {},
        };
      }

      // Handle Cloudflare errors (524, 520, 521, 522, 523)
      if (response.statusCode == 524 || response.statusCode == 520 || 
          response.statusCode == 521 || response.statusCode == 522 || 
          response.statusCode == 523) {
        print("❌ Cloudflare Error ${response.statusCode}");
        return {
          'status': false,
          'statusCode': response.statusCode,
          'message': 'Server timeout or unavailable. Please try again.',
          'response': {},
        };
      }

      // Cek apakah response adalah HTML (error page) bukan JSON
      if (response.body.trimLeft().startsWith('<') || response.body.contains('<br')) {
        print("❌ Server returned HTML instead of JSON (possibly error page)");
        print("Response Body: ${response.body.substring(0, min(500, response.body.length))}");
        return {
          'status': false,
          'statusCode': response.statusCode,
          'message': 'Server returned an error page. Please check your internet connection or try again later.',
          'response': {},
        };
      }

      // Handle empty response
      if (response.body.isEmpty) {
        print("❌ Server returned empty response body");
        return {
          'status': false,
          'statusCode': response.statusCode,
          'message': 'Server returned empty response',
          'response': {},
        };
      }

      if (response.statusCode == 300) {
        if(maxReload > 3) {
          return {
            'status': false,
            'statusCode': 300,
            'message': 'Max reload attempts exceeded, please login again',
            'response': {},
          };
        }
        
        Map<String, dynamic> refreshTokenResponse = await refreshingToken(body: {
          'refresh_token': refreshToken ?? "",
        });

        // Check if token refresh failed
        if (refreshTokenResponse['status'] != true) {
          print("❌ Token refresh failed in GET: ${refreshTokenResponse['message']}");
          SharedPreferences preferences = await SharedPreferences.getInstance();
          await preferences.remove('accessToken');
          await preferences.remove('refreshToken');
          return {
            'status': false,
            'statusCode': 401,
            'message': 'Session expired, please login again',
            'response': {},
          };
        }

        // Safely access response data
        try {
          accessToken = refreshTokenResponse['response']['access_token'];
          refreshToken = refreshTokenResponse['response']['refresh_token'];
        } catch (e) {
          print("❌ Error extracting tokens from refresh response in GET: $e");
          return {
            'status': false,
            'statusCode': 500,
            'message': 'Failed to extract tokens from refresh response',
            'response': {},
          };
        }

        // Set new access & refresh token to SharedPreferences
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString('accessToken', accessToken!);
        preferences.setString('refreshToken', refreshToken!);

        return await get(url, maxReload: maxReload + 1);
      }

      // Safe JSON decode
      Map<String, dynamic> respBody;
      try {
        respBody = jsonDecode(response.body);
      } catch (e) {
        print("❌ JSON Decode Error: ${e.toString()}");
        print("Response Body: ${response.body.substring(0, min(500, response.body.length))}");
        print("Response Status Code: ${response.statusCode}");
        return {
          'status': false,
          'statusCode': response.statusCode,
          'message': 'Invalid server response format. Server might be down.',
          'response': {},
        };
      }

      return {
        'status': respBody['status'],
        'statusCode': response.statusCode,
        'message': respBody['message'],
        'response': respBody['response'],
      };
    } catch (e, stackTrace) {
      final message = e.toString();
      print("❌ Exception di AuthService.get(): URL=$url, Error=$message");
      print("Stack trace: $stackTrace");
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
      
      // Detect specific error types for better error messaging
      String errorMessage = 'Network error: ${e.toString()}';
      
      if (message.contains('timeout') || message.contains('terlalu lama')) {
        errorMessage = 'TimeoutException: Koneksi memakan waktu terlalu lama (> 20 detik)';
      } else if (message.contains('Connection')) {
        errorMessage = 'SocketException: Koneksi internet terputus atau tidak tersedia';
      }
      
      // Return error response instead of throwing
      return {
        'status': false,
        'statusCode': 500,
        'message': errorMessage,
        'response': {},
      };
    }
  }

  Future<Map<String, dynamic>> getCustomURL(String url, {int maxReload = 0}) async {
    try {
      await init();
      headers['Authorization'] = 'Bearer $accessToken';

      Get.log('═══════════════════════════════════════════');
      Get.log('🚀 GET CUSTOM URL REQUEST');
      Get.log('═══════════════════════════════════════════');
      Get.log('URL: $url');
      Get.log('Headers: $headers');
      Get.log('───────────────────────────────────────────');

      http.Response response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      Get.log('📥 GET CUSTOM URL RESPONSE');
      Get.log('Status Code: ${response.statusCode}');
      Get.log('Body Preview: ${response.body.length > 200 ? response.body.substring(0, 200) + '...' : response.body}');
      Get.log('═══════════════════════════════════════════');

      // Check if response is HTML (error page)
      if (response.body.trimLeft().startsWith('<') || response.body.contains('<br')) {
        print("❌ Server returned HTML instead of JSON");
        return {
          'status': false,
          'statusCode': response.statusCode,
          'message': 'Server returned an error page.',
          'response': {},
        };
      }

      // Handle empty response
      if (response.body.isEmpty) {
        return {
          'status': false,
          'statusCode': response.statusCode,
          'message': 'Server returned empty response',
          'response': {},
        };
      }

      if (response.statusCode == 300) {
        if(maxReload > 3) {
          return {
            'status': false,
            'statusCode': 300,
            'message': 'Max reload attempts exceeded, please login again',
            'response': {},
          };
        }

        Map<String, dynamic> refreshTokenResponse = await refreshingToken(body: {
          'refresh_token': refreshToken ?? "",
        });

        // Check if token refresh failed
        if (refreshTokenResponse['status'] != true) {
          print("❌ Token refresh failed in getCustomURL: ${refreshTokenResponse['message']}");
          SharedPreferences preferences = await SharedPreferences.getInstance();
          await preferences.remove('accessToken');
          await preferences.remove('refreshToken');
          return {
            'status': false,
            'statusCode': 401,
            'message': 'Session expired, please login again',
            'response': {},
          };
        }

        // Safely access response data
        try {
          accessToken = refreshTokenResponse['response']['access_token'];
          refreshToken = refreshTokenResponse['response']['refresh_token'];
        } catch (e) {
          print("❌ Error extracting tokens from refresh response in getCustomURL: $e");
          return {
            'status': false,
            'statusCode': 500,
            'message': 'Failed to extract tokens from refresh response',
            'response': {},
          };
        }

        // Set new access & refresh token to SharedPreferences
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString('accessToken', accessToken!);
        preferences.setString('refreshToken', refreshToken!);

        return await getCustomURL(url, maxReload: maxReload + 1);
      }

      // Safe JSON decode
      Map<String, dynamic> respBody;
      try {
        respBody = jsonDecode(response.body);
      } catch (e) {
        print("❌ JSON Decode Error in getCustomURL: ${e.toString()}");
        return {
          'status': false,
          'statusCode': response.statusCode,
          'message': 'Invalid server response format.',
          'response': {},
        };
      }

      return {
        'status': respBody['status'],
        'statusCode': response.statusCode,
        'message': respBody['message'],
        'response': respBody['response'],
      };
    } catch (e, stackTrace) {
      print("❌ Exception di AuthService.getCustomURL(): URL=$url, Error=${e.toString()}");
      print("Stack trace: $stackTrace");
      return {
        'status': false,
        'statusCode': 500,
        'message': 'Network error: ${e.toString()}',
        'response': {},
      };
    }
  }

  Future<Map<String, dynamic>> refreshingToken({required Map<String, dynamic> body}) async {
    try {
      Get.log('═══════════════════════════════════════════');
      Get.log('🔄 REFRESHING TOKEN REQUEST');
      Get.log('═══════════════════════════════════════════');
      Get.log('URL: ${GlobalVariable.mainURL}/auth/refresh');
      Get.log('Body: $body');
      Get.log('───────────────────────────────────────────');

      http.Response response = await http.post(
        Uri.parse("${GlobalVariable.mainURL}/auth/refresh"),
        headers: headers,
        body: body,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Token refresh timeout'),
      );

      Get.log('📥 REFRESH TOKEN RESPONSE');
      Get.log('Status Code: ${response.statusCode}');
      Get.log('Body Preview: ${response.body.length > 200 ? response.body.substring(0, 200) + '...' : response.body}');
      Get.log('═══════════════════════════════════════════');

      // Handle server errors (5xx)
      if (response.statusCode >= 500) {
        print("❌ Server Error ${response.statusCode} when refreshing token");
        return {
          'status': false,
          'statusCode': response.statusCode,
          'message': 'Server error while refreshing token',
          'response': {},
        };
      }

      // Check if response is HTML (error page)
      if (response.body.trimLeft().startsWith('<') || response.body.contains('<br')) {
        print("❌ Server returned HTML instead of JSON when refreshing token");
        print("Response preview: ${response.body.substring(0, min(500, response.body.length))}");
        return {
          'status': false,
          'statusCode': response.statusCode,
          'message': 'Server error page, token refresh failed',
          'response': {},
        };
      }

      // Handle empty response
      if (response.body.isEmpty) {
        print("❌ Empty response when refreshing token");
        return {
          'status': false,
          'statusCode': response.statusCode,
          'message': 'Empty response from server',
          'response': {},
        };
      }

      // Safe JSON decode
      Map<String, dynamic> refreshTokenResponse;
      try {
        refreshTokenResponse = jsonDecode(response.body);
      } catch (e) {
        print("❌ JSON Decode Error in refreshingToken: ${e.toString()}");
        print("Response: ${response.body.substring(0, min(500, response.body.length))}");
        return {
          'status': false,
          'statusCode': response.statusCode,
          'message': 'Invalid token response format',
          'response': {},
        };
      }

      // Validate response structure
      if (refreshTokenResponse['status'] != true) {
        print("❌ Token refresh failed: status is not true");
        return {
          'status': false,
          'statusCode': response.statusCode,
          'message': refreshTokenResponse['message'] ?? 'Session Expired, please re-login',
          'response': {},
        };
      }

      if (!refreshTokenResponse.containsKey("response")) {
        print("❌ Token refresh response missing 'response' key");
        return {
          'status': false,
          'statusCode': response.statusCode,
          'message': 'Invalid Response structure',
          'response': {},
        };
      }

      if (!refreshTokenResponse['response'].containsKey("access_token") || 
          !refreshTokenResponse['response'].containsKey("refresh_token")) {
        print("❌ Token refresh response missing access_token or refresh_token");
        return {
          'status': false,
          'statusCode': response.statusCode,
          'message': 'Failed to refresh token - missing token fields',
          'response': {},
        };
      }

      Get.log('✅ TOKEN REFRESH SUCCESS');
      Get.log('New access token received: ${refreshTokenResponse['response']['access_token']?.substring(0, 20)}...');
      Get.log('═══════════════════════════════════════════');

      return refreshTokenResponse;

    } catch (e, stackTrace) {
      print("❌ Exception in refreshingToken(): ${e.toString()}");
      print("Stack trace: $stackTrace");
      
      // Return graceful error response instead of throwing
      return {
        'status': false,
        'statusCode': 0,
        'message': 'Token refresh failed: ${e.toString()}',
        'response': {},
      };
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
          return {
            'status': false,
            'statusCode': 300,
            'message': 'Max reload attempts exceeded, please login again',
            'response': [],
          };
        }

        Map<String, dynamic> refreshTokenResponse = await refreshingToken(body: {
          'refresh_token': refreshToken ?? "",
        });

        // Check if token refresh failed
        if (refreshTokenResponse['status'] != true) {
          print("❌ Token refresh failed in withdrawalMultipart: ${refreshTokenResponse['message']}");
          SharedPreferences preferences = await SharedPreferences.getInstance();
          await preferences.remove('accessToken');
          await preferences.remove('refreshToken');
          return {
            'status': false,
            'statusCode': 401,
            'message': 'Session expired, please login again',
            'response': [],
          };
        }

        // Safely access response data
        try {
          accessToken = refreshTokenResponse['response']['access_token'];
          refreshToken = refreshTokenResponse['response']['refresh_token'];
        } catch (e) {
          print("❌ Error extracting tokens from refresh response in withdrawalMultipart: $e");
          return {
            'status': false,
            'statusCode': 500,
            'message': 'Failed to extract tokens from refresh response',
            'response': [],
          };
        }

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
    } catch (e, stackTrace) {
      print("❌ Withdrawal Multipart Exception: $e");
      print("Stack trace: $stackTrace");
      return {
        'status': false,
        'statusCode': 0,
        'message': 'Withdrawal request failed: ${e.toString()}',
        'response': [],
      };
    }
  }
}
