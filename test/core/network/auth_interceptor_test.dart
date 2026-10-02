import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_edu/core/network/failure.dart';
import 'package:test_edu/core/network/interceptors/auth_interceptor.dart';
import 'package:test_edu/core/storage/token_storage.dart';

import '../../helpers/fake_http_adapter.dart';
import '../../helpers/fake_secure_storage.dart';

void main() {
  late FakeSecureStorage storage;
  late TokenStorage tokenStorage;
  late SessionEvents events;

  setUp(() {
    storage = FakeSecureStorage();
    tokenStorage = TokenStorage(storage: storage);
    events = SessionEvents();
  });

  tearDown(() => events.dispose());

  /// A [Dio] whose adapter answers [respond], with the interceptor attached.
  ({Dio dio, FakeHttpAdapter adapter}) buildDio(
    ResponseBody Function(RequestOptions options) respond,
  ) {
    final adapter = FakeHttpAdapter(respond);
    final dio = dioWith(adapter);
    dio.interceptors.add(
      AuthInterceptor(tokenStorage: tokenStorage, sessionEvents: events),
    );
    return (dio: dio, adapter: adapter);
  }

  /// Collects every event the stream emits for the rest of the test.
  List<SessionEvent> collectEvents() {
    final emitted = <SessionEvent>[];
    final subscription = events.stream.listen(emitted.add);
    addTearDown(subscription.cancel);
    return emitted;
  }

  ResponseBody ok(RequestOptions options) =>
      jsonResponse({'status': true, 'message': 'ok', 'data': null});

  test('attaches the Bearer header when a token is stored', () async {
    await tokenStorage.save('token-123');
    final (:dio, :adapter) = buildDio(ok);

    await dio.get('/me');

    expect(adapter.lastRequest!.headers['Authorization'], 'Bearer token-123');
  });

  test('attaches nothing when no token is stored', () async {
    final (:dio, :adapter) = buildDio(ok);

    await dio.get('/me');

    expect(adapter.lastRequest!.headers.containsKey('Authorization'), isFalse);
  });

  test('a 401 that carried a token clears it and emits sessionExpired', () async {
    await tokenStorage.save('token-123');
    final (:dio, :adapter) = buildDio(
      (_) => jsonResponse({
        'status': false,
        'message': 'Unauthenticated',
        'error_code': null,
      }, statusCode: 401),
    );
    final emitted = collectEvents();

    await expectLater(dio.get('/me'), throwsA(isA<DioException>()));
    await pumpEventQueue();

    expect(await tokenStorage.read(), isNull);
    expect(storage.data, isEmpty);
    expect(emitted, [SessionEvent.sessionExpired]);
  });

  test('a 401 without a token changes nothing', () async {
    final (:dio, :adapter) = buildDio(
      (_) => jsonResponse({
        'status': false,
        'message': 'Invalid credentials',
        'error_code': null,
      }, statusCode: 401),
    );
    final emitted = collectEvents();

    await expectLater(dio.get('/login'), throwsA(isA<DioException>()));
    await pumpEventQueue();

    expect(emitted, isEmpty);
    expect(storage.data, isEmpty);
  });

  test('STUDENT_SESSION_REVOKED on an HTTP 2xx emits sessionRevoked', () async {
    await tokenStorage.save('token-123');
    final (:dio, :adapter) = buildDio(
      (_) => jsonResponse({
        'status': false,
        'message': 'revoked',
        'error_code': FailureCodes.studentSessionRevoked,
      }),
    );
    final emitted = collectEvents();

    await dio.get('/me'); // HTTP 200: Dio does not throw.
    await pumpEventQueue();

    expect(emitted, [SessionEvent.sessionRevoked]);
    expect(await tokenStorage.read(), isNull);
  });

  test('STUDENT_SESSION_REVOKED on a 401 emits sessionRevoked, not expired', () async {
    await tokenStorage.save('token-123');
    final (:dio, :adapter) = buildDio(
      (_) => jsonResponse({
        'status': false,
        'message': 'revoked',
        'error_code': FailureCodes.studentSessionRevoked,
      }, statusCode: 401),
    );
    final emitted = collectEvents();

    await expectLater(dio.get('/me'), throwsA(isA<DioException>()));
    await pumpEventQueue();

    expect(emitted, [SessionEvent.sessionRevoked]);
    expect(await tokenStorage.read(), isNull);
  });
}
