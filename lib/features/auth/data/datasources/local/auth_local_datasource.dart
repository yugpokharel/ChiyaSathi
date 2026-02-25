import 'package:chiya_sathi/features/auth/data/models/auth_hive_model.dart';
import 'package:hive/hive.dart';

abstract class AuthLocalDatasource {
  Future<void> saveUser(AuthHiveModel model);
  Future<void> saveToken(String token);
  Future<AuthHiveModel?> getCurrentUser();
  Future<String?> getToken();
  Future<void> clearToken();
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  final Box box;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  AuthLocalDatasourceImpl(this.box);

  @override
  Future<void> saveUser(AuthHiveModel model) async {
    await box.put(_userKey, model);
  }

  @override
  Future<void> saveToken(String token) async {
    await box.put(_tokenKey, token);
  }

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    return box.get(_userKey) as AuthHiveModel?;
  }

  @override
  Future<String?> getToken() async {
    return box.get(_tokenKey) as String?;
  }

  @override
  Future<void> clearToken() async {
    await box.delete(_userKey);
    await box.delete(_tokenKey);
  }
}
