import 'package:chiya_sathi/features/menu/data/repositories/menu_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MenuRepository', () {
    late MenuRepository repository;

    setUp(() {
      repository = MenuRepository();
    });

    test('fallbackItems is not empty', () {
      expect(MenuRepository.fallbackItems, isNotEmpty);
    });

    test('fallbackItems contains Tea category', () {
      final teas = MenuRepository.fallbackItems
          .where((i) => i.category == 'Tea')
          .toList();
      expect(teas, isNotEmpty);
    });

    test('fallbackItems contains Coffee category', () {
      final coffees = MenuRepository.fallbackItems
          .where((i) => i.category == 'Coffee')
          .toList();
      expect(coffees, isNotEmpty);
    });

    test('fallbackItems contains Snacks category', () {
      final snacks = MenuRepository.fallbackItems
          .where((i) => i.category == 'Snacks')
          .toList();
      expect(snacks, isNotEmpty);
    });

    test('getMenuItemsByCategory returns only matching items', () {
      final teas = repository.getMenuItemsByCategory('Tea');
      expect(teas.every((i) => i.category == 'Tea'), true);
    });

    test('getMenuItemsByCategory returns empty for unknown category', () {
      final items = repository.getMenuItemsByCategory('Pizza');
      expect(items, isEmpty);
    });

    test('all fallback items have non-empty id and name', () {
      for (final item in MenuRepository.fallbackItems) {
        expect(item.id, isNotEmpty);
        expect(item.name, isNotEmpty);
        expect(item.price, greaterThan(0));
      }
    });
  });
}
