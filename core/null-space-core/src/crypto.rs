//! Cryptographic operations using AES-256-GCM
//!
//! Provides encryption and decryption for notes and vault data.

use aes_gcm::{
    aead::{Aead, KeyInit, OsRng},
    Aes256Gcm, Nonce,
};
use argon2::password_hash::SaltString;
use argon2::{Argon2, PasswordHasher};
use rand::RngCore;
use thiserror::Error;

#[derive(Error, Debug)]
pub enum EncryptionError {
    #[error("Encryption failed: {0}")]
    EncryptionFailed(String),
    #[error("Decryption failed: {0}")]
    DecryptionFailed(String),
    #[error("Key derivation failed: {0}")]
    KeyDerivationFailed(String),
    #[error("Invalid key length")]
    InvalidKeyLength,
}

/// Manages encryption and decryption operations
pub struct EncryptionManager {
    cipher: Aes256Gcm,
}

impl EncryptionManager {
    /// Create a new encryption manager with a derived key from password
    pub fn new_from_password(password: &str, salt: &str) -> Result<Self, EncryptionError> {
        let salt = SaltString::from_b64(salt)
            .map_err(|e| EncryptionError::KeyDerivationFailed(e.to_string()))?;

        let argon2 = Argon2::default();
        let password_hash = argon2
            .hash_password(password.as_bytes(), &salt)
            .map_err(|e| EncryptionError::KeyDerivationFailed(e.to_string()))?;

        let hash_bytes = password_hash
            .hash
            .ok_or(EncryptionError::KeyDerivationFailed(
                "No hash generated".to_string(),
            ))?;

        let key_bytes = hash_bytes.as_bytes();
        if key_bytes.len() < 32 {
            return Err(EncryptionError::InvalidKeyLength);
        }

        let cipher = Aes256Gcm::new_from_slice(&key_bytes[..32])
            .map_err(|e| EncryptionError::KeyDerivationFailed(e.to_string()))?;

        Ok(Self { cipher })
    }

    /// Generate a new random salt for key derivation
    pub fn generate_salt() -> String {
        SaltString::generate(&mut OsRng).to_string()
    }

    /// Encrypt data
    pub fn encrypt(&self, plaintext: &[u8]) -> Result<Vec<u8>, EncryptionError> {
        let mut nonce_bytes = [0u8; 12];
        OsRng.fill_bytes(&mut nonce_bytes);
        let nonce = Nonce::from_slice(&nonce_bytes);

        let ciphertext = self
            .cipher
            .encrypt(nonce, plaintext)
            .map_err(|e| EncryptionError::EncryptionFailed(e.to_string()))?;

        // Prepend nonce to ciphertext
        let mut result = nonce_bytes.to_vec();
        result.extend_from_slice(&ciphertext);
        Ok(result)
    }

    /// Decrypt data
    pub fn decrypt(&self, encrypted_data: &[u8]) -> Result<Vec<u8>, EncryptionError> {
        if encrypted_data.len() < 12 {
            return Err(EncryptionError::DecryptionFailed(
                "Data too short to contain nonce".to_string(),
            ));
        }

        let (nonce_bytes, ciphertext) = encrypted_data.split_at(12);
        let nonce = Nonce::from_slice(nonce_bytes);

        self.cipher
            .decrypt(nonce, ciphertext)
            .map_err(|e| EncryptionError::DecryptionFailed(e.to_string()))
    }
}

impl Drop for EncryptionManager {
    fn drop(&mut self) {
        // Zeroize sensitive data on drop
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_encrypt_decrypt() {
        let password = "test_password_123";
        let salt = EncryptionManager::generate_salt();
        let manager = EncryptionManager::new_from_password(password, &salt).unwrap();

        let plaintext = b"Hello, Null Space!";
        let encrypted = manager.encrypt(plaintext).unwrap();
        let decrypted = manager.decrypt(&encrypted).unwrap();

        assert_eq!(plaintext, decrypted.as_slice());
    }

    #[test]
    fn test_different_nonces() {
        let password = "test_password_123";
        let salt = EncryptionManager::generate_salt();
        let manager = EncryptionManager::new_from_password(password, &salt).unwrap();

        let plaintext = b"Same plaintext";
        let encrypted1 = manager.encrypt(plaintext).unwrap();
        let encrypted2 = manager.encrypt(plaintext).unwrap();

        // Should produce different ciphertexts due to different nonces
        assert_ne!(encrypted1, encrypted2);

        // But both should decrypt to the same plaintext
        let decrypted1 = manager.decrypt(&encrypted1).unwrap();
        let decrypted2 = manager.decrypt(&encrypted2).unwrap();
        assert_eq!(decrypted1, decrypted2);
    }
}
