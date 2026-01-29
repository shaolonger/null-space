//! Data models for notes, tags, and vaults

use serde::{Deserialize, Serialize};
use uuid::Uuid;
use chrono::{DateTime, Utc};

/// A note in the system
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Note {
    /// Unique identifier for the note
    pub id: Uuid,
    /// Title of the note
    pub title: String,
    /// Markdown content
    pub content: String,
    /// Nested tags (e.g., "work/project/urgent")
    pub tags: Vec<String>,
    /// Creation timestamp
    pub created_at: DateTime<Utc>,
    /// Last update timestamp
    pub updated_at: DateTime<Utc>,
    /// Version for conflict detection
    pub version: u64,
}

impl Note {
    /// Create a new note
    pub fn new(title: String, content: String, tags: Vec<String>) -> Self {
        let now = Utc::now();
        Self {
            id: Uuid::new_v4(),
            title,
            content,
            tags,
            created_at: now,
            updated_at: now,
            version: 1,
        }
    }

    /// Update the note content and increment version
    pub fn update(&mut self, title: String, content: String, tags: Vec<String>) {
        self.title = title;
        self.content = content;
        self.tags = tags;
        self.updated_at = Utc::now();
        self.version += 1;
    }
}

/// A tag with hierarchical structure
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Tag {
    /// Full path of the tag (e.g., "work/project/urgent")
    pub path: String,
    /// Display name of this level
    pub name: String,
    /// Parent tag path (if any)
    pub parent: Option<String>,
}

impl Tag {
    /// Parse a tag path into a Tag structure
    pub fn from_path(path: &str) -> Self {
        let parts: Vec<&str> = path.split('/').collect();
        let name = parts.last().unwrap_or(&"").to_string();
        let parent = if parts.len() > 1 {
            Some(parts[..parts.len() - 1].join("/"))
        } else {
            None
        };

        Self {
            path: path.to_string(),
            name,
            parent,
        }
    }

    /// Get all ancestor paths
    pub fn ancestors(&self) -> Vec<String> {
        let mut ancestors = Vec::new();
        let parts: Vec<&str> = self.path.split('/').collect();
        
        for i in 1..parts.len() {
            ancestors.push(parts[..i].join("/"));
        }
        
        ancestors
    }
}

/// A vault containing notes
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Vault {
    /// Unique identifier for the vault
    pub id: Uuid,
    /// Name of the vault
    pub name: String,
    /// Description
    pub description: String,
    /// Creation timestamp
    pub created_at: DateTime<Utc>,
    /// Last update timestamp
    pub updated_at: DateTime<Utc>,
    /// Encryption salt
    pub salt: String,
}

impl Vault {
    /// Create a new vault
    pub fn new(name: String, description: String, salt: String) -> Self {
        let now = Utc::now();
        Self {
            id: Uuid::new_v4(),
            name,
            description,
            created_at: now,
            updated_at: now,
            salt,
        }
    }
}

/// Metadata for vault export/import
#[derive(Debug, Serialize, Deserialize)]
pub struct VaultMetadata {
    pub vault: Vault,
    pub note_count: usize,
    pub export_date: DateTime<Utc>,
    pub version: String,
}

/// Conflict resolution strategy
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ConflictResolution {
    /// Overwrite existing note
    Overwrite,
    /// Keep both (create a copy)
    KeepBoth,
    /// Skip import
    Skip,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_note_creation() {
        let note = Note::new(
            "Test Note".to_string(),
            "Content".to_string(),
            vec!["tag1".to_string()],
        );
        assert_eq!(note.version, 1);
        assert_eq!(note.title, "Test Note");
    }

    #[test]
    fn test_note_update() {
        let mut note = Note::new(
            "Test".to_string(),
            "Content".to_string(),
            vec![],
        );
        let old_version = note.version;
        
        note.update("Updated".to_string(), "New Content".to_string(), vec![]);
        
        assert_eq!(note.version, old_version + 1);
        assert_eq!(note.title, "Updated");
    }

    #[test]
    fn test_tag_parsing() {
        let tag = Tag::from_path("work/project/urgent");
        assert_eq!(tag.name, "urgent");
        assert_eq!(tag.parent, Some("work/project".to_string()));
    }

    #[test]
    fn test_tag_ancestors() {
        let tag = Tag::from_path("work/project/urgent");
        let ancestors = tag.ancestors();
        assert_eq!(ancestors.len(), 2);
        assert_eq!(ancestors[0], "work");
        assert_eq!(ancestors[1], "work/project");
    }
}
