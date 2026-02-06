# 🔍 QUICK REFERENCE - WebViewChartView API & Flow

## 📌 API ENDPOINTS

```
1. GET /market/symbols-group?account={account}
   └─ Called by: SymbolsController.fetchSymbols()
   └─ Timing: ~2000ms after page load (async)
   └─ Purpose: Load all trading symbols grouped by category
   └─ Trigger: On page load + account change
   └─ Response: List of symbol groups with symbols data

2. POST /market/execution/open
   ├─ Market Order:
   │  ├─ Body: { login, symbol, operation, volume }
   │  ├─ operation: "buy" | "sell"
   │  └─ Timing: User-triggered, ~1-3 seconds
   │
   └─ Pending Order:
      ├─ Body: { login, symbol, operation, price, volume, sl, tp }
      ├─ operation: "buylimit" | "selllimit" | "buystop" | "sellstop"
      └─ Timing: User-triggered, ~1-3 seconds
```

---

## ⚡ EXECUTION FLOW

```
PAGE OPEN
  ↓
initState() 
  ├─ [~50ms] Create controllers
  ├─ [~50ms] Check network
  └─ [~50ms] Setup listeners
  ↓
build() 
  ├─ [~100ms] Build UI
  └─ [~100ms] Create WebView
  ↓
Chart Loading
  ├─ [~300ms] Request HTML from chart-rrfx.techcrm.dev
  ├─ [~1500ms] Receive chart HTML
  └─ [~1600ms] Chart rendered + JS injection for price tracking
  ↓
Background Initialization
  └─ [~2000ms] GET /market/symbols-group (async)
       ├─ Load symbols
       └─ Populate symbol list
  ↓
✅ PAGE READY FOR TRADING
   └─ WebView ready
   └─ Chart displayed
   └─ Trading panel ready
   └─ Symbols loaded
```

---

## 🎬 DETAILED SEQUENCE

### **Step 1: Controllers Created**
```dart
final chartController = Get.put(ChartControllers());      // 50ms
final accountController = Get.put(AccountController());   // 50ms
final symbolsController = Get.put(SymbolsController());   // 50ms
```
- **Purpose:** Manage state across the app
- **Effect:** Enables symbol selection, account switching, order tracking

---

### **Step 2: Symbol Set**
```dart
if (widget.symbol != null) {
  _currentSymbol = widget.symbol;
  chartController.selectedMarket.value = widget.symbol;
}
```
- **Purpose:** Set which symbol to display
- **Effect:** Passed to chart URL

---

### **Step 3: Network Check**
```dart
_checkConnection();  // Check internet connectivity
_connectionSubscription = 
  Connectivity().onConnectivityChanged.listen(...)  // Monitor changes
```
- **Purpose:** Detect internet status
- **Effect:** Show/hide connection error UI

---

### **Step 4: Build Chart URL**
```
URL = https://chart-rrfx.techcrm.dev/chart.php?
      symbol=EURUSD.db&
      server=demo&
      login=391638&
      theme=light&
      [platform=ios&mobile=1]
```
- **Purpose:** Load chart with correct parameters
- **Effect:** Chart server uses these params for data & rendering

---

### **Step 5: WebView Created**
```dart
InAppWebView.onWebViewCreated()
  ├─ Add JavaScript handler: 'priceUpdate'
  │  └─ Receive price updates from chart JS
  └─ Set timeout for iOS (10 sec)
```
- **Purpose:** Setup communication bridge between chart & Flutter
- **Effect:** Real-time price tracking

---

### **Step 6: Chart Loading**
```
onLoadStart()
  ├─ Show loading indicator
  ├─ Start 15-second timeout
  └─ Print: "📥 Loading started..."

[~1500ms delay while server sends chart]

onLoadStop()
  ├─ Hide loading indicator
  ├─ Inject JavaScript for price tracking
  └─ Print: "✅ Loading finished"
```

---

### **Step 7: Symbols Fetching (Parallel)**
```dart
SymbolsController.onInit()
  └─ Listen to accountController.selectedAccount changes
      └─ fetchSymbols() triggered
          └─ GET /market/symbols-group?account=391638
              ├─ [~500-2000ms] Request & response
              ├─ Parse into symbolGroups
              └─ State updated: allSymbols, symbolGroups
```

---

## 💡 KEY INSIGHTS

### **Initialization Strategy**
- ✅ **Parallel Loading:** Chart + Symbols loaded simultaneously
- ✅ **Async Operations:** Don't block UI thread
- ✅ **Smart Caching:** Symbols cached based on account

### **Error Handling**
- 🔴 Chart timeout: 15 seconds (shows error, reload option)
- 🔴 Network error: Shows connection lost banner
- 🔴 API error: Modern alert popup (non-technical message)

### **Performance**
- ⚡ Total startup: ~1700ms until page ready
- ⚡ Chart: ~1500ms load time
- ⚡ Symbols: ~2000ms (background, doesn't block)

### **Real-time Features**
- 📊 Price updates: WebSocket from chart server
- 📊 Price tracking: JavaScript injection to extract price
- 📊 Order execution: ~1-3 seconds per order

---

## 🔗 Related Files

- `webview_chart_view.dart` - Main page
- `chart_trading_panel.dart` - Order execution UI
- `symbols_controller.dart` - Symbol management
- `chart_execution_controller.dart` - Order API calls
- `symbol_service.dart` - Symbol API calls
- `market_selector_sheet.dart` - Market selection UI

---

## 📱 User Flow Example

```
User opens Trading page
  ↓
[1] Page initializes (initState)
    - Controllers created
    - Network checked
    - WebView created
  ↓
[2] Chart loads (WebView)
    - Requests chart from external server
    - Injects price tracking JS
    - Shows chart with current price
  ↓
[3] Symbols load (background)
    - GET /market/symbols-group API call
    - Populates market selector dropdown
  ↓
[4] User ready to trade ✅
    - Can select market
    - Can execute BUY/SELL
    - Can create pending orders
  ↓
[5] User clicks BUY
    - POST /market/execution/open
    - Shows loading overlay
    - ~1-3 seconds response
    - Success/error notification
```

---

## 🚨 Potential Issues & Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| Chart not loading | Slow connection | 15-sec timeout triggers reload |
| Symbols not showing | Account not selected | Account controller listener |
| Order failing | Invalid data | Modern error popup shows reason |
| Price not updating | JS injection failed | Manual price request on demand |
| Network disconnected | Internet lost | Connection listener detects & shows |

