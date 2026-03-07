import 'package:chiya_sathi/core/widgets/my_button_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MyButtonWidgets', () {
    testWidgets('renders button with correct text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyButtonWidgets(
              onPressed: () {},
              text: 'Login',
            ),
          ),
        ),
      );

      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyButtonWidgets(
              onPressed: () => pressed = true,
              text: 'Tap Me',
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      expect(pressed, true);
    });

    testWidgets('button has full width with padding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyButtonWidgets(
              onPressed: () {},
              text: 'Wide',
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, double.infinity);
    });

    testWidgets('uses ElevatedButton', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyButtonWidgets(
              onPressed: () {},
              text: 'Test',
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}
