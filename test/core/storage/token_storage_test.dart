import 'package:flutter_test/flutter_test.dart';
import 'package:test_edu/core/storage/token_storage.dart';

import '../../helpers/fake_secure_storage.dart';

void main() {
  late FakeSecureStorage storage;
  late TokenStorage tokenStorage;

  setUp(() {
    storage = FakeSecureStorage();
    tokenStorage = TokenStorage(storage: storage);
  });

  test('saves, reads and clears the token', () async {
    expect(await tokenStorage.read(), isNull);
    expect(tokenStorage.hasToken, isFalse);

    await tokenStorage.save('abc.def');
    expect(await tokenStorage.read(), 'abc.def');
    expect(storage.data[TokenStorage.storageKey], 'abc.def');
    expect(tokenStorage.hasToken, isTrue);

    await tokenStorage.clear();
    expect(await tokenStorage.read(), isNull);
    expect(storage.data, isEmpty);
    expect(tokenStorage.hasToken, isFalse);
  });

  test('reads the stored token only once', () async {
    storage.data[TokenStorage.storageKey] = 'xyz';

    expect(await tokenStorage.read(), 'xyz');
    expect(await tokenStorage.read(), 'xyz');
    expect(storage.reads, 1);
  });

  test('serves from cache, so a request does not hit secure storage', () async {
    await tokenStorage.save('abc');
    storage.reads = 0;

    await tokenStorage.read();
    await tokenStorage.read();
    await tokenStorage.read();

    expect(storage.reads, 0);
  });

  test('picks up a token that was stored before the cache was filled', () async {
    storage.data[TokenStorage.storageKey] = 'from-device';

    expect(tokenStorage.hasToken, isFalse); // cache is still cold
    expect(await tokenStorage.read(), 'from-device');
    expect(tokenStorage.hasToken, isTrue);
  });
}
