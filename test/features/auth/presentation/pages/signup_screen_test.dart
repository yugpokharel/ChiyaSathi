import 'package:chiya_sathi/core/error/failures.dart';
import 'package:chiya_sathi/features/auth/domain/entities/auth_entity.dart';
import 'package:chiya_sathi/features/auth/domain/repositories/auth_repository.dart';
import 'package:chiya_sathi/features/auth/domain/usecases/register_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late RegisterUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = RegisterUsecase(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(
      const AuthEntity(
        username: 'fallback',
        email: 'fallbackcom',
        password: 'fallback123',
        fullName: '',
        phoneNumber: '',
      ),
    );
  });

  group('RegisterUsecase', () {
    const tUsername = 'john_doe';
    const tEmail = 'john.doe@example.com';
    const tPassword = 'SecurePass123!';
    const tFullName = 'John Doe';
    const tPhoneNumber = '+9779841234567';

    test('should return Right(true) when registration is successful', () async {
      when(() => mockRepository.register(any())).thenAnswer((_) async => const Right(true));

      final result = await usecase(
        const RegisterUsecaseParams(
          username: tUsername,
          email: tEmail,
          password: tPassword,
          fullName: tFullName,
          phoneNumber: tPhoneNumber,
        ),
      );

      expect(result, const Right(true));
      verify(() => mockRepository.register(any())).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should pass correct AuthEntity with provided values to the repository', () async {
      AuthEntity? capturedEntity;

      when(() => mockRepository.register(any())).thenAnswer((invocation) async {
        capturedEntity = invocation.positionalArguments[0] as AuthEntity;
        return const Right(true);
      });

      await usecase(
        const RegisterUsecaseParams(
          username: tUsername,
          email: tEmail,
          password: tPassword,
          fullName: tFullName,
          phoneNumber: tPhoneNumber,
        ),
      );

      expect(capturedEntity, isNotNull);
      expect(capturedEntity?.username, tUsername);
      expect(capturedEntity?.email, tEmail);
      expect(capturedEntity?.password, tPassword);
      expect(capturedEntity?.fullName, tFullName);
      expect(capturedEntity?.phoneNumber, tPhoneNumber);
    });

    test('should return Left(Failure) when repository returns failure', () async {
      final tFailure = ApiFailure(
        message: 'Email already exists',
        statusCode: 409,  
      );

      when(() => mockRepository.register(any())).thenAnswer((_) async => Left(tFailure));

      final result = await usecase(
        const RegisterUsecaseParams(
          username: tUsername,
          email: tEmail,
          password: tPassword,
          fullName: tFullName,
          phoneNumber: tPhoneNumber,
        ),
      );

      expect(result, Left(tFailure));
      verify(() => mockRepository.register(any())).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}