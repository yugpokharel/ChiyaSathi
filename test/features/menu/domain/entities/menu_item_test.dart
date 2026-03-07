import 'package:chiya_sathi/features/menu/domain/entities/menu_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MenuItem', () {
    test('should create MenuItem with required fields', () {
      final item = MenuItem(
        id: '1',
        name: 'Milk Tea',
        price: 50.0,
        category: 'Tea',
      );

      expect(item.id, '1');
      expect(item.name, 'Milk Tea');
      expect(item.price, 50.0);
      expect(item.category, 'Tea');
      expect(item.image, isNull);
    });

    test('fromJson should parse all fields', () {
      final json = {
        '_id': 'tea-001',
        'name': 'Lemon Tea',
        'price': 40,
        'category': 'Tea',
        'image': 'http://example.com/img.jpg',
      };

      final item = MenuItem.fromJson(json);

      expect(item.id, 'tea-001');
      expect(item.name, 'Lemon Tea');
      expect(item.price, 40.0);
      expect(item.category, 'Tea');
      expect(item.image, 'http://example.com/img.jpg');
    });

    test('fromJson handles missing optional fields', () {
      final json = <String, dynamic>{};

      final item = MenuItem.fromJson(json);

      expect(item.id, '');
      expect(item.name, '');
      expect(item.price, 0);
      expect(item.category, '');
      expect(item.image, isNull);
    });

    test('fromJson prepends serverUrl for relative image paths', () {
      final json = {
        '_id': '1',
        'name': 'Coffee',
        'price': 100,
        'category': 'Coffee',
        'image': '/uploads/coffee.jpg',
      };

      final item = MenuItem.fromJson(json);

      expect(item.image, contains('/uploads/coffee.jpg'));
      expect(item.image, startsWith('http'));
    });

    test('fromJson does not modify absolute image URLs', () {
      final json = {
        '_id': '1',
        'name': 'Coffee',
        'price': 100,
        'category': 'Coffee',
        'image': 'http://cdn.example.com/coffee.jpg',
      };

      final item = MenuItem.fromJson(json);

      expect(item.image, 'http://cdn.example.com/coffee.jpg');
    });

    test('toJson should produce correct map', () {
      final item = MenuItem(
        id: '1',
        name: 'Samosa',
        price: 30.0,
        category: 'Snacks',
        image: 'snack.jpg',
      );

      final json = item.toJson();

      expect(json['name'], 'Samosa');
      expect(json['price'], 30.0);
      expect(json['category'], 'Snacks');
      expect(json['image'], 'snack.jpg');
      expect(json.containsKey('id'), false); // id not in toJson
    });

    test('toJson omits image when null', () {
      final item = MenuItem(
        id: '1',
        name: 'Item',
        price: 10.0,
        category: 'Test',
      );

      final json = item.toJson();

      expect(json.containsKey('image'), false);
    });

    test('copyWith changes only specified fields', () {
      final original = MenuItem(
        id: '1',
        name: 'Original',
        price: 50.0,
        category: 'Tea',
      );

      final updated = original.copyWith(name: 'Updated', price: 60.0);

      expect(updated.name, 'Updated');
      expect(updated.price, 60.0);
      expect(updated.id, '1');
      expect(updated.category, 'Tea');
    });
  });
}
