import 'package:chiya_sathi/core/error/failures.dart';
import 'package:chiya_sathi/core/usecase/app_usecase.dart';
import 'package:chiya_sathi/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import '../entities/auth_entity.dart';
import 'package:equatable/equatable.dart';
import 'dart:io';

// Params
class RegisterUsecaseParams extends Equatable {
  final String fullName;
  final String username;
  final String email;
  final String phoneNumber;
  final String password;
  final File? profilePicture;

  const RegisterUsecaseParams({
    required this.fullName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.password,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [fullName, username, email, phoneNumber, password, profilePicture];
}

// Usecase
class RegisterUsecase implements Usecase<bool, RegisterUsecaseParams> {
  final IAuthRepository _authRepository;

  RegisterUsecase(this._authRepository);

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) async {
    final entity = AuthEntity(
      fullName: params.fullName,
      username: params.username,
      email: params.email,
      phoneNumber: params.phoneNumber,
      password: params.password,
      token: null,
      profilePicture: params.profilePicture?.path,
    );
    return await _authRepository.register(entity);
  }
}
