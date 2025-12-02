class HttpRequestException implements Exception {
  final String message;
  final int statusCode;

  HttpRequestException(this.message, {required this.statusCode});

  @override
  String toString() => 'HttpRequestException ($statusCode): $message';
}