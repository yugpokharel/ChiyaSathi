import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasources.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/auth_repository_impl.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

final hiveBoxProvider = Provider<Box>((ref) {
  try {
    return Hive.box('authBox');
  } catch (e) {
    throw Exception('AuthBox not initialized. Make sure Hive.openBox("authBox") is called in main(). Error: $e');
  }
});

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasourceImpl(client: http.Client());
});

final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final box = ref.read(hiveBoxProvider);
  return AuthLocalDatasourceImpl(box);
});

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final remote = ref.read(authRemoteDatasourceProvider);
  final local = ref.read(authLocalDatasourceProvider);

  return AuthRepositoryImpl(
    remote: remote,
    local: local,
  );
});

final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return LoginUsecase(authRepository: repo);
});

final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return RegisterUsecase(authRepository: repo);
});
