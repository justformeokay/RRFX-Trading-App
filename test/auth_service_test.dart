import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:rrfx/src/service/auth_service.dart';

@GenerateMocks([AuthService])
void main() {
  
  group('AuthService Tests', () {
    test('should send correct login data', () async {
      final authService = AuthService();
      
      // Data yang akan dikirim
      final body = {
        'email': 'bomba1@yopmail.com',
        'password': 'YW1GdVoyRnVJRzVoYTJGcw',
      };

      // Act - Melakukan request sebenarnya
      final result = await authService.post("auth/login", body);
      
      // Memastikan response memiliki format yang benar
      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey("response"), true);
      expect(result['response'].containsKey("access_token"), true);
      expect(result['response'].containsKey("refresh_token"), true);
    });

    test('should return new access & refresh token', () async {
      final authService = AuthService();
      final body = {
        'refresh_token': '',
      };
      final result = await authService.refreshingToken(body: body);
      expect(result, isA<Map<String, dynamic>>());
      expect(result['status'], true);
    });


    test('should return new access & refresh token if response code 300', () async {
      final authService = AuthService();
      
      final fetchProfile = await authService.get("profile/info");

      expect(fetchProfile, isA<Map<String, dynamic>>());
      expect(fetchProfile.containsKey("status"), true);
    });
  });
}
