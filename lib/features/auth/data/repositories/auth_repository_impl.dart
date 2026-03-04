import 'dart:async';
import 'dart:io';
import 'package:chiya_sathi/core/error/exception.dart';
import 'package:chiya_sathi/core/error/failures.dart';
import 'package:chiya_sathi/core/network/network_info.dart';
import 'package:chiya_sathi/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:chiya_sathi/features/auth/data/datasources/remote/auth_remote_datasources.dart';
import 'package:chiya_sathi/features/auth/data/models/auth_hive_model.dart';
import 'package:chiya_sathi/features/auth/domain/entities/auth_entity.dart';
import 'package:chiya_sathi/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDatasource remoteDataSource;
  final AuthLocalDatasource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, AuthEntity>> login(
      String email, String password) async {
    // Always try remote first — don't rely on connectivity_plus
    String? remoteError;
    try {
      final remoteData = await remoteDataSource.login(email, password);
      final user = AuthEntity.fromJson(remoteData['user']);
      final token = remoteData['token'] as String;
      // Build user with token + password for offline login
      final userWithToken = AuthEntity(
        id: user.id,
        fullName: user.fullName,
        username: user.username,
        email: user.email,
        phoneNumber: user.phoneNumber,
        password: password,
        token: token,
        profilePicture: user.profilePicture,
        role: user.role,
      );
      await localDataSource.saveUser(AuthHiveModel.fromEntity(userWithToken));
      await localDataSource.saveToken(token);
      return Right(userWithToken);
    } on ServerException catch (e) {
      // Actual API error (wrong credentials, etc.) — return immediately
      return Left(ServerFailure(e.message));
    } on SocketException {
      remoteError = 'Cannot reach server';
    } on TimeoutException {
      remoteError = 'Server timed out';
    } catch (e) {
      remoteError = e.toString();
      print('Remote login error: $e');
    }

    // Remote failed (network issue) — try local Hive login
    try {
      final localUser = await localDataSource.getCurrentUser();
      if (localUser != null &&
          localUser.email == email &&
          localUser.password == password) {
        return Right(localUser.toEntity());
      } else {
        return Left(
            ConnectionFailure('$remoteError. No cached user available.'));
      }
    } catch (e) {
      return Left(
          ConnectionFailure('$remoteError. Local login also failed.'));
    }
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity authEntity) async {
    try {
      await remoteDataSource.register(
        email: authEntity.email,
        password: authEntity.password!,
        fullName: authEntity.fullName,
        username: authEntity.username,
        phoneNumber: authEntity.phoneNumber,
        role: authEntity.role,
        profilePicture: authEntity.profilePicture != null
            ? File(authEntity.profilePicture!)
            : null,
      );
      await localDataSource.saveUser(AuthHiveModel.fromEntity(authEntity));
      return const Right(true);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on SocketException {
      return const Left(ConnectionFailure('No internet connection'));
    } on TimeoutException {
      return const Left(ConnectionFailure('Server timed out. Please try again.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final localUser = await localDataSource.getCurrentUser();
      if (localUser != null) {
        return Right(localUser.toEntity());
      }
      return const Left(LocalDatabaseFailure("No user found"));
    } catch (e) {
      return Left(LocalDatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      await localDataSource.clearToken();
      return const Right(true);
    } catch (e) {
      return Left(LocalDatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> updateProfilePicture(File image) async {
    try {
      final token = await localDataSource.getToken();
      if (token == null) {
        return const Left(ServerFailure('Not authenticated'));
      }
      final newUrl = await remoteDataSource.updateProfilePicture(token, image);
      return Right(newUrl);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on SocketException {
      return const Left(ConnectionFailure('No internet connection'));
    } on TimeoutException {
      return const Left(ConnectionFailure('Server timed out. Please try again.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
