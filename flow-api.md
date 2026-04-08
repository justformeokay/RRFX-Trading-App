## Konfigurasi API

| Environment | URL | Fungsi |
|---|---|---|
| **API Utama** | `https://api-rrfx.techcrm.net` | Semua REST API |
| **Gateway** | `https://gateway.rrfx.co.id` | Payment/gateway |
| **MT5 API** | `https://api-mt5.techcrm.net` | Integrasi MetaTrader5 |
| **WS Market** | `ws://207.148.119.106:9003` | Harga pasar real-time |
| **WS Account** | `ws://207.148.119.106:9006` | Balance akun real-time |
| **API Key** | `fewAHdSkx28301294cKSnczdAs` | Header `x-api-key` |

---

## FLOW 1: App Start → Splashscreen

File: splashscreen.dart

1. App dimuat → cek `SharedPreferences.getBool('loggedIn')`
2. **Jika belum login** → ke halaman login
3. **Jika sudah login** → panggil API profile lalu route sesuai status

**API Call:**
| Method | Endpoint | Fungsi |
|---|---|---|
| **GET** | `/api/profile/info` | Ambil data profil + status passcode |

**Routing setelah profile:**

| Status | Kondisi | Tujuan |
|---|---|---|
| `active` | `passcode: true` | → `VerifyPasscodePage` |
| `active` | `passcode: false` | → `SetupPasscodePage` |
| `otp` | User baru | → `OtpPage` |
| `verification` | Email belum diverifikasi | → `VerificationAccountPage` |
| `suspend` | Akun disuspend | → `SuspendedAccountPage` |
| `locked` | Akun terkunci | → `LockedPage` |

---

## FLOW 2: Login

File: authentication.dart

| Method | Endpoint | Body | Fungsi |
|---|---|---|---|
| **POST** | `/api/auth/login` | `{email, password, device, device_id}` | Login utama |

**Response:** `{access_token, refresh_token, status, passcode, otp_expired_in}`

Setelah login berhasil:
1. Simpan `accessToken` & `refreshToken` ke SharedPreferences + GetStorage
2. Set `loggedIn = true`
3. Panggil `homeController.profile()` → **GET** `/api/profile/info`
4. Route berdasarkan status akun

---

## FLOW 3: Mainpage (Tab Navigation)

File: mainpage.dart — Bottom navigation 5 tab:

| Index | Tab | Widget |
|---|---|---|
| 0 | HOME | `IndexV2()` |
| 1 | MARKET | `MarketsMeta5View()` |
| **2** | **TRADE** | `WebViewChartView()` |
| 3 | HISTORY | `TransactionTab()` |
| 4 | SETTINGS | `Settings()` |

---

## FLOW 4: Trade Tab → Buy/Sell

File: trading.dart, trade/index.dart

### Urutan API yang dipanggil:

| # | Method | Endpoint | Fungsi |
|---|---|---|---|
| 1 | **GET** | `/api/market/account/list` | Ambil daftar trading account |
| 2 | **GET** | `/api/market/symbols?account={loginID}` | Ambil daftar simbol/pair |
| 3 | **GET** | `/api/market/price-history?account={loginID}&timeframe=H1&symbol=EURUSD` | Ambil data OHLC untuk chart |
| 4 | **WebSocket** | `ws://207.148.119.106:9003` | Terima harga real-time (bid, ask, spread) |
| 5 | **POST** | `/api/market/execution/open` | **Eksekusi BUY/SELL** |

### Detail Eksekusi Order (Buy/Sell):

```
POST /api/market/execution/open
Body: {
  login: "12345",        // Trading account login ID
  symbol: "EURUSD",      // Pair
  operation: "buy|sell",  // Arah trade
  volume: "1.0"          // Lot size
}
```

---

## FLOW 5: Manage Open Position

| Method | Endpoint | Body | Fungsi |
|---|---|---|---|
| **GET** | `/api/market/opened-order?login={loginID}` | - | Ambil daftar posisi terbuka |
| **POST** | `/api/market/execution/modify` | `{login, ticket, sl, tp, is_pending}` | Modify SL/TP |
| **POST** | `/api/market/execution/close` | `{login, ticket}` | Tutup posisi |

---

## FLOW 6: Trade History

| Method | Endpoint | Fungsi |
|---|---|---|
| **GET** | `/api/market/trade-history?login={loginID}` | Ambil riwayat trade yang sudah ditutup |

---

## FLOW 7: WebSocket Real-Time

### Market Price (Port 9003):
```json
{ "symbol": "EURUSD", "bid": 1.0850, "ask": 1.0852, "direction": "up|down", "spread": 2, "digits": 5 }
```

### Account Balance (Port 9006):
```json
Subscribe: { "action": "subscribe", "login": 12345, "server": "real|demo" }
Response:  { "balance": 50000, "equity": 50225, "margin": 1000, "margin_free": 49000, "profit": 225 }
```

---

## FLOW 8: Token Refresh

| Method | Endpoint | Trigger | Fungsi |
|---|---|---|---|
| **POST** | `/api/auth/refresh` | HTTP status 300 (token expired) | Refresh token otomatis, max 3 retry |

---

## FLOW 9: Trading Account Management

| Method | Endpoint | Fungsi |
|---|---|---|
| **POST** | `/api/market/account/add` | Tambah akun trading |
| **POST** | `/api/market/account/delete` | Hapus akun trading |
| **POST** | `/api/market/account/connect` | Koneksi ke MT5 |
| **POST** | `/api/market/account/update` | Update password MT5 |

---

## Ringkasan Semua API (16 endpoint + 2 WebSocket)

### REST API:
| # | Method | Endpoint |
|---|---|---|
| 1 | POST | `/api/auth/login` |
| 2 | POST | `/api/auth/refresh` |
| 3 | GET | `/api/profile/info` |
| 4 | GET | `/api/market/account/list` |
| 5 | POST | `/api/market/account/add` |
| 6 | POST | `/api/market/account/delete` |
| 7 | POST | `/api/market/account/connect` |
| 8 | POST | `/api/market/account/update` |
| 9 | GET | `/api/market/symbols` |
| 10 | GET | `/api/market/price-history` |
| 11 | POST | `/api/market/execution/open` |
| 12 | POST | `/api/market/execution/modify` |
| 13 | POST | `/api/market/execution/close` |
| 14 | GET | `/api/market/opened-order` |
| 15 | GET | `/api/market/trade-history` |

### WebSocket:
| # | URL | Fungsi |
|---|---|---|
| 1 | `ws://207.148.119.106:9003` | Harga market real-time |
| 2 | `ws://207.148.119.106:9006` | Balance & equity real-time |

### Header di semua request:
```
Authorization: Bearer {accessToken}
x-api-key: fewAHdSkx28301294cKSnczdAs
```

---

**Catatan untuk audit:** WebSocket menggunakan `ws://` (non-encrypted) bukan `wss://` — ini adalah potensi security concern karena data harga dan balance dikirim tanpa enkripsi. Selain itu, API key di-hardcode di global_variables.dart.