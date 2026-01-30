# Null Space Development Plan

## Project Overview

Null Space is a secure, local-first note-taking application with end-to-end encryption, full-text search, and offline-only operation. This document outlines the completed features, incomplete features, and detailed implementation tasks for AI-assisted development.

---

## Feature Status Summary

### ✅ Completed Features

| Category | Feature | Status | Location |
|----------|---------|--------|----------|
| **Rust Core** | AES-256-GCM Encryption Module | ✅ Complete | `core/null-space-core/src/crypto.rs` |
| **Rust Core** | Argon2 Key Derivation | ✅ Complete | `core/null-space-core/src/crypto.rs` |
| **Rust Core** | Tantivy Search Engine | ✅ Complete | `core/null-space-core/src/search.rs` |
| **Rust Core** | File Storage Operations | ✅ Complete | `core/null-space-core/src/storage.rs` |
| **Rust Core** | Vault Export/Import | ✅ Complete | `core/null-space-core/src/vault.rs` |
| **Rust Core** | Data Models (Note, Vault, Tag) | ✅ Complete | `core/null-space-core/src/models.rs` |
| **Rust Core** | UUID-based Conflict Detection | ✅ Complete | `core/null-space-core/src/vault.rs` |
| **Rust Core** | Unit Tests (12 tests) | ✅ Complete | Throughout `src/` |
| **Flutter UI** | Basic App Structure | ✅ Complete | `ui/null_space_app/lib/main.dart` |
| **Flutter UI** | Provider State Management | ✅ Complete | `ui/null_space_app/lib/providers/` |
| **Flutter UI** | Data Models (Dart) | ✅ Complete | `ui/null_space_app/lib/models/` |
| **Flutter UI** | Navigation Shell | ✅ Complete | `ui/null_space_app/lib/screens/home_screen.dart` |
| **Flutter UI** | Android Platform Setup | ✅ Complete | `ui/null_space_app/android/` |
| **Flutter UI** | iOS Platform Setup | ✅ Complete | `ui/null_space_app/ios/` |
| **Flutter UI** | macOS Platform Setup | ✅ Complete | `ui/null_space_app/macos/` |
| **Flutter UI** | Windows Platform Setup | ✅ Complete | `ui/null_space_app/windows/` |
| **Documentation** | README | ✅ Complete | `README.md` |
| **Documentation** | Architecture Overview | ✅ Complete | `docs/ARCHITECTURE.md` |
| **Documentation** | API Documentation | ✅ Complete | `docs/API.md` |
| **Documentation** | Development Guide | ✅ Complete | `docs/DEVELOPMENT.md` |

### ❌ Incomplete Features

| Category | Feature | Status | Priority |
|----------|---------|--------|----------|
| **FFI Bridge** | Rust-Flutter FFI Implementation | ❌ Not Started | High |
| **Flutter UI** | Complete Note CRUD Operations | ❌ Placeholder Only | High |
| **Flutter UI** | Vault Import/Export UI | ❌ Placeholder Only | High |
| **Flutter UI** | Tag Filtering and Search | ❌ Not Started | Medium |
| **Flutter UI** | Markdown Editor with Preview | ❌ Not Started | Medium |
| **Flutter UI** | Settings and Preferences | ❌ Not Started | Medium |
| **Flutter UI** | Note Editor Screen | ❌ Not Started | High |
| **Flutter UI** | Vault Creation Dialog | ❌ Not Started | High |
| **Flutter UI** | Services Layer | ❌ Not Started | High |
| **Flutter UI** | Widgets Library | ❌ Not Started | Medium |
| **Integration** | Biometric Authentication | ❌ Not Started | Low |
| **Localization** | Multi-language Support | ❌ Not Started | Low |
| **Backup** | Backup and Restore | ❌ Not Started | Low |

---

## Detailed Development Tasks

### Phase 1: FFI Bridge Implementation (High Priority)

#### Task 1.1: Create Rust FFI Exports
**File:** `core/null-space-core/src/ffi.rs`
**Description:** Create C-compatible function exports for the Rust core library.

**Implementation Steps:**
1. Create new file `ffi.rs` in `core/null-space-core/src/`
2. Add `pub mod ffi;` to `lib.rs`
3. Implement the following FFI functions:

```rust
// Required imports at the top of ffi.rs:
use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_void};

// Required FFI functions to implement:
#[no_mangle]
pub extern "C" fn null_space_init() -> *mut c_void;

#[no_mangle]
pub extern "C" fn null_space_free(ptr: *mut c_void);

#[no_mangle]
pub extern "C" fn null_space_generate_salt() -> *mut c_char;

#[no_mangle]
pub extern "C" fn null_space_encrypt(
    data: *const c_char,
    password: *const c_char,
    salt: *const c_char
) -> *mut c_char;

#[no_mangle]
pub extern "C" fn null_space_decrypt(
    encrypted: *const c_char,
    password: *const c_char,
    salt: *const c_char
) -> *mut c_char;

#[no_mangle]
pub extern "C" fn null_space_create_note(
    title: *const c_char,
    content: *const c_char,
    tags: *const c_char  // JSON array
) -> *mut c_char;  // Returns JSON

#[no_mangle]
pub extern "C" fn null_space_update_note(
    note_json: *const c_char
) -> *mut c_char;

#[no_mangle]
pub extern "C" fn null_space_search(
    index_path: *const c_char,
    query: *const c_char,
    limit: i32
) -> *mut c_char;  // Returns JSON array

#[no_mangle]
pub extern "C" fn null_space_export_vault(
    vault_json: *const c_char,
    notes_json: *const c_char,
    output_path: *const c_char,
    password: *const c_char
) -> i32;  // Returns 0 on success, error code otherwise

#[no_mangle]
pub extern "C" fn null_space_import_vault(
    input_path: *const c_char,
    password: *const c_char
) -> *mut c_char;  // Returns JSON with vault and notes

#[no_mangle]
pub extern "C" fn null_space_free_string(ptr: *mut c_char);
```

**Acceptance Criteria:**
- All functions compile without errors
- Functions handle null pointers gracefully
- Memory is properly managed (no leaks)
- Error handling returns proper error codes/messages

---

#### Task 1.2: Implement Dart FFI Bindings
**File:** `ui/null_space_app/lib/bridge/rust_bridge.dart`
**Description:** Complete the Dart FFI bindings to call Rust functions.

**Implementation Steps:**
1. Add necessary FFI type definitions
2. Implement dynamic library loading for all platforms
3. Implement wrapper methods that handle:
   - String conversion (Dart String ↔ C char*)
   - Memory management (malloc/free)
   - JSON serialization/deserialization
   - Error handling

**Required Methods:**
```dart
class RustBridge {
  // Initialization
  void init();
  void dispose();
  
  // Salt generation
  String generateSalt();
  
  // Encryption
  String encrypt(String data, String password, String salt);
  String decrypt(String encrypted, String password, String salt);
  
  // Note operations
  Map<String, dynamic> createNote(String title, String content, List<String> tags);
  Map<String, dynamic> updateNote(Map<String, dynamic> note);
  
  // Search
  List<Map<String, dynamic>> search(String indexPath, String query, int limit);
  
  // Vault operations
  bool exportVault(Map<String, dynamic> vault, List<Map<String, dynamic>> notes, String outputPath, String password);
  Map<String, dynamic> importVault(String inputPath, String password);
}
```

**Acceptance Criteria:**
- All platform libraries load correctly (Android, iOS, macOS, Windows)
- String conversions work without data corruption
- Memory is freed properly after each call
- Exceptions are thrown with meaningful messages on errors

---

#### Task 1.3: Create Build Scripts for Native Libraries
**Files:** 
- `scripts/build_android.sh`
- `scripts/build_ios.sh`
- `scripts/build_macos.sh`
- `scripts/build_windows.ps1`

**Description:** Create platform-specific build scripts for compiling Rust to native libraries.

**Android Build Requirements:**
- Target architectures: arm64-v8a, armeabi-v7a, x86_64
- Use Android NDK toolchain
- Output: `libnull_space_core.so` for each architecture

**iOS Build Requirements:**
- Target: iOS 12.0+
- Build universal framework (arm64, simulator)
- Output: `null_space_core.xcframework`

**macOS Build Requirements:**
- Target: macOS 10.14+
- Build universal binary (arm64, x86_64)
- Output: `libnull_space_core.dylib`

**Windows Build Requirements:**
- Target: x64
- Use MSVC toolchain
- Output: `null_space_core.dll`

**Acceptance Criteria:**
- Scripts run without errors on CI/CD
- Output libraries are placed in correct Flutter directories
- Libraries are properly signed (where required)

---

### Phase 2: Note CRUD Operations (High Priority)

#### Task 2.1: Create Note Service Layer
**File:** `ui/null_space_app/lib/services/note_service.dart`
**Description:** Implement business logic layer for note operations.

**Implementation Steps:**
1. Create `services` directory if not exists
2. Create a `FileStorage` helper class to abstract platform-specific file operations
3. Implement `NoteService` class with the following methods:

```dart
/// FileStorage helper for platform-agnostic file operations
/// Can use path_provider package to get app documents directory
class FileStorage {
  final String basePath;
  
  FileStorage(this.basePath);
  
  Future<void> writeFile(String relativePath, List<int> data);
  Future<List<int>> readFile(String relativePath);
  Future<void> deleteFile(String relativePath);
  Future<bool> exists(String relativePath);
  Future<List<String>> listFiles(String directory);
}

class NoteService {
  final RustBridge _bridge;
  final FileStorage _storage;
  
  NoteService({required RustBridge bridge, required FileStorage storage})
      : _bridge = bridge, _storage = storage;
  
  // Create a new note
  Future<Note> createNote({
    required String title,
    required String content,
    required List<String> tags,
    required String vaultPassword,
    required String vaultSalt,
  });
  
  // Update an existing note
  Future<Note> updateNote({
    required Note note,
    required String vaultPassword,
    required String vaultSalt,
  });
  
  // Delete a note
  Future<void> deleteNote({
    required String noteId,
    required String vaultPath,
  });
  
  // Load all notes from a vault
  Future<List<Note>> loadNotes({
    required String vaultPath,
    required String vaultPassword,
    required String vaultSalt,
  });
  
  // Save note to disk (encrypted)
  Future<void> saveNoteToDisk({
    required Note note,
    required String vaultPath,
    required String vaultPassword,
    required String vaultSalt,
  });
  
  // Index note for search
  Future<void> indexNote({
    required Note note,
    required String indexPath,
  });
}
```

**Acceptance Criteria:**
- Notes are encrypted before saving to disk
- Notes are decrypted when loaded
- Search index is updated when notes change
- Proper error handling for all operations

---

#### Task 2.2: Create Note Editor Screen
**File:** `ui/null_space_app/lib/screens/note_editor_screen.dart`
**Description:** Implement the full-featured note editor screen.

**UI Components Required:**
1. Title text field
2. Content text area with Markdown support
3. Tag input with autocomplete
4. Save/Cancel buttons
5. Delete button (for existing notes)
6. Markdown preview toggle

**Implementation Steps:**
1. Create new screen file
2. Implement state management for form fields
3. Integrate with NoteService
4. Add form validation
5. Implement save/update/delete actions

**Acceptance Criteria:**
- Title and content fields save correctly
- Tags can be added/removed with autocomplete
- Markdown preview renders correctly
- Unsaved changes prompt user before closing
- Loading states show during async operations

---

#### Task 2.3: Enhance Notes List Screen
**File:** `ui/null_space_app/lib/screens/home_screen.dart` → Extract to `notes_list_screen.dart`
**Description:** Replace placeholder with functional notes list.

**UI Components Required:**
1. List/Grid view of notes
2. Note card with title, preview, tags, date
3. Floating action button to create new note
4. Swipe-to-delete gesture
5. Tap to open note in editor
6. Sort options (date, title, recently updated)
7. Empty state with call-to-action

**Implementation Steps:**
1. Extract NotesListScreen to separate file
2. Connect to NoteProvider for state
3. Implement ListView.builder with NoteCard widgets
4. Add FAB with navigation to editor
5. Implement sorting and filtering
6. Add pull-to-refresh

**Acceptance Criteria:**
- Notes display with title, preview, and metadata
- Tap opens note in editor
- New note button creates blank note
- Delete removes note with confirmation
- List updates reactively to provider changes

---

#### Task 2.4: Create Note Card Widget
**File:** `ui/null_space_app/lib/widgets/note_card.dart`
**Description:** Create reusable note card widget for list display.

**Widget Properties:**
```dart
class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool isSelected;
}
```

**Design Requirements:**
- Show note title (bold, max 2 lines)
- Show content preview (max 3 lines)
- Show tags as chips (max 3, +N indicator)
- Show last updated date
- Support dark/light themes
- Elevation and hover effects

**Acceptance Criteria:**
- Consistent styling across all cards
- Text truncation works correctly
- Tags display properly
- Responsive to different screen sizes

---

### Phase 3: Vault Management (High Priority)

#### Task 3.1: Create Vault Service Layer
**File:** `ui/null_space_app/lib/services/vault_service.dart`
**Description:** Implement business logic layer for vault operations.

**Implementation Steps:**
```dart
class VaultService {
  final RustBridge _bridge;
  final FileStorage _storage;
  
  // Create a new vault
  Future<Vault> createVault({
    required String name,
    required String description,
    required String password,
  });
  
  // Open/unlock a vault
  Future<bool> unlockVault({
    required Vault vault,
    required String password,
  });
  
  // Lock a vault
  void lockVault({required String vaultId});
  
  // Export vault to file
  Future<String> exportVault({
    required Vault vault,
    required List<Note> notes,
    required String outputPath,
    required String password,
  });
  
  // Import vault from file
  // Returns a record type (Dart 3.0+) - ensure pubspec.yaml sdk >= 3.0.0
  // Alternative for older Dart: use ImportVaultResult class { Vault vault; List<Note> notes; }
  Future<(Vault, List<Note>)> importVault({
    required String inputPath,
    required String password,
  });
  
  // List all local vaults
  Future<List<Vault>> listVaults();
  
  // Delete a vault
  Future<void> deleteVault({required String vaultId});
}
```

**Acceptance Criteria:**
- Vaults are created with unique salt
- Password validation works correctly
- Export creates valid ZIP file
- Import reads and decrypts correctly
- Vault list persists across app restarts

---

#### Task 3.2: Create Vault Creation Dialog
**File:** `ui/null_space_app/lib/widgets/vault_creation_dialog.dart`
**Description:** Implement dialog for creating new vaults.

**UI Components:**
1. Vault name input field
2. Description input field (optional)
3. Password input with visibility toggle
4. Confirm password field
5. Password strength indicator
6. Create/Cancel buttons

**Validation Rules:**
- Name: Required, 1-100 characters
- Password: Required, minimum 8 characters
- Password confirmation must match
- Show password strength (weak/medium/strong)

**Acceptance Criteria:**
- Form validates before submission
- Password fields match
- Password strength displays correctly
- Error messages are clear
- Loading state during creation

---

#### Task 3.3: Create Vault Unlock Dialog
**File:** `ui/null_space_app/lib/widgets/vault_unlock_dialog.dart`
**Description:** Implement dialog for unlocking vaults.

**UI Components:**
1. Vault name display
2. Password input with visibility toggle
3. Remember password checkbox (optional)
4. Unlock/Cancel buttons
5. Forgot password warning

**Implementation Steps:**
1. Display vault name and info
2. Capture password securely
3. Call VaultService.unlockVault()
4. Handle success/failure states
5. Show error message on wrong password

**Acceptance Criteria:**
- Wrong password shows error
- Multiple failed attempts show warning
- Success navigates to notes
- Cancel returns to vault list

---

#### Task 3.4: Create Vault Card Widget
**File:** `ui/null_space_app/lib/widgets/vault_card.dart`
**Description:** Create reusable vault card widget for list display.

**Widget Properties:**
```dart
class VaultCard extends StatelessWidget {
  final Vault vault;
  final bool isLocked;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onExport;
  final bool isSelected;
}
```

**Design Requirements:**
- Show vault name (bold, max 2 lines)
- Show description preview (max 2 lines)
- Show lock/unlock icon indicator
- Show last accessed date
- Show note count badge (if available)
- Support dark/light themes
- Elevation and hover effects
- Context menu for actions (Export, Delete, Rename)

**Acceptance Criteria:**
- Consistent styling across all cards
- Lock status is clearly visible
- Text truncation works correctly
- Responsive to different screen sizes
- Long-press shows context menu

---

#### Task 3.5: Enhance Vault Management Screen
**File:** `ui/null_space_app/lib/screens/vault_screen.dart`
**Description:** Replace placeholder with full vault management.

**UI Components:**
1. List of vaults with lock/unlock status
2. Create new vault button
3. Import vault button (file picker)
4. Export vault button (for selected vault)
5. Delete vault button with confirmation
6. Vault settings/rename option

**Implementation Steps:**
1. Extract VaultScreen to separate file
2. Connect to VaultProvider
3. Implement vault list with VaultCard widgets
4. Add file picker for import
5. Add directory picker for export
6. Implement delete with confirmation

**Acceptance Criteria:**
- Vault list shows all local vaults
- Import/Export work with file system
- Create opens dialog
- Delete requires confirmation
- UI updates after operations

---

### Phase 4: Search and Filtering (Medium Priority)

#### Task 4.1: Create Search Service Layer
**File:** `ui/null_space_app/lib/services/search_service.dart`
**Description:** Implement search functionality using Rust core.

**Implementation Steps:**
```dart
class SearchService {
  final RustBridge _bridge;
  
  // Initialize search index
  Future<void> initializeIndex({required String indexPath});
  
  // Search notes
  Future<List<SearchResult>> search({
    required String query,
    int limit = 20,
  });
  
  // Index a single note
  Future<void> indexNote({required Note note});
  
  // Remove note from index
  Future<void> removeFromIndex({required String noteId});
  
  // Rebuild entire index
  Future<void> rebuildIndex({required List<Note> notes});
}

class SearchResult {
  final String noteId;
  final double score;
  final String titleSnippet;
  final String contentSnippet;
}
```

**Acceptance Criteria:**
- Search returns ranked results
- Index updates when notes change
- Rebuild recreates index from scratch
- Search handles special characters

---

#### Task 4.2: Enhance Search Screen
**File:** `ui/null_space_app/lib/screens/search_screen.dart`
**Description:** Implement full-featured search interface.

**UI Components:**
1. Search input field with debouncing
2. Search results list
3. Result cards with highlighted matches
4. Empty state messages
5. Search history (recent searches)
6. Clear search button

**Implementation Steps:**
1. Extract SearchScreen to separate file
2. Implement debounced search input (300ms)
3. Display results with relevance ranking
4. Highlight matching terms in results
5. Tap result opens note in editor
6. Show loading state during search

**Acceptance Criteria:**
- Search is responsive (< 200ms)
- Results update as user types
- Matching terms are highlighted
- No results shows helpful message
- Clear button resets search

---

#### Task 4.3: Create Tag Filter Widget
**File:** `ui/null_space_app/lib/widgets/tag_filter_widget.dart`
**Description:** Implement tag-based filtering for notes.

**UI Components:**
1. Tag cloud or list view
2. Hierarchical tag display (tree view)
3. Selected/unselected tag states
4. Tag count badges
5. Clear all filters button

**Implementation Steps:**
1. Extract unique tags from notes
2. Build hierarchical structure
3. Implement multi-select filtering
4. Update notes list based on selection
5. Show note counts per tag

**Acceptance Criteria:**
- Tags display hierarchically (work/project/urgent)
- Multiple tags can be selected (AND logic)
- Parent tag selects all children
- Counts update accurately

---

#### Task 4.4: Create Tag Input Widget
**File:** `ui/null_space_app/lib/widgets/tag_input_widget.dart`
**Description:** Implement tag input with autocomplete.

**UI Components:**
1. Text input field
2. Autocomplete dropdown
3. Tag chips for selected tags
4. Remove tag button on chips
5. Hierarchical suggestions

**Implementation Steps:**
1. Track all existing tags in vault
2. Show suggestions as user types
3. Support creating new tags
4. Allow hierarchical input (work/project)
5. Display selected tags as removable chips

**Acceptance Criteria:**
- Autocomplete shows relevant suggestions
- New tags can be created
- Hierarchical tags parse correctly
- Tags can be removed with X button

---

### Phase 5: Markdown Editor (Medium Priority)

#### Task 5.1: Create Markdown Editor Widget
**File:** `ui/null_space_app/lib/widgets/markdown_editor.dart`
**Description:** Implement Markdown editor with live preview.

**UI Components:**
1. Text editor with syntax highlighting
2. Live preview pane
3. Split view (edit + preview)
4. Toggle between edit/preview/split
5. Markdown toolbar (bold, italic, headers, lists, links)

**Implementation Steps:**
1. Create dual-pane layout
2. Integrate flutter_markdown for preview
3. Implement toolbar actions
4. Add keyboard shortcuts
5. Support paste images (future)

**Toolbar Actions:**
- Bold (**text**)
- Italic (*text*)
- Headers (# ## ###)
- Bullet list (- item)
- Numbered list (1. item)
- Link ([text](url))
- Code block (```code```)
- Quote (> quote)

**Acceptance Criteria:**
- Editor supports all common Markdown
- Preview renders in real-time
- Toolbar inserts correct syntax
- Keyboard shortcuts work (Ctrl+B for bold)
- Split view is responsive

---

#### Task 5.2: Create Markdown Toolbar Widget
**File:** `ui/null_space_app/lib/widgets/markdown_toolbar.dart`
**Description:** Implement toolbar for Markdown formatting.

**Widget Properties:**
```dart
class MarkdownToolbar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;
}
```

**Toolbar Buttons:**
| Button | Icon | Action | Keyboard Shortcut |
|--------|------|--------|-------------------|
| Bold | format_bold | Wrap selection with ** | Ctrl+B |
| Italic | format_italic | Wrap selection with * | Ctrl+I |
| H1 | title | Insert # at line start | - |
| H2 | text_fields | Insert ## at line start | - |
| List | format_list_bulleted | Insert - at line start | - |
| Numbered | format_list_numbered | Insert 1. at line start | - |
| Link | link | Insert [text](url) | Ctrl+K |
| Code | code | Wrap with backticks | Ctrl+` |
| Quote | format_quote | Insert > at line start | - |

**Acceptance Criteria:**
- All buttons insert correct syntax
- Selection is wrapped, not replaced
- Cursor position updates correctly
- Buttons are visually clear

---

### Phase 6: Settings and Preferences (Medium Priority)

#### Task 6.1: Create Settings Screen
**File:** `ui/null_space_app/lib/screens/settings_screen.dart`
**Description:** Implement app settings and preferences.

**Settings Categories:**
1. **Appearance**
   - Theme (Light/Dark/System)
   - Font size
   - Editor line spacing

2. **Security**
   - Auto-lock timeout
   - Biometric unlock (if available)
   - Clear clipboard after paste

3. **Editor**
   - Default view mode (Edit/Preview/Split)
   - Auto-save interval
   - Spell check on/off

4. **Storage**
   - Data directory location
   - Clear search index
   - Export all data

5. **About**
   - Version info
   - Licenses
   - Source code link

**Implementation Steps:**
1. Create settings screen with sections
2. Implement shared_preferences storage
3. Create SettingsProvider for state
4. Apply settings throughout app

**Acceptance Criteria:**
- Settings persist across restarts
- Changes apply immediately
- Settings are organized logically
- About section shows correct info

---

#### Task 6.2: Create Settings Provider
**File:** `ui/null_space_app/lib/providers/settings_provider.dart`
**Description:** Implement state management for settings.

**Implementation Steps:**
```dart
/// View mode options for the Markdown editor
enum EditorViewMode {
  edit,     // Edit only mode
  preview,  // Preview only mode
  split,    // Side-by-side edit and preview
}

class SettingsProvider extends ChangeNotifier {
  // Appearance
  ThemeMode get themeMode;
  void setThemeMode(ThemeMode mode);
  
  double get fontSize;
  void setFontSize(double size);
  
  // Security
  Duration get autoLockTimeout;
  void setAutoLockTimeout(Duration duration);
  
  bool get biometricEnabled;
  void setBiometricEnabled(bool enabled);
  
  // Editor
  EditorViewMode get defaultViewMode;
  void setDefaultViewMode(EditorViewMode mode);
  
  Duration get autoSaveInterval;
  void setAutoSaveInterval(Duration interval);
  
  // Persistence
  Future<void> loadSettings();
  Future<void> saveSettings();
}
```

**Acceptance Criteria:**
- Settings load on app start
- Changes are saved immediately
- Defaults are sensible
- Provider notifies listeners on change

---

### Phase 7: Polish and Production (Lower Priority)

#### Task 7.1: Implement Biometric Authentication
**File:** `ui/null_space_app/lib/services/auth_service.dart`
**Description:** Add biometric unlock support.

**Implementation Steps:**
1. Add `local_auth` package dependency
2. Create AuthService class
3. Check biometric availability
4. Implement vault unlock with biometrics
5. Fallback to password on failure

**Acceptance Criteria:**
- Works on iOS (Face ID, Touch ID)
- Works on Android (Fingerprint, Face)
- Falls back gracefully
- Can be disabled in settings

---

#### Task 7.2: Add Multi-language Support
**File:** `ui/null_space_app/lib/l10n/`
**Description:** Implement internationalization.

**Implementation Steps:**
1. Add `flutter_localizations` dependency
2. Create ARB files for languages
3. Generate Dart localization code
4. Replace hardcoded strings
5. Add language selector in settings

**Initial Languages:**
- English (en)
- Chinese Simplified (zh-CN)
- Chinese Traditional (zh-TW)
- Japanese (ja)
- Korean (ko)

**Acceptance Criteria:**
- All UI text is translatable
- Language changes without restart
- RTL languages supported (future)
- Date/time formats localized

---

#### Task 7.3: Create App Icons and Splash Screens
**Directories:**
- `ui/null_space_app/android/app/src/main/res/`
- `ui/null_space_app/ios/Runner/Assets.xcassets/`
- `ui/null_space_app/macos/Runner/Assets.xcassets/`
- `ui/null_space_app/windows/runner/resources/`

**Requirements:**
1. Create app icon in all required sizes
2. Create splash screen assets
3. Add launch screen for iOS/macOS
4. Configure Windows/Android splash

**Icon Specifications:**
- Android: 48dp - 192dp (mdpi to xxxhdpi)
- iOS: 20pt - 1024pt
- macOS: 16pt - 512pt
- Windows: 256x256 ICO

**Acceptance Criteria:**
- Icons display correctly on all platforms
- Splash screens show while loading
- Icons are sharp on high-DPI displays
- Consistent branding across platforms

---

#### Task 7.4: Write Unit and Widget Tests
**Files:**
- `ui/null_space_app/test/`
- `core/null-space-core/tests/`

**Test Categories:**

**Rust Unit Tests:**
- `tests/crypto_test.rs` - Additional encryption edge cases
- `tests/search_test.rs` - Search accuracy tests
- `tests/vault_test.rs` - Import/export edge cases

**Flutter Unit Tests:**
- `test/services/note_service_test.dart`
- `test/services/vault_service_test.dart`
- `test/providers/note_provider_test.dart`
- `test/providers/vault_provider_test.dart`

**Flutter Widget Tests:**
- `test/widgets/note_card_test.dart`
- `test/widgets/markdown_editor_test.dart`
- `test/screens/notes_list_test.dart`

**Integration Tests:**
- `test/integration/note_crud_test.dart`
- `test/integration/vault_import_export_test.dart`

**Acceptance Criteria:**
- 80%+ code coverage target
- All critical paths tested
- Tests run in CI pipeline
- Mock FFI for Flutter tests

---

#### Task 7.5: Implement CI/CD Pipeline
**File:** `.github/workflows/ci.yml`
**Description:** Create automated build and test pipeline.

**Pipeline Stages:**
1. **Lint**
   - Run `cargo clippy` for Rust
   - Run `flutter analyze` for Dart

2. **Test**
   - Run `cargo test` for Rust
   - Run `flutter test` for Dart

3. **Build**
   - Build Rust libraries for all platforms
   - Build Flutter apps for all platforms

4. **Release** (on tag)
   - Create GitHub release
   - Upload platform binaries
   - Generate changelog

**Acceptance Criteria:**
- Pipeline runs on PR and main branch
- Failures block merge
- Artifacts are uploaded
- Release automation works

---

## Development Order Recommendation

For optimal development flow, implement features in this order:

### Sprint 1 (Weeks 1-2): Core Integration
1. Task 1.1: Create Rust FFI Exports
2. Task 1.2: Implement Dart FFI Bindings
3. Task 1.3: Create Build Scripts

### Sprint 2 (Weeks 3-4): Note Management
4. Task 2.1: Create Note Service Layer
5. Task 2.4: Create Note Card Widget
6. Task 2.3: Enhance Notes List Screen
7. Task 2.2: Create Note Editor Screen

### Sprint 3 (Weeks 5-6): Vault Management
8. Task 3.1: Create Vault Service Layer
9. Task 3.2: Create Vault Creation Dialog
10. Task 3.3: Create Vault Unlock Dialog
11. Task 3.4: Create Vault Card Widget
12. Task 3.5: Enhance Vault Management Screen

### Sprint 4 (Weeks 7-8): Search and Tags
13. Task 4.1: Create Search Service Layer
14. Task 4.2: Enhance Search Screen
15. Task 4.3: Create Tag Filter Widget
16. Task 4.4: Create Tag Input Widget

### Sprint 5 (Weeks 9-10): Editor Enhancement
17. Task 5.1: Create Markdown Editor Widget
18. Task 5.2: Create Markdown Toolbar Widget

### Sprint 6 (Weeks 11-12): Settings and Polish
> Note: Task 6.2 is implemented before 6.1 because the Settings Screen depends on the Settings Provider for state management.

19. Task 6.2: Create Settings Provider
20. Task 6.1: Create Settings Screen
21. Task 7.4: Write Unit and Widget Tests
22. Task 7.5: Implement CI/CD Pipeline

### Sprint 7 (Weeks 13+): Production Ready
23. Task 7.1: Implement Biometric Authentication
24. Task 7.2: Add Multi-language Support
25. Task 7.3: Create App Icons and Splash Screens

---

## Technical Notes for AI Implementation

### Code Style Guidelines

**Rust:**
- Follow Rust Style Guide
- Use `Result<T, E>` for error handling
- Document public APIs with `///`
- Use `#[cfg(test)]` for test modules

**Dart/Flutter:**
- Follow Effective Dart guidelines
- Use `async/await` for asynchronous code
- Document public APIs with `///`
- Use `const` constructors where possible

### Memory Management

**FFI String Handling:**
- Rust: Use `CString` for owned strings, `CStr` for borrowed
- Dart: Use `toNativeUtf8()` to allocate, `free()` to release
- Always free memory on both sides of the FFI boundary

### Error Handling

**Rust FFI Errors:**
- Return null pointer or error code on failure
- Provide `null_space_get_last_error()` function
- Never panic across FFI boundary

**Flutter Error Handling:**
- Wrap FFI calls in try-catch
- Show user-friendly error messages
- Log detailed errors for debugging

### Testing Strategy

**Unit Tests:**
- Test individual functions in isolation
- Mock dependencies with interfaces
- Cover edge cases and error paths

**Integration Tests:**
- Test full flows (create → save → load → verify)
- Use temporary directories for storage
- Clean up after tests

---

## Appendix: File Structure After Implementation

```
null-space/
├── core/
│   └── null-space-core/
│       ├── src/
│       │   ├── lib.rs
│       │   ├── crypto.rs
│       │   ├── search.rs
│       │   ├── storage.rs
│       │   ├── vault.rs
│       │   ├── models.rs
│       │   └── ffi.rs           ← NEW
│       └── tests/
│           ├── crypto_test.rs    ← NEW
│           ├── search_test.rs    ← NEW
│           └── vault_test.rs     ← NEW
│
├── ui/
│   └── null_space_app/
│       └── lib/
│           ├── main.dart
│           ├── bridge/
│           │   └── rust_bridge.dart  ← UPDATED
│           ├── models/
│           │   ├── note.dart
│           │   └── vault.dart
│           ├── providers/
│           │   ├── note_provider.dart
│           │   ├── vault_provider.dart
│           │   └── settings_provider.dart  ← NEW
│           ├── services/              ← NEW
│           │   ├── file_storage.dart     ← Platform file operations
│           │   ├── note_service.dart
│           │   ├── vault_service.dart
│           │   ├── search_service.dart
│           │   └── auth_service.dart
│           ├── screens/
│           │   ├── home_screen.dart      ← UPDATED
│           │   ├── notes_list_screen.dart ← NEW
│           │   ├── note_editor_screen.dart ← NEW
│           │   ├── search_screen.dart     ← NEW
│           │   ├── vault_screen.dart      ← NEW
│           │   └── settings_screen.dart   ← NEW
│           ├── widgets/               ← NEW
│           │   ├── note_card.dart
│           │   ├── vault_card.dart
│           │   ├── tag_filter_widget.dart
│           │   ├── tag_input_widget.dart
│           │   ├── markdown_editor.dart
│           │   ├── markdown_toolbar.dart
│           │   ├── vault_creation_dialog.dart
│           │   └── vault_unlock_dialog.dart
│           └── l10n/                  ← NEW
│               ├── app_en.arb
│               ├── app_zh.arb
│               └── ...
│
├── scripts/                           ← NEW
│   ├── build_android.sh
│   ├── build_ios.sh
│   ├── build_macos.sh
│   └── build_windows.ps1
│
├── .github/
│   └── workflows/
│       └── ci.yml                     ← NEW
│
└── docs/
    ├── ARCHITECTURE.md
    ├── API.md
    ├── DEVELOPMENT.md
    └── DEVELOPMENT_PLAN.md            ← THIS FILE
```

---

*Last Updated: 2026-01-30*
*Version: 1.0*
