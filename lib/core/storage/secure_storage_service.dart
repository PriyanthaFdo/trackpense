
/// Abstract interface for secure storage operations.
/// Used for storing sensitive data like tokens, passwords, etc.
abstract class SecureStorageService {
  /// Saves a secure string value with the given key.
  Future<void> saveString(String key, String value);

  /// Retrieves a secure string value by key.
  Future<String?> getString(String key);

  /// Removes a secure value by key.
  Future<void> remove(String key);

  /// Clears all secure values.
  Future<void> clear();

  /// Checks if a secure key exists.
  Future<bool> containsKey(String key);
}

/// Placeholder implementation of [SecureStorageService].
/// 
/// In a production app, this would use flutter_secure_storage or similar.
/// For now, this is a simple in-memory implementation for development.
class InMemorySecureStorageService implements SecureStorageService {
  final Map<String, String> _storage = {};

  @override
  Future<void> saveString(String key, String value) async {
    _storage[key] = value;
  }

  @override
  Future<String?> getString(String key) async {
    return _storage[key];
  }

  @override
  Future<void> remove(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> clear() async {
    _storage.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    return _storage.containsKey(key);
  }
}
