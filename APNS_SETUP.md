# APNS Setup Guide untuk iOS

## ✅ Sudah Dilakukan (Kode & Config):

1. **AppDelegate.swift** - Setup remote notifications dan permission request
2. **Runner.entitlements** - File capabilities APNS
3. **notification_service.dart** - Firebase Messaging dan local notifications setup
4. **Info.plist** - Sudah memiliki `UIBackgroundModes` dengan `remote-notification`

## 📋 Yang Harus Dilakukan di Xcode:

### Step 1: Tambahkan Entitlements ke Xcode Project

1. Buka `ios/Runner.xcworkspace` (bukan .xcodeproj) di Xcode
2. Pilih **Runner** target
3. Buka tab **Signing & Capabilities**
4. Klik **+ Capability**
5. Cari dan tambahkan **Push Notifications**

### Step 2: Pastikan Development Team Dipilih

1. Di Xcode, pastikan **Team ID** sudah dipilih untuk runner target
2. Bundle Identifier harus unik dan match dengan App Store Connect

## 📱 Yang Harus Dilakukan di App Store Connect:

### Step 1: Create/Update Certificates

1. Login ke [App Store Connect](https://appstoreconnect.apple.com)
2. Buka **Certificates, Identifiers & Profiles**
3. Pilih **Certificates**
4. Buat **Apple Push Services certificate** baru jika belum ada
   - Pilih Push Notification service
   - Sesuaikan dengan bundle identifier app

### Step 2: Upload Key atau Certificate ke Firebase

1. Login ke [Firebase Console](https://console.firebase.google.com)
2. Pilih project RRFX
3. Buka **Project Settings** (gear icon)
4. Tab **Cloud Messaging**
5. Scroll ke iOS app section
6. Upload **APNs Key** atau **APNs Certificate**
   - Recommended: Upload APNs Key (lebih simple, 1 key untuk all certs)
   - Alternative: Upload APNs Certificate

### Step 3: Configure Provisioning Profile

1. Kembali ke Certificates, Identifiers & Profiles
2. Pilih **Identifiers**
3. Cari bundle identifier app RRFX
4. Pastikan **Push Notifications** capability enabled
5. Generate/update Provisioning Profile baru

## 🔧 Konfigurasi Build Setting di Xcode:

1. Di Xcode project settings, pastikan **Signing Certificate** dan **Provisioning Profile** sudah correct
2. Build dan run app pada physical iOS device (bukan simulator)

## 📲 Testing pada Physical Device:

1. Run app: `flutter run -d <device-id>`
2. App akan request permission untuk push notifications - **Tap ALLOW**
3. Check console logs untuk melihat:
   - ✅ FCM Token tersimpan
   - ✅ APNS token registered
   - ✅ Notification permission granted

## ⚠️ Important Notes:

- **Simulator tidak support push notifications** - harus test di physical device
- **APNS token hanya tersedia di production/TestFlight** atau saat app belum production ready
- **APNs Certificate perlu di-renew setiap year** - set reminder!

## 🔗 Useful Links:

- [Firebase Cloud Messaging - iOS Setup](https://firebase.google.com/docs/cloud-messaging/ios/certs)
- [Apple APNs Provider Key Setup](https://developer.apple.com/account/resources/certificates/create)
- [Flutter Firebase Messaging Docs](https://firebase.flutter.dev/docs/messaging/overview)
