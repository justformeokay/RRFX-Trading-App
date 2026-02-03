# Chart Price Integration Guide

## Implementasi Sudah Selesai ✅

### Flutter Side (Sudah Diimplementasi)

1. **webview_chart_view.dart**
   - ✅ Added `currentPrice` RxnDouble state variable
   - ✅ Added JavaScript handler `priceUpdate` di `onWebViewCreated`
   - ✅ Pass `currentPrice` ke ChartTradingPanel

2. **chart_trading_panel.dart**
   - ✅ Added `currentPrice` parameter
   - ✅ Added button "Use Current Price" di Entry Price field
   - ✅ Auto-fill price dengan tap button
   - ✅ Haptic feedback saat button diklik

### WebView/Chart Side (Perlu Ditambahkan)

Tambahkan kode berikut di file **chart.php**:

```javascript
// Function untuk kirim price update ke Flutter
function sendPriceToFlutter(price) {
  try {
    if (window.flutter_inappwebview) {
      window.flutter_inappwebview.callHandler('priceUpdate', price);
      console.log('📊 Price sent to Flutter:', price);
    }
  } catch (e) {
    console.error('Error sending price to Flutter:', e);
  }
}

// Contoh 1: Jika menggunakan TradingView Widget
// Tambahkan di callback widget
widget.onChartReady(function() {
  widget.subscribe('quote', function(symbolInfo, quote) {
    const currentPrice = quote.lp; // last price
    sendPriceToFlutter(currentPrice);
  });
});

// Contoh 2: Jika menggunakan custom chart dengan WebSocket
socket.onmessage = function(event) {
  const data = JSON.parse(event.data);
  if (data.price) {
    sendPriceToFlutter(data.price);
  }
};

// Contoh 3: Jika price ada di DOM element
// Update price secara periodik
setInterval(function() {
  const priceElement = document.querySelector('.current-price');
  if (priceElement) {
    const price = parseFloat(priceElement.innerText);
    if (!isNaN(price)) {
      sendPriceToFlutter(price);
    }
  }
}, 1000); // Update setiap 1 detik
```

## Cara Kerja

1. **Chart → Flutter**: Chart mengirim price via `window.flutter_inappwebview.callHandler('priceUpdate', price)`
2. **Flutter menerima**: JavaScript handler meng-update `currentPrice.value`
3. **UI Update**: Button di Entry Price field otomatis menampilkan current price
4. **User tap button**: Price otomatis diisi ke field Entry Price

## UI Features

- 🔄 **Live Price Badge**: Menampilkan current price di samping label "Entry Price *"
- 🎯 **One Tap Fill**: Tap badge untuk auto-fill price ke input field
- 📳 **Haptic Feedback**: Vibration saat mengisi price
- 🎨 **Blue Accent**: Badge dengan warna biru matching tema app
- ⚡ **Real-time**: Price update otomatis dari chart

## Testing

Untuk testing tanpa modify chart.php, bisa inject manual via Chrome DevTools:

```javascript
// Test di Chrome DevTools Console (saat debug webview)
window.flutter_inappwebview.callHandler('priceUpdate', 4919.17);
```

Atau tambahkan tombol test di chart.php:

```html
<button onclick="sendPriceToFlutter(4919.17)">Test Price Update</button>
```

## Example Layout

```
Entry Price *  [🔄 4919.17]  ← Tap button ini untuk fill price
┌─────────────────────────┐
│ 🏷️ Below current price  │
└─────────────────────────┘
```

## Notes

- Price format: 2 decimal places (e.g., 4919.17)
- Button hanya muncul jika `currentPrice != null`
- Otomatis hide jika price belum tersedia
- Compatible dengan semua execution types (Buy/Sell Limit/Stop)
