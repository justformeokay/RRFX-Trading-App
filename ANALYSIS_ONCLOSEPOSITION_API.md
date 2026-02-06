# Analisis: API yang Dipanggil pada Fungsi `_onClosePosition()`

## File: open_transacton_meta_5.dart
**Lokasi:** Fungsi `_onClosePosition()` di class `_PositionTile`  
**Baris:** ~743

---

## API yang Dipanggil

### 1️⃣ **POST `/market/execution/close`**
**Waktu Eksekusi:** Saat user mengkonfirmasi close position  
**Lokasi Kode:** 
```dart
await tradingController.closingOrder(
  loginID: loginID,
  ticketID: positionId ?? '',
);
```

**File Source:** [trading.dart line 630-643](lib/src/controllers/trading.dart#L630-L643)

**Implementasi:**
```dart
Future<Map<String, dynamic>> closingOrder({
  required String loginID,
  required String? ticketID,
}) async {
  try {
    Map<String, dynamic> result = await authService.post(
      'market/execution/close',  // ← API ENDPOINT
      {'login': loginID, 'ticket': ticketID},
    );
    return result;
  } catch (e) {
    isLoading(false);
    throw Exception("executionOrder error: $e");
  }
}
```

**Request Body:**
```json
{
  "login": "string (account login number)",
  "ticket": "string (position ID)"
}
```

**Response Expected:**
```json
{
  "status": boolean,
  "message": "string",
  "response": {
    // ... closing result details
  }
}
```

**Fungsi:** Menutup position yang terbuka (market order)

---

### 2️⃣ **GET `/market/opened-order?login={loginID}`**
**Waktu Eksekusi:** Setelah close position sukses (reload positions)  
**Lokasi Kode:**
```dart
await tradingController.openOrder(login: loginID);
```

**File Source:** [trading.dart line 617-628](lib/src/controllers/trading.dart#L617-L628)

**Implementasi:**
```dart
Future<Map<String, dynamic>> openOrder({required String login}) async {
  try {
    Map<String, dynamic> result = await authService.get(
      'market/opened-order?login=$login',  // ← API ENDPOINT
    );
    openOrderModel(OpenOrderModel.fromJson(result));
    print("INI RESULT OPEN ORDER => $result");
    return result;
  } catch (e) {
    throw Exception("executionOrder error: $e");
  }
}
```

**Query Parameter:**
```
login={loginID}  // e.g., login=391585
```

**Response Expected:**
```json
{
  "status": boolean,
  "message": "string",
  "response": [
    {
      "ticket": number,
      "symbol": "string",
      "orderType": "buy|sell",
      "lot": number,
      "openPrice": number,
      "openTime": "string",
      "currentPrice": number,
      "stopLoss": number,
      "takeProfit": number,
      "profit": number,
      "swap": number,
      "digits": number
    }
  ]
}
```

**Fungsi:** Mengambil daftar posisi yang masih terbuka untuk akun tersebut

---

## Timeline Eksekusi

```
┌──────────────────────────────────────────────────────────┐
│ 1. User Tap Slide Position (Geser ke kiri)              │
└────────────────┬─────────────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────────────┐
│ 2. _onClosePosition() dipanggil                          │
│    - Show confirmation dialog                            │
│    - "Anda yakin ingin tutup posisi?"                    │
└────────────────┬─────────────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────────────┐
│ 3. User Klik "Confirm" di dialog                         │
│    - onConfirm callback dieksekusi                       │
└────────────────┬─────────────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────────────┐
│ 4. POST /market/execution/close ⭐                       │
│    - Payload: {login, ticket}                            │
│    - Duration: ~1-2 seconds                              │
│    - Show: Loading indicator                             │
└────────────────┬─────────────────────────────────────────┘
                 │
                 ├─ ❌ Error?
                 │   └─→ Show error dialog + retry option
                 │
                 └─ ✅ Success?
                    │
                    ▼
                ┌────────────────────────────────────┐
                │ 5. GET /market/opened-order ⭐    │
                │    - Query: login={loginID}       │
                │    - Fetch latest positions       │
                │    - Duration: ~0.5-1 second      │
                └────────────────┬───────────────────┘
                                 │
                                 ▼
                        ┌─────────────────────────┐
                        │ 6. UI Update            │
                        │ - Show success snackbar │
                        │ - Remove closed pos     │
                        │ - Refresh position list │
                        └─────────────────────────┘
```

---

## Detailed Flow Code

```dart
// Step 1: User click close
void _onClosePosition(BuildContext context) async {
  // ... setup code ...
  
  await showCloseConfirmationDialog(
    onConfirm: () async {
      // Show loading
      Get.dialog(Center(child: CircularProgressIndicator()), ...);
      
      try {
        // ⭐ STEP 2: API Call 1 - Close Position
        await tradingController.closingOrder(
          loginID: loginID,
          ticketID: positionId ?? '',
        );
        
        // ✅ Success
        if (Get.isDialogOpen ?? false) Get.back();
        AppSnackbar.success("Posisi $positionId berhasil ditutup.");
        
        // ⭐ STEP 3: API Call 2 - Reload Positions
        await tradingController.openOrder(login: loginID);
        
      } catch (e) {
        // ❌ Error handling
        if (Get.isDialogOpen ?? false) Get.back();
        await ErrorHandler.showErrorDialog(e, ...);
      }
    },
  );
}
```

---

## Summary

**API yang dipanggil dalam `_onClosePosition()`:**

| No | HTTP Method | Endpoint | Waktu | Tujuan |
|----|-------------|----------|-------|--------|
| 1 | **POST** | `/market/execution/close` | Saat user confirm | Tutup/close position |
| 2 | **GET** | `/market/opened-order?login={id}` | Setelah close sukses | Refresh daftar posisi |

**Total API Calls:** 2 (berurutan, bukan parallel)

**Duration Total:** ~2-3 detik (tergantung network)

**Error Handling:** 
- Jika POST close gagal → show error dialog dengan retry option
- Jika GET reload gagal → positions tidak ter-refresh (masih menampilkan data lama)

**WebSocket Integration:**
- `openOrderModel` di-listen oleh worker untuk real-time updates
- Jika WebSocket sudah connected, GET reload tidak perlu dipanggil (WebSocket sudah handle)
- Tapi dalam kode ini, GET reload tetap dipanggil untuk memastikan sync data
