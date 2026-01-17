import 'package:chiya_sathi/core/constants/hive_table_constants.dart';
import 'package:chiya_sathi/features/auth/data/models/auth_hive_model.dart';
import 'package:hive/hive.dart';

abstract interface class AuthLocalDatasource {
  Future<void> saveUser(AuthHiveModel model);
  Future<AuthHiveModel?> getCurrentUser();
  Future<void> logout();
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  final Box<AuthHiveModel> box;

  AuthLocalDatasourceImpl(this.box);

  @override
  Future<void> saveUser(AuthHiveModel model) async {
    await box.put(HiveTableConstants.authBoxKey, model);
  }

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    return box.get(HiveTableConstants.authBoxKey);
  }

  @override
  Future<void> logout() async {
    await box.delete(HiveTableConstants.authBoxKey);
  }
}
