# 🌐 FLUTTER WEB - CORS & API Issues Guide

## Masalah Utama

Ketika menjalankan aplikasi Flutter di Web (Chrome), API tidak dapat dijangkau karena:

### 1. **CORS (Cross-Origin Resource Sharing)**
Browser memblokir request ke domain berbeda (cross-origin) jika server tidak mengirim header CORS yang benar.

API Anda:
- `https://api-rrfx.luxurymatrix.com`
- `https://gateway.rrfx.co.id`
- `https://api-mt5.techcrm.net`

Server-server ini perlu menambahkan header CORS:
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization, X-Api-Key
```

### 2. **`dart:io` tidak tersedia di Web**
Kode seperti `HttpOverrides`, `Platform.isAndroid`, dll tidak berfungsi di Web.

---

## 🛠️ Solusi Development (Sementara)

### Opsi 1: Jalankan Flutter dengan `--web-browser-flag`
```bash
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

### Opsi 2: Gunakan Chrome dengan CORS disabled
```bash
# macOS
open -n -a "Google Chrome" --args --disable-web-security --user-data-dir=/tmp/chrome_dev

# Windows
"C:\Program Files\Google\Chrome\Application\chrome.exe" --disable-web-security --user-data-dir="C:\tmp\chrome_dev"

# Linux
google-chrome --disable-web-security --user-data-dir="/tmp/chrome_dev"
```

### Opsi 3: Gunakan CORS Proxy untuk Development
Tambahkan proxy prefix ke URL API:
```dart
// Development only
final proxyUrl = 'https://cors-anywhere.herokuapp.com/';
final apiUrl = '${proxyUrl}https://api-rrfx.luxurymatrix.com/endpoint';
```

---

## 🔧 Solusi Production (Permanen)

### Solusi Backend (RECOMMENDED)
Minta tim backend untuk menambahkan header CORS di server API:

**Untuk Node.js/Express:**
```javascript
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Api-Key');
  if (req.method === 'OPTIONS') {
    return res.sendStatus(200);
  }
  next();
});
```

**Untuk Nginx:**
```nginx
location /api/ {
    add_header 'Access-Control-Allow-Origin' '*' always;
    add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
    add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization, X-Api-Key' always;
    
    if ($request_method = 'OPTIONS') {
        return 204;
    }
}
```

### Solusi Menggunakan Proxy Server
Buat proxy server sederhana yang menambahkan header CORS.

---

## 📱 Platform Check di Flutter

Untuk kode yang berbeda antara Web dan Mobile, gunakan:

```dart
import 'package:flutter/foundation.dart' show kIsWeb;

if (kIsWeb) {
  // Kode khusus Web
} else {
  // Kode khusus Mobile (Android/iOS)
}
```

---

## ⚠️ Catatan Penting

1. **JANGAN** deploy aplikasi dengan `--disable-web-security` ke production
2. Solusi CORS **HARUS** dilakukan di sisi server/backend
3. Beberapa package Flutter tidak support Web (seperti `local_auth`, `in_app_update`, dll)
