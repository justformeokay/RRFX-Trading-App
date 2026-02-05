# Error Handling Flow Diagram

## 🔄 Error Handling Process Flow

```
┌─────────────────────────────────────────────────────────────┐
│ User Action: Tap "Close Position" Button                    │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ Show Loading Dialog                                          │
│ (CircularProgressIndicator)                                 │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ Call: tradingController.closingOrder()                      │
│                                                             │
│ Makes API Request to:                                       │
│ POST /market/execution/close                               │
└────────────────────────┬────────────────────────────────────┘
                         │
              ┌──────────┴──────────┐
              │                     │
              ▼                     ▼
       ┌─────────────┐      ┌────────────────┐
       │ SUCCESS     │      │ ERROR THROWN   │
       │ (Rare)      │      │ (Network, etc) │
       └──────┬──────┘      └────────┬───────┘
              │                      │
              │                      ▼
              │           ┌──────────────────────┐
              │           │ Catch Exception (e)  │
              │           └──────────┬───────────┘
              │                      │
              │                      ▼
              │           ┌──────────────────────────────┐
              │           │ Close Loading Dialog          │
              │           │ (if still open)              │
              │           └──────────┬───────────────────┘
              │                      │
              │                      ▼
              │           ┌─────────────────────────────────────┐
              │           │ ErrorHandler.showErrorDialog()       │
              │           │                                     │
              │           │ 1. Detect error type                │
              │           │ 2. Find matching message            │
              │           │ 3. Show modern dialog               │
              │           └──────────┬────────────────────────┘
              │                      │
              │          ┌───────────┴───────────┐
              │          │                       │
              ▼          ▼                       ▼
         ┌─────────┐  ┌──────────────┐  ┌──────────────────┐
         │ SUCCESS │  │ USER CLICKS  │  │ USER CLICKS      │
         │ SNACKBAR│  │ "COBA LAGI"  │  │ "OK" / BACK      │
         │         │  │              │  │                  │
         │ "Posisi │  │ Retry logic  │  │ Dialog closes    │
         │ berhasil│  │ executed     │  │ Back to positions│
         │ ditutup"│  └──────┬───────┘  │ list             │
         └────┬────┘         │          └──────────────────┘
              │              │
              │              ▼
              │      ┌──────────────────┐
              │      │ Try Again         │
              │      │ (Full flow repeat)│
              │      └──────────────────┘
              │
              ▼
    ┌──────────────────────┐
    │ Reload positions     │
    │ await tradingController
    │ .openOrder(login: id)│
    └──────────────────────┘
```

---

## 🎯 Error Detection & Message Mapping

```
Raw Exception Input
       │
       ▼
┌──────────────────────────────────────┐
│ ErrorHandler.getErrorMessage()       │
│                                      │
│ Scans for known error keywords:      │
└────────────┬─────────────────────────┘
             │
    ┌────────┼────────┬──────────┬─────────┬─────────┬──────────────┐
    │        │        │          │         │         │              │
    ▼        ▼        ▼          ▼         ▼         ▼              ▼
Socket    Failed   No address  Connection Connection TimeoutException
Exception host     associated  refused    timed out
          lookup   with hostname

    │        │        │          │         │         │              │
    └────────┼────────┼──────────┼─────────┼─────────┼──────────────┘
             │        │          │         │         │
             ▼        ▼          ▼         ▼         ▼
"Koneksi"  "Tidak " "Tidak"   "Server"  "Koneksi" "Permintaan"
"internet"  "dapat" "dapat"    "tidak"   "memakan" "memakan"
"tidak"   "terhub terhub     "tersedia" "waktu"   "waktu"
"stabil"  ung"     ung"                          

             │
             ▼
      ┌─────────────────────────────────┐
      │ Return User-Friendly Message    │
      │ in Indonesian Language          │
      └────────────┬────────────────────┘
                   │
                   ▼
          ┌──────────────────────┐
          │ Display in Dialog    │
          │ or Snackbar          │
          └──────────────────────┘
```

---

## 📊 Error Dialog State Machine

```
                    IDLE STATE
                       │
                       │ catch(exception)
                       ▼
            ┌──────────────────────┐
            │ Create Dialog        │
            │ - Extract error      │
            │ - Map to message     │
            │ - Build widgets      │
            └──────────┬───────────┘
                       │
                       ▼
            ┌──────────────────────┐
            │ DIALOG SHOWN         │
            │                      │
            │ [Coba Lagi] [OK]     │
            └──────┬────────┬──────┘
                   │        │
         ┌─────────┘        └──────────┐
         │                             │
    User taps              User taps OK/Back
   "Coba Lagi"            or Taps outside
         │                             │
         ▼                             ▼
    Execute                    ┌────────────────┐
    Retry                      │ Dispose Dialog │
    Callback                   └────────┬───────┘
         │                             │
         │ onRetry()                   │
         │ executes                    │
         │ (user defined)              │
         │                             ▼
         │                        BACK TO
         │                    PREVIOUS STATE
         │
         └──────────┐
                    │
                    ▼ (May succeed or fail)
                 Start over
```

---

## 🔀 Code Flow in open_transacton_meta_5.dart

```
┌─────────────────────────────────────────────────────────────┐
│ _onClosePosition(context)                                   │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────┐
        │ showCloseConfirmDialog │
        │ User confirms action   │
        └────────┬───────────────┘
                 │
                 ▼
        ┌────────────────────────┐
        │ Show Loading Dialog    │
        │ CircularProgressIndic. │
        └────────┬───────────────┘
                 │
    ┌────────────┴────────────┐
    │                         │
    ▼                         ▼
 TRY BLOCK               CATCH BLOCK
    │                         │
    ├─ await closing          ├─ Close loading dialog
    │  Order()                │
    │                         ├─ ErrorHandler
    ├─ Close loading          │  .showErrorDialog(e)
    │  dialog                 │
    │                         ├─ Show dialog with:
    ├─ Show success           │  - Error message
    │  snackbar               │  - Retry button
    │                         │  - OK button
    ├─ Reload positions       │
    │  (await openOrder)      └─ User chooses action
    │
    └─ Success ✅
```

---

## 📱 User Journey

```
START: User sees open positions list
  │
  ├─ Long press on position
  │   │
  │   ▼
  │  Confirmation Dialog appears
  │  "Close Position?"
  │   │
  │   ├─ User taps "Cancel"
  │   │   └─ Back to positions list
  │   │
  │   └─ User taps "Confirm Close"
  │       │
  │       ▼
  │      Loading appears
  │       │
  │       ├─ API Success ✅
  │       │  ├─ Show "Posisi berhasil ditutup" snackbar
  │       │  └─ Reload positions
  │       │
  │       └─ API Error ❌
  │          ├─ Close loading
  │          ├─ Show Error Dialog
  │          │  "Gagal Menutup Posisi"
  │          │  "[User-friendly message]"
  │          │
  │          ├─ User taps "Coba Lagi"
  │          │  └─ Retry logic (back to Try block)
  │          │
  │          └─ User taps "OK"
  │             └─ Back to positions list
  │
  └─ END: Back to initial state
```

---

## 🔐 Security: Error Information Flow

```
SERVER ERROR
    │
    ├─ Contains: URL, Status code, Technical details
    │            Stack trace, Internal paths
    │            Database info, API structure
    │
    ▼
Exception Object in Dart
    │
    ├─ Before: Directly shown to user ❌
    │          "Error: exception/internal/api/..." 
    │
    ▼
ErrorHandler.showErrorDialog()
    │
    ├─ Detects error type
    │ ├─ SocketException
    │ ├─ Timeout
    │ ├─ Connection refused
    │ └─ etc.
    │
    ├─ Filters out sensitive information ✅
    │ ├─ ❌ Remove URL
    │ ├─ ❌ Remove internal paths
    │ ├─ ❌ Remove error codes
    │
    ▼
User-Friendly Message ✅
"Koneksi internet tidak stabil. 
 Silakan periksa koneksi Anda dan coba lagi."
```

---

## 💡 Features Overview

```
┌─────────────────────────────────────────────────────┐
│           ErrorHandler.showErrorDialog()             │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ✅ Features:                                       │
│  ├─ Auto-detect error type                         │
│  ├─ Convert to user-friendly message               │
│  ├─ Modern Material 3 design                       │
│  ├─ Dark mode support                              │
│  ├─ Retry callback support                         │
│  ├─ Smooth animations                              │
│  ├─ Responsive layout                              │
│  ├─ Icon + Title + Message layout                 │
│  └─ Custom button text                             │
│                                                     │
│  🎨 Styling:                                        │
│  ├─ Red icon container                             │
│  ├─ Rounded corners (BorderRadius 16)              │
│  ├─ Material elevation                             │
│  ├─ Custom colors (secondary color buttons)        │
│  └─ Inter font (Google Fonts)                      │
│                                                     │
│  📱 Parameters:                                     │
│  ├─ error (required) - Exception object           │
│  ├─ title - Dialog title                           │
│  ├─ customMessage - Override auto message          │
│  ├─ buttonText - OK button text                    │
│  └─ onRetry - Callback for retry button           │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## 🎯 Error Type Coverage

```
Network Errors (Most Common)
├─ SocketException ──────► "Koneksi tidak stabil"
├─ DNS Resolution ──────► "Tidak dapat terhubung"
├─ Connection Refused ──► "Server tidak tersedia"
└─ Timeout ─────────────► "Koneksi terlalu lama"

Server Errors
├─ 4xx Status Code ─────► "Permintaan tidak valid"
├─ 5xx Status Code ─────► "Server error"
└─ Generic Exception ───► "Kesalahan tidak terduga"
```

---

**Diagram Version**: 1.0
**Last Updated**: February 5, 2026
