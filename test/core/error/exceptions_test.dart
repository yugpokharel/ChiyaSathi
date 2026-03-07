import 'package:chiya_sathi/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Exceptions', () {
    test('ServerException stores message', () {
      final ex = ServerException(message: 'Internal Server Error');
      expect(ex.message, 'Internal Server Error');
    });

    test('ServerException toString returns message', () {
      final ex = ServerException(message: 'timeout');
      expect(ex.toString(), 'timeout');
    });

    test('CacheException stores message', () {
      final ex = CacheException(message: 'Cache miss');
      expect(ex.message, 'Cache miss');
    });

    test('CacheException toString returns message', () {
      final ex = CacheException(message: 'no data');
      expect(ex.toString(), 'no data');
    });

    test('ServerException implements Exception', () {
      final ex = ServerException(message: 'test');
      expect(ex, isA<Exception>());
    });

    test('CacheException implements Exception', () {
      final ex = CacheException(message: 'test');
      expect(ex, isA<Exception>());
    });
  });
}
