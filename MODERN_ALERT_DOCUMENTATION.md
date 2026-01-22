# Modern Alert Dialog - Dokumentasi

## Deskripsi
`ModernAlertDialog` adalah komponen popup alert yang modern dan kekinian untuk menggantikan `CustomScaffoldMessanger.showAppSnackBar()`. Komponen ini menyediakan dialog yang elegant dengan animasi smooth dan dukungan dark mode.

## Fitur
✅ Desain modern dan elegan
✅ 4 tipe alert: Success, Error, Warning, Info
✅ Animasi scale & fade yang smooth
✅ Dukungan dark mode otomatis
✅ Gradient button dengan shadow
✅ Icon dan warna yang sesuai dengan tipe alert
✅ Fully customizable

## Cara Penggunaan

### 1. Alert Error (Rekomendasi untuk login gagal)
```dart
ModernAlertDialog.error(
  message: "Email atau password salah",
  title: "Login Gagal",
  buttonText: "Coba Lagi",
  onPressed: () {
    // Action ketika button di-klik
  },
);
```

### 2. Alert Success
```dart
ModernAlertDialog.success(
  message: "Registrasi berhasil! Silakan login.",
  title: "Berhasil",
);
```

### 3. Alert Warning
```dart
ModernAlertDialog.warning(
  message: "Pastikan akun Anda sudah terverifikasi",
  title: "Peringatan",
);
```

### 4. Alert Info
```dart
ModernAlertDialog.info(
  message: "Fitur sedang dalam pengembangan",
  title: "Informasi",
);
```

### 5. Custom Alert
```dart
ModernAlertDialog.show(
  message: "Pesan custom",
  title: "Judul Custom",
  type: AlertType.success,
  buttonText: "Setuju",
  barrierDismissible: false,
  duration: const Duration(milliseconds: 500),
);
```

## Parameter

| Parameter | Type | Default | Deskripsi |
|-----------|------|---------|-----------|
| `message` | String | Required | Pesan utama |
| `title` | String? | null | Judul alert (opsional) |
| `type` | AlertType | AlertType.info | Tipe alert (success, error, warning, info) |
| `buttonText` | String | "OK" | Teks button |
| `onPressed` | VoidCallback? | null | Callback ketika button ditekan |
| `barrierDismissible` | bool | true | Bisa di-dismiss dengan tap outside |
| `duration` | Duration | 400ms | Durasi animasi |

## Tipe Alert

| Type | Icon | Warna | Untuk |
|------|------|-------|-------|
| `AlertType.success` | ✓ Check | Green | Login berhasil, aksi berhasil |
| `AlertType.error` | ✗ Error | Red | Login gagal, error |
| `AlertType.warning` | ⚠️ Warning | Orange | Peringatan |
| `AlertType.info` | ℹ️ Info | Blue | Informasi umum |

## Migrasi dari CustomScaffoldMessanger

### Sebelum
```dart
CustomScaffoldMessanger.showAppSnackBar(
  context,
  message: "Login gagal",
);
```

### Sesudah
```dart
ModernAlertDialog.error(
  message: "Login gagal",
  title: "Gagal",
);
```

## Styling

Komponen ini otomatis mengikuti dark mode dari aplikasi. Background, text color, dan shadow akan menyesuaikan secara otomatis.

- **Light Mode**: White background dengan shadow yang subtle
- **Dark Mode**: Dark background (#1E1E1E) dengan border white10

## Animasi

Dialog muncul dengan kombinasi animasi:
- **Scale**: 0.8 → 1.0 (elastic out)
- **Fade**: 0 → 1 (ease in out)
- Default duration: 400ms

Anda dapat customize durasi dengan parameter `duration`.

## Contoh Lengkap (Authentication Controller)

```dart
// Login Success
ModernAlertDialog.success(
  message: "Login berhasil!",
  title: "Berhasil",
  onPressed: () {
    Get.offAll(() => const MainPage());
  },
);

// Login Error
ModernAlertDialog.error(
  message: "Email atau password salah",
  title: "Login Gagal",
);

// Account Locked
ModernAlertDialog.warning(
  message: "Akun Anda terkunci. Hubungi admin untuk bantuan.",
  title: "Akun Terkunci",
);

// Registration Error
ModernAlertDialog.error(
  message: result['message'] ?? "Registrasi gagal",
  title: "Gagal Mendaftar",
);
```

## Tips

1. Gunakan `AlertType.error` untuk error/gagal
2. Gunakan `AlertType.success` untuk aksi berhasil
3. Gunakan `AlertType.warning` untuk peringatan penting
4. Gunakan `AlertType.info` untuk informasi umum
5. Selalu berikan `title` yang meaningful
6. Gunakan `onPressed` untuk handle aksi spesifik setelah dialog ditutup

---
File: `lib/src/components/alerts/modern_alert_dialog.dart`
