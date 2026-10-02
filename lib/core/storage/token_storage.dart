import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keeps the Sanctum token in the platform's secure storage.
///
/// The token is cached in memory after the first read, so the interceptors can
/// ask for it on every request without a platform round-trip each time. The value
/// is never logged.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  /// Where the token lives in secure storage.
  static const String storageKey = 'sanctum_token';

  final FlutterSecureStorage _storage;

  String? _cached;
  bool _loaded = false;

  /// The stored token, or null. Reads secure storage only once.
  Future<String?> read() async {
    if (_loaded) return _cached;
    _cached = await _storage.read(key: storageKey);
    _loaded = true;
    return _cached;
  }

  /// Stores [token] and remembers it in memory.
  Future<void> save(String token) async {
    _cached = token;
    _loaded = true;
    await _storage.write(key: storageKey, value: token);
  }

  /// Forgets the token, in memory and on the device.
  Future<void> clear() async {
    _cached = null;
    _loaded = true;
    await _storage.delete(key: storageKey);
  }

  /// Whether a token is currently held — reflects the in-memory cache, so it is
  /// only accurate after a [read] / [save] / [clear].
  bool get hasToken => _cached != null && _cached!.isNotEmpty;
}
