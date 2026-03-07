import 'package:chiya_sathi/common/my_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('showMySnackBar', () {
    testWidgets('displays snackbar with message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  showMySnackBar(context: context, message: 'Hello!');
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.text('Hello!'), findsOneWidget);
    });

    testWidgets('uses green color by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  showMySnackBar(context: context, message: 'Success');
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, Colors.green);
    });

    testWidgets('uses custom color when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  showMySnackBar(
                    context: context,
                    message: 'Error',
                    color: Colors.red,
                  );
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, Colors.red);
    });

    testWidgets('snackbar is floating', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  showMySnackBar(context: context, message: 'Float');
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.behavior, SnackBarBehavior.floating);
    });
  });
}
