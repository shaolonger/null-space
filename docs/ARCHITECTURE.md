# Architecture Overview

## Design Principles

1. **Security First**: All data is encrypted at rest using AES-256-GCM
2. **Offline-Only**: No network dependencies, no cloud services
3. **Cross-Platform**: Single codebase for all platforms via Rust + Flutter
4. **Performance**: Native performance through Rust core, 60fps UI through Flutter
5. **Privacy**: No telemetry, no analytics, no tracking

## Component Architecture

### Rust Core (`null-space-core`)

The core library provides all security-critical and performance-critical operations:

#### Modules

**`crypto.rs`**
- Implements AES-256-GCM encryption/decryption
- Uses Argon2 for password-based key derivation
- Generates cryptographically secure random salts and nonces
- Zeroizes sensitive data on drop

**`search.rs`**
- Integrates Tantivy for full-text search
- Indexes note titles, content, and tags
- Supports complex queries with ranking
- Maintains separate index per vault

**`storage.rs`**
- Abstracts filesystem operations
- Provides safe path handling
- Supports recursive directory operations
- Platform-agnostic file I/O

**`vault.rs`**
- Manages vault export to ZIP archives
- Handles vault import with decryption
- Implements conflict detection by UUID
- Supports three resolution strategies

**`models.rs`**
- Defines core data structures: Note, Vault, Tag
- Implements serialization with serde
- UUID-based unique identifiers
- Timestamp-based versioning

### Flutter UI (`null_space_app`)

The Flutter app provides a native UI for each platform:

#### Structure

**`models/`**
- Dart models mirroring Rust structures
- JSON serialization for FFI communication

**`providers/`**
- State management using Provider pattern
- `VaultProvider`: Current vault, vault list
- `NoteProvider`: Notes list, selected note, search

**`screens/`**
- Main screens: Home, Notes, Search, Vault
- Navigation with bottom navigation bar

**`widgets/`**
- Reusable UI components
- Custom markdown editor
- Tag selector with autocomplete

**`bridge/`**
- FFI bridge to Rust core
- Native library loading
- Type conversions between Dart and Rust

**`services/`**
- Business logic layer
- Coordinates between providers and bridge

## Data Flow

### Creating a Note

```
User Input (Flutter)
  → NoteProvider.addNote()
  → RustBridge.encrypt()
  → Rust: EncryptionManager.encrypt()
  → Rust: FileStorage.write_file()
  → Encrypted file on disk
  → Rust: SearchEngine.index_note()
  → Update Tantivy index
  → Return to Flutter
  → Update UI
```

### Searching Notes

```
User Query (Flutter)
  → NoteProvider.setSearchQuery()
  → RustBridge.search()
  → Rust: SearchEngine.search()
  → Tantivy query execution
  → Return ranked note IDs
  → Flutter loads note details
  → Display results in UI
```

### Exporting a Vault

```
User Action (Flutter)
  → VaultProvider.exportVault()
  → RustBridge.export_vault()
  → Rust: VaultManager.export_vault()
  → Collect all notes from FileStorage
  → Encrypt each note
  → Create ZIP archive with:
    - metadata.json
    - notes/*.json (encrypted)
  → Write to user-selected path
  → Return success to Flutter
```

## Security Architecture

### Threat Model

**In Scope**:
- Unauthorized access to device storage
- Data theft via physical access
- Memory dumping attacks (mitigated by zeroization)

**Out of Scope**:
- Network attacks (no network access)
- Supply chain attacks (use verified dependencies)
- Device compromise with root/admin access

### Key Management

1. User enters password for vault
2. Password + Salt → Argon2 → 32-byte key
3. Key used for AES-256-GCM encryption
4. Key stored in memory only (not on disk)
5. Key zeroized when app closes or vault is locked

### Encryption Scheme

```
Plaintext Note
  → JSON serialize
  → AES-256-GCM encrypt (with random nonce)
  → [12-byte nonce || ciphertext || 16-byte tag]
  → Write to disk
```

Decryption is the reverse process. The nonce is prepended to the ciphertext, and the authentication tag ensures integrity.

## Platform Integration

### Desktop (Windows/macOS/Linux)

- Native window management via Flutter
- File system access for vault storage
- System file picker for import/export
- Platform-specific keyboard shortcuts

### Mobile (Android/iOS)

- Native navigation patterns
- Biometric authentication (future)
- Share extensions for vault export
- Document provider for import

### FFI Bridge

The Flutter app communicates with Rust via FFI:

1. Dart defines function signatures matching Rust
2. Flutter loads platform-specific dynamic library
3. Function calls pass through FFI boundary
4. Data serialized as JSON strings
5. Results returned and deserialized

## Performance Considerations

### Rust Core

- Zero-copy where possible
- Minimal allocations in hot paths
- Streaming for large file operations
- Parallel search with Tantivy

### Flutter UI

- ListView builder for large note lists
- Lazy loading of note content
- Debounced search queries
- Cached tag hierarchies

## Testing Strategy

### Unit Tests

- Rust: Each module has comprehensive tests
- Flutter: Provider logic, model serialization

### Integration Tests

- End-to-end vault import/export
- Search accuracy and performance
- Conflict resolution scenarios

### Platform Tests

- Run on each target platform
- Verify FFI bridge on all platforms
- UI consistency checks

## Future Enhancements

1. **Attachments**: Support for images, PDFs in notes
2. **Sync**: Optional peer-to-peer sync without cloud
3. **Collaboration**: Shared vaults with multi-user encryption
4. **Version History**: Track note changes over time
5. **Plugins**: Extension API for custom functionality
