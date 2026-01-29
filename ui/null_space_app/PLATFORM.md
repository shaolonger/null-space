# Platform Implementation

This directory contains the platform-specific code for running the Null Space app on different platforms.

## Platforms Supported

### Android
- **Minimum SDK**: 21 (Android 5.0)
- **Target SDK**: Latest available through Flutter
- **Location**: `android/`
- **Entry Point**: `MainActivity.kt`

### iOS
- **Minimum Version**: iOS 12.0
- **Location**: `ios/`
- **Entry Point**: `AppDelegate.swift`

### macOS
- **Minimum Version**: macOS 10.14
- **Location**: `macos/`
- **Entry Point**: `AppDelegate.swift`, `MainFlutterWindow.swift`

### Windows
- **Minimum Version**: Windows 7
- **Location**: `windows/`
- **Entry Point**: `main.cpp`, `flutter_window.cpp`

## Building for Each Platform

### Android
```bash
flutter build apk          # Debug APK
flutter build apk --release # Release APK
flutter build appbundle    # App Bundle for Play Store
```

### iOS
```bash
flutter build ios          # Debug build
flutter build ios --release # Release build
flutter build ipa          # IPA for App Store
```

### macOS
```bash
flutter build macos        # Debug build
flutter build macos --release # Release build
```

### Windows
```bash
flutter build windows      # Debug build
flutter build windows --release # Release build
```

## Platform-Specific Features

### Android
- Material Design 3 theming
- Adaptive icons support
- File access permissions for vault import/export
- Dark mode support

### iOS
- Cupertino design elements where appropriate
- App icon and launch images
- Dark mode support
- iPad support

### macOS
- Native macOS window chrome
- Menu bar integration
- Keyboard shortcuts support
- Dark mode support

### Windows
- Win32 native window
- High DPI support
- Dark/Light theme detection
- Modern Windows 10/11 styling

## Icon Assets

Icon assets need to be added to the following locations:

### Android
- `android/app/src/main/res/mipmap-*/ic_launcher.png`
  - hdpi: 72x72
  - mdpi: 48x48
  - xhdpi: 96x96
  - xxhdpi: 144x144
  - xxxhdpi: 192x192

### iOS
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-*.png`
  - Various sizes from 20x20 to 1024x1024

### macOS
- `macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_*.png`
  - Various sizes from 16x16 to 1024x1024

### Windows
- `windows/runner/resources/app_icon.ico`
  - Multi-resolution icon file

## First-Time Setup

After cloning the repository, run:

```bash
cd ui/null_space_app
flutter pub get
```

This will:
1. Download all Dart dependencies
2. Generate platform-specific plugin registrant code
3. Setup platform-specific build configurations

## Platform-Specific Configuration

### Android
The Android configuration is in:
- `android/app/build.gradle` - App-level build config
- `android/build.gradle` - Project-level build config
- `android/settings.gradle` - Plugin configuration
- `android/app/src/main/AndroidManifest.xml` - App manifest

### iOS/macOS
The iOS/macOS configuration uses:
- `Podfile` - CocoaPods dependency management
- `Info.plist` - App metadata and permissions
- `.xcworkspace` - Xcode workspace

### Windows
The Windows configuration uses:
- `CMakeLists.txt` - CMake build configuration
- `runner.exe.manifest` - App manifest for DPI awareness

## Notes

- All platforms use Flutter embedding v2
- Dark mode is supported on all platforms
- The app is configured for offline-only operation (no internet required)
- File access permissions are configured for vault import/export
