# 🚀 DEPLOYMENT GUIDE - Staging Web Mobile RRFX

## 📋 **RINGKASAN MASALAH**

**Error yang terjadi:**
```
ClientException: Load failed, uri=https://rrfx.mathlab.id/api/auth/login
```

**Penyebab:**
- Flutter Web mencoba langsung hit API dari browser
- Browser **MEMBLOKIR** request karena **CORS Policy** (Cross-Origin Resource Sharing)
- API server tidak mengizinkan request dari domain web yang berbeda

**Analogi:**
```
❌ BLOCKED:
   Browser (https://staging-webmobile-rrfx.techcrm.net)
      → langsung ke API (https://api-rrfx.techcrm.net)
      
✅ ALLOWED:
   Browser (https://staging-webmobile-rrfx.techcrm.net)
      → Nginx Reverse Proxy (same domain: /api/)
      → Nginx forward ke API (https://api-rrfx.techcrm.net)
```

---

## 🛠️ **SOLUSI: Reverse Proxy dengan Nginx**

### **Arsitektur Deployment:**

```
User Browser
    ↓
https://staging-webmobile-rrfx.techcrm.net/
    ↓ (Flutter Web App loaded)
    ↓
Request: https://staging-webmobile-rrfx.techcrm.net/api/auth/login
    ↓
Nginx Reverse Proxy (add CORS headers)
    ↓
Forward to: https://api-rrfx.techcrm.net/auth/login
    ↓
API Response ← with CORS headers
    ↓
Browser ✅ (allowed karena same-origin)
```

---

## 📦 **STEP-BY-STEP DEPLOYMENT**

### **1️⃣ Build Flutter Web (Production Mode)**

Jalankan script deploy:
```bash
./deploy-staging.sh
```

Atau manual:
```bash
# Clean previous build
flutter clean
rm -rf build/web

# Get dependencies
flutter pub get

# Build for web (production)
flutter build web --release --web-renderer canvaskit --base-href /
```

**Output:** Folder `build/web/` berisi file static (HTML, JS, WASM, dll)

---

### **2️⃣ Upload ke Server Staging**

**Opsi A: Via SCP (Terminal)**
```bash
scp -r build/web/* root@YOUR_SERVER_IP:/www/wwwroot/staging-webmobile-rrfx.techcrm.net/
```

**Opsi B: Via FileZilla/FTP**
1. Connect ke server
2. Navigate ke: `/www/wwwroot/staging-webmobile-rrfx.techcrm.net/`
3. Upload semua file dari `build/web/`

**Opsi C: Via aaPanel File Manager**
1. Login aaPanel
2. File Manager → `/www/wwwroot/staging-webmobile-rrfx.techcrm.net/`
3. Upload files

---

### **3️⃣ Configure Nginx dengan CORS Reverse Proxy**

File konfigurasi sudah ada di: `nginx-staging.conf`

**Cara Pasang di aaPanel:**

1. **Login aaPanel** → Website → `staging-webmobile-rrfx.techcrm.net` → Settings

2. **Klik "Nginx Config"** atau "Configuration file"

3. **COPY location blocks** dari `nginx-staging.conf` (baris 68-230):
   - `/api/` → Proxy ke API backend
   - `/market/` → Proxy ke trading API
   - `/ws-account/` → Proxy untuk WebSocket

4. **PASTE** ke dalam server {} block yang sudah ada, **SEBELUM** `location / { ... }`

5. **Save** dan **Restart Nginx**

**Atau via SSH:**
```bash
# Edit nginx config
nano /www/server/panel/vhost/nginx/staging-webmobile-rrfx.techcrm.net.conf

# Test configuration
nginx -t

# Reload nginx
systemctl reload nginx
```

---

### **4️⃣ Setup SSL Certificate (HTTPS)**

**Via aaPanel:**
1. Website → `staging-webmobile-rrfx.techcrm.net` → SSL
2. Pilih "Let's Encrypt"
3. Apply certificate
4. Enable "Force HTTPS"

**Via Certbot (SSH):**
```bash
certbot --nginx -d staging-webmobile-rrfx.techcrm.net
```

---

### **5️⃣ Test Deployment**

**A. Test Web App Loading:**
```
https://staging-webmobile-rrfx.techcrm.net/
```
- ✅ Harus load Flutter app dengan benar
- ✅ Tidak ada error CORS di console

**B. Test API Call:**
Open browser console (F12) → Network tab:
```
Request URL: https://staging-webmobile-rrfx.techcrm.net/api/auth/login
Status: 200 OK
Response: { status: true, ... }
```

**C. Check CORS Headers:**
```bash
curl -I https://staging-webmobile-rrfx.techcrm.net/api/auth/login
```
Harus ada header:
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, PATCH, OPTIONS
```

---

## 🔧 **TROUBLESHOOTING**

### **Problem 1: Masih muncul CORS error**

**Solusi:**
1. Pastikan nginx config sudah include location blocks untuk `/api/`
2. Restart nginx: `systemctl restart nginx`
3. Clear browser cache (Ctrl+Shift+R atau Cmd+Shift+R)
4. Check di browser console apakah request ke `/api/` atau langsung ke external URL

---

### **Problem 2: 404 Not Found setelah refresh page**

**Solusi:**
Add di nginx config (sudah ada di `nginx-staging.conf`):
```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```

---

### **Problem 3: File WASM tidak load (MIME type error)**

**Solusi:**
Add di nginx config:
```nginx
location ~* \.wasm$ {
    types { application/wasm wasm; }
    add_header Content-Type application/wasm;
}
```

---

### **Problem 4: Slow loading (large files)**

**Solusi:**
Enable GZIP compression (sudah ada di `nginx-staging.conf`):
- Uncompressed: ~7.8 MB
- Compressed: ~2.2 MB (70% reduction)

---

## 📊 **MONITORING & MAINTENANCE**

### **Check Nginx Logs:**
```bash
# Access log
tail -f /www/wwwlogs/staging-webmobile-rrfx.techcrm.net.log

# Error log
tail -f /www/wwwlogs/staging-webmobile-rrfx.techcrm.net.error.log
```

### **Check Nginx Status:**
```bash
systemctl status nginx
```

### **Reload after config change:**
```bash
# Test config first
nginx -t

# Reload if OK
systemctl reload nginx
```

---

## 🎯 **BEST PRACTICES**

1. **Always build with `--release` flag** untuk production
2. **Enable GZIP compression** untuk faster load time
3. **Use HTTPS** untuk security
4. **Cache static assets** dengan proper headers
5. **Monitor error logs** untuk detect issues
6. **Backup config** sebelum update

---

## 📝 **NOTES**

- **Current API Backend:** `https://api-rrfx.techcrm.net`
- **Current Trading API:** `https://mt5-api-v3.techcrm.online`
- **WebSocket Endpoint:** `wss://staging-webmobile-rrfx.techcrm.net/ws-account/`

Kalau ada perubahan URL backend, update di `nginx-staging.conf` location blocks.

---

## ✅ **CHECKLIST DEPLOYMENT**

- [ ] Build Flutter Web dengan `./deploy-staging.sh`
- [ ] Upload `build/web/` ke server
- [ ] Configure nginx dengan CORS reverse proxy
- [ ] Setup SSL certificate
- [ ] Test web app loading
- [ ] Test API calls (check browser console)
- [ ] Verify CORS headers
- [ ] Monitor error logs

---

**Setelah semua step selesai, aplikasi akan berjalan normal di:**
```
https://staging-webmobile-rrfx.techcrm.net/
```

**Tidak akan ada lagi CORS error!** ✅
