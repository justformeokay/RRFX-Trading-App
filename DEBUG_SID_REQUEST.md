# Debug POST Request SID

## 📋 Ringkasan Perubahan

Telah menambahkan debug logging yang komprehensif untuk melacak masalah pengiriman SID yang tidak terkirim.

## 🔍 Lokasi Debug Log

### 1. **File: `/lib/src/views/accounts/registration_online/views/sid_registration.dart`**
   - **Line: ~918** - Sebelum submit request
   - Log yang ditampilkan:
     - `Selected Option` (0=punya SID, 1=tidak punya)
     - `Keterangan` (1 atau 2)
     - `SID Value` (SID yang akan dikirim)
     - Full SID tanpa formatting
     - Detail tiap komponen: Type, Status, Date, Trading ID, Check Digit

### 2. **File: `/lib/src/views/accounts/registration_online/repository/regol_repository.dart`**
   - **Line: ~197** - Di fungsi `step6ASID()`
   - Log sebelum request:
     - `Endpoint` yang dituju
     - `Request Data` lengkap
     - Nilai SID (null atau tidak)
     - Keterangan
   - Log setelah response:
     - Full response dari server
     - Response status
     - Response message
     - Response code
     - Response data
   - Log error jika terjadi exception

### 3. **File: `/lib/src/service/auth_service.dart`**
   - **Line: ~103-155** - Di fungsi `post()`
   - Log request:
     - URL lengkap yang diakses
     - Headers yang dikirim
     - Body/payload
     - Access token (20 karakter pertama)
   - Log response:
     - HTTP Status Code
     - Response headers
     - Response body
     - Panjang response
   - Log parsed response:
     - Status
     - Message
     - Response data

## 📝 Cara Menggunakan Debug Log

### Buka Logcat/Console:
```
flutter logs
```

### Filter untuk SID:
```
flutter logs | grep -i "SID\|step6\|post request\|response"
```

### Debug Output Format:
```
========== DEBUG SEBELUM SUBMIT SID ==========
Selected Option: 0 (0=punya SID, 1=tidak punya)
Keterangan: 1
SID Value: ID - D - 1199 - AB1234 - 56
...
==========================================

═══════════════════════════════════════════
🚀 POST REQUEST
═══════════════════════════════════════════
URL: https://api.example.com/regol/pernyataanPengungkapan_1
Headers: {...}
Body: {aggree: Ya, keterangan: 1, sid: ID - D - 1199 - AB1234 - 56}
...
═══════════════════════════════════════════

📥 POST RESPONSE
Status Code: 200
Response Body: {...}
═══════════════════════════════════════════
```

## 🔧 Kemungkinan Masalah yang Bisa Diidentifikasi

1. **SID null** → Check apakah controller diisi dengan benar
2. **SID empty string** → Check validasi input form
3. **Format SID salah** → Check fungsi `_getFormattedSID()`
4. **Request tidak terkirim** → Periksa network/API endpoint
5. **Response 300** → Token perlu di-refresh
6. **Response error 500** → Server error
7. **Response body kosong** → Masalah connection/timeout

## 📌 Checklist Debugging

- [ ] Lihat log saat submit SID
- [ ] Verifikasi SID value tidak null/empty
- [ ] Cek format SID sesuai ketentuan
- [ ] Pastikan access token valid
- [ ] Periksa response status code dari server
- [ ] Lihat error message dari server
- [ ] Verifikasi endpoint URL benar
- [ ] Cek network connectivity

## 🚀 Tips

Tambahkan breakpoint di `step6ASID()` function untuk inspect data secara real-time dalam debugger Flutter.
