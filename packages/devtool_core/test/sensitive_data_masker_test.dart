import 'package:devtool_core/devtool.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const SensitiveDataMasker masker = SensitiveDataMasker();

  group('SensitiveDataMasker', () {
    test('masks header values under sensitive keys', () {
      final Map<String, String> headers = <String, String>{
        'Authorization': 'Bearer abc123',
        'Content-Type': 'application/json',
        'Cookie': 'session=secret',
      };

      final Map<String, String> masked = masker.maskMap(headers);

      expect(masked['Authorization'], '***');
      expect(masked['Cookie'], '***');
      expect(masked['Content-Type'], 'application/json');
    });

    test('masks phone numbers in free text', () {
      expect(masker.maskText('call 13812345678 now'), 'call *** now');
    });

    test('masks JSON values under sensitive keys', () {
      const String body = '{"token":"abc123","name":"alice"}';
      expect(masker.maskText(body), '{"token":"***","name":"alice"}');
    });

    test('isSensitiveKey recognizes common sensitive names', () {
      expect(masker.isSensitiveKey('password'), isTrue);
      expect(masker.isSensitiveKey('api_key'), isTrue);
      expect(masker.isSensitiveKey('username'), isFalse);
    });

    test('handles null and empty input', () {
      expect(masker.maskText(null), '');
      expect(masker.maskText(''), '');
      expect(masker.maskMap(null), isEmpty);
    });
  });
}
