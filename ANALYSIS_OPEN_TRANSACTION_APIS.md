# Analisis Lengkap: API yang Di-hit pada Page open_transacton_meta_5.dart

## File: open_transacton_meta_5.dart
**Lokasi:** `/lib/src/views/transactions/views/open_transacton_meta_5.dart`

---

## API yang Dipanggil saat Page Load

### 📌 TOTAL API CALLS SAAT PAGE DIBUKA: 2 API + 2 WebSocket

---

## 1️⃣ API - GET `/account/info`

**Waktu Eksekusi:** Saat AccountController di-initialize (di `onInit`)  
**Lokasi Kode:** 
- [account_controller.dart line 29-31](lib/src/components/account_list/account_controller.dart#L29-L31)
- [account_service.dart line 19-26](lib/src/components/account_list/account_service.dart#L19-L26)

```dart
// File: account_controller.dart
void onInit() {
  super.onInit();
  fetchAccountInfo();  // ← Called immediately on init
}

Future<void> fetchAccountInfo() async {
  String accessToken = await _accountService.getAccessToken();
  final accountModel = await _accountService.fetchAccountInfo(accessToken: accessToken);
  // ↓ Calls: GET /account/info
}

// File: account_service.dart
Future<AccountModel> fetchAccountInfo({String? accessToken}) async {
  Map<String, dynamic> result = await _authService.get('/account/info');
  // ↓ API ENDPOINT: GET /account/info
  if(!result['status']) {
    throw Exception(errorMessage);
  }
  return AccountModel.fromJson(result);
}
```

**HTTP Method:** GET  
**Endpoint:** `/account/info`  
**Headers:** Authorization: Bearer {accessToken}

**Response Expected:**
```json
{
  "status": true,
  "message": "string",
  "response": {
    "allAccounts": [
      {
        "id": "string (unique account ID)",
        "login": "string (e.g., 391585)",
        "type": "demo|real",
        "balance": "string (numeric)",
        "equity": "string (numeric)",
        "margin": "string (numeric)",
        "marginFree": "string (numeric)",
        "marginFreePercent": "number"
      }
    ]
  }
}
```

**Fungsi:**
- Fetch semua akun trading user (demo dan real)
- Populate `AccountController.allAccounts` RxList
- Load default account (`_loadDefaultAccount()`)

**Duration:** ~1-2 seconds

---

## 2️⃣ API - GET `/market/opened-order?login={loginID}`

**Waktu Eksekusi:** Dalam `initState()` setelah AccountController siap  
**Lokasi Kode:** [open_transacton_meta_5.dart line 68-75](lib/src/views/transactions/views/open_transacton_meta_5.dart#L68-L75)

```dart
@override
void initState() {
  super.initState();
  
  // ... account listener setup ...
  
  // Initial load
  if (controller.selectedAccount.value != null) {
    _lastLoadedLogin = controller.selectedAccount.value!.login;
    _loadOrders();  // ← Called here
    _subscribeToAccountWS();
  }
}

Future<void> _loadOrders() async {
  String? loginID = controller.selectedAccount.value?.login;
  await tradingController.openOrder(login: loginID);
  // ↓ Calls: GET /market/opened-order?login={loginID}
}
```

**HTTP Method:** GET  
**Endpoint:** `/market/opened-order`  
**Query Parameter:** `login={loginID}`  
**Example:** `/market/opened-order?login=391585`  
**Headers:** Authorization: Bearer {accessToken}

**Response Expected:**
```json
{
  "status": true,
  "message": "string",
  "response": [
    {
      "ticket": 123456,
      "symbol": "EURUSD",
      "orderType": "buy|sell",
      "lot": 0.1,
      "openPrice": 1.08234,
      "openTime": "2025-02-06 14:30:00",
      "currentPrice": 1.08450,
      "stopLoss": 1.08000,
      "takeProfit": 1.08500,
      "profit": 21.60,
      "swap": 0.50,
      "digits": 5,
      "commission": 0.00
    }
  ]
}
```

**Fungsi:**
- Fetch daftar posisi yang masih terbuka
- Populate `TradingController.openOrderModel` Rxn
- Display di UI sebagai list of open positions

**Duration:** ~1-2 seconds

---

## 🔌 WebSocket Connections

### 3️⃣ WebSocket - Account Balance Subscription

**Waktu Eksekusi:** Dalam `initState()` setelah `_loadOrders()`  
**Lokasi Kode:** [open_transacton_meta_5.dart line 77-90](lib/src/views/transactions/views/open_transacton_meta_5.dart#L77-L90)

```dart
void _subscribeToAccountWS() {
  final login = controller.selectedAccount.value?.login;
  final serverType = controller.selectedAccount.value?.type;
  
  if (login != null && serverType != null) {
    accountWS.subscribe(login: login, serverType: serverType);
    // ↓ WebSocket Subscribe to account balance updates
  }
}
```

**Controller:** `AccountBalanceWSController`  
**Connection Type:** WebSocket (real-time)

**Subscription Payload:**
```json
{
  "login": "391585",
  "serverType": "demo"
}
```

**Real-time Updates Received:**
- Account balance changes
- Equity updates
- Margin/Free Margin changes
- Profit/Loss calculations
- Any position-related balance changes

**Listeners:**
- `accountWS.profit` - Real-time profit value
- Account balance fields update automatically

---

### 4️⃣ WebSocket - Market Data Subscription

**Waktu Eksekusi:** Saat page di-load (via Get.put permanent)  
**Lokasi Kode:** [open_transacton_meta_5.dart line 38-42](lib/src/views/transactions/views/open_transacton_meta_5.dart#L38-L42)

```dart
// Ensure MarketWebSocketController is registered
final MarketWebSocketController marketWS = Get.put(
  MarketWebSocketController(),
  permanent: true,
);
```

**Controller:** `MarketWebSocketController`  
**Purpose:** Real-time market price data for all symbols

**Real-time Data Received:**
- Current bid/ask prices
- Market movement updates
- Used for `currentPrice` in open positions
- Used in edit position dialog for live price updates

---

## Timeline Saat Page Load

```
┌──────────────────────────────────────────────────────────────────┐
│ 1. User Membuka TransactionTab > OPEN Tab                        │
└────────────────┬─────────────────────────────────────────────────┘
                 │
                 ▼
    ┌─────────────────────────────────────────┐
    │ OpenTransactonMeta5() created           │
    │ AccountController Get.put()             │
    │ └─→ onInit() triggered ⭐              │
    └────────────┬────────────────────────────┘
                 │
                 ▼
    ┌─────────────────────────────────────────┐
    │ API 1: GET /account/info ⭐            │
    │ └─ Duration: ~1-2 seconds               │
    │ └─ Response: All user accounts (demo)   │
    │ └─ Populate: allAccounts, selectedAcc   │
    └────────────┬────────────────────────────┘
                 │
                 ▼
    ┌─────────────────────────────────────────┐
    │ initState() of OpenTransactonMeta5      │
    │ └─ Check selectedAccount exists         │
    └────────────┬────────────────────────────┘
                 │
                 ├─→ API 2: GET /market/opened-order ⭐
                 │   └─ Query: login=391585
                 │   └─ Duration: ~1-2 seconds
                 │   └─ Response: List open positions
                 │
                 ├─→ WS 1: Subscribe Account Balance ⭐
                 │   └─ Real-time: profit, balance, margin
                 │   └─ Duration: continuous
                 │
                 └─→ WS 2: Market Data (permanent) ⭐
                     └─ Real-time: symbol prices
                     └─ Duration: continuous
                 │
                 ▼
    ┌─────────────────────────────────────────┐
    │ Widget Build                            │
    │ ├─ _BalanceHeaderDelegate renders      │
    │ ├─ Position list displays               │
    │ └─ All real-time data updates working   │
    └─────────────────────────────────────────┘
```

---

## API Calls Summary

| No | Type | Endpoint | Timing | Duration | Purpose |
|----|------|----------|--------|----------|---------|
| 1 | GET | `/account/info` | AccountController.onInit() | 1-2s | Fetch all user accounts |
| 2 | GET | `/market/opened-order?login={id}` | initState() | 1-2s | Fetch open positions |
| 3 | WS | Account Balance Subscribe | initState() | Continuous | Real-time balance updates |
| 4 | WS | Market Data Subscribe | onLoad | Continuous | Real-time price updates |

---

## Total Network Requests

**HTTP Requests:** 2 GET  
**WebSocket Connections:** 2 subscriptions  
**Total Duration:** ~2-4 seconds (both API calls in parallel or sequential)

---

## Key Controllers Involved

1. **AccountController** (`lib/src/components/account_list/`)
   - API: GET `/account/info`
   - Manages: allAccounts, selectedAccount
   - Permanent: Yes

2. **TradingController** (`lib/src/controllers/trading.dart`)
   - API: GET `/market/opened-order`
   - Manages: openOrderModel (Rxn)
   - Response: List of open positions

3. **AccountBalanceWSController** (`lib/src/controllers/account_balance_ws_controller.dart`)
   - WebSocket subscription for account balance
   - Real-time: profit, balance, equity, margin
   - Status: connected/disconnected

4. **MarketWebSocketController** (`lib/src/controllers/websocket_controller.dart`)
   - WebSocket subscription for market prices
   - Real-time: bid/ask prices for all symbols
   - Status: connected/disconnected

---

## Data Flow After Load

```
┌─────────────────────────────────────┐
│ GET /account/info Response          │
└──────────┬──────────────────────────┘
           │
           ▼
┌─────────────────────────────────────┐
│ AccountController.allAccounts       │
│ selectedAccount = allAccounts[0]    │
└──────────┬──────────────────────────┘
           │
           ▼
┌─────────────────────────────────────┐
│ GET /market/opened-order            │
│ (using selectedAccount.login)       │
└──────────┬──────────────────────────┘
           │
           ▼
┌─────────────────────────────────────┐
│ TradingController.openOrderModel    │
│ ├─ response: List<Position>         │
│ └─ Triggers UI rebuild (Obx)        │
└──────────┬──────────────────────────┘
           │
           ├─→ WS Updates profit value
           │   └─ accountWS.profit
           │   └─ Display in header
           │
           ├─→ WS Updates currentPrice
           │   └─ marketWS.marketData
           │   └─ Display in position list
           │
           └─→ Balance data displayed
               └─ _BalanceHeaderDelegate
```

---

## Code References

- **Page Component:** [OpenTransactonMeta5](lib/src/views/transactions/views/open_transacton_meta_5.dart)
- **initState:** [line 45-76](lib/src/views/transactions/views/open_transacton_meta_5.dart#L45-L76)
- **_loadOrders():** [line 92-107](lib/src/views/transactions/views/open_transacton_meta_5.dart#L92-L107)
- **_subscribeToAccountWS():** [line 77-90](lib/src/views/transactions/views/open_transacton_meta_5.dart#L77-L90)
- **AccountController:** [account_controller.dart](lib/src/components/account_list/account_controller.dart)
- **AccountService:** [account_service.dart](lib/src/components/account_list/account_service.dart)
- **TradingController:** [trading.dart](lib/src/controllers/trading.dart)

---

## Important Notes

✅ **Automatic Reload:**
- API calls triggered again jika user switch account (via ever listener)
- `_lastLoadedLogin` check mencegah duplicate calls

✅ **Real-time Updates:**
- WebSocket connection ongoing sepanjang page aktif
- UI auto-update via Obx() reactive programming

✅ **Error Handling:**
- API failures caught in try-catch
- Get.snackbar for error messages
- null checks di setiap step

⚠️ **Performance Considerations:**
- 2 API calls berjalan bersamaan (parallel mungkin)
- 2 WebSocket connections open simultaneously
- Total load time: ~2-4 seconds depending on network
