## Penyebab Lag yang Masih Ada

### Root Cause #1 — CRITICAL: `_executionQueue.refresh()` memicu rebuild semua item di overlay setiap kali status berubah

```dart
// _executeItem() — dipanggil untuk setiap order
_executionQueue[index]['status'] = 'success';
_executionQueue.refresh();   // ← notify Obx → rebuild SEMUA item
// ...
await Future.delayed(1500ms);
_executionQueue.removeWhere(...);  // ← RxList mutate → notify Obx lagi → rebuild SEMUA item lagi
```

Di overlay, Obx merespons dengan:

```dart
// _showQueueOverlay() — dijalankan setiap notify
_executionQueue
    .map((item) => _buildExecutionItem(item))  // ← rebuild SEMUA 8 item, bukan yang berubah
    .toList()
```

**Hitungan rebuild untuk 8 order rapid:**


| Event                                    | Jumlah          | Rebuild overlay             |
| ---------------------------------------- | --------------- | --------------------------- |
| `_executionQueue.add()` × 8             | 8               | 8 rebuilds                  |
| `.refresh()` saat status → success × 8 | 8               | 8 rebuilds                  |
| `.removeWhere()` × 8                    | 8               | 8 rebuilds                  |
| **Total**                                | **24 rebuilds** | **setiap rebuild = 8 item** |

= **192 kali `_buildExecutionItem()`** dipanggil, masing-masing berisi `Container` + `BoxDecoration` + `Border` + `Row` + `GoogleFonts.inter()`. Di Android mid-range dengan frame budget 16.6ms, ini langsung menyebabkan frame drops.

---

### Root Cause #2 — HIGH: `await` pada haptic + audio memblokir delay timer

```dart
// _playSuccessNotification() — AWAITED sebelum delay 1500ms
await HapticFeedback.mediumImpact();  // ← platform channel call ke Android vibrator
await _audioPool?.start();            // ← platform channel call ke audio engine
// baru kemudian:
await Future.delayed(const Duration(milliseconds: 1500));
```

Dua masalah:

**A.** `HapticFeedback.mediumImpact()` dan `_audioPool?.start()` adalah platform channel calls. Di Android, platform channel calls masuk ke antrian single-threaded di main thread. Untuk 8 order yang selesai hampir bersamaan: 8 haptic call + 8 audio call = 16 platform channel calls yang saling mengantri.

**B.** `await _playSuccessNotification()` memblokir eksekusi `_executeItem()` — timer 1500ms baru mulai setelah audio berhasil diinisiasi. Jika `_audioPool?.start()` butuh 30ms di Android, removal terjadi di 1530ms bukan 1500ms. Tidak besar per order, tapi saat 8 order: platform thread Android kewalahan melayani semua panggilan ini.

---

### Root Cause #3 — MEDIUM: Puluhan `print()` di hot path

```dart
// Dalam _executeItem() — dipanggil 8x saat rapid order:
print('🔄 Processing order: $operation for $itemSymbol');   // +1
print('📊 Login: ${widget.login}, Lot: ${item['lot']}');     // +1
print('✅ Order response received:');                         // +1
print('   Status: ${response['status']}');                    // +1
print('   Message: ${response['message']}');                  // +1
print('   Response: ${response['response']}');                // +1
print('⏱️ Execution time: ${execMs}ms');                     // +1

// Dalam _addToQueue():
print('Added to queue: $operation $lot, ...');               // +1
```

= **8 print per order × 8 order = 64 print() calls** saat rapid tap.

Di Android, `print()` masuk ke Logcat melalui sistem Android logging — bukan non-blocking. Di Dart VM pada debug/profile mode, ini cukup signifikan karena string interpolation (`${response['response']}`) juga men-serialize objek besar.

---

### Root Cause #4 — MEDIUM: `_buildExecutionItem()` memanggil `Get.isDarkMode` tiap rebuild

```dart
Widget _buildExecutionItem(Map<String, dynamic> item) {
  // ...
  decoration: BoxDecoration(
    color: Get.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,  // ← setiap rebuild
    // ...
  ),
```

`Get.isDarkMode` saat dipanggil 192 kali (lihat Root Cause #1) masing-masing mengakses `Get.theme.brightness` yang melakukan traversal context. Kecil per call, tapi dikali 192 menjadi signifikan.

---

## Ringkasan Prioritas Fix


| # | Issue                                               | Dampak                                           | Fix                                                             |
| - | --------------------------------------------------- | ------------------------------------------------ | --------------------------------------------------------------- |
| 1 | `refresh()` + `removeWhere()` → rebuild semua item | Frame drops, jank langsung terasa                | Ganti`Map` dengan model class Rx, atau gunakan key-based update |
| 2 | `await` haptic + audio sebelum delay                | Blokir timer, Android platform thread bottleneck | Ubah menjadi fire-and-forget (`unawaited`)                      |
| 3 | 64+`print()` di hot path                            | CPU overhead di debug/release                    | Hapus semua print di execution path                             |
| 4 | `Get.isDarkMode` per rebuild                        | Minor, tapi terkumulasi                          | Cache isDark sebagai local variable sebelum build item          |

**Fix #2 paling mudah dan dampaknya langsung terasa** — bisa dilakukan sekarang dengan mengubah dua baris. Lanjutkan perbaikan mulai dari mana?
