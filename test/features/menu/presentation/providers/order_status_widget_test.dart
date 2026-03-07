import 'package:chiya_sathi/features/menu/presentation/providers/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderStatus Widget Tests', () {
    Widget buildStatusWidget(OrderState state) {
      return MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Text('Status: ${state.statusLabel}'),
              if (state.hasActiveOrder)
                const Icon(Icons.access_time, key: Key('active_icon')),
              if (state.tableId != null) Text('Table: ${state.tableId}'),
              if (state.totalAmount > 0)
                Text('Total: Rs ${state.totalAmount}'),
            ],
          ),
        ),
      );
    }

    testWidgets('shows empty label for none status', (tester) async {
      await tester.pumpWidget(buildStatusWidget(OrderState()));
      expect(find.text('Status: '), findsOneWidget);
      expect(find.byKey(const Key('active_icon')), findsNothing);
    });

    testWidgets('shows Pending label and active icon', (tester) async {
      await tester.pumpWidget(buildStatusWidget(
        OrderState(status: OrderStatus.pending),
      ));
      expect(find.text('Status: Pending'), findsOneWidget);
      expect(find.byKey(const Key('active_icon')), findsOneWidget);
    });

    testWidgets('shows Preparing label and active icon', (tester) async {
      await tester.pumpWidget(buildStatusWidget(
        OrderState(status: OrderStatus.preparing),
      ));
      expect(find.text('Status: Preparing'), findsOneWidget);
      expect(find.byKey(const Key('active_icon')), findsOneWidget);
    });

    testWidgets('shows Ready to Pickup! label', (tester) async {
      await tester.pumpWidget(buildStatusWidget(
        OrderState(status: OrderStatus.ready),
      ));
      expect(find.text('Status: Ready to Pickup!'), findsOneWidget);
    });

    testWidgets('hides active icon for served status', (tester) async {
      await tester.pumpWidget(buildStatusWidget(
        OrderState(status: OrderStatus.served),
      ));
      expect(find.text('Status: Served'), findsOneWidget);
      expect(find.byKey(const Key('active_icon')), findsNothing);
    });

    testWidgets('shows table ID when present', (tester) async {
      await tester.pumpWidget(buildStatusWidget(
        OrderState(tableId: 'T-5'),
      ));
      expect(find.text('Table: T-5'), findsOneWidget);
    });

    testWidgets('shows total amount when > 0', (tester) async {
      await tester.pumpWidget(buildStatusWidget(
        OrderState(totalAmount: 250),
      ));
      expect(find.text('Total: Rs 250.0'), findsOneWidget);
    });

    testWidgets('hides total when 0', (tester) async {
      await tester.pumpWidget(buildStatusWidget(OrderState()));
      expect(find.textContaining('Total:'), findsNothing);
    });
  });
}
