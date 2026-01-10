import 'package:chiya_sathi/core/constants/hive_table_constants.dart';
import 'package:chiya_sathi/features/auth/data/models/auth_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstants.dbName}';
    Hive.init(path);

    _registerAdapter();
    await openBoxed();
  }

  void _registerAdapter() {
    if (!Hive.isAdapterRegistered(HiveTableConstants.authtypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  Future<void> openBoxed() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstants.authTable);
  }

  Future<void> close() async {
    await Hive.close();
  }

 

  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstants.authTable);

  Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
    await _authBox.put(model.userId, model);
    return model;
  }

  //login user
  Future<AuthHiveModel?> loginUser(String email, String password) async {
    try {
      final users = _authBox.values.where(
        (user) =>
            user.email.toLowerCase() == email.toLowerCase() &&
            user.password == password,
      );

      if (users.isNotEmpty) {
        return users.first;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  //logout user
  Future<void> logoutUser() async {}

  //get current user
  AuthHiveModel? getCurrentUser(String userId) {
    return _authBox.get(userId);
  }

  //is email exists
  bool isEmailExists(String email) {
    final users = _authBox.values.where(
      (user) => user.email.toLowerCase() == email.toLowerCase(),
    );
    return users.isNotEmpty;
  }
}
