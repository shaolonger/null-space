//! Vault management for import/export with conflict detection
//!
//! Handles zip-based vault export/import with UUID-based conflict resolution.

use crate::crypto::EncryptionManager;
use crate::models::{ConflictResolution, Note, Vault, VaultMetadata};
use crate::storage::FileStorage;
use chrono::Utc;
use std::io::{Read, Write};
use std::path::Path;
use thiserror::Error;
use uuid::Uuid;
use zip::{write::FileOptions, ZipArchive, ZipWriter};

#[derive(Error, Debug)]
pub enum VaultError {
    #[error("IO error: {0}")]
    IoError(#[from] std::io::Error),
    #[error("Zip error: {0}")]
    ZipError(#[from] zip::result::ZipError),
    #[error("Serialization error: {0}")]
    SerializationError(#[from] serde_json::Error),
    #[error("Encryption error: {0}")]
    EncryptionError(String),
    #[error("Vault not found: {0}")]
    VaultNotFound(String),
    #[error("Invalid vault format")]
    InvalidFormat,
}

/// Vault manager for export/import operations
pub struct VaultManager {
    storage: FileStorage,
}

impl VaultManager {
    /// Create a new vault manager
    pub fn new(storage: FileStorage) -> Self {
        Self { storage }
    }

    /// Export a vault to a zip file
    pub fn export_vault(
        &self,
        vault: &Vault,
        notes: &[Note],
        output_path: &Path,
        encryption: Option<&EncryptionManager>,
    ) -> Result<(), VaultError> {
        let file = std::fs::File::create(output_path)?;
        let mut zip = ZipWriter::new(file);
        let options = FileOptions::default().compression_method(zip::CompressionMethod::Deflated);

        // Write metadata
        let metadata = VaultMetadata {
            vault: vault.clone(),
            note_count: notes.len(),
            export_date: Utc::now(),
            version: "1.0".to_string(),
        };
        let metadata_json = serde_json::to_string_pretty(&metadata)?;
        zip.start_file("metadata.json", options)?;
        zip.write_all(metadata_json.as_bytes())?;

        // Write notes
        for note in notes {
            let note_json = serde_json::to_string_pretty(note)?;
            let data = if let Some(enc) = encryption {
                enc.encrypt(note_json.as_bytes())
                    .map_err(|e| VaultError::EncryptionError(e.to_string()))?
            } else {
                note_json.into_bytes()
            };

            let filename = format!("notes/{}.json", note.id);
            zip.start_file(filename, options)?;
            zip.write_all(&data)?;
        }

        zip.finish()?;
        Ok(())
    }

    /// Import a vault from a zip file
    pub fn import_vault(
        &self,
        input_path: &Path,
        encryption: Option<&EncryptionManager>,
        _conflict_resolution: ConflictResolution,
    ) -> Result<(Vault, Vec<Note>), VaultError> {
        let file = std::fs::File::open(input_path)?;
        let mut zip = ZipArchive::new(file)?;

        // Read metadata
        let metadata: VaultMetadata = {
            let mut metadata_file = zip.by_name("metadata.json")?;
            let mut metadata_json = String::new();
            metadata_file.read_to_string(&mut metadata_json)?;
            serde_json::from_str(&metadata_json)?
        };

        // Read notes
        let mut notes = Vec::new();
        let zip_len = zip.len();
        for i in 0..zip_len {
            let mut file = zip.by_index(i)?;
            let name = file.name().to_string();

            if name.starts_with("notes/") && name.ends_with(".json") {
                let mut data = Vec::new();
                file.read_to_end(&mut data)?;

                let note_json = if let Some(enc) = encryption {
                    let decrypted = enc
                        .decrypt(&data)
                        .map_err(|e| VaultError::EncryptionError(e.to_string()))?;
                    String::from_utf8(decrypted).map_err(|_| VaultError::InvalidFormat)?
                } else {
                    String::from_utf8(data).map_err(|_| VaultError::InvalidFormat)?
                };

                let note: Note = serde_json::from_str(&note_json)?;
                notes.push(note);
            }
        }

        Ok((metadata.vault, notes))
    }

    /// Detect conflicts when importing notes
    pub fn detect_conflicts(
        &self,
        existing_notes: &[Note],
        imported_notes: &[Note],
    ) -> Vec<(Note, Note)> {
        let mut conflicts = Vec::new();

        for imported in imported_notes {
            if let Some(existing) = existing_notes.iter().find(|n| n.id == imported.id) {
                // Same UUID but different versions - conflict!
                if existing.version != imported.version
                    || existing.updated_at != imported.updated_at
                {
                    conflicts.push((existing.clone(), imported.clone()));
                }
            }
        }

        conflicts
    }

    /// Resolve a conflict based on the resolution strategy
    pub fn resolve_conflict(
        &self,
        existing: Note,
        imported: Note,
        resolution: ConflictResolution,
    ) -> Vec<Note> {
        match resolution {
            ConflictResolution::Overwrite => vec![imported],
            ConflictResolution::KeepBoth => {
                let mut copy = imported.clone();
                copy.id = Uuid::new_v4();
                copy.title = format!("{} (Imported Copy)", copy.title);
                vec![existing, copy]
            }
            ConflictResolution::Skip => vec![existing],
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::crypto::EncryptionManager;
    use tempfile::tempdir;

    #[test]
    fn test_export_import_vault() {
        let temp_dir = tempdir().unwrap();
        let storage = FileStorage::new(temp_dir.path().to_path_buf()).unwrap();
        let manager = VaultManager::new(storage);

        let vault = Vault::new(
            "Test Vault".to_string(),
            "Description".to_string(),
            "salt123".to_string(),
        );

        let notes = vec![
            Note::new("Note 1".to_string(), "Content 1".to_string(), vec![]),
            Note::new("Note 2".to_string(), "Content 2".to_string(), vec![]),
        ];

        let export_path = temp_dir.path().join("export.zip");
        manager
            .export_vault(&vault, &notes, &export_path, None)
            .unwrap();

        let (imported_vault, imported_notes) = manager
            .import_vault(&export_path, None, ConflictResolution::Overwrite)
            .unwrap();

        assert_eq!(imported_vault.id, vault.id);
        assert_eq!(imported_notes.len(), 2);
    }

    #[test]
    fn test_conflict_detection() {
        let temp_dir = tempdir().unwrap();
        let storage = FileStorage::new(temp_dir.path().to_path_buf()).unwrap();
        let manager = VaultManager::new(storage);

        let note1 = Note::new("Note".to_string(), "Content".to_string(), vec![]);

        let mut note2 = note1.clone();
        note2.update("Updated".to_string(), "New Content".to_string(), vec![]);

        let conflicts = manager.detect_conflicts(&[note1], &[note2]);
        assert_eq!(conflicts.len(), 1);
    }
}
