# Analisis API & WebSocket pada Page Transaction Tab

## File: transaction_tab.dart
**Lokasi:** `/lib/src/views/transactions/views/transaction_tab.dart`

---

## Overview
Saat user membuka halaman `TransactionTab`, ada 2 tab:
1. **OPEN Tab** → Menampilkan posisi yang masih terbuka
2. **CLOSED Tab** → Menampilkan posisi yang sudah ditutup

Kedua tab akan hit API dan WebSocket yang berbeda.

---

## API & WebSocket yang Dipanggil

### 📊 TAB 1: OPEN POSITIONS (OpenTransactonMeta5)

#### **1️⃣ API - GET `/market/opened-order?login={loginID}`**
**Waktu:** Saat tab OPEN pertama kali dimuat (di initState)  
**Lokasi Kode:** [open_transacton_meta_5.dart line 45-75](lib/src/views/transactions/views/open_transacton_meta_5.dart#L45-L75)

```dart
Future<void> _loadOrders() async {
  if (_isLoadingOrders) return;
  if (!controller.hasAccounts) return;
  
  String? loginID = controller.selectedAccount.value?.login;
  if (loginID == null) return;
  
  try {
    _isLoadingOrders = true;
    await tradingController.openOrder(login: loginID);
    // ↓ Calls: GET /market/opened-order?login={loginID}
  } finally {
    _isLoadingOrders = false;
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

**Fungsi:** Mengambil list posisi terbuka dari server

---

#### **2️⃣ WebSocket - Account Balance Subscription**
**Waktu:** Saat tab OPEN pertama kali dimuat (di initState)  
**Lokasi Kode:** [open_transacton_meta_5.dart line 77-90](lib/src/views/transactions/views/open_transacton_meta_5.dart#L77-L90)

```dart
void _subscribeToAccountWS() {
  if (!controller.hasAccounts) return;
  
  final login = controller.selectedAccount.value?.login;
  final serverType = controller.selectedAccount.value?.type;
  
  if (login != null && serverType != null) {
    accountWS.subscribe(login: login, serverType: serverType);
    // ↓ Subscribe to real-time account balance updates
  }
}
```

**Controller:** `AccountBalanceWSController`  
**Subscription:** WebSocket connection dengan payload:
```json
{
  "login": "string (account login number)",
  "serverType": "string (demo|real)"
}
```

**Real-time Updates:**
- Account balance changes
- Profit/loss updates
- Margin level changes
- Any position updates

---

#### **3️⃣ WebSocket - Market Data Subscription (Optional)**
**Kontroller:** `MarketWebSocketController`  
**Fungsi:** Real-time market prices untuk update currentPrice posisi

```dart
final MarketWebSocketController marketWS = Get.put(
  MarketWebSocketController(),
  permanent: true,
);
```

---

### 📋 TAB 2: CLOSED POSITIONS (CloseTransactionMeta5)

#### **1️⃣ API - GET `/market/trade-history?login={loginID}`**
**Waktu:** Saat tab CLOSED pertama kali dimuat (di initState)  
**Lokasi Kode:** [close_transaction_meta_5.dart line 42-60](lib/src/views/transactions/views/close_transaction_meta_5.dart#L42-L60)

```dart
Future<void> _loadClosedOrders() async {
  if (!controller.hasAccounts) {
    Get.log("TIDAK MEMILIKI AKUN TRADING DEMO MAUPUN REAL");
    return;
  }
  
  isLoading.value = true;
  String? loginID = controller.selectedAccount.value?.login;
  
  if (loginID != null) {
    await tradingController.closedOrder(login: loginID);
    // ↓ Calls: GET /market/trade-history?login={loginID}
  }
  
  isLoading.value = false;
  await Future.delayed(const Duration(milliseconds: 600));
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
      "closePrice": number,
      "closeTime": "string",
      "profit": number,
      "swap": number,
      "commission": number,
      "comment": "string"
    }
  ]
}
```

**Fungsi:** Mengambil history posisi yang sudah ditutup

---

## Timeline Saat Buka Halaman

```
┌──────────────────────────────────────────────────────────────┐
│ 1. User Buka TransactionTab Page                             │
└────────────────┬─────────────────────────────────────────────┘
                 │
                 ├─── TAB 1: OPEN (Default active)
                 │    │
                 │    ├─→ initState() of OpenTransactonMeta5
                 │    │   │
                 │    │   ├─→ Setup account listener
                 │    │   │
                 │    │   ├─→ GET /market/opened-order ⭐
                 │    │   │   └─ Duration: ~1-2 seconds
                 │    │   │   └─ Response: List posisi terbuka
                 │    │   │
                 │    │   └─→ WebSocket Subscribe (Account Balance) ⭐
                 │    │       └─ Real-time updates
                 │    │
                 │    └─→ Render UI dengan data
                 │
                 └─── TAB 2: CLOSED (Lazy load)
                      │
                      ├─→ initState() of CloseTransactionMeta5
                      │   │
                      │   ├─→ Future.delayed(Duration.zero, ...)
                      │   │
                      │   ├─→ GET /market/trade-history ⭐
                      │   │   └─ Duration: ~1-2 seconds
                      │   │   └─ Response: History posisi tertutup
                      │   │
                      │   └─→ Render UI dengan data
                      │
                      └─→ No WebSocket subscription
```

---

## Summary Table

| Aspect | TAB: OPEN | TAB: CLOSED |
|--------|-----------|------------|
| **HTTP GET** | `/market/opened-order?login={id}` | `/market/trade-history?login={id}` |
| **WebSocket** | Yes (Account Balance) | No |
| **Real-time** | Yes | No (Static data) |
| **Update On** | Account changes, WS updates | User manual refresh |
| **Data Type** | Active positions | Closed/history positions |
| **File** | open_transacton_meta_5.dart | close_transaction_meta_5.dart |

---

## API Calls Detail

### GET /market/opened-order
```
Endpoint: /market/opened-order
Method: GET
Query Parameter: login={loginID}
Headers: Authorization: Bearer {accessToken}
Purpose: Fetch active/open positions
Frequency: Once per tab load + when account changes
Response Time: ~1-2 seconds
```

### GET /market/trade-history
```
Endpoint: /market/trade-history
Method: GET
Query Parameter: login={loginID}
Headers: Authorization: Bearer {accessToken}
Purpose: Fetch closed/history positions
Frequency: Once per tab load + when account changes
Response Time: ~1-2 seconds
```

### WebSocket: Account Balance (accountWS)
```
Type: Real-time WebSocket connection
Payload: {login, serverType}
Updates: Balance, Equity, Margin, Profit, etc.
Frequency: Continuous (as data changes)
Listeners: openOrderModel updates
```

---

## Detailed Code References

**OPEN Tab:**
- Main component: [OpenTransactonMeta5](lib/src/views/transactions/views/open_transacton_meta_5.dart)
- API call: [_loadOrders()](lib/src/views/transactions/views/open_transacton_meta_5.dart#L92-L107)
- WS subscribe: [_subscribeToAccountWS()](lib/src/views/transactions/views/open_transacton_meta_5.dart#L77-L90)
- Trading controller: [openOrder()](lib/src/controllers/trading.dart#L617-L628)

**CLOSED Tab:**
- Main component: [CloseTransactionMeta5](lib/src/views/transactions/views/close_transaction_meta_5.dart)
- API call: [_loadClosedOrders()](lib/src/views/transactions/views/close_transaction_meta_5.dart#L42-L60)
- Trading controller: [closedOrder()](lib/src/controllers/trading.dart#L604-L613)

---

## Key Observations

✅ **OPEN Tab:**
- Gets fresh data via API
- Listens to WebSocket for real-time balance updates
- Auto-refreshes when account switches

✅ **CLOSED Tab:**
- Gets historical data via API
- No WebSocket subscription (static data)
- Gets data once and caches it

⚠️ **Important:**
- Both tabs call their respective APIs as soon as they are created (not lazy-loaded)
- Account changes trigger both tabs to reload their data
- WebSocket is only for OPEN tab (real-time balance), not for CLOSED tab
