import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_edu/core/network/interceptors/debug_log_interceptor.dart';

import '../../helpers/fake_http_adapter.dart';

void main() {
  group('redaction', () {
    test('masks the Authorization header', () {
      final redacted = DebugLogInterceptor.redactHeaders({
        'Authorization': 'Bearer secret',
        'Accept': 'application/json',
      });

      expect(redacted['Authorization'], DebugLogInterceptor.redacted);
      expect(redacted['Accept'], 'application/json');
    });

    test('masks the Authorization header whatever its case', () {
      final redacted = DebugLogInterceptor.redactHeaders({
        'authorization': 'Bearer secret',
      });

      expect(redacted['authorization'], DebugLogInterceptor.redacted);
    });

    test('masks password and token fields at any depth', () {
      final redacted = DebugLogInterceptor.redactBody({
        'email': 'a@b.c',
        'password': 'secret',
        'token': 'secret',
        'nested': {'token': 'secret', 'name': 'keep'},
        'list': [
          {'password': 'secret'},
        ],
      });

      expect(redacted, {
        'email': 'a@b.c',
        'password': DebugLogInterceptor.redacted,
        'token': DebugLogInterceptor.redacted,
        'nested': {'token': DebugLogInterceptor.redacted, 'name': 'keep'},
        'list': [
          {'password': DebugLogInterceptor.redacted},
        ],
      });
    });

    test('leaves a non-map body untouched', () {
      expect(DebugLogInterceptor.redactBody('plain'), 'plain');
      expect(DebugLogInterceptor.redactBody(null), isNull);
    });
  });

  test('a logged request never contains the secret', () async {
    final logs = <String>[];
    final adapter = FakeHttpAdapter((_) => jsonResponse({'status': true}));
    final dio = dioWith(adapter)
      ..interceptors.add(DebugLogInterceptor(log: logs.add));

    await dio.post(
      '/login',
      data: {'email': 'a@b.c', 'password': 'hunter2'},
      options: Options(headers: {'Authorization': 'Bearer secret-token'}),
    );

    final log = logs.join('\n');
    expect(log, isNotEmpty);
    expect(log, isNot(contains('hunter2')));
    expect(log, isNot(contains('secret-token')));
    expect(log, contains(DebugLogInterceptor.redacted));
  });
}
