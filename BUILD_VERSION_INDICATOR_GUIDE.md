# Build Version Indicator - Dokumentasi

## Deskripsi
`BuildVersionIndicator` adalah floating widget modern yang menampilkan informasi versi build aplikasi. Widget ini dapat diklik untuk menampilkan label "Build Version" dan dirancang untuk integrasi mudah di berbagai halaman aplikasi.

## Fitur
✅ Menampilkan versi aplikasi otomatis dari package info
✅ Expandable/Collapsible dengan animasi smooth
✅ Dukungan dark mode
✅ Semi-transparent background dengan backdrop effect
✅ Icon indikator yang jelas
✅ Customizable positioning dan margin
✅ Lightweight dan tidak mengganggu UX

## Komponen yang Tersedia

### 1. BuildVersionIndicator (Recommended)
Widget utama dengan fitur expand/collapse.

```dart
const BuildVersionIndicator(
  alignment: Alignment.bottomRight,
  margin: EdgeInsets.all(16),
  showBuildNumber: true,
)
```

**Fitur:**
- Click untuk expand/collapse
- Menampilkan build number jika expand
- Background semi-transparent
- Animation smooth

### 2. SimpleVersionBadge
Widget sederhana yang langsung tampil tanpa expand.

```dart
const SimpleVersionBadge(
  alignment: Alignment.bottomRight,
  margin: EdgeInsets.all(12),
)
```

## Parameter

### BuildVersionIndicator

| Parameter | Type | Default | Deskripsi |
|-----------|------|---------|-----------|
| `alignment` | Alignment | Alignment.bottomRight | Posisi widget di screen |
| `margin` | EdgeInsets | EdgeInsets.all(16) | Margin dari tepi screen |
| `showBuildNumber` | bool | true | Tampilkan build number |

### SimpleVersionBadge

| Parameter | Type | Default | Deskripsi |
|-----------|------|---------|-----------|
| `alignment` | Alignment | Alignment.bottomRight | Posisi widget di screen |
| `margin` | EdgeInsets | EdgeInsets.all(12) | Margin dari tepi screen |

## Cara Penggunaan

### Pada Page (Seperti ExploreNoAuth)

```dart
@override
Widget build(BuildContext context) {
  return Stack(
    children: [
      // Content utama
      SingleChildScrollView(
        child: Column(
          children: [
            // Widgets lainnya...
          ],
        ),
      ),
      // Floating Version Indicator
      const BuildVersionIndicator(
        alignment: Alignment.bottomRight,
        margin: EdgeInsets.all(16),
        showBuildNumber: true,
      ),
    ],
  );
}
```

### Positioning Alternatif

```dart
// Bottom Left
const BuildVersionIndicator(
  alignment: Alignment.bottomLeft,
  margin: EdgeInsets.all(16),
)

// Top Right
const BuildVersionIndicator(
  alignment: Alignment.topRight,
  margin: EdgeInsets.all(16),
)

// Top Left
const BuildVersionIndicator(
  alignment: Alignment.topLeft,
  margin: EdgeInsets.all(16),
)

// Center Bottom dengan custom margin
const BuildVersionIndicator(
  alignment: Alignment.bottomCenter,
  margin: EdgeInsets.only(bottom: 20),
)
```

## Format Versi

Widget ini secara otomatis mengambil versi dari `pubspec.yaml`:

```yaml
version: 1.2.3+45
```

Tampilan:
- Dengan `showBuildNumber: true` → `v1.2.3+45`
- Dengan `showBuildNumber: false` → `v1.2.3`

## Styling

### Light Mode
- Background: Putih semi-transparent (0.8 opacity)
- Border: Hitam dengan opacity 0.1
- Text: Hitam (87% opacity)
- Icon: Biru

### Dark Mode
- Background: Hitam semi-transparent (0.6 opacity)
- Border: Putih dengan opacity 0.15
- Text: Putih
- Icon: Biru terang

## Animasi

Widget memiliki animasi smooth saat expand/collapse:
- **Duration**: 300ms
- **Curve**: easeInOut
- **Transform**: Container width dan padding bertransisi smooth

## Contoh Implementasi Lengkap

```dart
import 'package:rrfx/src/components/widgets/build_version_indicator.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main Content
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 200,
                  color: Colors.blue,
                  child: const Center(
                    child: Text("Main Content"),
                  ),
                ),
              ],
            ),
          ),
          
          // Version Indicator
          const BuildVersionIndicator(
            alignment: Alignment.bottomRight,
            margin: EdgeInsets.all(16),
            showBuildNumber: true,
          ),
        ],
      ),
    );
  }
}
```

## Tips & Best Practices

1. **Gunakan Stack sebagai parent** untuk layout yang benar
2. **Pilih positioning yang tidak menghalangi** tombol penting
3. **Use `showBuildNumber: false`** di production jika ingin simple
4. **Pilih SimpleVersionBadge** jika space terbatas
5. **Test di both light & dark mode** untuk memastikan visibility

## Troubleshooting

### Versi tidak muncul?
- Pastikan `package_info_plus` sudah di `pubspec.yaml`
- Rebuild app dan bukan hanya hot reload

### Widget tidak terlihat?
- Pastikan Stack benar-benar wrapping content
- Check alignment dan margin values
- Verifikasi layer positioning

### Performance issue?
- Widget ini very lightweight
- Loading versi bersifat async di initState
- Tidak ada re-render berlebihan

---
**File Utama**: `lib/src/components/widgets/build_version_indicator.dart`

**Sudah diintegrasikan di**: 
- `lib/src/views/no_auth_view/explore/explore_no_auth.dart`
