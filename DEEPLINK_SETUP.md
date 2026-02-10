# 🔗 Deeplink Setup Guide untuk RRFX App

## ✅ Perubahan yang Sudah Dilakukan

### Android (AndroidManifest.xml)
- ✅ Menambahkan intent-filter untuk `app.rrfx.co.id`
- ✅ Menambahkan intent-filter untuk `client.rrfx.co.id`
- ✅ Mengaktifkan `android:autoVerify="true"` untuk App Links

### iOS (Runner.entitlements & Info.plist)
- ✅ Menambahkan associated domains: `app.rrfx.co.id` dan `client.rrfx.co.id`
- ✅ Mengaktifkan `FlutterDeepLinkingEnabled`

## 📋 Langkah Setup di Server (WAJIB)

### 1. Upload File untuk Android App Links

Upload file `assetlinks.json` yang sudah ada di root project ke **kedua** domain:

```bash
https://app.rrfx.co.id/.well-known/assetlinks.json
https://client.rrfx.co.id/.well-known/assetlinks.json
```

**Isi file assetlinks.json sudah benar:**
```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.rrfx.app",
    "sha256_cert_fingerprints": [
      "CA:5E:1E:60:DA:1F:E7:15:B4:00:9E:A1:68:F7:A9:D9:05:F9:62:2E:53:DD:46:55:42:E5:7F:98:6A:F7:40:A4",
      "D7:CF:2C:63:48:5B:41:6C:89:4D:60:67:7F:25:4A:40:26:7C:10:A0:09:D4:79:0D:B9:20:62:CA:B1:EB:9B:B8",
      "2C:B8:6F:E4:FC:EF:B5:03:9C:0D:BF:7B:75:44:B7:76:7C:D9:BE:BB:0F:A4:22:7D:21:B9:5E:4D:3A:65:C9:FC"
    ]
  }
}]
```

### 2. Upload File untuk iOS Universal Links

Upload file `apple-app-site-association` (tanpa ekstensi) ke **kedua** domain:

```bash
https://app.rrfx.co.id/.well-known/apple-app-site-association
https://client.rrfx.co.id/.well-known/apple-app-site-association
```

⚠️ **PENTING:** Ganti `YOUR_TEAM_ID` di file `apple-app-site-association` dengan Apple Team ID yang sebenarnya dari Apple Developer Account.

Cara cek Team ID:
1. Login ke https://developer.apple.com/account
2. Membership → Team ID

### 3. Konfigurasi Server

File-file tersebut HARUS:
- ✅ Accessible via HTTPS (bukan HTTP)
- ✅ Return dengan `Content-Type: application/json` header
- ✅ Tidak ada redirect (direct access)
- ✅ Tidak memerlukan autentikasi

**Contoh nginx config:**
```nginx
location /.well-known/ {
    add_header Content-Type application/json;
    add_header Access-Control-Allow-Origin *;
}
```

## 🧪 Testing Deeplink

### Test di Android
```bash
# Via ADB
adb shell am start -W -a android.intent.action.VIEW \
  -d "https://app.rrfx.co.id/signup?referral=6917ee1a1d373" \
  com.rrfx.app
```

### Test di iOS
```bash
# Via Terminal / Safari
# Buka URL di Safari: https://app.rrfx.co.id/signup?referral=6917ee1a1d373
# Atau kirim via iMessage ke diri sendiri
```

### Verify Server Files
```bash
# Test assetlinks.json
curl -v https://app.rrfx.co.id/.well-known/assetlinks.json

# Test apple-app-site-association
curl -v https://app.rrfx.co.id/.well-known/apple-app-site-association
```

## 🔍 Troubleshooting

### Android tidak buka app, malah ke browser
1. ✅ Pastikan `assetlinks.json` sudah di-upload ke server
2. ✅ Clear app data: Settings → Apps → RRFX → Clear Data
3. ✅ Uninstall & reinstall app
4. ✅ Wait 24 jam (Google perlu verify assetlinks)
5. ✅ Test via: `adb shell pm get-app-links com.rrfx.app`

### iOS tidak buka app, malah ke Safari
1. ✅ Pastikan `apple-app-site-association` sudah di-upload
2. ✅ Pastikan Team ID sudah benar di file AASA
3. ✅ Delete app → Reinstall
4. ✅ Test dengan long-press link di Notes/Messages
5. ✅ Check di Settings → RRFX → Associated Domains

### Check App Links Status (Android)
```bash
# Check verification status
adb shell pm get-app-links --user 0 com.rrfx.app

# Reset verification
adb shell pm set-app-links --package com.rrfx.app 0 all
```

## 📱 Supported URL Patterns

Semua URL di bawah akan membuka app:

```
https://app.rrfx.co.id/signup?referral=xxx
https://app.rrfx.co.id/login
https://app.rrfx.co.id/reset-password?token=xxx
https://client.rrfx.co.id/any/path
http://app.rrfx.co.id/* (untuk development)
```

## 🚀 Next Steps

1. ⚠️ **WAJIB:** Upload `assetlinks.json` ke server
2. ⚠️ **WAJIB:** Upload `apple-app-site-association` ke server (ganti Team ID dulu)
3. ⚠️ **WAJIB:** Rebuild & reinstall app (release build)
4. ✅ Test deeplink dari browser
5. ✅ Wait 24 jam untuk Android App Links verification

## 📞 Support

Jika masih tidak bekerja setelah 24 jam:
- Cek file server via curl
- Cek verification status via adb
- Pastikan SHA256 fingerprints di assetlinks.json sesuai dengan keystore yang dipakai untuk signing
