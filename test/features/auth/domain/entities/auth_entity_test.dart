import 'package:chiya_sathi/features/auth/domain/entities/auth_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthEntity', () {
    test('should create AuthEntity with required fields', () {
      const entity = AuthEntity(
        fullName: 'John Doe',
        username: 'johndoe',
        email: 'john@example.com',
        phoneNumber: '9800000000',
      );

      expect(entity.fullName, 'John Doe');
      expect(entity.username, 'johndoe');
      expect(entity.email, 'john@example.com');
      expect(entity.phoneNumber, '9800000000');
      expect(entity.id, isNull);
      expect(entity.token, isNull);
      expect(entity.password, isNull);
      expect(entity.profilePicture, isNull);
      expect(entity.role, isNull);
    });

    test('should support equality via Equatable', () {
      const entity1 = AuthEntity(
        id: '1',
        fullName: 'Test',
        username: 'test',
        email: 'test@test.com',
        phoneNumber: '123',
      );
      const entity2 = AuthEntity(
        id: '1',
        fullName: 'Test',
        username: 'test',
        email: 'test@test.com',
        phoneNumber: '123',
      );

      expect(entity1, equals(entity2));
    });

    test('should not be equal when fields differ', () {
      const entity1 = AuthEntity(
        id: '1',
        fullName: 'Test',
        username: 'test',
        email: 'test@test.com',
        phoneNumber: '123',
      );
      const entity2 = AuthEntity(
        id: '2',
        fullName: 'Test',
        username: 'test',
        email: 'test@test.com',
        phoneNumber: '123',
      );

      expect(entity1, isNot(equals(entity2)));
    });

    test('fromJson should parse correctly', () {
      final json = {
        '_id': 'abc123',
        'fullName': 'Jane',
        'username': 'jane',
        'email': 'jane@test.com',
        'phoneNumber': '999',
        'token': 'tok',
        'profilePicture': 'pic.jpg',
        'role': 'customer',
      };

      final entity = AuthEntity.fromJson(json);

      expect(entity.id, 'abc123');
      expect(entity.fullName, 'Jane');
      expect(entity.username, 'jane');
      expect(entity.email, 'jane@test.com');
      expect(entity.phoneNumber, '999');
      expect(entity.token, 'tok');
      expect(entity.profilePicture, 'pic.jpg');
      expect(entity.role, 'customer');
    });

    test('fromJson should handle missing optional fields', () {
      final json = <String, dynamic>{};

      final entity = AuthEntity.fromJson(json);

      expect(entity.id, isNull);
      expect(entity.fullName, '');
      expect(entity.username, '');
      expect(entity.email, '');
      expect(entity.phoneNumber, '');
      expect(entity.token, isNull);
    });

    test('copyWith should return new entity with changed fields', () {
      const original = AuthEntity(
        id: '1',
        fullName: 'Old',
        username: 'old',
        email: 'old@test.com',
        phoneNumber: '111',
      );

      final updated = original.copyWith(
        fullName: 'New',
        email: 'new@test.com',
      );

      expect(updated.fullName, 'New');
      expect(updated.email, 'new@test.com');
      expect(updated.id, '1'); // unchanged
      expect(updated.username, 'old'); // unchanged
    });

    test('copyWith with no args returns equivalent entity', () {
      const original = AuthEntity(
        id: '1',
        fullName: 'Test',
        username: 'test',
        email: 'test@test.com',
        phoneNumber: '999',
      );

      final copy = original.copyWith();

      expect(copy, equals(original));
    });

    test('props list is correct for Equatable', () {
      const entity = AuthEntity(
        id: '1',
        fullName: 'A',
        username: 'b',
        email: 'c',
        phoneNumber: 'd',
        token: 't',
        profilePicture: 'p',
        role: 'r',
      );

      expect(entity.props, [
        '1', 'A', 'b', 'c', 'd', 't', 'p', 'r',
      ]);
    });
  });
}
