# Error Handler Usage Guide

## Deskripsi
`ErrorHandler` adalah utility class yang menyediakan solusi error handling yang user-friendly untuk aplikasi RRFX. Utility ini mengubah error teknis menjadi pesan bahasa Indonesia yang mudah dipahami pengguna.

## Fitur Utama

### 1. **showErrorDialog()** - Dialog Error yang Modern
Menampilkan dialog error dengan desain modern, pesan user-friendly, dan opsi retry.

```dart
try {
  await tradingController.closingOrder(
    loginID: loginID,
    ticketID: positionId,
  );
} catch (e) {
  await ErrorHandler.showErrorDialog(
    e,
    title: 'Gagal Menutup Posisi',
    onRetry: () {
      // Aksi retry
      _onClosePosition(context, positionId, loginID);
    },
  );
}
```

### 2. **showErrorSnackbar()** - Snackbar Notification
Menampilkan notifikasi error dalam bentuk snackbar yang elegan.

```dart
try {
  // Do something
} catch (e) {
  ErrorHandler.showErrorSnackbar(e);
}
```

### 3. **showSimpleErrorDialog()** - Dialog Sederhana
Menampilkan dialog dengan pesan custom tanpa auto-detection error.

```dart
await ErrorHandler.showSimpleErrorDialog(
  'Gagal memproses permintaan Anda. Silakan coba lagi nanti.'
);
```

## Error Messages yang Didukung

Handler secara otomatis mendeteksi error berikut dan menampilkan pesan Indonesia:

| Error Type | Pesan User-Friendly |
|-----------|----------------------|
| SocketException | "Koneksi internet tidak stabil. Silakan periksa koneksi Anda dan coba lagi." |
| No address associated with hostname | "Tidak dapat terhubung ke server. Silakan coba lagi nanti." |
| Failed host lookup | "Tidak dapat terhubung ke server. Silakan periksa koneksi internet Anda." |
| Connection refused | "Server sedang tidak tersedia. Silakan coba lagi nanti." |
| Connection timed out | "Koneksi memakan waktu terlalu lama. Silakan coba lagi." |
| TimeoutException | "Permintaan memakan waktu terlalu lama. Silakan coba lagi." |

## Cara Menambah Error Message Baru

1. Buka file `lib/src/helpers/error_handler.dart`
2. Tambahkan entry baru ke dalam `errorMessages` map:

```dart
static const Map<String, String> errorMessages = {
  'YourErrorType': 'Pesan user-friendly Anda',
  // ... existing entries
};
```

3. Gunakan dalam try-catch block seperti biasa

## Contoh Implementasi di Berbagai Skenario

### Skenario 1: Close Position
```dart
try {
  await tradingController.closingOrder(
    loginID: loginID,
    ticketID: positionId,
  );
  AppSnackbar.success("Posisi berhasil ditutup.");
} catch (e) {
  await ErrorHandler.showErrorDialog(
    e,
    title: 'Gagal Menutup Posisi',
  );
}
```

### Skenario 2: Modify Position
```dart
try {
  final result = await tradingController.modifyPosition(
    login: loginID,
    ticket: positionId,
    stopLoss: sl,
    takeProfit: tp,
  );
  AppSnackbar.success("Position berhasil dimodifikasi");
} catch (e) {
  await ErrorHandler.showErrorDialog(
    e,
    title: 'Gagal Memodifikasi Posisi',
  );
}
```

### Skenario 3: Dengan Custom Message
```dart
try {
  // Do something
} catch (e) {
  await ErrorHandler.showErrorDialog(
    e,
    customMessage: 'Custom pesan error dari Anda',
    title: 'Judul Custom',
  );
}
```

## Design Characteristics

✓ **Modern**: Design menggunakan Material 3 design principles
✓ **User-Friendly**: Pesan dalam bahasa Indonesia yang mudah dipahami
✓ **Non-Technical**: Tidak menampilkan URL, kode teknis, atau stack trace
✓ **Accessible**: Mendukung dark mode dan light mode
✓ **Responsive**: Menyesuaikan dengan ukuran layar berbeda
✓ **Actionable**: Memberikan opsi retry atau action lain kepada user

## Parameter Options

### showErrorDialog()
- `error` (dynamic): Error object yang akan ditampilkan
- `title` (String): Judul dialog (default: 'Oops, Terjadi Kesalahan!')
- `customMessage` (String?): Override auto-detected message
- `buttonText` (String): Text button utama (default: 'OK')
- `onRetry` (VoidCallback?): Callback untuk tombol Retry

### showErrorSnackbar()
- `error` (dynamic): Error object yang akan ditampilkan
- `customMessage` (String?): Override auto-detected message

### showSimpleErrorDialog()
- `message` (String): Pesan yang akan ditampilkan

## Best Practices

1. **Selalu gunakan ErrorHandler untuk API errors**
   ```dart
   // ✓ BAIK
   await ErrorHandler.showErrorDialog(e);
   
   // ✗ BURUK
   AppSnackbar.error("Error: ${e.toString()}");
   ```

2. **Gunakan title yang spesifik**
   ```dart
   // ✓ BAIK
   await ErrorHandler.showErrorDialog(e, title: 'Gagal Menutup Posisi');
   
   // ✗ BURUK
   await ErrorHandler.showErrorDialog(e);
   ```

3. **Tambahkan retry callback jika relevan**
   ```dart
   // ✓ BAIK
   await ErrorHandler.showErrorDialog(
     e,
     onRetry: () => retryFunction(),
   );
   
   // ✗ BURUK
   await ErrorHandler.showErrorDialog(e);
   ```

4. **Gunakan custom message hanya jika perlu**
   ```dart
   // ✓ BAIK - Auto-detect error type
   await ErrorHandler.showErrorDialog(e);
   
   // ✓ BAIK - Override dengan custom message
   await ErrorHandler.showErrorDialog(
     e,
     customMessage: 'Pesan khusus untuk user',
   );
   ```

## File Location
```
lib/src/helpers/error_handler.dart
```

## Implementasi di Proyek
Sudah diimplementasikan di:
- `lib/src/views/transactions/views/open_transacton_meta_5.dart`
- `lib/src/views/transactions/index.dart`
- `lib/src/views/transactions/views/open_transaction_tab.dart`
