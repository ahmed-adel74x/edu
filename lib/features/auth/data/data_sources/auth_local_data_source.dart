import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/storage/token_storage.dart';
import '../../../../shared/models/user.dart';

/// The session the app keeps on the device: the token plus the account.
typedef CachedSession = ({String token, User user});

/// Stores and reads the signed-in session locally.
///
/// The token lives in [TokenStorage]; the account is cached next to it as JSON
/// so the app can start signed in without a request. Nothing here talks to the
/// network or logs the token.
class AuthLocalDataSource {
  AuthLocalDataSource({
    required this.tokenStorage,
    required this.storage,
  });

  /// Where the cached user JSON lives in secure storage.
  static const String userKey = 'cached_user';

  final TokenStorage tokenStorage;
  final FlutterSecureStorage storage;

  /// Keeps [token] and [user] as the current session.
  Future<void> saveSession({required String token, required User user}) async {
    await tokenStorage.save(token);
    await storage.write(key: userKey, value: jsonEncode(user.toJson()));
  }

  /// The stored session, or null when there isn't a complete one.
  ///
  /// Reading the token also fills [TokenStorage]'s cache, so a request made
  /// right after a restore carries the bearer header.
  Future<CachedSession?> readSession() async {
    final token = await tokenStorage.read();
    if (token == null || token.isEmpty) {
      await clearSession();
      return null;
    }

    final raw = await storage.read(key: userKey);
    if (raw == null) {
      await clearSession();
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        await clearSession();
        return null;
      }
      final user = User.fromJson(
        decoded.map((key, item) => MapEntry(key.toString(), item)),
      );
      if (user.role == null) {
        await clearSession();
        return null;
      }
      return (token: token, user: user);
    } on FormatException {
      await clearSession();
      return null;
    }
  }

  /// Forgets the session, in memory and on the device.
  Future<void> clearSession() async {
    await tokenStorage.clear();
    await storage.delete(key: userKey);
  }
}
