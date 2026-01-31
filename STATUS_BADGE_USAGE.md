# Status Badge dengan Icon dan Warna

## 📋 Daftar Status & Styling

| Status | Warna | Icon | Label |
|--------|-------|------|-------|
| Registrasi | 🔵 Blue | `clock` | Sedang Diproses |
| Ditolak | 🔴 Red | `close_circle` | Ditolak |
| Regol belum selesai | 🟠 Orange | `alert_circle` | Regol Belum Selesai |
| Proses Akun | 🟠 Orange | `clock` | Proses Akun |
| Unknown Status | ⚫ Grey | `info_circle` | {status_name} |

## 🎨 Status Style Map

```dart
Map<String, Map<String, dynamic>> statusStyleMap = {
  "Registrasi": {
    "color": Colors.blue,
    "icon": Iconsax.clock,
    "label": "Sedang Diproses",
  },
  "Ditolak": {
    "color": Colors.red,
    "icon": Iconsax.close_circle,
    "label": "Ditolak",
  },
  "Regol belum selesai": {
    "color": Colors.orange,
    "icon": Iconsax.alert_circle,
    "label": "Regol Belum Selesai",
  },
  "Proses Akun": {
    "color": Colors.orange,
    "icon": Iconsax.clock,
    "label": "Proses Akun",
  },
};
```

## 🚀 Cara Penggunaan

### 1. **Initialize Status pada initState**
```dart
@override
void initState() {
  super.initState();
  fetchPendingAccountStatus(); // Load pending account status
}
```

### 2. **Tampilkan Badge di UI**
```dart
// Simple
buildPendingStatusBadge()

// Dalam Container atau Card
Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Text("Status Akun Anda"),
        const SizedBox(height: 8),
        buildPendingStatusBadge(),
      ],
    ),
  ),
)
```

### 3. **Akses Data Langsung (jika perlu)**
```dart
// Dapatkan warna
Obx(() => Container(
  color: backgroundStatusPending.value,
  child: Text("Custom Widget"),
))

// Dapatkan icon
Obx(() => Icon(iconStatusPending.value))

// Dapatkan status
Obx(() => Text(pendingAccountStatus.value))
```

## 📝 Customization

### Tambah Status Baru
```dart
statusStyleMap["Status Baru"] = {
  "color": Colors.green,
  "icon": Iconsax.tick_circle,
  "label": "Label untuk ditampilkan",
};
```

### Ubah Style Existing Status
```dart
statusStyleMap["Registrasi"] = {
  "color": Colors.purple,
  "icon": Iconsax.timer,
  "label": "Sedang Memproses",
};
```

## 🎯 Function Overview

### `fetchPendingAccountStatus()`
- **Purpose**: Load pending account status dari controller
- **Updates**: 
  - `containsPendingAccount`
  - `pendingAccountStatus`
  - `backgroundStatusPending`
  - `iconStatusPending`

### `getStatusStyle(String status)`
- **Purpose**: Get icon, color, dan label untuk status tertentu
- **Parameters**: `status` - status string
- **Returns**: Map dengan keys: `color`, `icon`, `label`

### `buildPendingStatusBadge()`
- **Purpose**: Widget badge untuk menampilkan status
- **Returns**: Widget dengan icon dan warna sesuai status
- **Reactive**: Menggunakan Obx untuk auto-update

## 💡 Tips

- Gunakan `Obx()` untuk membuat widget reactive
- Panggil `fetchPendingAccountStatus()` setiap kali perlu refresh status
- Icon menggunakan Iconsax dari package `icons_plus`
- Warna otomatis adjust opacity untuk background

## 🔄 Reactive Variables

```dart
RxString pendingAccountStatus = "".obs;              // Status text
Rx<Color?> backgroundStatusPending = Rx<Color?>(null);   // Status color
Rx<IconData?> iconStatusPending = Rx<IconData?>(null);   // Status icon
RxBool containsPendingAccount = false.obs;           // Has pending account
```
