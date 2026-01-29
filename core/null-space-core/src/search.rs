//! Full-text search using Tantivy
//!
//! Provides indexing and searching for notes with Markdown support.

use tantivy::{
    collector::TopDocs,
    doc,
    query::QueryParser,
    schema::*,
    Index, IndexWriter, IndexReader, TantivyDocument,
};
use thiserror::Error;
use std::path::PathBuf;

#[derive(Error, Debug)]
pub enum SearchError {
    #[error("Index error: {0}")]
    IndexError(String),
    #[error("Search error: {0}")]
    SearchFailed(String),
    #[error("Parse error: {0}")]
    ParseError(String),
}

/// Search engine for notes
pub struct SearchEngine {
    index: Index,
    schema: Schema,
}

impl SearchEngine {
    /// Create a new search engine with an index at the given path
    pub fn new(index_path: PathBuf) -> Result<Self, SearchError> {
        let mut schema_builder = Schema::builder();
        
        schema_builder.add_text_field("id", TEXT | STORED);
        schema_builder.add_text_field("title", TEXT | STORED);
        schema_builder.add_text_field("content", TEXT);
        schema_builder.add_text_field("tags", TEXT | STORED);
        schema_builder.add_date_field("created_at", INDEXED | STORED);
        schema_builder.add_date_field("updated_at", INDEXED | STORED);
        
        let schema = schema_builder.build();
        
        std::fs::create_dir_all(&index_path)
            .map_err(|e| SearchError::IndexError(e.to_string()))?;
        
        let index = Index::create_in_dir(&index_path, schema.clone())
            .or_else(|_| Index::open_in_dir(&index_path))
            .map_err(|e| SearchError::IndexError(e.to_string()))?;
        
        Ok(Self { index, schema })
    }

    /// Get an index writer
    pub fn get_writer(&self) -> Result<IndexWriter, SearchError> {
        self.index
            .writer(50_000_000)
            .map_err(|e| SearchError::IndexError(e.to_string()))
    }

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
    ) -> Result<(), SearchError> {
        let id_field = self.schema.get_field("id").unwrap();
        let title_field = self.schema.get_field("title").unwrap();
        let content_field = self.schema.get_field("content").unwrap();
        let tags_field = self.schema.get_field("tags").unwrap();
        let created_field = self.schema.get_field("created_at").unwrap();
        let updated_field = self.schema.get_field("updated_at").unwrap();

        let tags_str = tags.join(" ");

        let doc = doc!(
            id_field => id,
            title_field => title,
            content_field => content,
            tags_field => tags_str,
            created_field => tantivy::DateTime::from_timestamp_secs(created_at),
            updated_field => tantivy::DateTime::from_timestamp_secs(updated_at),
        );

        writer
            .add_document(doc)
            .map_err(|e| SearchError::IndexError(e.to_string()))?;

        Ok(())
    }

    /// Commit changes to the index
    pub fn commit(&self, writer: &mut IndexWriter) -> Result<(), SearchError> {
        writer
            .commit()
            .map_err(|e| SearchError::IndexError(e.to_string()))?;
        Ok(())
    }

    /// Search for notes
    pub fn search(&self, query_str: &str, limit: usize) -> Result<Vec<(f32, String)>, SearchError> {
        let reader: IndexReader = self.index
            .reader()
            .map_err(|e| SearchError::IndexError(e.to_string()))?;

        let searcher = reader.searcher();

        let title_field = self.schema.get_field("title").unwrap();
        let content_field = self.schema.get_field("content").unwrap();
        let tags_field = self.schema.get_field("tags").unwrap();

        let query_parser = QueryParser::for_index(
            &self.index,
            vec![title_field, content_field, tags_field],
        );

        let query = query_parser
            .parse_query(query_str)
            .map_err(|e| SearchError::ParseError(e.to_string()))?;

        let top_docs = searcher
            .search(&query, &TopDocs::with_limit(limit))
            .map_err(|e| SearchError::SearchFailed(e.to_string()))?;

        let id_field = self.schema.get_field("id").unwrap();
        let mut results = Vec::new();

        for (score, doc_address) in top_docs {
            let retrieved_doc: TantivyDocument = searcher
                .doc(doc_address)
                .map_err(|e| SearchError::SearchFailed(e.to_string()))?;

            if let Some(id_value) = retrieved_doc.get_first(id_field) {
                if let Some(id_str) = id_value.as_str() {
                    results.push((score, id_str.to_string()));
                }
            }
        }

        Ok(results)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::tempdir;

    #[test]
    fn test_search_engine() {
        let temp_dir = tempdir().unwrap();
        let index_path = temp_dir.path().to_path_buf();

        let engine = SearchEngine::new(index_path).unwrap();
        let mut writer = engine.get_writer().unwrap();

        engine.index_note(
            &mut writer,
            "note-1",
            "My First Note",
            "This is the content of my first note",
            &["personal".to_string(), "test".to_string()],
            1640000000,
            1640000000,
        ).unwrap();

        engine.commit(&mut writer).unwrap();

        let results = engine.search("first", 10).unwrap();
        assert_eq!(results.len(), 1);
        assert_eq!(results[0].1, "note-1");
    }
}
