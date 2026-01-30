/// FileStorage helper for platform-agnostic file operations
/// 
/// This class abstracts file I/O operations to work across different platforms
/// (Android, iOS, macOS, Windows, Linux). It uses path_provider to get the
/// appropriate base directory for each platform.

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Exception thrown when file storage operations fail
class FileStorageException implements Exception {
  final String message;
  final String? path;
  final Object? cause;

  FileStorageException(this.message, {this.path, this.cause});

  @override
  String toString() {
    final buffer = StringBuffer('FileStorageException: $message');
    if (path != null) {
      buffer.write(' (path: $path)');
    }
    if (cause != null) {
      buffer.write(' - Caused by: $cause');
    }
    return buffer.toString();
  }
}

/// Platform-agnostic file storage abstraction
/// 
/// This class provides a simple interface for reading, writing, and managing
/// files on disk. It handles path resolution and error handling consistently
/// across all platforms.
/// 
/// Example usage:
/// ```dart
/// final storage = await FileStorage.create();
/// await storage.writeFile('notes/note1.json', utf8.encode('{"title": "Test"}'));
/// final data = await storage.readFile('notes/note1.json');
/// ```
class FileStorage {
  final String basePath;

  FileStorage._(this.basePath);

  /// Create a FileStorage instance using the app's documents directory
  /// 
  /// This factory method initializes FileStorage with the appropriate base
  /// path for the current platform. On mobile devices, this uses the app's
  /// documents directory. On desktop, it uses the application support directory.
  static Future<FileStorage> create() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      return FileStorage._(directory.path);
    } catch (e) {
      throw FileStorageException(
        'Failed to get application documents directory',
        cause: e,
      );
    }
  }

  /// Create a FileStorage instance with a custom base path
  /// 
  /// This is useful for testing or when you need to use a specific directory.
  factory FileStorage.withBasePath(String basePath) {
    return FileStorage._(basePath);
  }

  /// Get the absolute path for a relative path
  String _getAbsolutePath(String relativePath) {
    return path.join(basePath, relativePath);
  }

  /// Write data to a file
  /// 
  /// Creates parent directories if they don't exist. Overwrites existing files.
  /// 
  /// [relativePath] - Path relative to the base directory
  /// [data] - Binary data to write
  /// 
  /// Throws [FileStorageException] if the operation fails.
  Future<void> writeFile(String relativePath, List<int> data) async {
    final absolutePath = _getAbsolutePath(relativePath);
    try {
      final file = File(absolutePath);
      
      // Create parent directories if they don't exist
      final parentDir = file.parent;
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
      }
      
      await file.writeAsBytes(data);
    } catch (e) {
      throw FileStorageException(
        'Failed to write file',
        path: relativePath,
        cause: e,
      );
    }
  }

  /// Read data from a file
  /// 
  /// [relativePath] - Path relative to the base directory
  /// 
  /// Returns the file contents as binary data.
  /// 
  /// Throws [FileStorageException] if the file doesn't exist or can't be read.
  Future<List<int>> readFile(String relativePath) async {
    final absolutePath = _getAbsolutePath(relativePath);
    try {
      final file = File(absolutePath);
      
      if (!await file.exists()) {
        throw FileStorageException(
          'File does not exist',
          path: relativePath,
        );
      }
      
      return await file.readAsBytes();
    } catch (e) {
      if (e is FileStorageException) rethrow;
      throw FileStorageException(
        'Failed to read file',
        path: relativePath,
        cause: e,
      );
    }
  }

  /// Delete a file
  /// 
  /// [relativePath] - Path relative to the base directory
  /// 
  /// Throws [FileStorageException] if the operation fails.
  /// Does not throw if the file doesn't exist.
  Future<void> deleteFile(String relativePath) async {
    final absolutePath = _getAbsolutePath(relativePath);
    try {
      final file = File(absolutePath);
      
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw FileStorageException(
        'Failed to delete file',
        path: relativePath,
        cause: e,
      );
    }
  }

  /// Check if a file exists
  /// 
  /// [relativePath] - Path relative to the base directory
  /// 
  /// Returns true if the file exists, false otherwise.
  Future<bool> exists(String relativePath) async {
    final absolutePath = _getAbsolutePath(relativePath);
    try {
      final file = File(absolutePath);
      return await file.exists();
    } catch (e) {
      throw FileStorageException(
        'Failed to check file existence',
        path: relativePath,
        cause: e,
      );
    }
  }

  /// List all files in a directory
  /// 
  /// [directory] - Directory path relative to the base directory
  /// 
  /// Returns a list of file paths relative to the base directory.
  /// Returns an empty list if the directory doesn't exist.
  /// 
  /// Throws [FileStorageException] if the operation fails.
  Future<List<String>> listFiles(String directory) async {
    final absolutePath = _getAbsolutePath(directory);
    try {
      final dir = Directory(absolutePath);
      
      if (!await dir.exists()) {
        return [];
      }
      
      final files = <String>[];
      await for (final entity in dir.list()) {
        if (entity is File) {
          // Return path relative to base directory
          final relativePath = path.relative(entity.path, from: basePath);
          files.add(relativePath);
        }
      }
      
      return files;
    } catch (e) {
      throw FileStorageException(
        'Failed to list files',
        path: directory,
        cause: e,
      );
    }
  }

  /// Delete a directory and all its contents
  /// 
  /// [directory] - Directory path relative to the base directory
  /// 
  /// Throws [FileStorageException] if the operation fails.
  /// Does not throw if the directory doesn't exist.
  Future<void> deleteDirectory(String directory) async {
    final absolutePath = _getAbsolutePath(directory);
    try {
      final dir = Directory(absolutePath);
      
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      throw FileStorageException(
        'Failed to delete directory',
        path: directory,
        cause: e,
      );
    }
  }

  /// Create a directory
  /// 
  /// [directory] - Directory path relative to the base directory
  /// 
  /// Creates parent directories if they don't exist.
  /// Does nothing if the directory already exists.
  /// 
  /// Throws [FileStorageException] if the operation fails.
  Future<void> createDirectory(String directory) async {
    final absolutePath = _getAbsolutePath(directory);
    try {
      final dir = Directory(absolutePath);
      
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    } catch (e) {
      throw FileStorageException(
        'Failed to create directory',
        path: directory,
        cause: e,
      );
    }
  }
}
