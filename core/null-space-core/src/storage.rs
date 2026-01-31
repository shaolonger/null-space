//! File storage operations
//!
//! Handles reading and writing notes to the filesystem.

use std::fs;
use std::path::{Path, PathBuf};
use thiserror::Error;
use walkdir::WalkDir;

#[derive(Error, Debug)]
pub enum StorageError {
    #[error("IO error: {0}")]
    IoError(#[from] std::io::Error),
    #[error("Path error: {0}")]
    PathError(String),
    #[error("Not found: {0}")]
    NotFound(String),
}

/// File storage manager
pub struct FileStorage {
    base_path: PathBuf,
}

impl FileStorage {
    /// Create a new file storage at the given base path
    pub fn new(base_path: PathBuf) -> Result<Self, StorageError> {
        fs::create_dir_all(&base_path)?;
        Ok(Self { base_path })
    }

    /// Get the full path for a relative path
    pub fn get_path(&self, relative_path: &str) -> PathBuf {
        self.base_path.join(relative_path)
    }

    /// Write data to a file
    pub fn write_file(&self, relative_path: &str, data: &[u8]) -> Result<(), StorageError> {
        let full_path = self.get_path(relative_path);

        if let Some(parent) = full_path.parent() {
            fs::create_dir_all(parent)?;
        }

        fs::write(full_path, data)?;
        Ok(())
    }

    /// Read data from a file
    pub fn read_file(&self, relative_path: &str) -> Result<Vec<u8>, StorageError> {
        let full_path = self.get_path(relative_path);

        if !full_path.exists() {
            return Err(StorageError::NotFound(relative_path.to_string()));
        }

        Ok(fs::read(full_path)?)
    }

    /// Delete a file
    pub fn delete_file(&self, relative_path: &str) -> Result<(), StorageError> {
        let full_path = self.get_path(relative_path);

        if !full_path.exists() {
            return Err(StorageError::NotFound(relative_path.to_string()));
        }

        fs::remove_file(full_path)?;
        Ok(())
    }

    /// Check if a file exists
    pub fn exists(&self, relative_path: &str) -> bool {
        self.get_path(relative_path).exists()
    }

    /// List all files in a directory recursively
    pub fn list_files(&self, relative_path: &str) -> Result<Vec<String>, StorageError> {
        let full_path = self.get_path(relative_path);

        if !full_path.exists() {
            return Ok(Vec::new());
        }

        let mut files = Vec::new();

        for entry in WalkDir::new(full_path).into_iter().filter_map(|e| e.ok()) {
            if entry.file_type().is_file() {
                let path = entry.path();
                if let Ok(relative) = path.strip_prefix(&self.base_path) {
                    if let Some(path_str) = relative.to_str() {
                        files.push(path_str.to_string());
                    }
                }
            }
        }

        Ok(files)
    }

    /// Create a directory
    pub fn create_dir(&self, relative_path: &str) -> Result<(), StorageError> {
        let full_path = self.get_path(relative_path);
        fs::create_dir_all(full_path)?;
        Ok(())
    }

    /// Get the base path
    pub fn base_path(&self) -> &Path {
        &self.base_path
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::tempdir;

    #[test]
    fn test_file_operations() {
        let temp_dir = tempdir().unwrap();
        let storage = FileStorage::new(temp_dir.path().to_path_buf()).unwrap();

        let test_data = b"Hello, World!";
        storage.write_file("test.txt", test_data).unwrap();

        assert!(storage.exists("test.txt"));

        let read_data = storage.read_file("test.txt").unwrap();
        assert_eq!(test_data, read_data.as_slice());

        storage.delete_file("test.txt").unwrap();
        assert!(!storage.exists("test.txt"));
    }

    #[test]
    fn test_nested_files() {
        let temp_dir = tempdir().unwrap();
        let storage = FileStorage::new(temp_dir.path().to_path_buf()).unwrap();

        storage
            .write_file("folder/nested/file.txt", b"nested")
            .unwrap();
        assert!(storage.exists("folder/nested/file.txt"));

        let files = storage.list_files("").unwrap();
        assert_eq!(files.len(), 1);
        assert!(files[0].contains("file.txt"));
    }
}
