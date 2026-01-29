import 'package:chiya_sathi/core/error/failures.dart';
import 'package:chiya_sathi/core/usecase/app_usecase.dart';
import 'package:chiya_sathi/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import '../entities/auth_entity.dart';
import 'package:equatable/equatable.dart';

// Params
class RegisterUsecaseParams extends Equatable {
  final String fullName;
  final String username;
  final String email;
  final String phoneNumber;
  final String password;

  const RegisterUsecaseParams({
    required this.fullName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });

  @override
  List<Object?> get props => [fullName, username, email, phoneNumber, password];
}

// Usecase
class RegisterUsecase implements UsecaseWithParams<bool, RegisterUsecaseParams> {
  final IAuthRepository _authRepository;

  RegisterUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) {
    final entity = AuthEntity(
      fullName: params.fullName,
      username: params.username,
      email: params.email,
      phoneNumber: params.phoneNumber,
      password: params.password,
      token: null,
    );
    return _authRepository.register(entity);
  }
}
