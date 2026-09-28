import 'package:devtool_h5/devtool_h5.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parseHeaders parses key: value lines', () {
    final Map<String, String> headers = parseHeaders('Authorization: Bearer x\nX-Custom: 1\n:ignored\n');
    expect(headers['Authorization'], 'Bearer x');
    expect(headers['X-Custom'], '1');
    expect(headers.containsKey('ignored'), isFalse);
  });

  test('formatJsResult serializes objects to JSON', () {
    expect(formatJsResult(null), '(null)');
    expect(formatJsResult('hello'), 'hello');
    expect(formatJsResult(const <String, Object>{'a': 1}), contains('"a"'));
    expect(formatJsResult(const <Object>[1, 2]), contains('1'));
  });

  test('buildRequest sets url and headers', () {
    final request = buildRequest('https://example.com/api', 'Authorization: Bearer x\nX-Custom: 1');
    expect(request.url.toString(), 'https://example.com/api');
    expect(request.headers?['Authorization'], 'Bearer x');
    expect(request.headers?['X-Custom'], '1');
  });
}
