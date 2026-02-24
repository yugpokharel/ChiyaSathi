import 'package:chiya_sathi/features/auth/presentation/view_model/auth_view_model_provider.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chiya_sathi/features/auth/presentation/providers/auth_usecase_provider.dart';
import 'package:chiya_sathi/features/auth/domain/usecases/login_usecase.dart';
import 'package:chiya_sathi/features/auth/domain/usecases/register_usecase.dart';
import 'package:chiya_sathi/features/auth/domain/entities/auth_entity.dart';
import 'package:chiya_sathi/core/error/failures.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}
class MockRegisterUsecase extends Mock implements RegisterUsecase {}

void main() {
  late ProviderContainer container;
  late MockLoginUsecase mockLoginUsecase;
  late MockRegisterUsecase mockRegisterUsecase;

  const tEmail = 'test@gmail.com';
  const tPassword = '123456';

  final tUser = AuthEntity(
    id: '1',
    fullName: 'Test User',
    username: 'test',
    email: tEmail,
    phoneNumber: '9800000000',
    token: 'token123',
  );

  setUpAll(() {
    registerFallbackValue(
      LoginUsecaseParams(email: 'a', password: 'b'),
    );

    registerFallbackValue(
      RegisterUsecaseParams(
        fullName: 'a',
        username: 'b',
        email: 'c',
        phoneNumber: 'd',
        password: 'e',
        profilePicture: null,
      ),
    );
  });

  setUp(() {
    mockLoginUsecase = MockLoginUsecase();
    mockRegisterUsecase = MockRegisterUsecase();

    container = ProviderContainer(
      overrides: [
        loginUseCaseProvider.overrideWith((ref) => mockLoginUsecase),
        registerUseCaseProvider.overrideWith((ref) => mockRegisterUsecase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthViewModel Unit Tests', () {
    test('initial state', () {
      final state = container.read(authViewModelProvider);
      expect(state.isLoading, false);
      expect(state.user, isNull);
      expect(state.error, isNull);
    });

    test('login success', () async {
      when(() => mockLoginUsecase(any()))
          .thenAnswer((_) async => Right(tUser));

      await container
          .read(authViewModelProvider.notifier)
          .login(email: tEmail, password: tPassword);

      final state = container.read(authViewModelProvider);

      expect(state.isLoading, false);
      expect(state.user, tUser);
      expect(state.error, isNull);

      verify(() => mockLoginUsecase(any())).called(1);
    });

    test('login failure', () async {
      when(() => mockLoginUsecase(any()))
          .thenAnswer((_) async => Left(ApiFailure(message: 'Login failed')));

      await container
          .read(authViewModelProvider.notifier)
          .login(email: tEmail, password: tPassword);

      final state = container.read(authViewModelProvider);

      expect(state.isLoading, false);
      expect(state.user, isNull);
      expect(state.error, 'Login failed');
    });

    test('register success', () async {
      when(() => mockRegisterUsecase(any()))
          .thenAnswer((_) async => const Right(true));

      await container.read(authViewModelProvider.notifier).register(
            fullName: 'Test',
            username: 'test',
            email: tEmail,
            phoneNumber: '9800000000',
            password: tPassword,
            profilePicture: null,
          );

      final state = container.read(authViewModelProvider);

      expect(state.isLoading, false);
      expect(state.user, isNull);
      expect(state.error, isNull);

      verify(() => mockRegisterUsecase(any())).called(1);
    });

    test('login emits loading first', () async {
      when(() => mockLoginUsecase(any()))
          .thenAnswer((_) async => Right(tUser));

      final notifier = container.read(authViewModelProvider.notifier);

      final future = notifier.login(email: tEmail, password: tPassword);

      expect(
        container.read(authViewModelProvider).isLoading,
        true,
      );

      await future;
    });
  });
}
