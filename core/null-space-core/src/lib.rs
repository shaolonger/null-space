//! Null Space Core Library
//!
//! This is the core Rust library that handles:
//! - AES-256-GCM encryption/decryption
//! - Tantivy full-text search indexing
//! - File I/O operations
//! - Vault management
//! - UUID-based conflict detection

pub mod crypto;
pub mod ffi;
pub mod models;
pub mod search;
pub mod storage;
pub mod vault;

pub use crypto::{EncryptionError, EncryptionManager};
pub use search::{SearchEngine, SearchError};
pub use storage::{FileStorage, StorageError};
pub use vault::{VaultError, VaultManager};

/// Result type for the library
pub type Result<T> = std::result::Result<T, Box<dyn std::error::Error + Send + Sync>>;

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_library_loads() {
        // Basic sanity test
        assert!(true);
    }
}
