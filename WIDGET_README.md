# 📱 Android Home Screen Widget - Quick Start

## ✅ Yang Sudah Dibuat

1. **Packages ditambahkan** ✓
   - `home_widget: ^0.7.0`
   - `workmanager: ^0.5.2`

2. **Files Android** ✓
   - Layout XML widget
   - Widget provider Kotlin
   - Widget info XML
   - Background drawable
   - AndroidManifest updated

3. **Flutter Files** ✓
   - `lib/src/services/widget_service.dart` - Service manager
   - `lib/src/views/settings/widget_settings_page.dart` - UI setup

## 🚀 Langkah Setup

### 1. Update API Endpoint

Edit `lib/src/services/widget_service.dart` line 104:

```dart
static Future<Map<String, dynamic>?> fetchXAUUSDData() async {
  try {
    final response = await http.get(
      Uri.parse('GANTI_DENGAN_API_ANDA/market/xauusd'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer YOUR_TOKEN', // jika perlu
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  } catch (e) {
    print('Error: $e');
    return null;
  }
}
```

**Format response yang diharapkan:**
```json
{
  "symbol": "XAUUSD",
  "price": "2034.50",
  "change": "12.50",
  "changePercent": "0.62",
  "bid": "2034.25",
  "ask": "2034.75",
  "high": "2045.80",
  "low": "2020.15"
}
```

### 2. Tambahkan Menu di Settings

Tambahkan navigasi ke widget settings page:

```dart
import 'package:rrfx/src/views/settings/widget_settings_page.dart';

// Di settings page:
ListTile(
  leading: Icon(BoxIcons.bx_widget),
  title: Text("Home Screen Widget"),
  subtitle: Text("XAUUSD Market Widget"),
  trailing: Icon(Icons.chevron_right),
  onTap: () => Get.to(() => const WidgetSettingsPage()),
),
```

### 3. Build & Test

```bash
flutter clean
flutter build apk
# Install ke device
flutter install
```

### 4. Cara Menggunakan

1. Buka app → Settings → Home Screen Widget
2. Tap **"Enable Widget"**
3. Kembali ke home screen Android
4. Long press home screen → Widgets
5. Cari "RRFX" → Drag ke home screen
6. Done! ✓

## ⚠️ PENTING: WebSocket Limitation

### Kenapa WebSocket TIDAK BISA di Widget?

❌ **Widget bukan proses aktif** - Hanya "repaint" saat di-trigger
❌ **Persistent connection tidak memungkinkan** - Battery drain
❌ **Android background limitations** - Sangat restrictive
❌ **Widget sleep saat tidak visible** - Connection putus

### ✅ Solusi yang Digunakan

**1. Periodic HTTP Polling (Sudah diimplementasi)**
```dart
// Update setiap 15 menit dengan WorkManager
// Minimal interval yang diizinkan Android
frequency: Duration(minutes: 15)
```

**2. Push Notification Trigger (Recommended)**
```dart
// Server push notification saat harga berubah signifikan
FirebaseMessaging.onMessage.listen((message) {
  if (message.data['type'] == 'price_update') {
    WidgetService.manualUpdate(); // Update widget
  }
});
```

**3. Hybrid Approach (Best)**
- **In-App**: WebSocket real-time ✓
- **Widget**: Periodic update + Notification trigger ✓

```dart
// Di dalam app - Real-time dengan WebSocket
WebSocketChannel.connect(...)
  .stream.listen((data) {
    updateUIInApp(data);
    WidgetService.updateWidget(data); // Update widget juga
  });

// Di background - WorkManager fallback
// Auto-update setiap 15 menit
```

## 🎯 Alternative: WebSocket di In-App + Widget Sync

Jika Anda tetap ingin WebSocket behavior:

```dart
// Di controller trading Anda
class TradingController extends GetxController {
  late WebSocketChannel _channel;
  
  @override
  void onInit() {
    super.onInit();
    _connectWebSocket();
  }
  
  void _connectWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://your-server.com/xauusd'),
    );
    
    _channel.stream.listen((data) {
      final price = json.decode(data);
      
      // Update in-app UI
      updatePriceInApp(price);
      
      // Juga update widget
      WidgetService.updateWidget(
        symbol: price['symbol'],
        price: price['price'],
        change: price['change'],
        // ...
      );
    });
  }
}
```

Dengan cara ini:
- ✅ In-app tetap real-time dengan WebSocket
- ✅ Widget update saat app dibuka
- ✅ Widget tetap update via polling saat app ditutup

## 📊 Update Frequency

| Method | Frequency | Battery Impact | Data Usage |
|--------|-----------|----------------|------------|
| WebSocket (in-app only) | Real-time | Medium | Low |
| Polling (widget) | 15 min | Minimal | Very Low |
| Push Notification | On-demand | Minimal | Minimal |
| **Recommended: Hybrid** | Real-time + 15 min | Low | Low |

## 🐛 Troubleshooting

**Widget tidak muncul?**
```bash
flutter clean
flutter build apk
# Uninstall app → Install ulang
```

**Widget tidak update?**
- Check API endpoint
- Check logcat: `adb logcat | grep Widget`
- Test manual update di Widget Settings

**Data tidak tampil?**
- Verify API response format
- Check parsing di `XAUUSDWidgetProvider.kt`

## 📝 Customization

### Ubah Update Interval
`lib/src/services/widget_service.dart`:
```dart
frequency: Duration(minutes: 15), // Min: 15 menit
```

### Ubah Design
Edit: `android/app/src/main/res/layout/xauusd_widget.xml`

### Ubah Warna
Edit: `android/app/src/main/res/drawable/widget_background.xml`

## 📚 Lihat Dokumentasi Lengkap

Baca [WIDGET_GUIDE.md](WIDGET_GUIDE.md) untuk dokumentasi lengkap.

---

**Status:** ✅ Ready to use
**Next:** Update API endpoint & test di real device
