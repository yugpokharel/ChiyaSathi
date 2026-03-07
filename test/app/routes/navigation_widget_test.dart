import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for general navigation and routing patterns used in the app.
void main() {
  group('App Navigation Widget Tests', () {
    testWidgets('pushNamed navigates to correct route', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/': (_) => Scaffold(
                  body: Builder(
                    builder: (ctx) => ElevatedButton(
                      onPressed: () => Navigator.pushNamed(ctx, '/second'),
                      child: const Text('Go'),
                    ),
                  ),
                ),
            '/second': (_) => const Scaffold(body: Text('Second Page')),
          },
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.text('Second Page'), findsOneWidget);
    });

    testWidgets('pop returns to previous route', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/': (_) => Scaffold(
                  body: Builder(
                    builder: (ctx) => ElevatedButton(
                      onPressed: () => Navigator.pushNamed(ctx, '/second'),
                      child: const Text('Go'),
                    ),
                  ),
                ),
            '/second': (_) => Scaffold(
                  body: Builder(
                    builder: (ctx) => ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Back'),
                    ),
                  ),
                ),
          },
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      expect(find.text('Go'), findsOneWidget);
    });

    testWidgets('BottomNavigationBar switches tabs', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: _TestBottomNavScreen(),
        ),
      );

      expect(find.text('Home Content'), findsOneWidget);

      await tester.tap(find.text('Menu'));
      await tester.pump();

      expect(find.text('Menu Content'), findsOneWidget);

      await tester.tap(find.text('Profile'));
      await tester.pump();

      expect(find.text('Profile Content'), findsOneWidget);
    });

    testWidgets('BottomNavigationBar shows correct selected index',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: _TestBottomNavScreen(),
        ),
      );

      final nav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(nav.currentIndex, 0);
    });
  });
}

class _TestBottomNavScreen extends StatefulWidget {
  @override
  State<_TestBottomNavScreen> createState() => _TestBottomNavScreenState();
}

class _TestBottomNavScreenState extends State<_TestBottomNavScreen> {
  int _currentIndex = 0;

  final _pages = const [
    Center(child: Text('Home Content')),
    Center(child: Text('Menu Content')),
    Center(child: Text('Profile Content')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
