import 'package:chiya_sathi/core/error/failures.dart';
import 'package:chiya_sathi/core/usecase/app_usecase.dart';
import 'package:chiya_sathi/features/auth/data/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../entities/auth_entity.dart';
import 'package:equatable/equatable.dart';

class LoginUsecaseParams extends Equatable {
  final String email;
  final String password;

  LoginUsecaseParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

final LoginUsecaseProvider = Provider<LoginUsecase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUsecase(authRepository: repository);
});

class LoginUsecase implements UsecaseWithParams<AuthEntity, LoginUsecaseParams> {
  final IAuthRepository _authRepository;

  LoginUsecase({required IAuthRepository authRepository}) : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(LoginUsecaseParams params) {
    return _authRepository.login(params.email, params.password);
  }
}
