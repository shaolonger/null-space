//! FFI (Foreign Function Interface) bindings for Null Space Core
//!
//! This module provides C-compatible functions that can be called from other languages
//! like Dart/Flutter. All functions use C-compatible types and follow FFI conventions.
#![allow(clippy::not_unsafe_ptr_arg_deref)]

use base64::{engine::general_purpose, Engine as _};
use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_int, c_void};
use std::path::{Path, PathBuf};
use std::ptr;

use crate::crypto::EncryptionManager;
use crate::models::{ConflictResolution, Note};
use crate::search::SearchEngine;
use crate::storage::FileStorage;
use crate::vault::VaultManager;

/// Initialize the library (currently a no-op, but reserved for future use)
#[no_mangle]
pub extern "C" fn null_space_init() -> *mut c_void {
    // Return a non-null pointer to indicate successful initialization
    // In the future, this could return an actual context/state object
    Box::into_raw(Box::new(0u8)) as *mut c_void
}

/// Free library resources
#[no_mangle]
pub extern "C" fn null_space_free(ptr: *mut c_void) {
    if !ptr.is_null() {
        unsafe {
            let _ = Box::from_raw(ptr as *mut u8);
        }
    }
}

/// Generate a random salt for key derivation
/// Returns a C string that must be freed with null_space_free_string
#[no_mangle]
pub extern "C" fn null_space_generate_salt() -> *mut c_char {
    let salt = EncryptionManager::generate_salt();

    match CString::new(salt) {
        Ok(c_str) => c_str.into_raw(),
        Err(_) => ptr::null_mut(),
    }
}

/// Encrypt data with a password and salt
///
/// # Arguments
/// * `data` - The plaintext data to encrypt (null-terminated C string)
/// * `password` - The password to use for encryption (null-terminated C string)
/// * `salt` - The salt for key derivation (null-terminated C string)
///
/// # Returns
/// A base64-encoded string containing the encrypted data, or null on error.
/// The returned string must be freed with null_space_free_string.
#[no_mangle]
pub extern "C" fn null_space_encrypt(
    data: *const c_char,
    password: *const c_char,
    salt: *const c_char,
) -> *mut c_char {
    // Validate input pointers
    if data.is_null() || password.is_null() || salt.is_null() {
        return ptr::null_mut();
    }

    // Convert C strings to Rust strings
    let data_str = unsafe {
        match CStr::from_ptr(data).to_str() {
            Ok(s) => s,
            Err(_) => return ptr::null_mut(),
        }
    };

    let password_str = unsafe {
        match CStr::from_ptr(password).to_str() {
            Ok(s) => s,
            Err(_) => return ptr::null_mut(),
        }
    };

    let salt_str = unsafe {
        match CStr::from_ptr(salt).to_str() {
            Ok(s) => s,
            Err(_) => return ptr::null_mut(),
        }
    };

    // Create encryption manager
    let manager = match EncryptionManager::new_from_password(password_str, salt_str) {
        Ok(m) => m,
        Err(_) => return ptr::null_mut(),
    };

    // Encrypt the data
    let encrypted = match manager.encrypt(data_str.as_bytes()) {
        Ok(e) => e,
        Err(_) => return ptr::null_mut(),
    };

    // Encode as base64
    let encoded = general_purpose::STANDARD.encode(&encrypted);

    // Convert to C string
    match CString::new(encoded) {
        Ok(c_str) => c_str.into_raw(),
        Err(_) => ptr::null_mut(),
    }
}

/// Decrypt data with a password and salt
///
/// # Arguments
/// * `encrypted` - Base64-encoded encrypted data (null-terminated C string)
/// * `password` - The password to use for decryption (null-terminated C string)
/// * `salt` - The salt for key derivation (null-terminated C string)
///
/// # Returns
/// The decrypted plaintext as a C string, or null on error.
/// The returned string must be freed with null_space_free_string.
#[no_mangle]
pub extern "C" fn null_space_decrypt(
    encrypted: *const c_char,
    password: *const c_char,
    salt: *const c_char,
) -> *mut c_char {
    // Validate input pointers
    if encrypted.is_null() || password.is_null() || salt.is_null() {
        return ptr::null_mut();
    }

    // Convert C strings to Rust strings
    let encrypted_str = unsafe {
        match CStr::from_ptr(encrypted).to_str() {
            Ok(s) => s,
            Err(_) => return ptr::null_mut(),
        }
    };

    let password_str = unsafe {
        match CStr::from_ptr(password).to_str() {
            Ok(s) => s,
            Err(_) => return ptr::null_mut(),
        }
    };

    let salt_str = unsafe {
        match CStr::from_ptr(salt).to_str() {
            Ok(s) => s,
            Err(_) => return ptr::null_mut(),
        }
    };

    // Decode from base64
    let encrypted_bytes = match general_purpose::STANDARD.decode(encrypted_str) {
        Ok(b) => b,
        Err(_) => return ptr::null_mut(),
    };

    // Create encryption manager
    let manager = match EncryptionManager::new_from_password(password_str, salt_str) {
        Ok(m) => m,
        Err(_) => return ptr::null_mut(),
    };

    // Decrypt the data
    let decrypted = match manager.decrypt(&encrypted_bytes) {
        Ok(d) => d,
        Err(_) => return ptr::null_mut(),
    };

    // Convert to string
    let decrypted_str = match String::from_utf8(decrypted) {
        Ok(s) => s,
        Err(_) => return ptr::null_mut(),
    };

    // Convert to C string
    match CString::new(decrypted_str) {
        Ok(c_str) => c_str.into_raw(),
        Err(_) => ptr::null_mut(),
    }
}

/// Create a new note
///
/// # Arguments
/// * `title` - The note title (null-terminated C string)
/// * `content` - The note content in Markdown (null-terminated C string)
/// * `tags` - JSON array of tags as a string (null-terminated C string)
///
/// # Returns
/// JSON representation of the created note, or null on error.
/// The returned string must be freed with null_space_free_string.
#[no_mangle]
pub extern "C" fn null_space_create_note(
    title: *const c_char,
    content: *const c_char,
    tags: *const c_char,
) -> *mut c_char {
    // Validate input pointers
    if title.is_null() || content.is_null() || tags.is_null() {
        return ptr::null_mut();
    }

    // Convert C strings to Rust strings
    let title_str = unsafe {
        match CStr::from_ptr(title).to_str() {
            Ok(s) => s,
            Err(_) => return ptr::null_mut(),
        }
    };

    let content_str = unsafe {
        match CStr::from_ptr(content).to_str() {
            Ok(s) => s,
            Err(_) => return ptr::null_mut(),
        }
    };

    let tags_str = unsafe {
        match CStr::from_ptr(tags).to_str() {
            Ok(s) => s,
            Err(_) => return ptr::null_mut(),
        }
    };

    // Parse tags JSON
    let tags_vec: Vec<String> = match serde_json::from_str(tags_str) {
        Ok(t) => t,
        Err(_) => return ptr::null_mut(),
    };

    // Create the note
    let note = Note::new(title_str.to_string(), content_str.to_string(), tags_vec);

    // Serialize to JSON
    let json = match serde_json::to_string(&note) {
        Ok(j) => j,
        Err(_) => return ptr::null_mut(),
    };

    // Convert to C string
    match CString::new(json) {
        Ok(c_str) => c_str.into_raw(),
        Err(_) => ptr::null_mut(),
    }
}

/// Update an existing note
///
/// # Arguments
/// * `note_json` - JSON representation of the note to update (null-terminated C string)
///
/// # Returns
/// JSON representation of the updated note with incremented version and timestamp, or null on error.
/// The returned string must be freed with null_space_free_string.
///
/// # Note
/// This function expects the full note JSON with the updated title, content, and tags.
/// It will increment the version number and update the timestamp automatically.
/// The caller should modify the note object on their side before calling this function.
#[no_mangle]
pub extern "C" fn null_space_update_note(note_json: *const c_char) -> *mut c_char {
    // Validate input pointer
    if note_json.is_null() {
        return ptr::null_mut();
    }

    // Convert C string to Rust string
    let json_str = unsafe {
        match CStr::from_ptr(note_json).to_str() {
            Ok(s) => s,
            Err(_) => return ptr::null_mut(),
        }
    };

    // Parse note from JSON
    let mut note: Note = match serde_json::from_str(json_str) {
        Ok(n) => n,
        Err(_) => return ptr::null_mut(),
    };

    // Update the note (this increments the version and updates timestamp)
    note.update(note.title.clone(), note.content.clone(), note.tags.clone());

    // Serialize back to JSON
    let json = match serde_json::to_string(&note) {
        Ok(j) => j,
        Err(_) => return ptr::null_mut(),
    };

    // Convert to C string
    match CString::new(json) {
        Ok(c_str) => c_str.into_raw(),
        Err(_) => ptr::null_mut(),
    }
}

/// Search notes in the index
///
/// # Arguments
/// * `index_path` - Path to the search index directory (null-terminated C string)
/// * `query` - Search query string (null-terminated C string)
/// * `limit` - Maximum number of results to return
///
/// # Returns
/// JSON array of search results, or null on error.
/// The returned string must be freed with null_space_free_string.
#[no_mangle]
pub extern "C" fn null_space_search(
    index_path: *const c_char,
    query: *const c_char,
    limit: c_int,
) -> *mut c_char {
    // Validate input pointers
    if index_path.is_null() || query.is_null() {
        return ptr::null_mut();
    }

    // Convert C strings to Rust strings
    let index_path_str = unsafe {
        match CStr::from_ptr(index_path).to_str() {
            Ok(s) => s,
            Err(_) => return ptr::null_mut(),
        }
    };

    let query_str = unsafe {
        match CStr::from_ptr(query).to_str() {
            Ok(s) => s,
            Err(_) => return ptr::null_mut(),
        }
    };

    // Create or open search engine
    let engine = match SearchEngine::new(PathBuf::from(index_path_str)) {
        Ok(e) => e,
        Err(_) => return ptr::null_mut(),
    };

    // Perform search
    let results = match engine.search(query_str, limit as usize) {
        Ok(r) => r,
        Err(_) => return ptr::null_mut(),
    };

    // Serialize results to JSON
    let json = match serde_json::to_string(&results) {
        Ok(j) => j,
        Err(_) => return ptr::null_mut(),
    };

    // Convert to C string
    match CString::new(json) {
        Ok(c_str) => c_str.into_raw(),
        Err(_) => ptr::null_mut(),
    }
}

/// Export a vault to a ZIP file
///
/// # Arguments
/// * `vault_json` - JSON representation of the vault metadata (null-terminated C string)
/// * `notes_json` - JSON array of notes to export (null-terminated C string)
/// * `output_path` - Path where to save the ZIP file (null-terminated C string)
/// * `password` - Password for encrypting the vault (null-terminated C string)
///
/// # Returns
/// 0 on success, negative error code on failure:
/// * -1: Null pointer in one or more parameters
/// * -2: Invalid vault_json string encoding
/// * -3: Invalid notes_json string encoding
/// * -4: Invalid output_path string encoding
/// * -5: Invalid password string encoding
/// * -6: Failed to parse vault JSON
/// * -7: Failed to parse notes JSON
/// * -8: Failed to create encryption manager
/// * -9: Failed to create file storage
/// * -10: Failed to export vault
#[no_mangle]
pub extern "C" fn null_space_export_vault(
    vault_json: *const c_char,
    notes_json: *const c_char,
    output_path: *const c_char,
    password: *const c_char,
) -> c_int {
    // Validate input pointers
    if vault_json.is_null() || notes_json.is_null() || output_path.is_null() || password.is_null() {
        return -1;
    }

    // Convert C strings to Rust strings
    let vault_json_str = unsafe {
        match CStr::from_ptr(vault_json).to_str() {
            Ok(s) => s,
            Err(_) => return -2,
        }
    };

    let notes_json_str = unsafe {
        match CStr::from_ptr(notes_json).to_str() {
            Ok(s) => s,
            Err(_) => return -3,
        }
    };

    let output_path_str = unsafe {
        match CStr::from_ptr(output_path).to_str() {
            Ok(s) => s,
            Err(_) => return -4,
        }
    };

    let password_str = unsafe {
        match CStr::from_ptr(password).to_str() {
            Ok(s) => s,
            Err(_) => return -5,
        }
    };

    // Parse vault metadata
    let vault: crate::models::Vault = match serde_json::from_str(vault_json_str) {
        Ok(v) => v,
        Err(_) => return -6,
    };

    // Parse notes
    let notes: Vec<Note> = match serde_json::from_str(notes_json_str) {
        Ok(n) => n,
        Err(_) => return -7,
    };

    // Create encryption manager
    let manager = match EncryptionManager::new_from_password(password_str, &vault.salt) {
        Ok(m) => m,
        Err(_) => return -8,
    };

    // Create vault manager with temporary storage
    let storage = match FileStorage::new(PathBuf::from(".")) {
        Ok(s) => s,
        Err(_) => return -9,
    };

    let vault_manager = VaultManager::new(storage);

    // Export vault
    match vault_manager.export_vault(&vault, &notes, Path::new(output_path_str), Some(&manager)) {
        Ok(_) => 0,
        Err(_) => -10,
    }
}

/// Import a vault from a ZIP file
///
/// # Arguments
/// * `input_path` - Path to the ZIP file to import (null-terminated C string)
/// * `password` - Password for decrypting the vault (null-terminated C string, currently unused)
///
/// # Returns
/// JSON string with vault metadata and notes, or null on error.
/// The returned string must be freed with null_space_free_string.
///
/// # JSON Format
/// ```json
/// {
///   "vault": { ... },
///   "notes": [ ... ]
/// }
/// ```
///
/// # Note on Encryption
/// Currently, this function imports vaults without decryption.
/// The password parameter is reserved for future use when vault-level encryption is implemented.
/// Individual notes can still be encrypted/decrypted using the vault's salt and the provided password
/// via the null_space_decrypt function after import.
#[no_mangle]
pub extern "C" fn null_space_import_vault(
    input_path: *const c_char,
    password: *const c_char,
) -> *mut c_char {
    // Validate input pointers
    if input_path.is_null() || password.is_null() {
        return ptr::null_mut();
    }

    // Convert C strings to Rust strings
    let input_path_str = unsafe {
        match CStr::from_ptr(input_path).to_str() {
            Ok(s) => s,
            Err(_) => return ptr::null_mut(),
        }
    };

    let _password_str = unsafe {
        match CStr::from_ptr(password).to_str() {
            Ok(s) => s,
            Err(_) => return ptr::null_mut(),
        }
    };

    // Create vault manager with temporary storage
    let storage = match FileStorage::new(PathBuf::from(".")) {
        Ok(s) => s,
        Err(_) => return ptr::null_mut(),
    };

    let vault_manager = VaultManager::new(storage);

    // Import vault without encryption manager initially (we'll create it from vault metadata)
    let (vault, notes) = match vault_manager.import_vault(
        Path::new(input_path_str),
        None, // We can't create the encryption manager without the salt from the vault
        ConflictResolution::KeepBoth,
    ) {
        Ok(result) => result,
        Err(_) => return ptr::null_mut(),
    };

    // Note: In a real implementation, we would need to decrypt notes using the password
    // and the salt from the vault metadata. For now, this assumes notes are not encrypted
    // or returns them as-is.

    // Create result object
    let result = serde_json::json!({
        "vault": vault,
        "notes": notes,
    });

    // Serialize to JSON
    let json = match serde_json::to_string(&result) {
        Ok(j) => j,
        Err(_) => return ptr::null_mut(),
    };

    // Convert to C string
    match CString::new(json) {
        Ok(c_str) => c_str.into_raw(),
        Err(_) => ptr::null_mut(),
    }
}

/// Free a C string allocated by this library
///
/// # Safety
/// The pointer must have been returned by one of the FFI functions in this module.
/// Calling this with any other pointer will result in undefined behavior.
#[no_mangle]
pub extern "C" fn null_space_free_string(ptr: *mut c_char) {
    if !ptr.is_null() {
        unsafe {
            let _ = CString::from_raw(ptr);
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::ffi::CString;

    #[test]
    fn test_init_and_free() {
        let ptr = null_space_init();
        assert!(!ptr.is_null());
        null_space_free(ptr);
    }

    #[test]
    fn test_generate_salt() {
        let salt_ptr = null_space_generate_salt();
        assert!(!salt_ptr.is_null());

        let salt = unsafe { CStr::from_ptr(salt_ptr).to_string_lossy().to_string() };

        assert!(!salt.is_empty());
        null_space_free_string(salt_ptr);
    }

    #[test]
    fn test_encrypt_decrypt() {
        // Generate salt
        let salt_ptr = null_space_generate_salt();
        let salt = unsafe { CStr::from_ptr(salt_ptr) };

        // Prepare test data
        let data = CString::new("Hello, World!").unwrap();
        let password = CString::new("test_password").unwrap();

        // Encrypt
        let encrypted_ptr = null_space_encrypt(data.as_ptr(), password.as_ptr(), salt.as_ptr());
        assert!(!encrypted_ptr.is_null());

        // Decrypt
        let decrypted_ptr = null_space_decrypt(encrypted_ptr, password.as_ptr(), salt.as_ptr());
        assert!(!decrypted_ptr.is_null());

        let decrypted = unsafe { CStr::from_ptr(decrypted_ptr).to_string_lossy().to_string() };

        assert_eq!(decrypted, "Hello, World!");

        // Cleanup
        null_space_free_string(salt_ptr);
        null_space_free_string(encrypted_ptr);
        null_space_free_string(decrypted_ptr);
    }

    #[test]
    fn test_create_note() {
        let title = CString::new("Test Note").unwrap();
        let content = CString::new("This is test content").unwrap();
        let tags = CString::new(r#"["tag1", "tag2"]"#).unwrap();

        let note_ptr = null_space_create_note(title.as_ptr(), content.as_ptr(), tags.as_ptr());
        assert!(!note_ptr.is_null());

        let note_json = unsafe { CStr::from_ptr(note_ptr).to_string_lossy().to_string() };

        // Verify it's valid JSON
        let note: Note = serde_json::from_str(&note_json).unwrap();
        assert_eq!(note.title, "Test Note");
        assert_eq!(note.content, "This is test content");
        assert_eq!(note.tags, vec!["tag1", "tag2"]);

        null_space_free_string(note_ptr);
    }

    #[test]
    fn test_update_note() {
        // First create a note
        let title = CString::new("Original Title").unwrap();
        let content = CString::new("Original content").unwrap();
        let tags = CString::new(r#"["tag1"]"#).unwrap();

        let note_ptr = null_space_create_note(title.as_ptr(), content.as_ptr(), tags.as_ptr());
        assert!(!note_ptr.is_null());

        let note_json = unsafe { CStr::from_ptr(note_ptr).to_string_lossy().to_string() };

        let mut note: Note = serde_json::from_str(&note_json).unwrap();
        let original_version = note.version;

        // Modify the note
        note.title = "Updated Title".to_string();
        note.content = "Updated content".to_string();
        note.tags = vec!["tag1".to_string(), "tag2".to_string()];

        let modified_json = serde_json::to_string(&note).unwrap();
        let modified_json_cstr = CString::new(modified_json).unwrap();

        // Update the note
        let updated_ptr = null_space_update_note(modified_json_cstr.as_ptr());
        assert!(!updated_ptr.is_null());

        let updated_json = unsafe { CStr::from_ptr(updated_ptr).to_string_lossy().to_string() };

        let updated_note: Note = serde_json::from_str(&updated_json).unwrap();

        // Verify the update
        assert_eq!(updated_note.title, "Updated Title");
        assert_eq!(updated_note.content, "Updated content");
        assert_eq!(updated_note.tags, vec!["tag1", "tag2"]);
        assert_eq!(updated_note.version, original_version + 1);
        assert!(updated_note.updated_at > note.created_at);

        // Cleanup
        null_space_free_string(note_ptr);
        null_space_free_string(updated_ptr);
    }

    #[test]
    fn test_null_pointer_handling() {
        // Test that functions handle null pointers gracefully
        assert!(null_space_encrypt(ptr::null(), ptr::null(), ptr::null()).is_null());
        assert!(null_space_decrypt(ptr::null(), ptr::null(), ptr::null()).is_null());
        assert!(null_space_create_note(ptr::null(), ptr::null(), ptr::null()).is_null());
        assert!(null_space_update_note(ptr::null()).is_null());
        assert!(null_space_search(ptr::null(), ptr::null(), 10).is_null());
        assert_eq!(
            null_space_export_vault(ptr::null(), ptr::null(), ptr::null(), ptr::null()),
            -1
        );
        assert!(null_space_import_vault(ptr::null(), ptr::null()).is_null());
    }
}
