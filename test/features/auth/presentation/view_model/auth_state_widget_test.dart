import 'package:chiya_sathi/features/auth/presentation/state/auth_state.dart';
import 'package:chiya_sathi/features/auth/domain/entities/auth_entity.dart';
import 'package:chiya_sathi/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:chiya_sathi/features/auth/domain/usecases/login_usecase.dart';
import 'package:chiya_sathi/features/auth/domain/usecases/register_usecase.dart';
import 'package:chiya_sathi/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}
class MockRegisterUsecase extends Mock implements RegisterUsecase {}
class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockLoginUsecase mockLogin;
  late MockRegisterUsecase mockRegister;
  late MockAuthRepository mockRepo;

  const tUser = AuthEntity(
    id: '1',
    fullName: 'Test User',
    username: 'test',
    email: 'test@test.com',
    phoneNumber: '123',
    token: 'token',
  );

  setUpAll(() {
    registerFallbackValue(const LoginUsecaseParams(email: '', password: ''));
    registerFallbackValue(const RegisterUsecaseParams(
      fullName: '', username: '', email: '', phoneNumber: '', password: '',
    ));
  });

  setUp(() {
    mockLogin = MockLoginUsecase();
    mockRegister = MockRegisterUsecase();
    mockRepo = MockAuthRepository();
  });

  Widget buildTestWidget(AuthViewModel viewModel, AuthState state) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            if (state.isLoading) const CircularProgressIndicator(),
            if (state.error != null) Text('Error: ${state.error}'),
            if (state.user != null) Text('User: ${state.user!.fullName}'),
            if (!state.isLoading && state.user == null && state.error == null)
              const Text('Unauthenticated'),
          ],
        ),
      ),
    );
  }

  group('AuthState widget rendering', () {
    testWidgets('shows Unauthenticated for initial state', (tester) async {
      final vm = AuthViewModel(mockLogin, mockRegister, mockRepo);
      await tester.pumpWidget(buildTestWidget(vm, const AuthState.unauthenticated()));
      expect(find.text('Unauthenticated'), findsOneWidget);
    });

    testWidgets('shows loading indicator for loading state', (tester) async {
      final vm = AuthViewModel(mockLogin, mockRegister, mockRepo);
      await tester.pumpWidget(buildTestWidget(vm, const AuthState.loading()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows user name for authenticated state', (tester) async {
      final vm = AuthViewModel(mockLogin, mockRegister, mockRepo);
      await tester.pumpWidget(
        buildTestWidget(vm, const AuthState.authenticated(tUser)),
      );
      expect(find.text('User: Test User'), findsOneWidget);
    });

    testWidgets('shows error message for error state', (tester) async {
      final vm = AuthViewModel(mockLogin, mockRegister, mockRepo);
      await tester.pumpWidget(
        buildTestWidget(vm, const AuthState.error('Login failed')),
      );
      expect(find.text('Error: Login failed'), findsOneWidget);
    });
  });
}
