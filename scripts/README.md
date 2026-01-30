# Build Scripts for Native Libraries

This directory contains platform-specific build scripts for compiling the Rust core library into native libraries that can be used by the Flutter application.

## Overview

The Null Space application consists of:
- **Rust Core**: Handles encryption, search, and file I/O
- **Flutter UI**: Cross-platform user interface

These scripts compile the Rust core into native libraries for each target platform.

## Available Scripts

### 1. `build_all.sh` - Master Build Script
Builds for one or more platforms with a single command.

**Usage:**
```bash
./scripts/build_all.sh [OPTIONS]

Options:
  -a, --android     Build for Android
  -i, --ios         Build for iOS
  -m, --macos       Build for macOS
  -w, --windows     Build for Windows
  --all             Build for all platforms
  -h, --help        Display help
```

**Examples:**
```bash
# Build for Android only
./scripts/build_all.sh --android

# Build for Android and iOS
./scripts/build_all.sh --android --ios

# Build for all platforms
./scripts/build_all.sh --all
```

### 2. `build_android.sh` - Android Build Script
Builds the Rust core for Android devices and emulators.

**Targets:**
- `arm64-v8a`: 64-bit ARM (most modern devices)
- `armeabi-v7a`: 32-bit ARM (older devices)
- `x86_64`: 64-bit x86 (emulators)

**Output:** `ui/null_space_app/android/app/src/main/jniLibs/`

**Requirements:**
- Android NDK (or cargo-ndk)
- ANDROID_NDK_HOME or NDK_HOME environment variable (optional with cargo-ndk)

**Usage:**
```bash
./scripts/build_android.sh
```

### 3. `build_ios.sh` - iOS Build Script
Builds the Rust core as an XCFramework for iOS devices and simulators.

**Targets:**
- iOS devices (arm64)
- iOS Simulator (arm64 + x86_64)

**Output:** `ui/null_space_app/ios/NullSpaceCore.xcframework`

**Requirements:**
- macOS 10.14+ with Xcode 14+
- iOS deployment target: 12.0+

**Usage:**
```bash
./scripts/build_ios.sh
```

### 4. `build_macos.sh` - macOS Build Script
Builds the Rust core as a universal dynamic library for macOS.

**Targets:**
- Apple Silicon (arm64)
- Intel (x86_64)

**Output:** `ui/null_space_app/macos/Frameworks/libnull_space_core.dylib`

**Requirements:**
- macOS 10.14+

**Usage:**
```bash
./scripts/build_macos.sh
```

### 5. `build_windows.ps1` - Windows Build Script
Builds the Rust core as a DLL for Windows.

**Target:**
- x64 (64-bit)

**Output:** `ui/null_space_app/windows/bin/x64/null_space_core.dll`

**Requirements:**
- Windows 10+
- Visual Studio 2019+ with C++ Build Tools
- MSVC toolchain

**Usage:**
```powershell
.\scripts\build_windows.ps1
```

## Prerequisites

### Common Requirements
- **Rust**: 1.70+ (install via [rustup](https://rustup.rs/))
  ```bash
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  ```

### Android
- **Android NDK** (recommended: r25 or later)
  - Option 1: Install via Android Studio SDK Manager
  - Option 2: Install cargo-ndk: `cargo install cargo-ndk`
- Set environment variable: `export ANDROID_NDK_HOME=/path/to/ndk`

### iOS/macOS
- **Xcode**: 14+ (install from Mac App Store)
- **Command Line Tools**: `xcode-select --install`

### Windows
- **Visual Studio**: 2019+ with "Desktop development with C++"
- **Windows 10 SDK**

## Build Process

### First Time Setup
1. Install Rust:
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```

2. Add required targets (automatic when running scripts):
   ```bash
   # Android
   rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android
   
   # iOS
   rustup target add aarch64-apple-ios aarch64-apple-ios-sim x86_64-apple-ios
   
   # macOS
   rustup target add aarch64-apple-darwin x86_64-apple-darwin
   
   # Windows
   rustup target add x86_64-pc-windows-msvc
   ```

### Building Libraries
```bash
# Option 1: Build all platforms at once
cd /path/to/null-space
./scripts/build_all.sh --all

# Option 2: Build specific platform
./scripts/build_android.sh
./scripts/build_ios.sh
./scripts/build_macos.sh
# On Windows:
.\scripts\build_windows.ps1
```

### Continuous Integration
For CI/CD pipelines, use the master script:
```yaml
# GitHub Actions example
- name: Build native libraries
  run: |
    chmod +x scripts/build_all.sh
    ./scripts/build_all.sh --android --ios
```

## Output Locations

After building, native libraries are placed in the Flutter project:

```
ui/null_space_app/
├── android/
│   └── app/src/main/jniLibs/
│       ├── arm64-v8a/libnull_space_core.so
│       ├── armeabi-v7a/libnull_space_core.so
│       └── x86_64/libnull_space_core.so
├── ios/
│   └── NullSpaceCore.xcframework/
├── macos/
│   └── Frameworks/libnull_space_core.dylib
└── windows/
    └── bin/x64/null_space_core.dll
```

## Troubleshooting

### Android: NDK not found
```bash
# Install cargo-ndk as an alternative
cargo install cargo-ndk

# Or set NDK path
export ANDROID_NDK_HOME=/path/to/android-sdk/ndk/25.2.9519653
```

### iOS/macOS: Command not found (lipo, xcodebuild)
```bash
# Install Xcode Command Line Tools
xcode-select --install

# Verify installation
xcodebuild -version
```

### Windows: Build fails with linker errors
- Ensure Visual Studio 2019+ with C++ tools is installed
- Run script from "x64 Native Tools Command Prompt for VS"
- Or use Developer PowerShell for VS

### Cross-compilation issues
- iOS and macOS builds **must** be performed on macOS
- Windows builds **must** be performed on Windows
- Android and Linux can be built from any platform (with NDK)

## Development Workflow

1. Make changes to Rust core in `core/null-space-core/`
2. Run the appropriate build script
3. Test changes in Flutter app:
   ```bash
   cd ui/null_space_app
   flutter run
   ```

## Performance Notes

- **Build Time**: First build takes longer (downloads dependencies)
- **Incremental Builds**: Subsequent builds are faster (cached artifacts)
- **Parallel Builds**: Can build different platforms simultaneously on different machines

## Security

- All libraries are built from source (no pre-compiled binaries)
- Code signing (macOS/iOS) happens during Flutter build phase
- Windows DLL should be signed before distribution

## Additional Resources

- [Rust FFI Guide](https://doc.rust-lang.org/nomicon/ffi.html)
- [Flutter Platform Channels](https://flutter.dev/docs/development/platform-integration/platform-channels)
- [Android NDK Documentation](https://developer.android.com/ndk/guides)
- [Xcode Build Settings](https://developer.apple.com/documentation/xcode)

## Support

For issues with the build scripts:
1. Check the [Troubleshooting](#troubleshooting) section
2. Verify all prerequisites are installed
3. Open an issue on GitHub with:
   - Platform (OS version)
   - Rust version (`rustc --version`)
   - Error message/logs
