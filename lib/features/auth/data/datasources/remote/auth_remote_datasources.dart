import 'package:chiya_sathi/features/auth/data/models/auth_api_model.dart';
import 'package:dio/dio.dart';

abstract interface class AuthRemoteDatasource {
  Future<AuthApiModel> login(String email, String password);
  Future<void> register(AuthApiModel model);
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final Dio dio;

  AuthRemoteDatasourceImpl(this.dio);

  @override
  Future<AuthApiModel> login(String email, String password) async {
    final response = await dio.post(
      '/auth/login',
      data: {
        "email": email,
        "password": password,
      },
    );

    return AuthApiModel.fromJson(response.data['data']);
  }

  @override
  Future<void> register(AuthApiModel model) async {
    await dio.post(
      '/auth/register',
      data: model.toJson(),
    );
  }
}
