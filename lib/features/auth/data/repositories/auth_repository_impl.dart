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
    // Always try remote first if connected
    if (await networkInfo.isConnected) {
      try {
        final remoteData = await remoteDataSource.login(email, password);
        final user = AuthEntity.fromJson(remoteData['user']);
        // Save user with password so offline login works later
        final userWithPassword = AuthEntity(
          id: user.id,
          fullName: user.fullName,
          username: user.username,
          email: user.email,
          phoneNumber: user.phoneNumber,
          password: password,
          token: user.token,
          profilePicture: user.profilePicture,
        );
        await localDataSource.saveUser(AuthHiveModel.fromEntity(userWithPassword));
        await localDataSource.saveToken(remoteData['token']);
        return Right(user);
      } catch (_) {
        // Remote failed (server down, timeout, etc.) — fall through to local login
      }
    }

    // Offline or remote failed — try local Hive login
    try {
      final localUser = await localDataSource.getCurrentUser();
      if (localUser != null &&
          localUser.email == email &&
          localUser.password == password) {
        return Right(localUser.toEntity());
      } else {
        return const Left(
            ConnectionFailure('Invalid credentials or no cached user'));
      }
    } catch (e) {
      return const Left(
          LocalDatabaseFailure('Error logging in locally'));
    }
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity authEntity) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.register(
          email: authEntity.email,
          password: authEntity.password!,
          fullName: authEntity.fullName,
          username: authEntity.username,
          phoneNumber: authEntity.phoneNumber,
        );
        await localDataSource.saveUser(AuthHiveModel.fromEntity(authEntity));
        return const Right(true);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(ConnectionFailure('No internet connection'));
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
}
