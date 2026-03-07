import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for form validation patterns used in login/signup screens.
void main() {
  group('Form Validation Widget Tests', () {
    testWidgets('empty email shows validation error', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Email can't be empty";
                      if (!RegExp(r'\S+@\S+\.\S+').hasMatch(v)) {
                        return "Enter valid email";
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: () => formKey.currentState!.validate(),
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(find.text("Email can't be empty"), findsOneWidget);
    });

    testWidgets('invalid email format shows error', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: 'notanemail',
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Email can't be empty";
                      if (!RegExp(r'\S+@\S+\.\S+').hasMatch(v)) {
                        return "Enter valid email";
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: () => formKey.currentState!.validate(),
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(find.text('Enter valid email'), findsOneWidget);
    });

    testWidgets('valid email passes validation', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: 'test@example.com',
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Email can't be empty";
                      if (!RegExp(r'\S+@\S+\.\S+').hasMatch(v)) {
                        return "Enter valid email";
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: () => formKey.currentState!.validate(),
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(find.text("Email can't be empty"), findsNothing);
      expect(find.text("Enter valid email"), findsNothing);
    });

    testWidgets('short password shows error', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: '1234',
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Password can't be empty";
                      if (v.length < 8) return "Min 8 characters";
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: () => formKey.currentState!.validate(),
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(find.text('Min 8 characters'), findsOneWidget);
    });

    testWidgets('valid password passes validation', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: 'password123',
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Password can't be empty";
                      if (v.length < 8) return "Min 8 characters";
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: () => formKey.currentState!.validate(),
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(find.text("Password can't be empty"), findsNothing);
      expect(find.text("Min 8 characters"), findsNothing);
    });

    testWidgets('password mismatch detection', (tester) async {
      final pwd = TextEditingController(text: 'password123');
      final confirmPwd = TextEditingController(text: 'different123');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final match = pwd.text == confirmPwd.text;
                return Column(
                  children: [
                    if (!match) const Text('Passwords do not match'),
                    if (match) const Text('Passwords match'),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });
}
