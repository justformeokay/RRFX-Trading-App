# API Login Flow & Account Connection - Detailed Analysis

## Pertanyaan User
> "Nah pas ada popup muncul itu, dia proses get API mana ya?" 
> (Ketika popup success "Akun demo 391585 berhasil dihubungkan ke MetaTrader 5" muncul, GET API mana yang diproses?)

---

## Jawaban: GET `/account/info`

Saat popup "Success - Akun demo 391585 berhasil dihubungkan ke MetaTrader 5" muncul, **GET API yang diproses adalah `/account/info`**.

---

## Complete Login Flow

### Stage 1: Login Request
```
Location: lib/src/controllers/authentication.dart (line 60-163)

POST /auth/login
Headers:
  - x-api-key: {GlobalVariable.x_api_key}
  - Content-Type: application/x-www-form-urlencoded

Body:
  - email: string
  - password: string
  - device: JSON (device info)
  - device_id: string (FCM Token)

Response:
{
  "status": boolean,
  "message": string,
  "response": {
    "status": "active|otp|verification|suspend",
    "passcode": boolean,
    "access_token": string,
    "refresh_token": string
  }
}
```

**Success Flow:**
- Token disimpan ke SharedPreferences
- Account status diset berdasarkan response
- Navigate ke halaman berikutnya (Setup Passcode, OTP, Verification, etc)

---

### Stage 2: Fetch User Profile
```
Location: lib/src/controllers/home.dart (line 14-42)

GET /profile/info
Headers:
  - Authorization: Bearer {access_token}

Response:
{
  "status": boolean,
  "message": string,
  "response": {
    "name": string,
    "email": string,
    "phone": string,
    // ... other profile fields
  }
}
```

**Note:** Ini dipanggil setelah login sukses, dalam fungsi `homeController.profile()`

---

### Stage 3: Fetch Trading Accounts ⭐ **HERE IS THE POPUP SOURCE**
```
Location: lib/src/controllers/trading.dart (line 447-468)

GET /account/info
Headers:
  - Authorization: Bearer {access_token}

Response:
{
  "status": boolean,
  "message": string,
  "response": {
    "demo": [
      {
        "id": string (unique account ID),
        "login": number (e.g., 391585),
        "balance": number,
        "currency": "USD|IDR",
        "leverage": number,
        "margin": number,
        "marginFree": number,
        "marginFreePercent": number,
        "rate": string (e.g., "Floating" or specific rate),
        "namaTipeAkun": string (e.g., "Akun Demo"),
        "pnl": number (Profit/Loss),
        "minDeposit": number,
        "minTopup": number,
        "minWithdrawal": number,
        "maxWithdrawal": number,
        "totalDepositIdr": number,
        "totalDepositUsd": number,
        "totalWithdrawalIdr": number,
        "totalWithdrawalUsd": number
      }
    ],
    "real": [
      // ... same structure as demo
    ]
  }
}
```

**Function Call:**
```dart
Future<bool> getTradingAccount() async {
  try {
    isLoading(true);
    Map<String, dynamic> result = await authService.get("account/info");
    isLoading(false);
    if (result['statusCode'] == 200) {
      tradingAccountModels(TradingAccountModels.fromJson(result['response']));
      // ... handle response
      return true;
    }
    return false;
  } catch (e) {
    isLoading(false);
    return false;
  }
}
```

---

## Timeline of API Calls During Login

```
┌─────────────────────────────────────────────────┐
│ User Opens App & Navigates to Login Page        │
└──────────────┬──────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│ Step 1: POST /auth/login                        │
│ - Send: email, password, device_id (FCM token) │
│ - Receive: access_token, refresh_token, status │
│ - Duration: ~1-3 seconds                        │
└──────────────┬──────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│ Step 2: GET /profile/info                       │
│ - Fetch: User profile (name, email, phone)    │
│ - Uses: access_token for authentication        │
│ - Duration: ~0.5-1 second                       │
└──────────────┬──────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│ Step 3: GET /account/info ⭐                    │
│ - Fetch: All trading accounts (demo & real)    │
│ - Returns: Account login numbers (e.g., 391585)│
│ - Duration: ~0.5-1 second                       │
│                                                 │
│ RESPONSE TRIGGERS: Success Popup Showing        │
│ "Akun demo 391585 berhasil dihubungkan ke      │
│  MetaTrader 5"                                  │
└──────────────┬──────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│ User Successfully Logged In                     │
│ - All trading accounts loaded                   │
│ - UI ready to display accounts                  │
│ - Can start trading                             │
└─────────────────────────────────────────────────┘
```

---

## Important Notes

1. **GET /account/info Response** is what generates the success popup
   - It confirms account 391585 is connected
   - Data shows it's a demo account
   - MetaTrader 5 connection is established

2. **Account Connection** (if separate from login)
   - If user connects account separately: `POST /market/account/connect`
   - Then: `GET /account/info` fetches updated connection status
   - This might show different popup

3. **Related Account APIs**
   - `POST /market/account/add` - Add account to trading UI
   - `POST /market/account/connect` - Connect/link account to MetaTrader 5
   - `GET /market/account/list` - Get list of added trading accounts
   - `DELETE /market/account/{id}` - Remove account

---

## Code References

- **Login Controller**: [authentication.dart](lib/src/controllers/authentication.dart#L60-L163)
- **Profile Fetch**: [home.dart](lib/src/controllers/home.dart#L14-L42)
- **Trading Account Fetch**: [trading.dart](lib/src/controllers/trading.dart#L447-L468)
- **Trading Account UI**: [trade/index.dart](lib/src/views/trade/index.dart#L148)

---

## Summary

**Jawaban Singkat:**
Popup "Success - Akun demo 391585 berhasil dihubungkan ke MetaTrader 5" muncul sebagai hasil dari **GET `/account/info`** API call yang dilakukan setelah login. API ini mengembalikan informasi lengkap semua trading accounts (demo dan real) yang terhubung ke akun user, termasuk login number 391585.
