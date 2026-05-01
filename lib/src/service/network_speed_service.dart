import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class NetworkSpeedService {
  /// Mengukur network speed dengan mengirim HTTP request kecil (latency check)
  /// Returns latency dalam milliseconds
  static Future<int?> measureNetworkSpeed({
    String url = 'https://www.google.com',
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final stopwatch = Stopwatch()..start();
      
      final response = await http
          .head(
            Uri.parse(url),
            headers: {
              'Connection': 'keep-alive',
            },
          )
          .timeout(timeout);
      
      stopwatch.stop();
      
      if (response.statusCode == 200 || response.statusCode == 301 || response.statusCode == 302) {
        return stopwatch.elapsedMilliseconds;
      }
      
      return stopwatch.elapsedMilliseconds;
    } catch (e) {
      // print('Network Speed Error: $e');
      return null;
    }
  }

  /// Mengukur network speed dengan download file kecil (lebih akurat)
  /// Returns speed dalam Mbps (megabits per second)
  static Future<double?> measureDownloadSpeed({
    String url = 'https://httpbin.org/delay/0',
    Duration timeout = const Duration(seconds: 15),
  }) async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = timeout;
      dio.options.receiveTimeout = timeout;
      dio.options.sendTimeout = timeout;

      final stopwatch = Stopwatch()..start();
      
      final response = await dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          receiveDataWhenStatusError: true,
        ),
      );

      stopwatch.stop();

      if (response.statusCode == 200 && response.data != null) {
        final bytes = response.data as List<int>;
        final sizeInBits = bytes.length * 8;
        final timeInSeconds = stopwatch.elapsedMilliseconds / 1000;
        
        if (timeInSeconds > 0) {
          final speedInBps = sizeInBits / timeInSeconds;
          final speedInMbps = speedInBps / (1000 * 1000);
          
          // print('Download Speed: ${speedInMbps.toStringAsFixed(2)} Mbps (${bytes.length} bytes in ${stopwatch.elapsedMilliseconds}ms)');
          return speedInMbps;
        }
      }
      return null;
    } catch (e) {
      // print('Download Speed Error: $e');
      return null;
    }
  }

  /// Mengukur network latency dengan multiple ping requests (lebih akurat)
  /// Returns latency dalam milliseconds
  static Future<int?> measureLatency({
    String url = 'https://www.google.com/favicon.ico',
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final stopwatch = Stopwatch()..start();
      
      // Clear DNS cache dengan menggunakan berbagai domain untuk first request
      final response = await http
          .get(
            Uri.parse(url),
          )
          .timeout(timeout);
      
      stopwatch.stop();
      
      // Hanya return latency jika response successful
      if (response.statusCode == 200) {
        return stopwatch.elapsedMilliseconds;
      }
      
      return stopwatch.elapsedMilliseconds;
    } catch (e) {
      // print('Latency Measurement Error: $e');
      return null;
    }
  }

  /// Mengukur network speed dengan retry logic
  /// Melakukan beberapa kali pengukuran untuk hasil yang lebih akurat
  /// Sekarang mengukur latency pertama, kemudian opsi download speed
  static Future<int?> measureNetworkSpeedWithRetry({
    int retryCount = 3,
    String url = 'https://www.google.com',
  }) async {
    final results = <int>[];
    
    // Skip first request (usually slower due to DNS/connection setup)
    try {
      await measureLatency(url: 'https://www.google.com/favicon.ico');
      await Future.delayed(const Duration(milliseconds: 200));
    } catch (_) {}
    
    // Measure actual latency multiple times
    for (int i = 0; i < retryCount; i++) {
      try {
        final speed = await measureLatency(url: url);
        if (speed != null) {
          results.add(speed);
          // print('Latency attempt $i: ${speed}ms');
        }
        // Delay antar pengukuran untuk menghindari rate limiting
        await Future.delayed(const Duration(milliseconds: 300));
      } catch (e) {
        // print('Retry $i failed: $e');
      }
    }
    
    if (results.isEmpty) return null;
    
    // Return median dari semua pengukuran (lebih akurat dari rata-rata)
    results.sort();
    if (results.length.isEven) {
      return ((results[results.length ~/ 2 - 1] + results[results.length ~/ 2]) / 2).round();
    } else {
      return results[results.length ~/ 2];
    }
  }

  /// Mengukur download speed dengan file kecil
  /// Returns speed dalam Mbps
  static Future<double?> measureNetworkSpeedDownloadWithRetry({
    int retryCount = 2,
    String url = 'https://httpbin.org/bytes/100000', // 100KB file
  }) async {
    final results = <double>[];
    
    for (int i = 0; i < retryCount; i++) {
      try {
        final speed = await measureDownloadSpeed(url: url);
        if (speed != null && speed > 0) {
          results.add(speed);
          // print('Download speed attempt $i: ${speed.toStringAsFixed(2)} Mbps');
        }
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        // print('Download retry $i failed: $e');
      }
    }
    
    if (results.isEmpty) return null;
    
    // Return rata-rata dari semua pengukuran
    return results.reduce((a, b) => a + b) / results.length;
  }
}
