import 'package:chiya_sathi/core/error/failures.dart';
import 'package:chiya_sathi/core/usecase/app_usecase.dart';
import 'package:chiya_sathi/features/auth/data/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../entities/auth_entity.dart';
import 'package:equatable/equatable.dart';

class RegisterUsecaseParams extends Equatable {
  final String fullName;
  final String userName;
  final String email;
  final String phoneNumber;
  final String password;
  final String? profileImage;

  RegisterUsecaseParams({
    required this.fullName,
    required this.userName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    this.profileImage,
  });

  @override
  List<Object?> get props => [fullName, userName, email, phoneNumber, password, profileImage];
}

final RegisterUsecaseProvider = Provider<RegisterUsecase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUsecase(authRepository: repository);
});

class RegisterUsecase implements UsecaseWithParams<bool, RegisterUsecaseParams> {
  final IAuthRepository _authRepository;

  RegisterUsecase({required IAuthRepository authRepository}) : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) {
    final entity = AuthEntity(
      fullName: params.fullName,
      userName: params.userName,
      email: params.email,
      phoneNumber: params.phoneNumber,
      password: params.password, username: '', token: '',
    );
    return _authRepository.register(entity);
  }
}
