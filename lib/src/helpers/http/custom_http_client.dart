import 'package:http/http.dart' as http;

/// Custom HTTP client yang bisa handle status code 300
class CustomHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _inner.send(request).then((response) {
      // Handle status code 300 dan redirect lainnya
      if (response.statusCode == 300 || 
          (response.statusCode >= 300 && response.statusCode < 400)) {
        // Return 200 untuk redirect responses agar bisa di-process
        print('[CustomHttpClient] Handling redirect status ${response.statusCode} for ${request.url}');
        return http.StreamedResponse(
          response.stream,
          200, // Override to 200
          request: response.request,
          headers: response.headers,
          isRedirect: response.isRedirect,
        );
      }
      return response;
    });
  }
}

/// Create custom http client untuk image loading
final customHttpClient = CustomHttpClient();
