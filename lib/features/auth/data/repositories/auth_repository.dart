import 'package:chiya_sathi/core/error/failures.dart';
import 'package:chiya_sathi/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:chiya_sathi/features/auth/data/datasources/remote/auth_remote_datasources.dart';
import 'package:chiya_sathi/features/auth/data/models/auth_api_model.dart';
import 'package:chiya_sathi/features/auth/data/models/auth_hive_model.dart';
import 'package:chiya_sathi/features/auth/domain/entities/auth_entity.dart';
import 'package:chiya_sathi/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final remote = ref.watch(authRemoteDatasourceProvider);
  final local = ref.watch(authLocalDatasourceProvider);
  return AuthRepository(
    remoteDatasource: remote,
    localDatasource: local,
  );
});

class AuthRepository implements IAuthRepository {
  final AuthRemoteDatasource remoteDatasource;
  final AuthLocalDatasource localDatasource;

  AuthRepository({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final apiModel = await remoteDatasource.login(email, password);
      final hiveModel = AuthHiveModel.fromEntity(apiModel.toEntity());

      await localDatasource.saveUser(hiveModel);

      return Right(apiModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity authEntity) async {
    try {
      final apiModel = AuthApiModel.fromEntity(authEntity);
      await remoteDatasource.register(apiModel);
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final model = await localDatasource.getCurrentUser();
      if (model == null) {
        return Left(LocalDatabaseFailure(message: "User not found"));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      await localDatasource.logout();
      return const Right(true);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
