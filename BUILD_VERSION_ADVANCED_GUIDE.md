# BuildVersionIndicator - Advanced Scroll Detection

## Update Terbaru ✨

Widget `BuildVersionIndicator` telah di-upgrade dengan fitur-fitur canggih:

### Fitur Baru

✅ **Scroll Detection** - Otomatis menghilang ketika user scroll
✅ **Liquid Glass Animation** - Efek bouncing yang smooth saat muncul
✅ **Idle Detection** - Muncul kembali saat scroll berhenti (idle)
✅ **Positioned Top Right** - Default positioning di pojok kanan atas
✅ **Smooth Animations** - Slide slide dan bounce dengan elastic curve

---

## Cara Kerja

1. **Saat User Scroll**
   - Widget slide ke kanan dengan smooth animation (600ms)
   - Menghilang dari layar

2. **Saat Scroll Idle** (1200ms setelah scroll berhenti)
   - Widget slide kembali dari kanan
   - Tampil dengan animasi bounce/scale (elasticOut)
   - Liquid glass effect yang elegant

3. **Click untuk Expand**
   - Widget dapat di-click untuk expand/collapse
   - Menampilkan label "Build Version"

---

## Implementasi

### Pada ExploreNoAuth (Sudah Diintegrasikan)

```dart
class _ExploreNoAuthState extends State<ExploreNoAuth> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initInit();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,  // ← Penting!
          child: Column(...),
        ),
        BuildVersionIndicator(
          scrollController: _scrollController,  // ← Pass controller
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          showBuildNumber: true,
          autoHideOnScroll: true,
        ),
      ],
    );
  }
}
```

### Parameter

| Parameter | Type | Default | Deskripsi |
|-----------|------|---------|-----------|
| `scrollController` | ScrollController? | null | Controller dari SingleChildScrollView |
| `margin` | EdgeInsets | EdgeInsets.fromLTRB(16,16,16,16) | Margin dari tepi |
| `showBuildNumber` | bool | true | Tampilkan build number |
| `autoHideOnScroll` | bool | true | Otomatis hide saat scroll |

---

## Timing

- **Slide Animation Duration**: 600ms
- **Bounce Animation Duration**: 900ms (elasticOut curve)
- **Idle Detection Delay**: 1200ms (setelah scroll berhenti)

---

## Styling - Liquid Glass Effect

### Light Mode
```
Background: White dengan opacity 0.6
Border: White dengan opacity 0.4
Text: Blue shade 700
Icon: Blue shade 400
```

### Dark Mode
```
Background: Black dengan opacity 0.35
Border: White dengan opacity 0.25
Text: White
Icon: Blue shade 400
```

### Shadow
```
- Primary: Blue shadow 0.2 opacity, blur 20, offset (0,8)
- Secondary: Black shadow 0.1 opacity, blur 24, spreadRadius 2
```

---

## Animation Flow

```
┌─────────────────────────────────────────────────────────┐
│ User Scrolling Started                                   │
└──────────────────┬──────────────────────────────────────┘
                   │
                   ▼
        [Slide Out Animation]
        Position: Offset(0.5, 0) ← Slide ke kanan
        Duration: 600ms
        Curve: easeInOut
                   │
                   ▼
          Widget Hilang dari Layar
                   │
         (User berhenti scroll)
          1200ms idle timer dimulai
                   │
                   ▼
        [Slide In Animation]
        Position: Offset.zero ← Kembali
        Duration: 600ms
        Curve: easeInOut
                   │
                   ▼
        [Bounce Animation]
        Scale: 0.8 → 1.0
        Duration: 900ms
        Curve: elasticOut ← Bouncing effect!
                   │
                   ▼
      Widget Tampil dengan Bounce
```

---

## Contoh Penggunaan di Page Lain

```dart
class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                // Your content here
              ],
            ),
          ),
          // Floating version indicator
          BuildVersionIndicator(
            scrollController: _scrollController,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            showBuildNumber: true,
            autoHideOnScroll: true,
          ),
        ],
      ),
    );
  }
}
```

---

## Disable Auto Hide

Jika ingin widget selalu visible:

```dart
BuildVersionIndicator(
  scrollController: _scrollController,
  autoHideOnScroll: false,  // ← Always visible
)
```

---

## Troubleshooting

### Widget tidak hide saat scroll?
- Pastikan `autoHideOnScroll: true`
- Pastikan `scrollController` di-pass dengan benar

### Animasi terlihat choppy?
- Ensure device performance cukup
- Animasi menggunakan `elasticOut` curve yang smooth

### Widget tidak muncul saat idle?
- Check idle timer delay (default 1200ms)
- Pastikan scroll controller properly connected

---

## Best Practices

1. ✅ Selalu dispose `ScrollController` di `dispose()`
2. ✅ Pass `ScrollController` ke `SingleChildScrollView`
3. ✅ Gunakan `Stack` untuk layering
4. ✅ Test di both light & dark mode
5. ✅ Ensure content memiliki scrollable height

---

**File**: `lib/src/components/widgets/build_version_indicator.dart`
**Integrasi Utama**: `lib/src/views/no_auth_view/explore/explore_no_auth.dart`
