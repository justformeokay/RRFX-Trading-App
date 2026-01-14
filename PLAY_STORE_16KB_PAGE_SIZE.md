# Google Play Store - 16 KB Memory Page Size Support

## Problem
Error when submitting to Play Store:
```
Your app does not support 16 KB memory page sizes
```

## Solution Applied

### 1. Updated NDK Version
Changed NDK from `27.0.12077973` to `28.0.12433566` in [`android/app/build.gradle.kts`](android/app/build.gradle.kts)

**Why:** NDK 28+ has full support for 16KB page sizes, which is required by Google Play Store for API 34+ (Android 14 and above) apps.

```gradle
ndkVersion = "28.0.12433566"
```

### 2. Added Debug Symbol Level Configuration
Added explicit debug symbol configuration to ensure full support:

```gradle
defaultConfig {
    // ... other config
    ndk.debugSymbolLevel = "FULL"
}
```

### 3. Verified Target SDK
Already set to `targetSdk = 35` which is required for Play Store (API 34 minimum as of 2024).

### 4. ABI Architectures
Ensure all required ABIs are included:
```gradle
ndk {
    abiFilters += listOf("arm64-v8a", "armeabi-v7a", "x86_64")
}
```

- `arm64-v8a` - Primary (required for newer devices)
- `armeabi-v7a` - Legacy 32-bit support
- `x86_64` - Emulator/tablet support

### 5. Release Signing (if needed)
For release builds, ensure you have `android/key.properties` file with:
```properties
storeFile=../key.jks
storePassword=YOUR_PASSWORD
keyAlias=YOUR_KEY_ALIAS
keyPassword=YOUR_PASSWORD
```

## Building for Play Store

### Create App Bundle (Recommended)
```bash
flutter build appbundle --release
```

This generates: `build/app/outputs/bundle/release/app-release.aab`

### Create APK (Alternative)
```bash
flutter build apk --release
```

This generates: `build/app/outputs/apk/release/app-release.apk`

## Verification

To verify 16KB page size support in your build:

```bash
# Extract APK from AAB or use APK directly
unzip app-release.apk -d apk_extracted

# Check for arm64-v8a library
ls -la apk_extracted/lib/arm64-v8a/
```

The presence of native libraries indicates proper NDK integration with 16KB page size support.

## Testing Before Submission

1. Build the AAB file:
   ```bash
   flutter build appbundle --release
   ```

2. Test on Play Console (Internal Testing Track):
   - Go to your app on Google Play Console
   - Navigate to Testing → Internal testing
   - Upload the AAB file
   - Google Play will validate 16KB page size support

3. If validation passes, proceed to production release

## Common Issues

| Error | Solution |
|-------|----------|
| "16 KB memory page sizes not supported" | Update NDK to 28+ (already done) |
| Build fails with keystoreProperties | Ensure `key.properties` exists or app is in debug mode |
| "targetSdk too low" | Verify `targetSdk = 35` is set |
| "Missing ABI" | Check all required ABIs are in `abiFilters` |

## References
- [Android NDK 28 Release](https://developer.android.com/studio/releases/ndk)
- [Google Play Policy - 64-bit requirement](https://play.google.com/console/about/platforms/android/)
- [16KB Page Size Support](https://source.android.com/docs/core/runtime/memtag-ext)
