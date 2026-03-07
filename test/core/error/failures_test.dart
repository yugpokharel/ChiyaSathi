import 'package:chiya_sathi/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failure classes', () {
    test('ServerFailure stores message', () {
      const failure = ServerFailure('server down');
      expect(failure.message, 'server down');
    });

    test('ServerFailure supports Equatable', () {
      const f1 = ServerFailure('error');
      const f2 = ServerFailure('error');
      expect(f1, equals(f2));
    });

    test('LocalDatabaseFailure stores message', () {
      const failure = LocalDatabaseFailure('db error');
      expect(failure.message, 'db error');
    });

    test('ConnectionFailure stores message', () {
      const failure = ConnectionFailure('no internet');
      expect(failure.message, 'no internet');
    });

    test('ApiFailure stores message and optional statusCode', () {
      const failure = ApiFailure(message: 'not found', statusCode: 404);
      expect(failure.message, 'not found');
      expect(failure.statusCode, 404);
    });

    test('ApiFailure without statusCode defaults to null', () {
      const failure = ApiFailure(message: 'error');
      expect(failure.statusCode, isNull);
    });

    test('different failure types are not equal', () {
      const server = ServerFailure('err');
      const local = LocalDatabaseFailure('err');
      // They are different runtime types, so not equal
      expect(server, isNot(equals(local)));
    });
  });
}
