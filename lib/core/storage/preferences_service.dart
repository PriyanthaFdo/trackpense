import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackpense/core/error/exceptions.dart';

/// Service for managing app preferences using SharedPreferences.
class PreferencesService {
  /// Gets the SharedPreferences instance.
  Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }

  /// Saves a string value with the given key.
  Future<bool> saveString(String key, String value) async {
    try {
      final prefs = await _prefs;
      return await prefs.setString(key, value);
    } catch (e, stackTrace) {
      throw CacheException('Failed to save string for key: $key', e, stackTrace);
    }
  }

  /// Retrieves a string value by key.
  Future<String?> getString(String key) async {
    try {
      final prefs = await _prefs;
      return prefs.getString(key);
    } catch (e, stackTrace) {
      throw CacheException('Failed to read string for key: $key', e, stackTrace);
    }
  }

  /// Saves a boolean value with the given key.
  Future<bool> saveBool(String key, bool value) async {
    try {
      final prefs = await _prefs;
      return await prefs.setBool(key, value);
    } catch (e, stackTrace) {
      throw CacheException('Failed to save bool for key: $key', e, stackTrace);
    }
  }

  /// Retrieves a boolean value by key.
  Future<bool?> getBool(String key) async {
    try {
      final prefs = await _prefs;
      return prefs.getBool(key);
    } catch (e, stackTrace) {
      throw CacheException('Failed to read bool for key: $key', e, stackTrace);
    }
  }

  /// Saves an integer value with the given key.
  Future<bool> saveInt(String key, int value) async {
    try {
      final prefs = await _prefs;
      return await prefs.setInt(key, value);
    } catch (e, stackTrace) {
      throw CacheException('Failed to save int for key: $key', e, stackTrace);
    }
  }

  /// Retrieves an integer value by key.
  Future<int?> getInt(String key) async {
    try {
      final prefs = await _prefs;
      return prefs.getInt(key);
    } catch (e, stackTrace) {
      throw CacheException('Failed to read int for key: $key', e, stackTrace);
    }
  }

  /// Saves a double value with the given key.
  Future<bool> saveDouble(String key, double value) async {
    try {
      final prefs = await _prefs;
      return await prefs.setDouble(key, value);
    } catch (e, stackTrace) {
      throw CacheException('Failed to save double for key: $key', e, stackTrace);
    }
  }

  /// Retrieves a double value by key.
  Future<double?> getDouble(String key) async {
    try {
      final prefs = await _prefs;
      return prefs.getDouble(key);
    } catch (e, stackTrace) {
      throw CacheException('Failed to read double for key: $key', e, stackTrace);
    }
  }

  /// Saves a string list with the given key.
  Future<bool> saveStringList(String key, List<String> value) async {
    try {
      final prefs = await _prefs;
      return await prefs.setStringList(key, value);
    } catch (e, stackTrace) {
      throw CacheException('Failed to save string list for key: $key', e, stackTrace);
    }
  }

  /// Retrieves a string list by key.
  Future<List<String>?> getStringList(String key) async {
    try {
      final prefs = await _prefs;
      return prefs.getStringList(key);
    } catch (e, stackTrace) {
      throw CacheException('Failed to read string list for key: $key', e, stackTrace);
    }
  }

  /// Removes a value by key.
  Future<bool> remove(String key) async {
    try {
      final prefs = await _prefs;
      return await prefs.remove(key);
    } catch (e, stackTrace) {
      throw CacheException('Failed to remove key: $key', e, stackTrace);
    }
  }

  /// Clears all preferences.
  Future<bool> clear() async {
    try {
      final prefs = await _prefs;
      return await prefs.clear();
    } catch (e, stackTrace) {
      throw CacheException('Failed to clear preferences', e, stackTrace);
    }
  }

  /// Checks if a key exists.
  Future<bool> containsKey(String key) async {
    try {
      final prefs = await _prefs;
      return prefs.containsKey(key);
    } catch (e, stackTrace) {
      throw CacheException('Failed to check key: $key', e, stackTrace);
    }
  }

  /// Gets all keys.
  Future<Set<String>> getAllKeys() async {
    try {
      final prefs = await _prefs;
      return prefs.getKeys();
    } catch (e, stackTrace) {
      throw CacheException('Failed to get all keys', e, stackTrace);
    }
  }
}
