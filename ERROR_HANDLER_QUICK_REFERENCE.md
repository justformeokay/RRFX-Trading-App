# Quick Reference - Error Handler

## Import Statement
```dart
import 'package:rrfx/src/helpers/error_handler.dart';
```

## Method Options

### 1️⃣ Show Error Dialog (Most Common)
```dart
await ErrorHandler.showErrorDialog(
  error,  // Required: Exception object
  title: 'Gagal Menutup Posisi',  // Optional: Custom title
  customMessage: 'Custom message',  // Optional: Override auto-message
  buttonText: 'OK',  // Optional: Button text (default: 'OK')
  onRetry: () => retryFunc(),  // Optional: Retry callback
);
```

### 2️⃣ Show Error Snackbar
```dart
ErrorHandler.showErrorSnackbar(
  error,  // Required: Exception object
  customMessage: 'Custom message',  // Optional
);
```

### 3️⃣ Show Simple Dialog (No auto-detection)
```dart
await ErrorHandler.showSimpleErrorDialog(
  'Your custom message here',  // Required: Message string
);
```

---

## Common Use Cases

### Use Case 1: Close Position
```dart
try {
  await tradingController.closingOrder(loginID: loginID, ticketID: positionId);
  AppSnackbar.success("Posisi berhasil ditutup.");
} catch (e) {
  await ErrorHandler.showErrorDialog(
    e,
    title: 'Gagal Menutup Posisi',
    onRetry: () => _onClosePosition(context, positionId, loginID),
  );
}
```

### Use Case 2: Modify Position
```dart
try {
  final result = await tradingController.modifyPosition(...);
  AppSnackbar.success("Position berhasil dimodifikasi");
} catch (e) {
  await ErrorHandler.showErrorDialog(
    e,
    title: 'Gagal Memodifikasi Posisi',
  );
}
```

### Use Case 3: Open Order
```dart
try {
  await tradingController.openOrder(login: loginID);
} catch (e) {
  ErrorHandler.showErrorSnackbar(e);
}
```

---

## Auto-Detected Error Messages

| Error Contains | Shows |
|---|---|
| `SocketException` | "Koneksi internet tidak stabil..." |
| `Failed host lookup` | "Tidak dapat terhubung ke server..." |
| `No address associated with hostname` | "Tidak dapat terhubung ke server..." |
| `Connection refused` | "Server sedang tidak tersedia..." |
| `Connection timed out` | "Koneksi memakan waktu terlalu lama..." |
| `TimeoutException` | "Permintaan memakan waktu terlalu lama..." |
| Other Exception | "Terjadi kesalahan yang tidak terduga..." |

---

## Adding Custom Error Type

1. Open `lib/src/helpers/error_handler.dart`
2. Add to `errorMessages` map:
```dart
static const Map<String, String> errorMessages = {
  'YourErrorKeyword': 'Your custom user message',
  // existing entries...
};
```

---

## Dialog Preview

```
┌────────────────────────────────┐
│  ❌  [Title]                   │
├────────────────────────────────┤
│  [User-friendly message]       │
│  [Multiple lines OK]           │
│                                │
└────────────────────────────────┘
      [Coba Lagi]  [OK]
```

---

## Tips & Tricks

✅ Always use for API errors
✅ Set meaningful `title`
✅ Add `onRetry` for retryable operations
✅ Use `customMessage` only when auto-detection fails
❌ Don't expose technical error details
❌ Don't show URLs to users
❌ Don't show stack traces
