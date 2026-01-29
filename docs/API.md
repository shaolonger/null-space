# API Documentation

## Rust Core API

### Crypto Module

#### `EncryptionManager`

Manages encryption and decryption of data using AES-256-GCM.

```rust
pub struct EncryptionManager {
    cipher: Aes256Gcm,
}

impl EncryptionManager {
    /// Create a new encryption manager with a derived key from password
    pub fn new_from_password(password: &str, salt: &str) -> Result<Self, EncryptionError>;
    
    /// Generate a new random salt for key derivation
    pub fn generate_salt() -> String;
    
    /// Encrypt data
    pub fn encrypt(&self, plaintext: &[u8]) -> Result<Vec<u8>, EncryptionError>;
    
    /// Decrypt data
    pub fn decrypt(&self, encrypted_data: &[u8]) -> Result<Vec<u8>, EncryptionError>;
}
```

**Example:**

```rust
use null_space_core::crypto::EncryptionManager;

let password = "my_secure_password";
let salt = EncryptionManager::generate_salt();
let manager = EncryptionManager::new_from_password(password, &salt)?;

let plaintext = b"Secret note content";
let encrypted = manager.encrypt(plaintext)?;
let decrypted = manager.decrypt(&encrypted)?;

assert_eq!(plaintext, decrypted.as_slice());
```

### Search Module

#### `SearchEngine`

Full-text search engine powered by Tantivy.

```rust
pub struct SearchEngine {
    index: Index,
    schema: Schema,
}

impl SearchEngine {
    /// Create a new search engine with an index at the given path
    pub fn new(index_path: PathBuf) -> Result<Self, SearchError>;
    
    /// Get an index writer
    pub fn get_writer(&self) -> Result<IndexWriter, SearchError>;
    
    /// Index a note
    pub fn index_note(
        &self,
        writer: &mut IndexWriter,
        id: &str,
        title: &str,
        content: &str,
        tags: &[String],
        created_at: i64,
        updated_at: i64,
    ) -> Result<(), SearchError>;
    
    /// Commit changes to the index
    pub fn commit(&self, writer: &mut IndexWriter) -> Result<(), SearchError>;
    
    /// Search for notes
    pub fn search(&self, query_str: &str, limit: usize) -> Result<Vec<(f32, String)>, SearchError>;
}
```

**Example:**

```rust
use null_space_core::search::SearchEngine;

let engine = SearchEngine::new("./index".into())?;
let mut writer = engine.get_writer()?;

engine.index_note(
    &mut writer,
    "note-123",
    "My Note",
    "This is the content",
    &["work".to_string()],
    1640000000,
    1640000000,
)?;

engine.commit(&mut writer)?;

let results = engine.search("content", 10)?;
// Returns: [(score, "note-123")]
```

### Storage Module

#### `FileStorage`

File system operations for notes and vaults.

```rust
pub struct FileStorage {
    base_path: PathBuf,
}

impl FileStorage {
    /// Create a new file storage at the given base path
    pub fn new(base_path: PathBuf) -> Result<Self, StorageError>;
    
    /// Write data to a file
    pub fn write_file(&self, relative_path: &str, data: &[u8]) -> Result<(), StorageError>;
    
    /// Read data from a file
    pub fn read_file(&self, relative_path: &str) -> Result<Vec<u8>, StorageError>;
    
    /// Delete a file
    pub fn delete_file(&self, relative_path: &str) -> Result<(), StorageError>;
    
    /// Check if a file exists
    pub fn exists(&self, relative_path: &str) -> bool;
    
    /// List all files in a directory recursively
    pub fn list_files(&self, relative_path: &str) -> Result<Vec<String>, StorageError>;
    
    /// Create a directory
    pub fn create_dir(&self, relative_path: &str) -> Result<(), StorageError>;
}
```

### Vault Module

#### `VaultManager`

Import and export encrypted vaults.

```rust
pub struct VaultManager {
    storage: FileStorage,
}

impl VaultManager {
    /// Create a new vault manager
    pub fn new(storage: FileStorage) -> Self;
    
    /// Export a vault to a zip file
    pub fn export_vault(
        &self,
        vault: &Vault,
        notes: &[Note],
        output_path: &Path,
        encryption: Option<&EncryptionManager>,
    ) -> Result<(), VaultError>;
    
    /// Import a vault from a zip file
    pub fn import_vault(
        &self,
        input_path: &Path,
        encryption: Option<&EncryptionManager>,
        conflict_resolution: ConflictResolution,
    ) -> Result<(Vault, Vec<Note>), VaultError>;
    
    /// Detect conflicts when importing notes
    pub fn detect_conflicts(
        &self,
        existing_notes: &[Note],
        imported_notes: &[Note],
    ) -> Vec<(Note, Note)>;
    
    /// Resolve a conflict based on the resolution strategy
    pub fn resolve_conflict(
        &self,
        existing: Note,
        imported: Note,
        resolution: ConflictResolution,
    ) -> Vec<Note>;
}
```

**Example:**

```rust
use null_space_core::vault::VaultManager;
use null_space_core::models::{Vault, Note, ConflictResolution};

let storage = FileStorage::new("./data".into())?;
let manager = VaultManager::new(storage);

// Export
let vault = Vault::new("My Vault".into(), "Description".into(), "salt".into());
let notes = vec![/* ... */];
manager.export_vault(&vault, &notes, "export.zip".as_ref(), None)?;

// Import
let (imported_vault, imported_notes) = manager.import_vault(
    "export.zip".as_ref(),
    None,
    ConflictResolution::KeepBoth,
)?;
```

### Models Module

#### `Note`

Represents a note in the system.

```rust
pub struct Note {
    pub id: Uuid,
    pub title: String,
    pub content: String,
    pub tags: Vec<String>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    pub version: u64,
}

impl Note {
    pub fn new(title: String, content: String, tags: Vec<String>) -> Self;
    pub fn update(&mut self, title: String, content: String, tags: Vec<String>);
}
```

#### `Vault`

Represents a vault containing notes.

```rust
pub struct Vault {
    pub id: Uuid,
    pub name: String,
    pub description: String,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    pub salt: String,
}

impl Vault {
    pub fn new(name: String, description: String, salt: String) -> Self;
}
```

#### `Tag`

Represents a hierarchical tag.

```rust
pub struct Tag {
    pub path: String,
    pub name: String,
    pub parent: Option<String>,
}

impl Tag {
    pub fn from_path(path: &str) -> Self;
    pub fn ancestors(&self) -> Vec<String>;
}
```

## Flutter API

### Providers

#### `VaultProvider`

Manages vault state.

```dart
class VaultProvider extends ChangeNotifier {
  Vault? get currentVault;
  List<Vault> get vaults;
  
  void setCurrentVault(Vault vault);
  void addVault(Vault vault);
  void removeVault(String vaultId);
  void updateVault(Vault vault);
}
```

#### `NoteProvider`

Manages note state and search.

```dart
class NoteProvider extends ChangeNotifier {
  List<Note> get notes;
  Note? get selectedNote;
  String get searchQuery;
  
  void setNotes(List<Note> notes);
  void addNote(Note note);
  void updateNote(Note note);
  void deleteNote(String noteId);
  void selectNote(Note? note);
  void setSearchQuery(String query);
}
```

### FFI Bridge

#### `RustBridge`

Interface to Rust core functionality.

```dart
class RustBridge {
  RustBridge();
  
  String encrypt(String data, String key);
  String decrypt(String data, String key);
  List<String> search(String query, int limit);
}
```

**Note**: FFI implementation is in progress. This is the planned API.

## Error Handling

### Rust Errors

All Rust functions return `Result<T, E>` where E is one of:

- `EncryptionError`: Encryption/decryption failures
- `SearchError`: Search index errors
- `StorageError`: File I/O errors
- `VaultError`: Vault import/export errors

### Flutter Errors

Flutter uses try-catch with async/await:

```dart
try {
  final result = await rustBridge.encrypt(data, key);
} catch (e) {
  // Handle error
}
```

## Performance Notes

- **Search**: O(log n) for indexed queries
- **Encryption**: ~1 MB/s on typical hardware
- **Export**: Dependent on note count and size
- **Import**: Same as export + conflict detection O(n²) worst case
