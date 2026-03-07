import 'package:chiya_sathi/core/widgets/my_text_field_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MyTextFieldWidgets', () {
    testWidgets('renders with hint and label text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyTextFieldWidgets(
              controller: TextEditingController(),
              hintText: 'Enter email',
              text: 'Email',
            ),
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('accepts text input', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyTextFieldWidgets(
              controller: controller,
              hintText: 'Enter name',
              text: 'Name',
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'John');
      expect(controller.text, 'John');
    });

    testWidgets('shows validation error when empty', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: MyTextFieldWidgets(
                controller: TextEditingController(),
                hintText: 'Enter email',
                text: 'Email',
              ),
            ),
          ),
        ),
      );

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Please enter Email'), findsOneWidget);
    });

    testWidgets('shows visibility toggle when obscureText is true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyTextFieldWidgets(
              controller: TextEditingController(),
              hintText: 'Enter password',
              text: 'Password',
              obscureText: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('toggles password visibility on icon tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyTextFieldWidgets(
              controller: TextEditingController(),
              hintText: 'Enter password',
              text: 'Password',
              obscureText: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('does not show visibility icon when obscureText is false',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyTextFieldWidgets(
              controller: TextEditingController(),
              hintText: 'Enter text',
              text: 'Text',
              obscureText: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility_off), findsNothing);
      expect(find.byIcon(Icons.visibility), findsNothing);
    });
  });
}
