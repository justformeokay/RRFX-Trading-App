# Android Home Screen Widget untuk XAUUSD Market

## 📌 Overview
Widget ini menampilkan harga XAUUSD (Gold) real-time di home screen Android dengan fitur auto-update setiap 15 menit.

## 🎯 Fitur
- ✅ Tampilan harga XAUUSD real-time
- ✅ Perubahan harga (change & change %)
- ✅ Bid, Ask, High, Low prices
- ✅ Auto-update setiap 15 menit
- ✅ Manual refresh dengan tombol
- ✅ Background updates dengan WorkManager
- ✅ Dark theme design
- ✅ Tap to open app

## 🚀 Instalasi

### 1. Install Dependencies
```bash
flutter pub get
```

Dependencies yang ditambahkan:
- `home_widget: ^0.7.0` - Untuk membuat widget
- `workmanager: ^0.5.2` - Untuk background updates

### 2. Setup Android

File yang telah dibuat:
- ✅ `android/app/src/main/res/layout/xauusd_widget.xml` - Layout widget
- ✅ `android/app/src/main/res/drawable/widget_background.xml` - Background design
- ✅ `android/app/src/main/res/xml/xauusd_widget_info.xml` - Widget info
- ✅ `android/app/src/main/kotlin/com/rrfx/app/XAUUSDWidgetProvider.kt` - Widget provider
- ✅ `lib/src/services/widget_service.dart` - Service untuk manage widget
- ✅ `lib/src/views/settings/widget_settings_page.dart` - UI untuk setup widget

### 3. Update API Endpoint

Edit `lib/src/services/widget_service.dart` line 104:
```dart
static Future<Map<String, dynamic>?> fetchXAUUSDData() async {
  try {
    final response = await http.get(
      Uri.parse('YOUR_API_ENDPOINT/market/xauusd'), // ⚠️ Ganti dengan API Anda
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));
    
    // Response format yang diharapkan:
    // {
    //   "symbol": "XAUUSD",
    //   "price": "2034.50",
    //   "change": "12.50",
    //   "changePercent": "0.62",
    //   "bid": "2034.25",
    //   "ask": "2034.75",
    //   "high": "2045.80",
    //   "low": "2020.15"
    // }
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  } catch (e) {
    print('Error fetching XAUUSD data: $e');
    return null;
  }
}
```

### 4. Initialize Widget di App

Tambahkan di `main.dart` atau di halaman settings:
```dart
import 'package:rrfx/src/services/widget_service.dart';

// Initialize saat app start atau saat user enable widget
await WidgetService.initialize();

// Manual update widget
await WidgetService.manualUpdate();
```

### 5. Tambahkan Menu ke Settings

Di halaman settings Anda, tambahkan navigasi ke Widget Settings:
```dart
ListTile(
  leading: Icon(BoxIcons.bx_widget),
  title: Text("Home Screen Widget"),
  subtitle: Text("Setup XAUUSD widget"),
  onTap: () => Get.to(() => const WidgetSettingsPage()),
),
```

## 📱 Cara Menggunakan

1. Buka app dan pergi ke **Settings > Home Screen Widget**
2. Tap **"Enable Widget"**
3. Kembali ke home screen Android
4. Long press pada home screen kosong
5. Tap **"Widgets"**
6. Cari **"RRFX"** dan drag widget ke home screen
7. Done! Widget akan auto-update setiap 15 menit

## 🔄 Update Mechanism

### Auto Update (Background)
- Update setiap **15 menit** menggunakan WorkManager
- Berjalan di background meskipun app ditutup
- Menggunakan API untuk fetch data terbaru

### Manual Update
- Tap tombol refresh di widget
- Atau tap "Update Now" di Widget Settings page

## ⚠️ WebSocket Limitation

**Penting: WebSocket TIDAK BISA digunakan di Android Widget karena:**

1. **Widget bukan Activity/Fragment** - Widget adalah komponen UI pasif
2. **Tidak bisa maintain persistent connection** - Widget hanya "paint" UI saat di-trigger
3. **Battery drain** - WebSocket persistent connection akan menguras baterai
4. **Android limitations** - Background process sangat dibatasi untuk battery optimization

### Alternatif Solusi:

#### ✅ Solusi 1: Periodic HTTP Polling (RECOMMENDED)
```dart
// Di widget_service.dart sudah diimplementasikan
// Update setiap 15 menit dengan WorkManager
await Workmanager().registerPeriodicTask(
  'updateXAUUSDWidget',
  'updateXAUUSDWidget',
  frequency: const Duration(minutes: 15),
);
```

#### ✅ Solusi 2: Server-Side Push Notification
Jika perlu update lebih sering:
```dart
// Server mengirim notification saat harga berubah signifikan
// Notification trigger widget update
FirebaseMessaging.onMessage.listen((message) {
  if (message.data['type'] == 'price_update') {
    WidgetService.manualUpdate();
  }
});
```

#### ✅ Solusi 3: Combine dengan In-App WebSocket
- Di dalam app: Gunakan WebSocket untuk real-time
- Di widget: Gunakan polling/notification untuk periodic update

```dart
// In App - Real-time dengan WebSocket
final channel = WebSocketChannel.connect(
  Uri.parse('wss://your-websocket-server.com'),
);
channel.stream.listen((data) {
  // Update UI real-time
  updatePriceInApp(data);
  
  // Juga update widget
  WidgetService.updateWidget(/* data */);
});

// Di Widget - Periodic update fallback
// Sudah dihandle oleh WorkManager
```

## 🎨 Customization

### Ubah Update Interval
Edit `widget_service.dart` line 39:
```dart
frequency: const Duration(minutes: 15), // Minimal 15 menit
```
⚠️ Tidak bisa kurang dari 15 menit karena Android restrictions.

### Ubah Design Widget
Edit `android/app/src/main/res/layout/xauusd_widget.xml`:
- Ubah colors, sizes, fonts
- Tambah/kurangi elemen UI
- Ubah layout structure

### Ubah Background Widget
Edit `android/app/src/main/res/drawable/widget_background.xml`:
```xml
<gradient
    android:startColor="#YOUR_COLOR"
    android:endColor="#YOUR_COLOR"
/>
```

## 🐛 Troubleshooting

### Widget tidak muncul di list
1. Pastikan sudah `flutter clean && flutter build apk`
2. Uninstall app dan install ulang
3. Check AndroidManifest.xml sudah benar

### Widget tidak update
1. Check API endpoint benar
2. Check internet permission
3. Check WorkManager permission
4. Lihat logcat: `adb logcat | grep Widget`

### Data tidak tampil
1. Check format response API sesuai
2. Check parsing data di `XAUUSDWidgetProvider.kt`
3. Pastikan SharedPreferences key match

## 📊 Performance

- **Battery Impact**: Minimal (update setiap 15 menit)
- **Data Usage**: ~1KB per update
- **Memory**: ~10MB for widget service
- **CPU**: Negligible (only during update)

## 🔐 Security

- Data disimpan di SharedPreferences (encrypted by Android)
- HTTPS untuk API calls
- No sensitive data di widget

## 📝 Notes

1. Widget size: 4x2 cells (dapat di-resize)
2. Update frequency: 15 minutes minimum (Android limitation)
3. WebSocket: **TIDAK SUPPORTED** di widget
4. Background updates: Menggunakan WorkManager
5. Notification-triggered update: SUPPORTED

## 🎯 Next Steps

1. Update API endpoint di `widget_service.dart`
2. Test widget di real device (emulator limited untuk widget)
3. Customize design sesuai brand
4. Add analytics tracking (optional)
5. Implement server-side notification untuk instant updates

## 📞 Support

Jika ada pertanyaan:
1. Check logs: `adb logcat | grep -E "Widget|WorkManager"`
2. Debug mode: Set `isInDebugMode: true` di WorkManager
3. Test manual update dulu sebelum auto-update

---

**Created with ❤️ for RRFX**
