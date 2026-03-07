import 'package:chiya_sathi/features/menu/domain/entities/menu_item.dart';
import 'package:chiya_sathi/features/menu/presentation/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tea = MenuItem(id: 'tea-1', name: 'Milk Tea', price: 50, category: 'Tea');
  final coffee = MenuItem(id: 'coffee-1', name: 'Latte', price: 160, category: 'Coffee');

  group('Cart Widget Tests', () {
    testWidgets('displays empty cart message when no items', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  final cart = ref.watch(cartProvider);
                  return cart.isEmpty
                      ? const Text('Cart is empty')
                      : Text('${cart.length} items');
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Cart is empty'), findsOneWidget);
    });

    testWidgets('displays item count after adding items', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  final cart = ref.watch(cartProvider);
                  return Column(
                    children: [
                      Text('${cart.length} items'),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(cartProvider.notifier).addItem(tea);
                        },
                        child: const Text('Add Tea'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('0 items'), findsOneWidget);

      await tester.tap(find.text('Add Tea'));
      await tester.pump();

      expect(find.text('1 items'), findsOneWidget);
    });

    testWidgets('displays total amount correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  final notifier = ref.watch(cartProvider.notifier);
                  final cart = ref.watch(cartProvider);
                  return Column(
                    children: [
                      Text('Total: Rs ${notifier.totalAmount}'),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(cartProvider.notifier).addItem(tea);
                          ref.read(cartProvider.notifier).addItem(coffee);
                        },
                        child: const Text('Add Items'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Total: Rs 0.0'), findsOneWidget);

      await tester.tap(find.text('Add Items'));
      await tester.pump();

      expect(find.text('Total: Rs 210.0'), findsOneWidget);
    });

    testWidgets('clear cart updates UI', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  final cart = ref.watch(cartProvider);
                  return Column(
                    children: [
                      Text('${cart.length} items'),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(cartProvider.notifier).addItem(tea),
                        child: const Text('Add'),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(cartProvider.notifier).clearCart(),
                        child: const Text('Clear'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Add'));
      await tester.pump();
      expect(find.text('1 items'), findsOneWidget);

      await tester.tap(find.text('Clear'));
      await tester.pump();
      expect(find.text('0 items'), findsOneWidget);
    });
  });
}
