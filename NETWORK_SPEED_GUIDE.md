# Network Speed Checking Implementation Guide

Fitur ini mengecek kecepatan jaringan user dan menampilkan warning popup jika latency > 100ms untuk mencegah transaksi dengan koneksi tidak stabil.

## 📁 File yang Ditambahkan

1. **`lib/src/service/network_speed_service.dart`**
   - Service untuk mengukur network speed
   - Method: `measureNetworkSpeed()` dan `measureNetworkSpeedWithRetry()`

2. **`lib/src/components/popups/network_speed_dialog.dart`**
   - Dialog widget dengan theme gelap/terang
   - Support Material Design 3
   - Menampilkan latency info dan rekomendasi

3. **Update `lib/src/controllers/network_controller.dart`**
   - Added: `checkNetworkSpeed()`
   - Added: `getNetworkSpeed()`
   - Auto-trigger saat perubahan koneksi

4. **Update `lib/main.dart`**
   - Auto-trigger network speed check saat app launch

## 🚀 Cara Penggunaan

### 1. Auto Check (Sudah Berjalan)
Network speed akan otomatis dicek saat:
- App pertama kali di-launch
- Koneksi jaringan berubah (dari offline ke online)

### 2. Manual Check di Page Tertentu

```dart
// Di halaman transaksi atau tempat penting lainnya
import 'package:rrfx/src/controllers/network_controller.dart';
import 'package:rrfx/src/components/popups/network_speed_dialog.dart';

class TransactionPage extends GetView<NetworkController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              // Trigger check sebelum transaksi
              await controller.checkNetworkSpeed();
              
              // Atau dapatkan speed tanpa dialog
              final speed = await controller.getNetworkSpeed();
              
              if (speed != null && speed > 100) {
                // Handle transaksi dengan koneksi tidak stabil
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Latency: ${speed}ms - Transaksi tidak direkomendasikan')),
                );
              } else {
                // Lanjutkan transaksi
                // ...
              }
            },
            child: const Text('Proses Transaksi'),
          ),
        ],
      ),
    );
  }
}
```

### 3. Akses Network Speed Realtime

```dart
GetBuilder<NetworkController>(
  builder: (controller) {
    return Text('Speed: ${controller.networkSpeed.value}ms');
  },
);

// Atau dengan Obx
Obx(() {
  return Text('Speed: ${networkController.networkSpeed.value}ms');
});
```

## 🎨 Fitur Dialog

Dialog yang ditampilkan memiliki:
- ✅ Theme Gelap & Terang (otomatis mengikuti app theme)
- ✅ Icon animasi dengan gradient
- ✅ Info card dengan latency
- ✅ Tips/Rekomendasi
- ✅ Button action (Tutup & Coba Lagi)
- ✅ Blur effect pada background
- ✅ Smooth animations

## ⚙️ Konfigurasi

### Threshold untuk Peringatan
Edit di `network_controller.dart`, line dengan kondisi:
```dart
if (speed > 100) {  // Ubah 100 ke nilai lain jika diperlukan
```

### URL untuk Measurement
Ubah di `network_speed_service.dart`:
```dart
static Future<int?> measureNetworkSpeed({
  String url = 'https://www.google.com', // Ubah URL di sini
  ...
})
```

### Retry Count
```dart
final speed = await NetworkSpeedService.measureNetworkSpeedWithRetry(
  retryCount: 2,  // Ubah jumlah retry
);
```

## 📊 Debug Output

Network speed akan di-print ke console:
```
flutter: Network Speed: 45ms
```

## 🔍 Troubleshooting

1. **Dialog tidak muncul?**
   - Pastikan `ThemeController` sudah di-initialize
   - Pastikan ada `Get.dialog` context

2. **Speed selalu null?**
   - Check internet connection
   - Verify URL ping-able
   - Check timeout settings

3. **Performance issue?**
   - Reduce `retryCount` ke 1
   - Increase `timeout` duration

## 📝 Notes

- Network speed check berjalan di background, tidak blocking UI
- Menggunakan HTTP HEAD request untuk minimalisir data
- Hasil adalah rata-rata dari multiple measurements
- Theme otomatis mengikuti Dark/Light mode user
