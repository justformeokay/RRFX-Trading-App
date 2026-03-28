// ignore_for_file: avoid_print
/// Development-only CORS proxy server for Flutter Web.
/// Run: dart run proxy_server.dart
/// Then run Flutter web: flutter run -d chrome
///
/// This proxies /api/* requests to the real API, adding CORS headers.
import 'dart:io';
import 'dart:convert';

const String targetHost = 'api-rrfx.luxurymatrix.com';
const int proxyPort = 8089;

void main() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, proxyPort);
  print('🚀 CORS Proxy running on http://localhost:$proxyPort');
  print('   Proxying /api/* → https://$targetHost/*');
  print('   Press Ctrl+C to stop.\n');

  await for (final request in server) {
    _handleRequest(request);
  }
}

Future<void> _handleRequest(HttpRequest request) async {
  final response = request.response;

  // Add CORS headers to every response
  response.headers.set('Access-Control-Allow-Origin', '*');
  response.headers.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS');
  response.headers.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  response.headers.set('Access-Control-Max-Age', '86400');

  // Handle preflight
  if (request.method == 'OPTIONS') {
    response.statusCode = 200;
    await response.close();
    return;
  }

  // Only proxy /api paths
  final path = request.uri.path;
  if (!path.startsWith('/api')) {
    response.statusCode = 404;
    response.write('Not found');
    await response.close();
    return;
  }

  // Strip /api prefix and forward
  final targetPath = path.replaceFirst('/api', '');
  final targetUri = Uri.https(targetHost, targetPath, request.uri.queryParametersAll);

  try {
    final client = HttpClient();
    final proxyRequest = await client.openUrl(request.method, targetUri);

    // Forward headers (except host)
    request.headers.forEach((name, values) {
      if (name.toLowerCase() != 'host') {
        for (final v in values) {
          proxyRequest.headers.add(name, v);
        }
      }
    });
    proxyRequest.headers.set('Host', targetHost);

    // Forward body
    final body = await utf8.decodeStream(request);
    if (body.isNotEmpty) {
      proxyRequest.write(body);
    }

    final proxyResponse = await proxyRequest.close();

    // Copy status + headers back
    response.statusCode = proxyResponse.statusCode;
    proxyResponse.headers.forEach((name, values) {
      // Skip hop-by-hop headers
      if (!const ['transfer-encoding', 'connection', 'access-control-allow-origin']
          .contains(name.toLowerCase())) {
        for (final v in values) {
          response.headers.add(name, v);
        }
      }
    });

    await proxyResponse.pipe(response);
    client.close(force: false);

    print('[${request.method}] $targetUri → ${proxyResponse.statusCode}');
  } catch (e) {
    print('❌ Proxy error: $e');
    response.statusCode = 502;
    response.write('Proxy error: $e');
    await response.close();
  }
}
