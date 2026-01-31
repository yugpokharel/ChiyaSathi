import 'package:chiya_sathi/features/auth/presentation/pages/login_screen.dart';
import 'package:chiya_sathi/features/auth/presentation/state/auth_state.dart';
import 'package:chiya_sathi/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:chiya_sathi/features/auth/presentation/view_model/auth_view_model_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthNotifier extends Mock implements AuthViewModel {}

void main() {
  late MockAuthNotifier mockNotifier;

  setUp(() {
    mockNotifier = MockAuthNotifier();
  });

  Widget createWidget(AuthState state) {
    when(() => mockNotifier.state).thenReturn(state);

    return ProviderScope(
      overrides: [
        authViewModelProvider.overrideWith(() => mockNotifier),
      ],
      child: MaterialApp(
        routes: {
          '/dashboard': (_) => const Scaffold(body: Text('Dashboard')),
          '/signup': (_) => const Scaffold(body: Text('Signup')),
        },
        home: const LoginScreen(),
      ),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('renders email, password and button',
        (tester) async {
      await tester.pumpWidget(
        createWidget(const AuthState()),
      );

      expect(find.text('EMAIL ADDRESS'), findsOneWidget);
      expect(find.text('PASSWORD'), findsOneWidget);
      expect(find.text('SIGN IN'), findsOneWidget);
    });

    testWidgets('shows validation errors when fields empty',
        (tester) async {
      await tester.pumpWidget(
        createWidget(const AuthState()),
      );

      await tester.tap(find.text('SIGN IN'));
      await tester.pump();

      expect(find.text("Email can't be empty"), findsOneWidget);
      expect(find.text("Password can't be empty"), findsOneWidget);
    });

    testWidgets('calls login when valid inputs provided',
        (tester) async {
      when(() => mockNotifier.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async {});

      await tester.pumpWidget(
        createWidget(const AuthState()),
      );

      await tester.enterText(
          find.byType(TextFormField).at(0), 'test@gmail.com');
      await tester.enterText(
          find.byType(TextFormField).at(1), '12345678');

      await tester.tap(find.text('SIGN IN'));
      await tester.pump();

      verify(() => mockNotifier.login(
            email: 'test@gmail.com',
            password: '12345678',
          )).called(1);
    });

    testWidgets('shows loading indicator when status loading',
        (tester) async {
      await tester.pumpWidget(
        createWidget(const AuthState(status: AuthStatus.loading)),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('navigates to dashboard on authenticated',
        (tester) async {
      await tester.pumpWidget(
        createWidget(const AuthState(status: AuthStatus.authenticated)),
      );

      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
    });
  });
}
