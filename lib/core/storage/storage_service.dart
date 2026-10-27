import 'dart:io';
import 'package:trackpense/core/error/exceptions.dart';

/// Abstract interface for storage operations.
abstract class StorageService {
  /// Saves a string value with the given key.
  Future<void> saveString(String key, String value);

  /// Retrieves a string value by key.
  Future<String?> getString(String key);

  /// Saves a boolean value with the given key.
  Future<void> saveBool(String key, bool value);

  /// Retrieves a boolean value by key.
  Future<bool?> getBool(String key);

  /// Saves an integer value with the given key.
  Future<void> saveInt(String key, int value);

  /// Retrieves an integer value by key.
  Future<int?> getInt(String key);

  /// Saves a double value with the given key.
  Future<void> saveDouble(String key, double value);

  /// Retrieves a double value by key.
  Future<double?> getDouble(String key);

  /// Removes a value by key.
  Future<void> remove(String key);

  /// Clears all stored values.
  Future<void> clear();

  /// Checks if a key exists.
  Future<bool> containsKey(String key);
}

/// Implementation of [StorageService] using file system.
class FileStorageService implements StorageService {
  FileStorageService(this._storagePath);

  final String _storagePath;

  File _getFile(String key) {
    return File('$_storagePath/$key');
  }

  @override
  Future<void> saveString(String key, String value) async {
    try {
      final file = _getFile(key);
      await file.parent.create(recursive: true);
      await file.writeAsString(value);
    } catch (e, stackTrace) {
      throw FileSystemException('Failed to save string for key: $key', e, stackTrace);
    }
  }

  @override
  Future<String?> getString(String key) async {
    try {
      final file = _getFile(key);
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e, stackTrace) {
      throw FileSystemException('Failed to read string for key: $key', e, stackTrace);
    }
  }

  @override
  Future<void> saveBool(String key, bool value) async {
    await saveString(key, value.toString());
  }

  @override
  Future<bool?> getBool(String key) async {
    final value = await getString(key);
    if (value == null) return null;
    return value.toLowerCase() == 'true';
  }

  @override
  Future<void> saveInt(String key, int value) async {
    await saveString(key, value.toString());
  }

  @override
  Future<int?> getInt(String key) async {
    final value = await getString(key);
    if (value == null) return null;
    return int.tryParse(value);
  }

  @override
  Future<void> saveDouble(String key, double value) async {
    await saveString(key, value.toString());
  }

  @override
  Future<double?> getDouble(String key) async {
    final value = await getString(key);
    if (value == null) return null;
    return double.tryParse(value);
  }

  @override
  Future<void> remove(String key) async {
    try {
      final file = _getFile(key);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e, stackTrace) {
      throw FileSystemException('Failed to remove key: $key', e, stackTrace);
    }
  }

  @override
  Future<void> clear() async {
    try {
      final directory = Directory(_storagePath);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    } catch (e, stackTrace) {
      throw FileSystemException('Failed to clear storage', e, stackTrace);
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      final file = _getFile(key);
      return await file.exists();
    } catch (e, stackTrace) {
      throw FileSystemException('Failed to check key: $key', e, stackTrace);
    }
  }
}
