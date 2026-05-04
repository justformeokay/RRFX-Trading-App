import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/service/auth_service.dart';
import 'package:rrfx/src/views/accounts/components/change_mt5_password.dart';

/// Service untuk fetch & cache kredensial akun trading (login, password, server, token)
/// dari API market/account/list dan MT5 Connect API.
///
/// Data disimpan di GetStorage dengan encoding base64 agar tidak plain text.
/// Hanya fetch ulang jika:
/// - Belum ada data lokal
/// - Dipaksa via [forceRefresh]
class AccountCredentialsService {
  static const String _storageKey = 'acct_creds_enc';
  static String get _mt5ConnectBase => GlobalVariable.tradingApiBase;
  static final GetStorage _storage = GetStorage();

  /// In-memory cache agar tidak perlu base64 decode setiap kali lookup
  static List<Map<String, dynamic>>? _memoryCache;

  /// Flag untuk INVALID_ACCOUNT yang tertunda redirect
  /// Disimpan di sini, di-consume oleh main page setelah user benar-benar masuk
  static String? _pendingInvalidAccount;

  /// Cek apakah ada pending INVALID_ACCOUNT redirect.
  /// Jika ada, navigate ke ChangeMT5PasswordPage dan clear flag.
  /// Panggil ini dari main page onInit/initState.
  static void checkPendingInvalidAccount() {
    final user = _pendingInvalidAccount;
    if (user != null) {
      _pendingInvalidAccount = null;
      // Get.log('🔒 [AcctCreds] Pending INVALID_ACCOUNT → arahkan ke ubah password untuk $user');
      Get.to(() => ChangeMT5PasswordPage(mt5AccountId: user));
    }
  }

  /// Fetch kredensial dari API, simpan ke lokal, lalu fetch token MT5 per akun.
  /// Jika sudah ada data lokal dan [forceRefresh] false, skip fetch credentials.
  /// Setelah itu, cek apakah tiap akun sudah punya token — jika belum, fetch.
  /// Return true jika berhasil.
  static Future<bool> fetchAndCache({bool forceRefresh = false}) async {
    // Step 1: Fetch credentials dari API jika belum ada
    if (forceRefresh || !hasCachedData()) {
      try {
        final authService = Get.find<AuthService>();
        final result = await authService.get('market/account/list');

        if (result['status'] == true && result['response'] != null) {
          final List<dynamic> accounts = result['response'];
          await _saveToStorage(accounts);
          // Get.log('✅ [AcctCreds] ${accounts.length} akun berhasil disimpan.');
        } else {
          // Get.log('⚠️ [AcctCreds] API response tidak sukses: ${result['message']}');
          return false;
        }
      } catch (e) {
        // Get.log('❌ [AcctCreds] Error fetching credentials: $e');
        return false;
      }
    } else {
      // Get.log('✅ [AcctCreds] Data sudah ada di lokal, skip fetch.');
    }

    // Step 2: Fetch token MT5 untuk setiap akun yang belum punya token
    await _fetchMissingTokens();

    return true;
  }

  /// Fetch token MT5 Connect untuk akun-akun yang belum punya token (parallel)
  static Future<void> _fetchMissingTokens() async {
    final credentials = getCachedCredentials();
    if (credentials == null || credentials.isEmpty) return;

    // Kumpulkan index akun yang perlu fetch token
    final pending = <int>[];
    for (int i = 0; i < credentials.length; i++) {
      final cred = credentials[i];
      if (cred['token'] != null && cred['token'].toString().isNotEmpty) {
        // Get.log('✅ [AcctCreds] Token sudah ada untuk login ${cred['login']}, skip.');
        continue;
      }
      final login = cred['login']?.toString() ?? '';
      final password = cred['password']?.toString() ?? '';
      final server = cred['server']?.toString() ?? '';
      if (login.isEmpty || password.isEmpty || server.isEmpty) {
        // Get.log('⚠️ [AcctCreds] Data tidak lengkap untuk index $i, skip.');
        continue;
      }
      pending.add(i);
    }

    if (pending.isEmpty) return;

    // Get.log('🔗 [AcctCreds] Fetching ${pending.length} token(s) in parallel...');

    // Fetch token dengan concurrency max 2 \u2014 prevents N parallel HTTP spikes at startup
    final results = <MapEntry<int, String?>>[];
    const concurrency = 2;
    for (var start = 0; start < pending.length; start += concurrency) {
      final batch = pending.sublist(start, (start + concurrency).clamp(0, pending.length));
      final batchResults = await Future.wait(
        batch.map((i) async {
          final cred = credentials[i];
          final login = cred['login'].toString();
          try {
            final token = await _connectMT5(
              user: login,
              password: cred['password'].toString(),
              host: cred['server'].toString(),
            );
            return MapEntry(i, token);
          } catch (e) {
            return MapEntry(i, null);
          }
        }),
        eagerError: false,
      );
      results.addAll(batchResults);
    }

    // Update credentials dengan token yang berhasil
    bool updated = false;
    for (final entry in results) {
      final token = entry.value;
      if (token != null && token.isNotEmpty) {
        credentials[entry.key]['token'] = token;
        updated = true;
        // Get.log('✅ [AcctCreds] Token berhasil didapat untuk login ${credentials[entry.key]['login']}');
      }
    }

    // Simpan ulang jika ada update
    if (updated) {
      await _saveToStorage(credentials);
      // Get.log('💾 [AcctCreds] Data dengan token baru berhasil disimpan.');
    }
  }

  /// Panggil MT5 Connect API untuk mendapatkan token
  static Future<String?> _connectMT5({
    required String user,
    required String password,
    required String host,
  }) async {
    if (kDebugMode) print("🔗 [AcctCreds] Connecting MT5 for user $user at host $host...");
    final uri = Uri.parse(
      '$_mt5ConnectBase/Connect'
      '?user=$user'
      '&password=${Uri.encodeComponent(password)}'
      '&host=$host'
      '&port=443'
      '&connectTimeoutSeconds=30'
      '&downloadOrderHistory=false'
      '&reconnectOnSymbolUpdate=false',
    );

    // Get.log('🔗 [AcctCreds] Connecting MT5 for user $user...');

    final response = await http.get(
      uri,
      headers: {'accept': 'text/plain'},
    ).timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw Exception('MT5 Connect timeout'),
    );

    if (response.statusCode == 200) {
      final token = response.body.trim();
      // Validate token format (UUID-like)
      if (token.isNotEmpty && !token.startsWith('{')) {
        return token;
      }
      // Get.log('⚠️ [AcctCreds] Response bukan token valid: $token');
      return null;
    } else {
      // Get.log('❌ [AcctCreds] MT5 Connect error ${response.statusCode}: ${response.body}');

      // Parse error response untuk cek INVALID_ACCOUNT
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (kDebugMode) print("🔍 [AcctCreds] MT5 Connect error response: $data");
        if (data['code'] == 'INVALID_ACCOUNT') {
          // Get.log('🔒 [AcctCreds] INVALID_ACCOUNT untuk user $user → simpan flag');
          _pendingInvalidAccount = user;
        }
      } catch (_) {}

      return null;
    }
  }

  /// Simpan data ke GetStorage dengan encoding base64 + update memory cache
  static Future<void> _saveToStorage(List<dynamic> accounts) async {
    final jsonStr = jsonEncode(accounts);
    final encoded = base64Encode(utf8.encode(jsonStr));
    await _storage.write(_storageKey, encoded);
    // Update in-memory cache
    _memoryCache = accounts.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Baca data — prioritas dari memory cache, fallback ke GetStorage
  static List<Map<String, dynamic>>? getCachedCredentials() {
    // Return memory cache jika ada
    if (_memoryCache != null && _memoryCache!.isNotEmpty) return _memoryCache;

    try {
      final encoded = _storage.read<String>(_storageKey);
      if (encoded == null || encoded.isEmpty) return null;

      final jsonStr = utf8.decode(base64Decode(encoded));
      final List<dynamic> decoded = jsonDecode(jsonStr);
      _memoryCache = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      return _memoryCache;
    } catch (e) {
      // Get.log('❌ [AcctCreds] Error reading cached credentials: $e');
      return null;
    }
  }

  /// Ambil kredensial untuk login ID tertentu
  static Map<String, dynamic>? getCredentialByLogin(String login) {
    final credentials = getCachedCredentials();
    if (credentials == null) return null;
    return credentials.firstWhereOrNull((c) => c['login'] == login);
  }

  /// Ambil token MT5 untuk login ID tertentu
  static String? getTokenByLogin(String login) {
    final cred = getCredentialByLogin(login);
    return cred?['token']?.toString();
  }

  /// Refresh token MT5 untuk login tertentu (dipanggil saat INVALID_TOKEN)
  /// Memanggil ulang /Connect API, update token di storage, return token baru.
  static Future<String?> refreshTokenForLogin(String login) async {
    final credentials = getCachedCredentials();
    if (credentials == null || credentials.isEmpty) return null;

    final index = credentials.indexWhere((c) => c['login']?.toString() == login);
    if (index == -1) {
      // Get.log('⚠️ [AcctCreds] Login $login tidak ditemukan di cache.');
      return null;
    }

    final cred = credentials[index];
    final password = cred['password']?.toString() ?? '';
    final server = cred['server']?.toString() ?? '';

    if (password.isEmpty || server.isEmpty) {
      // Get.log('⚠️ [AcctCreds] Data tidak lengkap untuk login $login.');
      return null;
    }

    try {
      // Get.log('🔄 [AcctCreds] Refreshing token untuk login $login...');
      final token = await _connectMT5(
        user: login,
        password: password,
        host: server,
      );

      if (token != null && token.isNotEmpty) {
        credentials[index]['token'] = token;
        await _saveToStorage(credentials);
        // Get.log('✅ [AcctCreds] Token baru berhasil disimpan untuk login $login');
        return token;
      } else {
        // Get.log('⚠️ [AcctCreds] Token kosong saat refresh untuk login $login');
        return null;
      }
    } catch (e) {
      // Get.log('❌ [AcctCreds] Gagal refresh token untuk login $login: $e');
      return null;
    }
  }

  /// Cek apakah ada data lokal
  static bool hasCachedData() {
    try {
      final encoded = _storage.read<String>(_storageKey);
      return encoded != null && encoded.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Hapus data lokal (untuk logout)
  static Future<void> clearCache() async {
    try {
      _memoryCache = null;
      await _storage.remove(_storageKey);
      // Get.log('✅ [AcctCreds] Cache cleared.');
    } catch (e) {
      // Get.log('❌ [AcctCreds] Error clearing cache: $e');
    }
  }
}
