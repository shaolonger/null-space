# Development Guide

## Getting Started

### Environment Setup

#### Install Rust

```bash
# Install rustup (Rust toolchain manager)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Add to PATH (Linux/macOS)
source $HOME/.cargo/env

# Verify installation
rustc --version
cargo --version
```

#### Install Flutter

```bash
# Download Flutter SDK
# Visit https://flutter.dev/docs/get-started/install

# Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Run Flutter doctor
flutter doctor
```

#### Platform-Specific Setup

**Windows:**
```bash
# Install Visual Studio 2019 or later with:
# - Desktop development with C++
# - Windows 10 SDK

# For Android
# Install Android Studio and Android SDK
```

**macOS:**
```bash
# Install Xcode from App Store
xcode-select --install

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# For iOS development
sudo gem install cocoapods
```

**Linux:**
```bash
# Install build essentials
sudo apt-get update
sudo apt-get install -y build-essential libssl-dev pkg-config

# For Android
# Install Android Studio from https://developer.android.com/studio
```

## Project Structure

```
null-space/
├── Cargo.toml              # Workspace configuration
├── .gitignore              # Git ignore patterns
├── README.md               # Project overview
│
├── core/                   # Rust backend
│   └── null-space-core/
│       ├── Cargo.toml      # Crate configuration
│       ├── src/
│       │   ├── lib.rs      # Library entry point
│       │   ├── crypto.rs   # Encryption module
│       │   ├── search.rs   # Search engine
│       │   ├── storage.rs  # File operations
│       │   ├── vault.rs    # Vault management
│       │   └── models.rs   # Data models
│       └── tests/          # Integration tests
│
├── ui/                     # Flutter frontend
│   └── null_space_app/
│       ├── pubspec.yaml    # Flutter dependencies
│       ├── lib/
│       │   ├── main.dart   # App entry point
│       │   ├── models/     # Dart models
│       │   ├── providers/  # State management
│       │   ├── screens/    # UI screens
│       │   ├── widgets/    # UI components
│       │   ├── services/   # Business logic
│       │   └── bridge/     # FFI bridge
│       └── test/           # Widget tests
│
└── docs/                   # Documentation
    ├── ARCHITECTURE.md     # Architecture overview
    ├── API.md              # API documentation
    └── DEVELOPMENT.md      # This file
```

## Development Workflow

### Building the Rust Core

```bash
cd core/null-space-core

# Debug build
cargo build

# Release build (optimized)
cargo build --release

# Build as dynamic library
cargo build --release --lib

# Check code without building
cargo check

# Format code
cargo fmt

# Lint code
cargo clippy
```

### Running Rust Tests

```bash
cd core/null-space-core

# Run all tests
cargo test

# Run specific test
cargo test test_encrypt_decrypt

# Run with output
cargo test -- --nocapture

# Run with coverage (requires cargo-tarpaulin)
cargo install cargo-tarpaulin
cargo tarpaulin --out Html
```

### Building the Flutter App

```bash
cd ui/null_space_app

# Get dependencies
flutter pub get

# Run on connected device
flutter run

# Run on specific device
flutter devices                    # List devices
flutter run -d macos              # Run on macOS
flutter run -d chrome             # Run on Chrome

# Build for release
flutter build apk --release       # Android APK
flutter build appbundle           # Android App Bundle
flutter build ios --release       # iOS
flutter build macos               # macOS
flutter build windows             # Windows
```

### Running Flutter Tests

```bash
cd ui/null_space_app

# Run all tests
flutter test

# Run specific test file
flutter test test/note_provider_test.dart

# Run with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Coding Standards

### Rust

Follow the official [Rust Style Guide](https://doc.rust-lang.org/nightly/style-guide/):

- Use `snake_case` for functions and variables
- Use `PascalCase` for types and traits
- Use `SCREAMING_SNAKE_CASE` for constants
- Maximum line length: 100 characters
- Use `cargo fmt` before committing

**Example:**

```rust
// Good
pub fn create_new_note(title: String, content: String) -> Note {
    Note::new(title, content, vec![])
}

// Bad
pub fn CreateNewNote(Title: String, Content: String) -> Note {
    Note::new(Title, Content, vec![])
}
```

### Flutter/Dart

Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines:

- Use `lowerCamelCase` for variables, functions, parameters
- Use `UpperCamelCase` for classes, enums, typedefs
- Use `lowercase_with_underscores` for libraries and file names
- Maximum line length: 80 characters
- Use `flutter analyze` before committing

**Example:**

```dart
// Good
class NoteProvider extends ChangeNotifier {
  void addNote(Note note) {
    _notes.add(note);
    notifyListeners();
  }
}

// Bad
class note_provider extends ChangeNotifier {
  void AddNote(Note note) {
    _notes.add(note);
    notifyListeners();
  }
}
```

## Debugging

### Rust Debugging

```bash
# Enable debug logging
export RUST_LOG=debug

# Run with backtrace on panic
export RUST_BACKTRACE=1

# Use rust-gdb or rust-lldb
rust-gdb target/debug/null-space-core
```

### Flutter Debugging

```bash
# Run in debug mode (default)
flutter run

# Use DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Debug in VS Code
# Use launch.json configuration
```

## FFI Integration

### Exporting Functions from Rust

```rust
use std::ffi::{CStr, CString};
use std::os::raw::c_char;

#[no_mangle]
pub extern "C" fn encrypt_note(data: *const c_char, key: *const c_char) -> *mut c_char {
    // Convert C strings to Rust strings
    let data_str = unsafe { CStr::from_ptr(data).to_str().unwrap() };
    let key_str = unsafe { CStr::from_ptr(key).to_str().unwrap() };
    
    // Perform encryption
    let encrypted = encrypt_internal(data_str, key_str);
    
    // Convert result back to C string
    CString::new(encrypted).unwrap().into_raw()
}
```

### Calling from Flutter

```dart
import 'dart:ffi';
import 'package:ffi/ffi.dart';

typedef EncryptNoteNative = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>);
typedef EncryptNoteDart = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>);

final dylib = DynamicLibrary.open('libnull_space_core.so');
final encryptNote = dylib.lookupFunction<EncryptNoteNative, EncryptNoteDart>('encrypt_note');

String encrypt(String data, String key) {
  final dataPtr = data.toNativeUtf8();
  final keyPtr = key.toNativeUtf8();
  
  final resultPtr = encryptNote(dataPtr, keyPtr);
  final result = resultPtr.toDartString();
  
  malloc.free(dataPtr);
  malloc.free(keyPtr);
  malloc.free(resultPtr);
  
  return result;
}
```

## Performance Profiling

### Rust Profiling

```bash
# Install flamegraph
cargo install flamegraph

# Profile with flamegraph
cargo flamegraph --bin null-space-core

# Profile with perf (Linux)
perf record --call-graph=dwarf cargo run --release
perf report
```

### Flutter Profiling

```bash
# Run with performance overlay
flutter run --profile

# Capture timeline trace
flutter run --profile --trace-startup

# Use DevTools Performance view
flutter pub global activate devtools
flutter pub global run devtools
```

## Continuous Integration

### GitHub Actions Example

```yaml
name: CI

on: [push, pull_request]

jobs:
  rust:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions-rs/toolchain@v1
        with:
          toolchain: stable
      - run: cargo test --all-features
      - run: cargo clippy -- -D warnings

  flutter:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.0.0'
      - run: flutter pub get
      - run: flutter test
      - run: flutter analyze
```

## Release Process

### Version Numbering

We use [Semantic Versioning](https://semver.org/): MAJOR.MINOR.PATCH

- MAJOR: Breaking changes
- MINOR: New features (backward compatible)
- PATCH: Bug fixes

### Creating a Release

```bash
# 1. Update version numbers
# - Cargo.toml
# - pubspec.yaml

# 2. Update CHANGELOG.md

# 3. Run all tests
cargo test
flutter test

# 4. Build release binaries
cargo build --release
flutter build apk --release
flutter build ios --release
flutter build macos
flutter build windows

# 5. Tag release
git tag -a v0.1.0 -m "Release v0.1.0"
git push origin v0.1.0

# 6. Create GitHub release with binaries
```

## Troubleshooting

### Common Issues

**Rust: `linker 'cc' not found`**
```bash
# Ubuntu/Debian
sudo apt-get install build-essential

# macOS
xcode-select --install
```

**Flutter: `CocoaPods not found`**
```bash
sudo gem install cocoapods
pod setup
```

**FFI: `Library not found`**
- Ensure the Rust library is built for the correct architecture
- Check that the library is in the correct location for the platform
- Verify the library name matches in Dart code

## Resources

- [Rust Book](https://doc.rust-lang.org/book/)
- [Flutter Documentation](https://flutter.dev/docs)
- [Tantivy Guide](https://docs.rs/tantivy/)
- [AES-GCM Specification](https://csrc.nist.gov/publications/detail/sp/800-38d/final)
- [Argon2 RFC](https://www.rfc-editor.org/rfc/rfc9106.html)
