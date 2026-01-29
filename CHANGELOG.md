# Changelog

All notable changes to the Null Space project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial scaffold for secure, local-first note-taking application
- Rust core library (`null-space-core`) with:
  - AES-256-GCM encryption module
  - Tantivy full-text search integration
  - File I/O operations
  - Vault import/export with UUID-based conflict detection
  - Data models for Notes, Vaults, and Tags
- Flutter UI application with:
  - Provider-based state management
  - Basic screens (Home, Notes, Search, Vault)
  - FFI bridge stub for Rust interop
  - Cross-platform support (Windows, macOS, Android, iOS)
- Comprehensive documentation:
  - README with feature overview and usage guide
  - ARCHITECTURE.md with design principles
  - API.md with detailed API documentation
  - DEVELOPMENT.md with development workflow
- Test suite with 12 passing tests
- MIT License
- Monorepo structure with Cargo workspace

## [0.1.0] - 2026-01-29

### Added
- Initial project scaffold
- Basic project structure
