import 'package:chiya_sathi/core/constants/hive_table_constants.dart';
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

  AuthLocalDatasourceImpl(this.box);

  @override
  Future<void> saveUser(AuthHiveModel model) async {
    await box.put(HiveTableConstants.authBoxKey, model);
  }

  @override
  Future<void> saveToken(String token) async {
    await box.put(_tokenKey, token);
  }

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    return box.get(HiveTableConstants.authBoxKey) as AuthHiveModel?;
  }

  @override
  Future<String?> getToken() async {
    return box.get(_tokenKey) as String?;
  }

  @override
  Future<void> clearToken() async {
    await box.delete(HiveTableConstants.authBoxKey);
    await box.delete(_tokenKey);
  }
}
