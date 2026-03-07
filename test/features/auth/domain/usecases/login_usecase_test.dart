import 'package:chiya_sathi/features/auth/domain/entities/auth_entity.dart';
import 'package:chiya_sathi/features/auth/domain/repositories/auth_repository.dart';
import 'package:chiya_sathi/features/auth/domain/usecases/login_usecase.dart';
import 'package:chiya_sathi/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LoginUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUsecase(mockRepository);
  });

  const tEmail = 'test@test.com';
  const tPassword = 'password123';
  final tUser = AuthEntity(
    id: '1',
    fullName: 'Test User',
    username: 'test',
    email: tEmail,
    phoneNumber: '9800000000',
    token: 'jwt-token',
  );

  group('LoginUsecase', () {
    test('should return AuthEntity on successful login', () async {
      when(() => mockRepository.login(tEmail, tPassword))
          .thenAnswer((_) async => Right(tUser));

      final result = await usecase(
        const LoginUsecaseParams(email: tEmail, password: tPassword),
      );

      expect(result, Right(tUser));
      verify(() => mockRepository.login(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Failure on login error', () async {
      const failure = ApiFailure(message: 'Invalid credentials');
      when(() => mockRepository.login(tEmail, tPassword))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase(
        const LoginUsecaseParams(email: tEmail, password: tPassword),
      );

      expect(result, const Left(failure));
      verify(() => mockRepository.login(tEmail, tPassword)).called(1);
    });

    test('LoginUsecaseParams supports equality', () {
      const params1 = LoginUsecaseParams(email: 'a', password: 'b');
      const params2 = LoginUsecaseParams(email: 'a', password: 'b');
      expect(params1, equals(params2));
    });

    test('LoginUsecaseParams props are correct', () {
      const params = LoginUsecaseParams(email: 'e', password: 'p');
      expect(params.props, ['e', 'p']);
    });
  });
}
