/// Unit tests for FileStorage
/// 
/// Tests the platform-agnostic file storage abstraction to ensure
/// proper file operations across different scenarios.

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:null_space_app/services/file_storage.dart';

void main() {
  group('FileStorage', () {
    late FileStorage storage;
    late Directory tempDir;

    setUp(() async {
      // Create a temporary directory for testing
      tempDir = await Directory.systemTemp.createTemp('file_storage_test_');
      storage = FileStorage.withBasePath(tempDir.path);
    });

    tearDown(() async {
      // Clean up the temporary directory
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('writeFile should create file with correct content', () async {
      final data = [1, 2, 3, 4, 5];
      await storage.writeFile('test.txt', data);

      final file = File('${tempDir.path}/test.txt');
      expect(await file.exists(), isTrue);
      expect(await file.readAsBytes(), equals(data));
    });

    test('writeFile should create parent directories', () async {
      final data = [1, 2, 3];
      await storage.writeFile('dir1/dir2/test.txt', data);

      final file = File('${tempDir.path}/dir1/dir2/test.txt');
      expect(await file.exists(), isTrue);
      expect(await file.readAsBytes(), equals(data));
    });

    test('readFile should return correct content', () async {
      final data = [10, 20, 30];
      await storage.writeFile('test.txt', data);

      final readData = await storage.readFile('test.txt');
      expect(readData, equals(data));
    });

    test('readFile should throw if file does not exist', () async {
      expect(
        () => storage.readFile('nonexistent.txt'),
        throwsA(isA<FileStorageException>()),
      );
    });

    test('deleteFile should remove file', () async {
      await storage.writeFile('test.txt', [1, 2, 3]);
      expect(await storage.exists('test.txt'), isTrue);

      await storage.deleteFile('test.txt');
      expect(await storage.exists('test.txt'), isFalse);
    });

    test('deleteFile should not throw if file does not exist', () async {
      expect(() => storage.deleteFile('nonexistent.txt'), returnsNormally);
    });

    test('exists should return true for existing file', () async {
      await storage.writeFile('test.txt', [1, 2, 3]);
      expect(await storage.exists('test.txt'), isTrue);
    });

    test('exists should return false for non-existing file', () async {
      expect(await storage.exists('nonexistent.txt'), isFalse);
    });

    test('listFiles should return all files in directory', () async {
      await storage.writeFile('dir/file1.txt', [1]);
      await storage.writeFile('dir/file2.txt', [2]);
      await storage.writeFile('dir/file3.txt', [3]);

      final files = await storage.listFiles('dir');
      expect(files.length, equals(3));
      expect(files, contains('dir/file1.txt'));
      expect(files, contains('dir/file2.txt'));
      expect(files, contains('dir/file3.txt'));
    });

    test('listFiles should return empty list for non-existing directory',
        () async {
      final files = await storage.listFiles('nonexistent');
      expect(files, isEmpty);
    });

    test('listFiles should not return subdirectories', () async {
      await storage.writeFile('dir/file.txt', [1]);
      await storage.writeFile('dir/subdir/file.txt', [2]);

      final files = await storage.listFiles('dir');
      expect(files.length, equals(1));
      expect(files.first, equals('dir/file.txt'));
    });

    test('deleteDirectory should remove directory and contents', () async {
      await storage.writeFile('dir/file1.txt', [1]);
      await storage.writeFile('dir/file2.txt', [2]);

      await storage.deleteDirectory('dir');

      expect(await storage.exists('dir/file1.txt'), isFalse);
      expect(await storage.exists('dir/file2.txt'), isFalse);
    });

    test('deleteDirectory should not throw if directory does not exist',
        () async {
      expect(() => storage.deleteDirectory('nonexistent'), returnsNormally);
    });

    test('createDirectory should create directory', () async {
      await storage.createDirectory('newdir');

      final dir = Directory('${tempDir.path}/newdir');
      expect(await dir.exists(), isTrue);
    });

    test('createDirectory should create parent directories', () async {
      await storage.createDirectory('dir1/dir2/dir3');

      final dir = Directory('${tempDir.path}/dir1/dir2/dir3');
      expect(await dir.exists(), isTrue);
    });

    test('createDirectory should not throw if directory exists', () async {
      await storage.createDirectory('dir');
      expect(() => storage.createDirectory('dir'), returnsNormally);
    });

    test('overwriting file should work correctly', () async {
      await storage.writeFile('test.txt', [1, 2, 3]);
      expect(await storage.readFile('test.txt'), equals([1, 2, 3]));

      await storage.writeFile('test.txt', [4, 5, 6]);
      expect(await storage.readFile('test.txt'), equals([4, 5, 6]));
    });
  });

  group('FileStorageException', () {
    test('toString should include message', () {
      final exception = FileStorageException('Test error');
      expect(exception.toString(), contains('Test error'));
    });

    test('toString should include path if provided', () {
      final exception =
          FileStorageException('Test error', path: 'test/path.txt');
      final str = exception.toString();
      expect(str, contains('Test error'));
      expect(str, contains('test/path.txt'));
    });

    test('toString should include cause if provided', () {
      final cause = Exception('Underlying error');
      final exception =
          FileStorageException('Test error', cause: cause);
      final str = exception.toString();
      expect(str, contains('Test error'));
      expect(str, contains('Caused by'));
    });
  });
}
