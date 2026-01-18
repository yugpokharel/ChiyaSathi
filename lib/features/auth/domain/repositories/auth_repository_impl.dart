import 'dart:io';
import 'package:chiya_sathi/core/error/failures.dart';
import 'package:chiya_sathi/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:chiya_sathi/features/auth/data/datasources/remote/auth_remote_datasources.dart';
import 'package:chiya_sathi/features/auth/data/repositories/auth_repository.dart';
import 'package:chiya_sathi/features/auth/domain/entities/auth_entity.dart';
import 'package:chiya_sathi/features/auth/presentation/pages/login_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remote;
  final AuthLocalDatasource local;

  AuthRepositoryImpl({required this.remote, required this.local});

  Future<void> LoginScreen(String email, String password) async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult != ConnectivityResult.none) {
      try {
        final token = await remote.login(email, password);

        await local.saveToken(token);
      } on SocketException {
        return _offlineFallback();
      } catch (e) {

        rethrow;
      }
    } 

    else {
      return _offlineFallback();
    }
  }

  Future<void> _offlineFallback() async {
    final cachedToken = local.getToken();
    if (cachedToken != null) {

      return; 
    } else {
      throw Exception("No internet connection and no saved session found.");
    }
  }

  @override
  Future<void> signup(String email, String password, String confirmPassword) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception("Cannot create account while offline.");
    }
    
    await remote.signup(email, password, confirmPassword);
  }

  @override
  bool isLoggedIn() {
    return local.getToken() != null;
  }

  @override
  void logout() {
    local.clearToken();
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity authEntity) {
    // TODO: implement register
    throw UnimplementedError();
  }
}