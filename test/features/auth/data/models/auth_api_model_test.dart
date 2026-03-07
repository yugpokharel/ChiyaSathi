import 'package:chiya_sathi/features/auth/data/models/auth_api_model.dart';
import 'package:chiya_sathi/features/auth/domain/entities/auth_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthApiModel', () {
    test('fromJson should parse all fields correctly', () {
      final json = {
        '_id': 'abc',
        'name': 'John',
        'username': 'john',
        'email': 'john@test.com',
        'phoneNumber': '123',
        'profilePicture': 'pic.jpg',
        'password': 'secret',
      };

      final model = AuthApiModel.fromJson(json);

      expect(model.id, 'abc');
      expect(model.fullName, 'John');
      expect(model.username, 'john');
      expect(model.email, 'john@test.com');
      expect(model.phoneNumber, '123');
      expect(model.profilePicture, 'pic.jpg');
      expect(model.password, 'secret');
    });

    test('toJson should produce correct map', () {
      const model = AuthApiModel(
        fullName: 'John',
        username: 'john',
        email: 'john@test.com',
        phoneNumber: '123',
        password: 'pass',
        profilePicture: 'pic.jpg',
      );

      final json = model.toJson();

      expect(json['name'], 'John');
      expect(json['username'], 'john');
      expect(json['email'], 'john@test.com');
      expect(json['phoneNumber'], '123');
      expect(json['password'], 'pass');
      expect(json['profilePicture'], 'pic.jpg');
    });

    test('toEntity should convert to AuthEntity correctly', () {
      const model = AuthApiModel(
        id: 'abc',
        fullName: 'John',
        username: 'john',
        email: 'john@test.com',
        phoneNumber: '123',
        profilePicture: 'pic.jpg',
        password: 'pass',
      );

      final entity = model.toEntity();

      expect(entity, isA<AuthEntity>());
      expect(entity.id, 'abc');
      expect(entity.fullName, 'John');
      expect(entity.username, 'john');
      expect(entity.email, 'john@test.com');
      expect(entity.phoneNumber, '123');
      expect(entity.profilePicture, 'pic.jpg');
      expect(entity.token, isNull);
    });

    test('fromEntity should create model from AuthEntity', () {
      const entity = AuthEntity(
        id: 'x1',
        fullName: 'Jane',
        username: 'jane',
        email: 'jane@x.com',
        phoneNumber: '999',
        password: 'pw',
        profilePicture: 'img.png',
      );

      final model = AuthApiModel.fromEntity(entity);

      expect(model.id, 'x1');
      expect(model.fullName, 'Jane');
      expect(model.username, 'jane');
      expect(model.email, 'jane@x.com');
      expect(model.phoneNumber, '999');
      expect(model.password, 'pw');
      expect(model.profilePicture, 'img.png');
    });

    test('roundtrip: entity -> model -> entity preserves data', () {
      const original = AuthEntity(
        id: 'r1',
        fullName: 'Round',
        username: 'trip',
        email: 'r@t.com',
        phoneNumber: '000',
        password: 'rp',
        profilePicture: 'rt.jpg',
      );

      final model = AuthApiModel.fromEntity(original);
      final restored = model.toEntity();

      expect(restored.id, original.id);
      expect(restored.fullName, original.fullName);
      expect(restored.username, original.username);
      expect(restored.email, original.email);
      expect(restored.phoneNumber, original.phoneNumber);
      expect(restored.password, original.password);
      expect(restored.profilePicture, original.profilePicture);
    });
  });
}
