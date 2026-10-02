import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// An in-memory stand-in for the platform's secure storage.
///
/// [FlutterSecureStorage]'s methods are overridden, so nothing touches a platform
/// channel: a test fully controls what is stored and can [reads] to prove
/// `TokenStorage` serves a cached token without a second lookup.
class FakeSecureStorage extends FlutterSecureStorage {
  FakeSecureStorage([Map<String, String>? initial]) : data = {...?initial};

  /// The in-memory store, exposed so a test can inspect it directly.
  final Map<String, String> data;

  /// How many times [read] has been awaited.
  int reads = 0;

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    reads++;
    return data[key];
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      data.remove(key);
    } else {
      data[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    data.remove(key);
  }
}
