import 'package:chiya_sathi/core/error/failures.dart';
import 'package:chiya_sathi/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:chiya_sathi/features/auth/data/datasources/remote/auth_remote_datasources.dart';
import 'package:chiya_sathi/features/auth/domain/entities/auth_entity.dart';
import 'package:chiya_sathi/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'dart:io';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDatasource remote;
  final AuthLocalDatasource local;

  AuthRepositoryImpl({
    required this.remote,
    required this.local,
  });

  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) async {
    try {
      final token = await remote.login(email, password);

      await local.saveToken(token);

      return Right(
        AuthEntity(
          id: null,
          fullName: '',
          username: '',
          email: email,
          phoneNumber: '',
          token: token,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    try {
      await remote.register(
        email: entity.email,
        password: entity.password ?? '',
        fullName: entity.fullName,
        username: entity.username,
        phoneNumber: entity.phoneNumber,
        profilePicture: entity.profilePicture != null 
          ? File(entity.profilePicture!) 
          : null,
      );
      return const Right(true);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      await local.clearToken();
      return const Right(true);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final token = await local.getToken();
      if (token == null) {
        return const Left(LocalDatabaseFailure(message: 'No session found'));
      }

      final user = await remote.getCurrentUser(token);
      return Right(user);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
