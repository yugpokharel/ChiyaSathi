import 'package:chiya_sathi/features/menu/domain/entities/menu_item.dart';
import 'package:chiya_sathi/features/menu/presentation/providers/menu_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MenuState Widget Tests', () {
    testWidgets('displays loading indicator when isLoading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (_) {
                const state = MenuState(isLoading: true);
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays menu items in a list', (tester) async {
      final items = [
        MenuItem(id: '1', name: 'Milk Tea', price: 50, category: 'Tea'),
        MenuItem(id: '2', name: 'Latte', price: 160, category: 'Coffee'),
      ];
      final state = MenuState(items: items);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: state.items
                  .map((item) => ListTile(
                        title: Text(item.name),
                        subtitle: Text('Rs ${item.price}'),
                      ))
                  .toList(),
            ),
          ),
        ),
      );

      expect(find.text('Milk Tea'), findsOneWidget);
      expect(find.text('Latte'), findsOneWidget);
      expect(find.text('Rs 50.0'), findsOneWidget);
      expect(find.text('Rs 160.0'), findsOneWidget);
    });

    testWidgets('displays error message when error exists', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (_) {
                const state = MenuState(error: 'Failed to load menu');
                if (state.error != null) {
                  return Center(child: Text(state.error!));
                }
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(find.text('Failed to load menu'), findsOneWidget);
    });

    testWidgets('displays empty state when no items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (_) {
                const state = MenuState();
                if (state.items.isEmpty && !state.isLoading) {
                  return const Center(child: Text('No menu items'));
                }
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(find.text('No menu items'), findsOneWidget);
    });
  });
}
