# 📊 Analisis Flow & API Calls - WebViewChartView Page

## 📋 Daftar Isi
1. [Urutan Eksekusi Saat Page Dibuka](#urutan-eksekusi-saat-page-dibuka)
2. [API Calls Detail](#api-calls-detail)
3. [Dependencies & Controllers](#dependencies--controllers)
4. [Data Flow Diagram](#data-flow-diagram)
5. [Timeline Eksekusi](#timeline-eksekusi)

---

## 🚀 Urutan Eksekusi Saat Page Dibuka

### **TAHAP 1: INITIALIZATION (initState)**

```
1. WebViewChartView Constructor
   ├─ Menerima parameter: symbol, serverType, login
   └─ Creates StatefulWidget

2. _WebViewChartViewState.initState() 
   ├─ [1] Create/Put Controllers ke GetX Service Locator
   │   ├─ ChartControllers (chartController)
   │   ├─ AccountController (accountController)
   │   └─ SymbolsController (symbolsController)
   │
   ├─ [2] Set Symbol
   │   └─ Jika widget.symbol != null
   │       └─ chartController.selectedMarket.value = widget.symbol
   │
   ├─ [3] Check Connection Status
   │   └─ _checkConnection()
   │       └─ Mengecek konektivitas internet
   │
   └─ [4] Setup Connection Listener
       └─ Listening ke Connectivity().onConnectivityChanged
           └─ Update _hasConnection saat status berubah
```

**Waktu: ~50ms - 100ms**

---

### **TAHAP 2: BUILD UI & WEBVIEW CREATION**

```
3. build() method dipanggil
   ├─ Scaffold dibuat dengan AppBar & Body
   └─ InAppWebView created dengan initialUrlRequest
       └─ _buildChartUrl() dipanggil
           ├─ symbol = _currentSymbol ?? widget.symbol ?? chartController.selectedMarket.value
           ├─ server = widget.serverType ?? accountController.selectedAccount.value?.type ?? 'demo'
           ├─ login = widget.login ?? accountController.selectedAccount.value?.login ?? ''
           ├─ theme = Get.isDarkMode ? 'dark' : 'light'
           │
           └─ Build URL:
               https://chart-rrfx.techcrm.dev/chart.php?
               symbol=EURUSD.db&
               server=demo&
               login=391638&
               theme=light&
               [platform=ios&mobile=1]  // hanya untuk iOS
```

**Waktu: ~100ms - 200ms**

---

### **TAHAP 3: WEBVIEW LOADING**

```
4. InAppWebView.onWebViewCreated()
   ├─ webViewController = controller
   ├─ Untuk non-Web platform:
   │   └─ controller.addJavaScriptHandler('priceUpdate')
   │       └─ Handler untuk menerima price updates dari chart
   │
   └─ Untuk iOS platform:
       └─ Set 10 second timeout untuk reload jika gagal

5. InAppWebView.onLoadStart()
   ├─ _startTimeoutTimer() 
   │   └─ Set 15 second timeout untuk detect jika loading terlalu lama
   ├─ setState: isLoading = true, hasError = false
   └─ Print: "📥 Loading started..."

   ⏱️ Waktu: saat URL request dimulai
```

**Waktu: ~50ms**

---

### **TAHAP 4: CHART PAGE LOAD (dari server)**

```
6. Chart HTML/JS dari server dimuat
   ├─ Server: chart-rrfx.techcrm.dev
   ├─ File: chart.php dengan parameters
   └─ Responses:
       ├─ HTML structure
       ├─ JavaScript untuk chart rendering
       ├─ CSS styling
       └─ Real-time price updates (websocket atau polling)

   ⏱️ Waktu: ~1000ms - 3000ms tergantung koneksi & server
```

**Catatan:** Pada tahap ini chart service melakukan request ke backend untuk:
- Chart history data
- Current price
- Symbol information
- Market status

---

### **TAHAP 5: WEBVIEW READY (onLoadStop)**

```
7. InAppWebView.onLoadStop()
   ├─ _cancelTimeoutTimer()
   ├─ Untuk non-Web platform:
   │   └─ controller.evaluateJavascript()
   │       └─ Inject JavaScript untuk extract current price dari chart
   │           └─ Function sendPriceToFlutter(price)
   │               └─ Call priceUpdate handler dengan price value
   │
   ├─ setState: isLoading = false, hasError = false
   ├─ Print: "✅ Loading finished: {url}"
   └─ Untuk Web platform: Auto hide loading setelah 2 detik

   ⏱️ Waktu: ~50ms - 100ms
```

**Hasil:** 
- WebView siap untuk user interaction
- Price updates mulai diterima (currentPrice.value)
- ChartTradingPanel siap untuk order

---

### **TAHAP 6: BACKGROUND INITIALIZATION**

```
8. SymbolsController.onInit() (jika belum ter-initialize)
   ├─ _loadFavorites() dari GetStorage
   │   └─ Load favorite symbols dari local storage
   │
   └─ Setup listener untuk selectedAccount changes
       └─ ever(accountController.selectedAccount, (_) {
           └─ Jika account berubah, call fetchSymbols()

9. fetchSymbols() dipanggil JIKA account berubah
   ├─ isLoading.value = true
   ├─ CALL API: GET /market/symbols-group?account=391638
   │   ├─ Endpoint: market/symbols-group
   │   ├─ Method: GET
   │   ├─ Parameter: account (login number)
   │   └─ Response: SymbolsResponse dengan grouped symbols
   │
   ├─ Parse response dan populate:
   │   ├─ symbolGroups (grouped by category)
   │   ├─ allSymbols (flat list)
   │   └─ filteredSymbols = allSymbols
   │
   └─ isLoading.value = false

   ⏱️ Waktu: ~500ms - 2000ms (async, tidak blocking UI)
```

---

## 📡 API Calls Detail

### **1️⃣ GET /market/symbols-group?account={account}**

**Dipanggil oleh:** `SymbolService.getSymbolsGroup(account)`

**Kondisi:** 
- Saat page dibuka jika account sudah terpilih
- Jika account berubah

**Flow:**
```dart
accountController.selectedAccount.value != null
  ↓
fetchSymbols() triggered
  ↓
_symbolService.getSymbolsGroup(account)
  ↓
_authService.get('market/symbols-group?account=$account')
```

**Request:**
```
Method: GET
URL: /market/symbols-group?account=391638
Headers: 
  - Authorization: Bearer {token}
  - Content-Type: application/json
```

**Response:**
```json
{
  "status": true,
  "statusCode": 200,
  "message": "Success",
  "response": [
    {
      "name": "Forex Major",
      "symbols": [
        {
          "symbol": "EURUSD.db",
          "symbolAlias": "EUR/USD",
          "spread": "1.2",
          "lots": "0.1-100.0"
        },
        ...
      ]
    },
    {
      "name": "Commodities",
      "symbols": [...]
    }
  ]
}
```

**Purpose:**
- Load daftar semua symbols yang tersedia
- Dikelompokkan by category
- Digunakan untuk Market Selector dropdown

**Timing:** ~500ms - 2000ms setelah page load

---

### **2️⃣ POST /market/execution/open** (Market Order)

**Dipanggil oleh:** `ChartExecutionController.executeOrder()`

**Kondisi:** 
- User klik BUY button
- User klik SELL button

**Flow:**
```dart
_executeBuy() / _executeSell()
  ↓
_addToQueue('buy' / 'sell')
  ↓
_processQueue()
  ↓
executionController.executeOrder(login, symbol, operation, volume)
  ↓
_authService.post('market/execution/open', requestBody)
```

**Request:**
```
Method: POST
URL: /market/execution/open
Headers:
  - Authorization: Bearer {token}
  - Content-Type: application/json

Body:
{
  "login": "391638",
  "symbol": "EURUSD.db",
  "operation": "buy",
  "volume": "0.5"
}
```

**Response:**
```json
{
  "status": true,
  "statusCode": 200,
  "message": "Order executed successfully",
  "response": {
    "order": 12345,
    "volume": 0.5,
    "openPrice": 1.0850,
    "commission": 2.50
  }
}
```

**Purpose:**
- Execute market order (instant execution)
- Volume dalam lots

**Timing:** User-triggered, ~1000ms - 3000ms

---

### **3️⃣ POST /market/execution/open** (Pending Order)

**Dipanggil oleh:** `ChartExecutionController.executePendingOrder()`

**Kondisi:**
- User membuat Buy Limit order
- User membuat Sell Limit order
- User membuat Buy Stop order
- User membuat Sell Stop order

**Flow:**
```dart
_handlePendingOrder()
  ↓
executionController.executePendingOrder(
  login, symbol, operation, price, volume, sl, tp
)
  ↓
_authService.post('market/execution/open', requestBody)
```

**Request:**
```
Method: POST
URL: /market/execution/open
Headers:
  - Authorization: Bearer {token}
  - Content-Type: application/json

Body:
{
  "login": "391638",
  "symbol": "EURUSD.db",
  "operation": "buylimit",
  "volume": "0.5",
  "price": "1.0850",
  "sl": "1.0800",
  "tp": "1.0950"
}
```

**Parameters:**
- `operation`: buylimit, selllimit, buystop, sellstop
- `volume`: Lot size (0.1 - 20.0)
- `price`: Entry price (dalam harga, bukan points)
- `sl`: Stop Loss price (optional, dalam harga yang sudah dikonversi dari points)
- `tp`: Take Profit price (optional, dalam harga yang sudah dikonversi dari points)

**Response:**
```json
{
  "status": true,
  "statusCode": 200,
  "message": "Pending order created",
  "response": {
    "order": 12346,
    "volume": 0.5,
    "price": 1.0850,
    "sl": 1.0800,
    "tp": 1.0950
  }
}
```

**Purpose:**
- Buat pending order dengan conditional trigger

**Timing:** User-triggered, ~1000ms - 3000ms

---

## 🔄 Dependencies & Controllers

### **ChartControllers**
```dart
// Purpose: Manage selected market symbol
// Properties:
  - selectedMarket: RxString (current symbol)
// Methods:
  - setMarket(symbol)
```

### **AccountController**
```dart
// Purpose: Manage user accounts
// Properties:
  - selectedAccount: Rxn<AccountModel>
  - realAccounts: List<AccountModel>
  - type: String (demo/live)
// Methods:
  - fetchAccountInfo()
  - setSelectedAccount(account)
```

### **SymbolsController**
```dart
// Purpose: Manage symbols/markets
// Properties:
  - allSymbols: RxList<SymbolModel>
  - symbolGroups: RxList<SymbolGroupModel>
  - favoriteSymbols: List<SymbolModel>
  - isLoading: RxBool
// Methods:
  - fetchSymbols()
  - searchSymbols(query)
  - toggleFavorite(symbol)
```

### **ChartExecutionController**
```dart
// Purpose: Execute orders (market & pending)
// Properties:
  - lot: RxDouble
  - isExecuting: RxBool
// Methods:
  - executeOrder(login, symbol, operation, volume)
  - executePendingOrder(login, symbol, operation, price, volume, sl, tp)
  - incrementLot() / decrementLot()
```

---

## 📊 Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                   WebViewChartView Page                      │
└─────────────────────────────────────────────────────────────┘
                            ↓
            ┌───────────────┴────────────────┐
            ↓                                ↓
    ┌──────────────────┐          ┌──────────────────────┐
    │  initState()     │          │   build() - UI       │
    ├──────────────────┤          ├──────────────────────┤
    │ • Put controllers│          │ • InAppWebView       │
    │ • Set symbol     │          │ • ChartTradingPanel  │
    │ • Check network  │          │ • MarketSelector     │
    └──────────────────┘          └──────────────────────┘
            ↓                                ↓
    ┌──────────────────┐          ┌──────────────────────┐
    │ SymbolsController│          │  Chart HTML Loaded   │
    │  onInit()        │          │  (from server)       │
    ├──────────────────┤          ├──────────────────────┤
    │ • Load favorites │          │ • WebView creation   │
    │ • Setup listener │          │ • onLoadStop()       │
    │ • fetchSymbols() │          │ • JS injection       │
    └──────────────────┘          └──────────────────────┘
            ↓                                ↓
    ┌──────────────────────────────────────────────────────┐
    │     GET /market/symbols-group?account=xxx            │
    │     - Load all symbols grouped by category           │
    │     - Response: 500ms - 2000ms                       │
    └──────────────────────────────────────────────────────┘
            ↓                                ↓
    ┌──────────────────┐          ┌──────────────────────┐
    │ Symbols Ready    │          │  Trading Panel Ready │
    │ (in SymbolsList) │          │ (User can trade)     │
    └──────────────────┘          └──────────────────────┘
            ↓                                ↓
    ┌──────────────────┐          ┌──────────────────────┐
    │  User Actions:   │          │   User Actions:      │
    │ • Select market  │          │ • BUY/SELL button    │
    │ • Add favorite   │          │ • Pending order      │
    │ • Search symbols │          │ • Change lot size    │
    └──────────────────┘          └──────────────────────┘
            ↓                                ↓
    ┌──────────────────────────────────────────────────────┐
    │     POST /market/execution/open (Market/Pending)     │
    │     - Execute buy/sell order                         │
    │     - Response: 1000ms - 3000ms                      │
    └──────────────────────────────────────────────────────┘
```

---

## ⏱️ Timeline Eksekusi

```
t=0ms          initState() mulai
t=50ms         Controllers initialized & put to GetX
t=100ms        Check connection
t=150ms        build() method called
t=200ms        InAppWebView created
t=250ms        _buildChartUrl() executed
t=300ms        Chart HTML request ke server
t=500ms        onWebViewCreated() - JS handler setup
t=550ms        onLoadStart() - Loading indicator shown
t=1500ms       Chart HTML received dari server
t=1600ms       onLoadStop() - JS injection for price tracking
t=1700ms       Chart rendered & trading panel ready
               ∥
t=2000ms       GET /market/symbols-group?account=xxx START
t=2500ms       Symbol data received
t=2600ms       SymbolsController state updated
t=2700ms       Market selector dropdown ready
               ∥
               ╔════════════════════════════════════════════╗
               ║   Page Fully Loaded & Ready for Trading   ║
               ╚════════════════════════════════════════════╝

User BUY/SELL Order:
t=3000ms       User click BUY button
t=3100ms       POST /market/execution/open START
t=4000ms       Response received
t=4100ms       Order success notification shown
```

---

## 🎯 Summary

### **GET Requests:**
1. **GET /market/symbols-group?account={account}**
   - Load semua symbols
   - Timing: ~2000ms setelah page load
   - Background task (async)

### **POST Requests:**
1. **POST /market/execution/open** (Market Order)
   - Buy/Sell order
   - User-triggered, ~1-3 detik untuk response

2. **POST /market/execution/open** (Pending Order)
   - Limit/Stop orders
   - User-triggered, ~1-3 detik untuk response

### **Data Sources:**
1. **WebView (chart-rrfx.techcrm.dev)** - Chart rendering & price data
2. **Backend API** - Symbols, order execution
3. **Local Storage (GetStorage)** - Favorite symbols
4. **Real-time Communication** - Price updates (WebSocket/Polling)

### **Key Points:**
- ✅ Multiple parallel initialization (tidak blocking)
- ✅ Symbols fetch async (background)
- ✅ WebView load async (background)
- ✅ Order execution triggered by user
- ✅ Error handling dengan modern popups
- ✅ Network connectivity monitoring
