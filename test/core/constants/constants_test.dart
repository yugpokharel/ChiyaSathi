import 'package:chiya_sathi/core/constants/api_constants.dart';
import 'package:chiya_sathi/core/constants/hive_table_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiConstants', () {
    test('baseUrl contains serverIp and serverPort', () {
      expect(ApiConstants.baseUrl,
          contains(ApiConstants.serverIp));
      expect(ApiConstants.baseUrl,
          contains(ApiConstants.serverPort));
    });

    test('baseUrl ends with /api', () {
      expect(ApiConstants.baseUrl, endsWith('/api'));
    });

    test('serverUrl does not end with /api', () {
      expect(ApiConstants.serverUrl, isNot(endsWith('/api')));
    });

    test('serverUrl is prefix of baseUrl', () {
      expect(ApiConstants.baseUrl, startsWith(ApiConstants.serverUrl));
    });
  });

  group('HiveTableConstants', () {
    test('authBox is authBox', () {
      expect(HiveTableConstants.authBox, 'authBox');
    });

    test('authTypeId is 0', () {
      expect(HiveTableConstants.authTypeId, 0);
    });
  });
}
