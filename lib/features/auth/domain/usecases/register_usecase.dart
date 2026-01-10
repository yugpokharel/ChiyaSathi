import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/usecase/app_usecase.dart';
import 'package:click_shop/features/auth/data/repositories/auth_repository.dart';
import 'package:click_shop/features/auth/domain/entities/auth_entity.dart';
import 'package:click_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterUsecaseParams extends Equatable {
  final String userName;
  final String email;
  final String password;
  final String? profileImage;

  RegisterUsecaseParams({
    required this.userName,
    required this.email,
    required this.password,
    required this.profileImage,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [userName, email, password, profileImage];
}

//provider for Register usecase
final RegisterUsecaseProvider = Provider<RegisterUsecase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return RegisterUsecase(authRepository: authRepository);
});

class RegisterUsecase
    implements UsecaseWithParams<bool, RegisterUsecaseParams> {
  final IAuthRepository _authRepository;

  RegisterUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) {
    final authEntity = AuthEntity(
      userName: params.userName,
      email: params.email,
      password: params.password,
      profileImage: params.profileImage,
    );
    return _authRepository.register(authEntity);
  }
}
