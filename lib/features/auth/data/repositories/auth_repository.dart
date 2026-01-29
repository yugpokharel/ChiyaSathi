import 'package:chiya_sathi/core/error/failures.dart';
import 'package:chiya_sathi/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:chiya_sathi/features/auth/data/models/auth_hive_model.dart';
import 'package:chiya_sathi/features/auth/domain/entities/auth_entity.dart';
import 'package:chiya_sathi/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class AuthRepository implements IAuthRepository {
  final AuthLocalDatasource _authDatasource;

  AuthRepository({required AuthLocalDatasource authDatasource})
      : _authDatasource = authDatasource;

  @override
  Future<Either<Failure, bool>> register(AuthEntity authEntity) async {
    try {
      final model = AuthHiveModel.fromEntity(authEntity);
      await _authDatasource.saveUser(model);
      return const Right(true);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) async {
    try {
      final model = await _authDatasource.getCurrentUser();
      if (model != null && model.email == email && model.password == password) {
        return Right(model.toEntity());
      }
      return const Left(LocalDatabaseFailure(message: "Invalid email or password"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final model = await _authDatasource.getCurrentUser();
      if (model != null) return Right(model.toEntity());
      return const Left(LocalDatabaseFailure(message: "No user found"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      await _authDatasource.clearToken();
      return const Right(true);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
