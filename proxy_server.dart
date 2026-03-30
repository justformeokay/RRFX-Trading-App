// ignore_for_file: avoid_print
/// Development-only CORS proxy server for Flutter Web.
/// Run: dart run proxy_server.dart
/// Then run Flutter web: flutter run -d chrome
///
/// Routes:
///   /api/*      → https://api-rrfx.luxurymatrix.com/*
///   /gateway/*  → https://gateway.rrfx.co.id/*
///   /mt5/*      → https://api-mt5.techcrm.net/*
import 'dart:io';
import 'dart:convert';

const int proxyPort = 8089;

/// Route prefix → target host
const Map<String, String> routes = {
  '/api': 'api-rrfx.luxurymatrix.com',
  '/gateway': 'gateway.rrfx.co.id',
  '/mt5': 'api-mt5.techcrm.net',
};

void main() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, proxyPort);
  print('🚀 CORS Proxy running on http://localhost:$proxyPort');
  for (final entry in routes.entries) {
    print('   ${entry.key}/* → https://${entry.value}/*');
  }
  print('   Press Ctrl+C to stop.\n');

  await for (final request in server) {
    _handleRequest(request);
  }
}

Future<void> _handleRequest(HttpRequest request) async {
  final response = request.response;

  // Handle preflight
  if (request.method == 'OPTIONS') {
    response.statusCode = 200;
    _addCorsHeaders(response);
    await response.close();
    return;
  }

  // Only proxy known route prefixes
  final path = request.uri.path;
  String? matchedPrefix;
  String? targetHost;
  for (final entry in routes.entries) {
    if (path.startsWith(entry.key)) {
      matchedPrefix = entry.key;
      targetHost = entry.value;
      break;
    }
  }

  if (matchedPrefix == null || targetHost == null) {
    response.statusCode = 404;
    _addCorsHeaders(response);
    response.write('Not found');
    await response.close();
    return;
  }

  // Strip prefix and forward
  final targetPath = path.replaceFirst(matchedPrefix, '');
  final targetUri = Uri.https(targetHost, targetPath, request.uri.queryParametersAll);

  try {
    final client = HttpClient();
    final proxyRequest = await client.openUrl(request.method, targetUri);

    // Forward headers (except host and origin)
    request.headers.forEach((name, values) {
      final lower = name.toLowerCase();
      if (lower != 'host' && lower != 'origin') {
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

    // Set status
    response.statusCode = proxyResponse.statusCode;

    // Copy safe response headers (skip hop-by-hop and CORS)
    const skipHeaders = {
      'transfer-encoding', 'connection', 'keep-alive',
      'access-control-allow-origin', 'access-control-allow-methods',
      'access-control-allow-headers', 'access-control-max-age',
    };
    proxyResponse.headers.forEach((name, values) {
      if (!skipHeaders.contains(name.toLowerCase())) {
        for (final v in values) {
          response.headers.add(name, v);
        }
      }
    });

    // Add CORS headers AFTER copying upstream headers
    _addCorsHeaders(response);

    // Read full body and write it (avoid pipe issues with chunked encoding)
    final responseBody = await proxyResponse.fold<List<int>>(
      [],
      (list, chunk) => list..addAll(chunk),
    );
    response.add(responseBody);
    await response.close();
    client.close(force: false);

    print('[${request.method}] $targetUri → ${proxyResponse.statusCode}');
  } catch (e) {
    print('❌ Proxy error: $e');
    response.statusCode = 502;
    _addCorsHeaders(response);
    response.write('Proxy error: $e');
    await response.close();
  }
}

void _addCorsHeaders(HttpResponse response) {
  response.headers.set('Access-Control-Allow-Origin', '*');
  response.headers.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS');
  response.headers.set('Access-Control-Allow-Headers', '*');
  response.headers.set('Access-Control-Max-Age', '86400');
}
