import 'package:chiya_sathi/features/menu/presentation/providers/menu_provider.dart';
import 'package:chiya_sathi/features/menu/domain/entities/menu_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MenuState', () {
    test('default state has empty items and is not loading', () {
      const state = MenuState();
      expect(state.items, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('copyWith returns new state with changed fields', () {
      const state = MenuState();
      final items = [
        MenuItem(id: '1', name: 'Tea', price: 50, category: 'Tea'),
      ];

      final updated = state.copyWith(items: items, isLoading: true);

      expect(updated.items.length, 1);
      expect(updated.isLoading, true);
      expect(updated.error, isNull);
    });

    test('byCategory filters items correctly', () {
      final items = [
        MenuItem(id: '1', name: 'Milk Tea', price: 50, category: 'Tea'),
        MenuItem(id: '2', name: 'Latte', price: 160, category: 'Coffee'),
        MenuItem(id: '3', name: 'Black Tea', price: 30, category: 'Tea'),
      ];

      final state = MenuState(items: items);
      final teas = state.byCategory('Tea');

      expect(teas.length, 2);
      expect(teas.every((i) => i.category == 'Tea'), true);
    });

    test('byCategory returns empty for non-existent category', () {
      final items = [
        MenuItem(id: '1', name: 'Milk Tea', price: 50, category: 'Tea'),
      ];

      final state = MenuState(items: items);
      expect(state.byCategory('Pizza'), isEmpty);
    });

    test('categories returns unique categories in preferred order', () {
      final items = [
        MenuItem(id: '1', name: 'A', price: 10, category: 'Snacks'),
        MenuItem(id: '2', name: 'B', price: 20, category: 'Tea'),
        MenuItem(id: '3', name: 'C', price: 30, category: 'Coffee'),
        MenuItem(id: '4', name: 'D', price: 40, category: 'Tea'),
        MenuItem(id: '5', name: 'E', price: 50, category: 'Cigarette'),
      ];

      final state = MenuState(items: items);
      final cats = state.categories;

      // Preferred order: Tea, Coffee, Cigarette, Snacks
      expect(cats, ['Tea', 'Coffee', 'Cigarette', 'Snacks']);
    });

    test('categories appends non-preferred categories at the end', () {
      final items = [
        MenuItem(id: '1', name: 'A', price: 10, category: 'Tea'),
        MenuItem(id: '2', name: 'B', price: 20, category: 'Dessert'),
      ];

      final state = MenuState(items: items);
      final cats = state.categories;

      expect(cats, ['Tea', 'Dessert']);
    });

    test('categories returns empty for empty items', () {
      const state = MenuState();
      expect(state.categories, isEmpty);
    });
  });
}
