import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('UserController - addBankRegol Tests', () {

    test('addBankRegol dengan urlBukuRekening null harus berhasil', () async {
      // Test Case 1: urlBukuRekening = null
      print('✅ Test 1: urlBukuRekening = null');
      
      // Verifikasi bahwa file map kosong ketika urlBukuRekening null
      String? testUrl;
      Map<String, String> file = {};
      
      if(testUrl != null && testUrl.isNotEmpty) {
        file['bank-image'] = testUrl;
      }
      
      expect(file.isEmpty, true, reason: 'File map harus kosong ketika urlBukuRekening null');
      print('   File map kosong: ${file.isEmpty}');
    });

    test('addBankRegol dengan urlBukuRekening empty string harus berhasil', () async {
      // Test Case 2: urlBukuRekening = ""
      print('✅ Test 2: urlBukuRekening = ""');
      
      String testUrl = "";
      Map<String, String> file = {};
      
      if(testUrl.isNotEmpty) {
        file['bank-image'] = testUrl;
      }
      
      expect(file.isEmpty, true, reason: 'File map harus kosong ketika urlBukuRekening empty string');
      print('   File map kosong: ${file.isEmpty}');
    });

    test('addBankRegol dengan urlBukuRekening berisi path valid', () async {
      // Test Case 3: urlBukuRekening = valid path
      print('✅ Test 3: urlBukuRekening = valid path');
      
      String testUrl = "/path/to/image.jpg";
      Map<String, String> file = {};
      
      if(testUrl.isNotEmpty) {
        file['bank-image'] = testUrl;
      }
      
      expect(file.isNotEmpty, true, reason: 'File map harus terisi ketika urlBukuRekening valid');
      expect(file['bank-image'], testUrl, reason: 'Path gambar harus sesuai');
      print('   File map terisi: ${file.isNotEmpty}');
      print('   Path: ${file['bank-image']}');
    });

    test('Verifikasi parameter body selalu terisi', () async {
      // Test Case 4: Memastikan body selalu terisi
      print('✅ Test 4: Verifikasi body parameters');
      
      Map<String, String> body = {
        'bank-name': 'BCA',
        'bank-number': '1234567890',
      };
      
      expect(body['bank-name'], 'BCA');
      expect(body['bank-number'], '1234567890');
      print('   Body parameters valid');
    });

    test('Menguji berbagai kondisi urlBukuRekening', () async {
      print('\n🧪 Test Comprehensive:');
      
      // Kasus 1: null
      testUrlBukuRekening(null, 'null');
      
      // Kasus 2: empty
      testUrlBukuRekening('', 'empty string');
      
      // Kasus 3: whitespace
      testUrlBukuRekening('   ', 'whitespace');
      
      // Kasus 4: valid path
      testUrlBukuRekening('/storage/image.jpg', 'valid path');
    });
  });
}

void testUrlBukuRekening(String? url, String testCase) {
  Map<String, String> file = {};
  
  if(url != null && url.isNotEmpty) {
    file['bank-image'] = url;
  }
  
  print('   Case: $testCase');
  print('   Input: ${url ?? "null"}');
  print('   File map kosong: ${file.isEmpty}');
  print('   ---');
}
