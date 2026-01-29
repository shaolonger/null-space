# Null Space

A secure, local-first note-taking application with end-to-end encryption, full-text search, and offline-only operation.

## 🔐 Core Features

- **Offline-Only**: No cloud sync, no internet required. Your data stays on your device.
- **AES-256 Encryption**: Military-grade encryption for all notes and vaults.
- **Full-Text Search**: Powered by Tantivy for fast, efficient searching.
- **Markdown Support**: Rich text formatting with Markdown.
- **Nested Tags**: Hierarchical tag system (e.g., `work/project/urgent`).
- **Vault System**: Organize notes into encrypted vaults with manual import/export.
- **Conflict Detection**: UUID-based conflict resolution with manual merge options.
- **Cross-Platform**: Windows, macOS, Android, and iOS support.

## 📁 Architecture

This is a monorepo containing both the Rust core and Flutter UI:

```
null-space/
├── core/                      # Rust core library
│   └── null-space-core/      # Main crate
│       ├── src/
│       │   ├── lib.rs        # Library entry point
│       │   ├── crypto.rs     # AES-256-GCM encryption
│       │   ├── search.rs     # Tantivy search engine
│       │   ├── storage.rs    # File I/O operations
│       │   ├── vault.rs      # Vault import/export
│       │   └── models.rs     # Data models
│       └── tests/
├── ui/                        # Flutter application
│   └── null_space_app/
│       ├── lib/
│       │   ├── main.dart
│       │   ├── models/       # Dart data models
│       │   ├── providers/    # State management
│       │   ├── screens/      # UI screens
│       │   ├── widgets/      # Reusable widgets
│       │   ├── services/     # Business logic
│       │   └── bridge/       # FFI bridge to Rust
│       └── pubspec.yaml
└── docs/                      # Documentation

```

### Technology Stack

**Backend (Rust Core)**
- **Encryption**: `aes-gcm` (AES-256-GCM), `argon2` (key derivation)
- **Search**: `tantivy` (full-text search engine)
- **Serialization**: `serde` + `serde_json`
- **UUID**: `uuid` v4 for unique identifiers
- **File I/O**: `zip` for vault archives, `walkdir` for directory traversal

**Frontend (Flutter)**
- **UI Framework**: Flutter 3.x with Material Design 3
- **State Management**: Provider pattern
- **Markdown Rendering**: `flutter_markdown`
- **FFI Bridge**: `dart:ffi` for Rust interop
- **Local Storage**: `sqflite` for metadata, filesystem for encrypted files

## 🏗️ Building from Source

### Prerequisites

- **Rust**: 1.70+ (`rustup` recommended)
- **Flutter**: 3.0+ 
- **Platform SDKs**: 
  - Windows: Visual Studio 2019+ with C++ tools
  - macOS: Xcode 14+
  - Android: Android Studio with NDK
  - iOS: Xcode 14+

### Build Rust Core

```bash
cd core/null-space-core
cargo build --release

# Run tests
cargo test

# Build as dynamic library for Flutter
cargo build --release --lib
```

The compiled library will be in `target/release/`:
- Linux: `libnull_space_core.so`
- macOS: `libnull_space_core.dylib`
- Windows: `null_space_core.dll`

### Build Flutter App

```bash
cd ui/null_space_app

# Get dependencies
flutter pub get

# Run on desktop (macOS/Windows/Linux)
flutter run -d macos    # or windows, linux

# Run on mobile
flutter run -d android  # or ios

# Build release
flutter build apk       # Android
flutter build ipa       # iOS
flutter build macos     # macOS
flutter build windows   # Windows
```

## 🔒 Security Model

### Encryption

1. **Key Derivation**: User passwords are hashed using Argon2 with a unique salt per vault.
2. **Encryption**: Notes are encrypted with AES-256-GCM using the derived key.
3. **Nonce**: Each encryption uses a unique random nonce (included in ciphertext).
4. **Storage**: Only encrypted data is written to disk.

### Vault Structure

Vaults are exported as ZIP files with the following structure:

```
vault.zip
├── metadata.json       # Vault info, note count, export date
└── notes/
    ├── <uuid1>.json   # Encrypted note
    ├── <uuid2>.json   # Encrypted note
    └── ...
```

### Conflict Resolution

When importing a vault, conflicts are detected by comparing:
- UUID (same note)
- Version number
- Last update timestamp

Three resolution strategies:
1. **Overwrite**: Replace existing note with imported one
2. **Keep Both**: Create a copy with new UUID
3. **Skip**: Keep existing note, discard imported one

## 📝 Usage Guide

### Creating a Vault

1. Launch the app
2. Navigate to "Vault" tab
3. Tap "Create New Vault"
4. Enter vault name and password
5. Your vault is created and encrypted locally

### Creating Notes

1. Open a vault
2. Tap the "+" button
3. Write your note in Markdown
4. Add tags using the format: `work/project/urgent`
5. Notes are automatically encrypted and saved

### Searching Notes

1. Navigate to "Search" tab
2. Enter search terms
3. Results are ranked by relevance using Tantivy
4. Tap a result to open the note

### Importing/Exporting Vaults

**Export:**
1. Open vault settings
2. Tap "Export Vault"
3. Choose location to save `.zip` file
4. Share the file manually (USB, email, etc.)

**Import:**
1. Navigate to "Vault" tab
2. Tap "Import Vault"
3. Select the `.zip` file
4. Enter the vault password
5. Choose conflict resolution strategy
6. Vault is imported and decrypted

## 🏷️ Tag System

Tags use a hierarchical structure with `/` as separator:

```
work/
  ├── project-a/
  │   ├── urgent
  │   └── review
  └── project-b/
personal/
  ├── finance
  └── health
```

Benefits:
- Organize notes by multiple dimensions
- Filter by parent tags (e.g., all "work" notes)
- Auto-complete suggests tag hierarchies

## 🔧 Development

### Project Structure

- `core/null-space-core`: Self-contained Rust library with all crypto, search, and I/O logic
- `ui/null_space_app`: Flutter UI that communicates with Rust via FFI
- `docs/`: Architecture decisions, API docs, user guides

### Running Tests

```bash
# Rust tests
cd core/null-space-core
cargo test

# Flutter tests
cd ui/null_space_app
flutter test
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes with tests
4. Run `cargo fmt` and `cargo clippy` for Rust
5. Run `flutter analyze` for Flutter
6. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details

## 🛣️ Roadmap

- [x] Core Rust library with encryption and search
- [x] Basic Flutter UI scaffold
- [ ] FFI bridge implementation
- [ ] Complete note CRUD operations
- [ ] Vault import/export functionality
- [ ] Tag filtering and search
- [ ] Markdown editor with preview
- [ ] Settings and preferences
- [ ] Multi-language support
- [ ] Backup and restore functionality

## 🤝 Acknowledgments

- **Tantivy**: Fast full-text search library
- **AES-GCM**: Authenticated encryption standard
- **Flutter**: Cross-platform UI framework
- **Rust**: Systems programming language

---

**Note**: This is an offline-only application. No telemetry, no analytics, no cloud services. Your data never leaves your device unless you explicitly export and share a vault.