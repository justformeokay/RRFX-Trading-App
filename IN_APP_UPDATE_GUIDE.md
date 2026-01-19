# In-App Update Implementation Guide

## 📦 Overview
Aplikasi sekarang menggunakan **Google Play In-App Update API** untuk mendeteksi dan memaksa user melakukan update langsung dari Play Store, tanpa memerlukan backend API version checker.

---

## 🔧 Implementasi

### 1. **Package Added** ✅
```yaml
# pubspec.yaml
in_app_update: ^4.2.3
```

### 2. **New Service Created** ✅
- **File**: `lib/src/service/in_app_update_service.dart`
- **Singleton Pattern**: Satu instance service di seluruh aplikasi
- **Methods**:
  - `checkForUpdate()` - Check update dari Play Store
  - `hasAvailableUpdate()` - Cek apakah ada update

### 3. **Splashscreen Updated** ✅
- **File**: `lib/src/views/authentications/splashscreen.dart`
- Menghilangkan API backend version check (`getVersionApp()`)
- Langsung call `InAppUpdateService().checkForUpdate()` saat app launch
- Removed unused imports (FailedVersionPage, GlobalVariable, etc.)

---

## 🚀 Cara Kerja

### Update Flow:
```
App Launch
    ↓
Splash Screen Load
    ↓
checkForUpdate() from Play Store
    ↓
    ├─ Immediate Update Available → Show force update prompt
    │  └─ User HARUS update (tidak bisa skip)
    │
    ├─ Flexible Update Available → Show optional update message
    │  └─ User bisa continue pakai app
    │
    └─ No Update Available → Continue with normal flow
       └─ Load Profile/Auth Check
```

### Update Prioritas di Play Store:

**Immediate (Force) Update:**
- Play Store akan show native dialog
- User tidak bisa skip
- App restart after download

**Flexible (Optional) Update:**
- Show snackbar notification
- User bisa continue pakai app
- Update install in background
- App restart saat convenient time

---

## 📋 Play Store Configuration

### Set Update Priority via Play Console:
1. Go to **Google Play Console** → Your App
2. Go to **Release** → **Production/Testing**
3. Upload new APK/AAB
4. Set **In-app update priority**:
   - **1-2** = Low priority (flexible)
   - **3-4** = Medium priority (flexible)
   - **5** = Highest priority (immediate/force)

### Example Priority Levels:
| Priority | Type | Behavior |
|----------|------|----------|
| 1 | Flexible | Optional update, user can skip |
| 2 | Flexible | Optional update, user can skip |
| 3 | Flexible | Optional update, user can skip |
| 4 | Flexible or Immediate | Recommended update |
| 5 | Immediate | Force update, user CANNOT skip |

---

## 🔍 Debug Logs

Aplikasi akan print logs seperti ini di production:

```
🚀 [SPLASH] Starting app flow...
📱 [SPLASH] Checking for app updates...
🔍 [IN_APP_UPDATE] Checking for updates...
📱 [IN_APP_UPDATE] Flexible update allowed: false
📱 [IN_APP_UPDATE] Immediate update allowed: true
🚨 [IN_APP_UPDATE] Immediate update available
📥 [IN_APP_UPDATE] Starting immediate update...
✅ [SPLASH] Update check completed, proceeding with app flow...
```

---

## ✅ Features

### ✔ Supported:
- **Android**: Full support via Google Play
- **Automatic detection**: Check saat app launch di splash screen
- **Force update**: Immediate update jika priority 5
- **Optional update**: Flexible update untuk priority 1-4
- **Error handling**: Graceful fallback jika check gagal
- **Logging**: Detailed logs untuk debugging

### ⚠ Limitations:
- **iOS**: Hanya bisa redirect ke App Store (tidak ada in-app update API)
- **Sideload/Unofficial**: Hanya kerja dengan app dari Play Store
- **Network error**: Skip check dan lanjut dengan app flow

---

## 🛠 Backend Changes

❌ **Removed**:
- API endpoint: `POST /public/check-version`
- Version checking logic di backend
- FailedVersionPage (not needed anymore)
- GlobalVariable.playStoreUrl constant

✅ **New**:
- Direct Play Store integration
- No backend API calls needed
- Simpler architecture

---

## 📱 Testing

### Test di Development:
1. Update `pubspec.yaml` version: `1.1.0+6` → `1.1.1+7`
2. Upload APK ke Play Console (Internal Testing Track)
3. Install app dari Play Store
4. Update version lagi: `1.1.1+7` → `1.1.2+8`
5. Upload new APK dengan priority 5
6. Reinstall app dari testing link
7. Akan melihat force update dialog

### Test Immediate Update (Priority 5):
```
App Launch → Splash Screen → Force Update Dialog → User must update
```

### Test Flexible Update (Priority 1-4):
```
App Launch → Splash Screen → Snackbar "Update Available" → Continue using app
```

---

## 🔄 Migration dari API Backend

### Sebelumnya:
```dart
Map<String, dynamic> versionCheck = await authController.getVersionApp();
if (versionCheck['success'] != true) {
  // Show FailedVersionPage
}
```

### Sekarang:
```dart
await InAppUpdateService().checkForUpdate();
// Automatically handle by Play Store
```

---

## 📝 File Changed

1. **pubspec.yaml** - Added `in_app_update: ^4.2.3`
2. **lib/src/service/in_app_update_service.dart** - NEW service file
3. **lib/src/views/authentications/splashscreen.dart** - Updated to use new service
4. **lib/src/helpers/variables/global_variables.dart** - Added playStoreUrl constant

---

## ❓ FAQ

**Q: Bagaimana jika user tidak punya Play Store?**
- A: Update check akan skip secara otomatis, app tetap bisa digunakan

**Q: Apakah bisa force update tanpa priority 5?**
- A: Tidak, hanya priority 5 yang force update

**Q: Bagaimana monitor update usage?**
- A: Lihat di Play Console → User Acquisition → In-app updates

**Q: Apakah bisa set minimum version?**
- A: Tidak langsung, gunakan priority 5 untuk update penting

---

## 🚀 Release Checklist

- [ ] Bump version di `pubspec.yaml`
- [ ] Update `CHANGELOG.md`
- [ ] Build APK/AAB: `flutter build appbundle --release`
- [ ] Upload ke Play Console
- [ ] Set priority (1-5) sesuai importance
- [ ] Monitor user adoption in Play Console

---

## 📞 Support

Untuk issues atau questions, check:
- [Google Play In-App Update Documentation](https://developer.android.com/guide/playcore/in-app-updates)
- [Upgrader Package (Alternative)](https://pub.dev/packages/upgrader)
