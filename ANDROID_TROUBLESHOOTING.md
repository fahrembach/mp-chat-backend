# Android Build Troubleshooting Guide

## Problem: "Build failed due to use of deleted Android v1 embedding"

This error occurs when your Flutter project is not properly configured for Android v2 embedding.

### Solution ✅
I've already fixed this by creating the proper Android project structure:

1. **MainActivity.kt** - Created with FlutterActivity v2 embedding
2. **AndroidManifest.xml** - Updated with proper v2 embedding metadata
3. **Gradle files** - Created proper build configuration
4. **Resource files** - Added necessary styles and drawables

## Additional Steps You May Need:

### 1. Install Flutter SDK
If Flutter is not installed:
```bash
# Download Flutter from https://flutter.dev/docs/get-started/install
# Add Flutter to your PATH
export PATH="$PATH:/path/to/flutter/bin"
```

### 2. Run Flutter Doctor
```bash
flutter doctor -v
```

### 3. Accept Android Licenses
```bash
flutter doctor --android-licenses
```

### 4. Set Android Environment Variables
Add to your system environment:
```bash
ANDROID_HOME=/path/to/Android/Sdk
ANDROID_SDK_ROOT=/path/to/Android/Sdk
PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
```

### 5. Clean and Rebuild
```bash
flutter clean
flutter pub get
flutter build apk --release
```

## Build Commands:

### Debug APK (faster build)
```bash
flutter build apk --debug
```

### Release APK (for distribution)
```bash
flutter build apk --release
```

### App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

## Output Locations:
- **Debug APK**: `build/app/outputs/flutter-apk/app-debug.apk`
- **Release APK**: `build/app/outputs/flutter-apk/app-release.apk`
- **App Bundle**: `build/app/outputs/bundle/release/app-release.aab`

## If Problems Persist:

1. Check that you have Android Studio installed
2. Verify Android SDK is installed via Android Studio SDK Manager
3. Make sure you have at least one Android platform installed (API 21 or higher)
4. Check that Android Build Tools are installed

## Quick Test:
Run the `test_build.bat` file I created to verify your setup before using the main build script.