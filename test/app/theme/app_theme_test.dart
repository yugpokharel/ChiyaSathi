import 'package:chiya_sathi/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App Theme', () {
    testWidgets('getLightTheme returns light brightness', (tester) async {
      final theme = getLightTheme();

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              final t = Theme.of(context);
              expect(t.brightness, Brightness.light);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('getDarkTheme returns dark brightness', (tester) async {
      final theme = getDarkTheme();

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              final t = Theme.of(context);
              expect(t.brightness, Brightness.dark);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('light theme uses OpenSans Regular fontFamily',
        (tester) async {
      final theme = getLightTheme();

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              expect(Theme.of(context).textTheme.bodyMedium?.fontFamily,
                  contains('OpenSans'));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('light theme scaffold bg is grey shade', (tester) async {
      final theme = getLightTheme();
      expect(theme.scaffoldBackgroundColor, Colors.grey.shade50);
    });

    testWidgets('dark theme scaffold bg is dark', (tester) async {
      final theme = getDarkTheme();
      expect(theme.scaffoldBackgroundColor, const Color(0xFF121212));
    });

    testWidgets('light theme uses Material3', (tester) async {
      final theme = getLightTheme();
      expect(theme.useMaterial3, true);
    });

    testWidgets('dark theme uses Material3', (tester) async {
      final theme = getDarkTheme();
      expect(theme.useMaterial3, true);
    });

    testWidgets('light theme bottom nav selected color is orange',
        (tester) async {
      final theme = getLightTheme();
      expect(
        theme.bottomNavigationBarTheme.selectedItemColor,
        Colors.orange.shade600,
      );
    });
  });
}
