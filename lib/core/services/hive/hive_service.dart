// import 'package:chiya_sathi/core/constants/hive_table_constants.dart';
// import 'package:chiya_sathi/features/auth/data/models/auth_hive_model.dart';
// import 'package:hive/hive.dart';
// import 'package:path_provider/path_provider.dart';

// class HiveService {
//   Future<void> init() async {
//     final directory = await getApplicationDocumentsDirectory();
//     final path = '${directory.path}/${HiveTableConstants.dbName}';
//     Hive.init(path);

//     _registerAdapter();
//     await _openBoxes();
//   }

//   void _registerAdapter() {
//     if (!Hive.isAdapterRegistered(HiveTableConstants.authtypeId)) {
//       Hive.registerAdapter(AuthHiveModelAdapter());
//     }
//   }

//   Future<void> _openBoxes() async {
//     await Hive.openBox<AuthHiveModel>(HiveTableConstants.authTable);
//   }

//   Future<void> close() async {
//     await Hive.close();
//   }

//   Box<AuthHiveModel> get _authBox =>
//       Hive.box<AuthHiveModel>(HiveTableConstants.authTable);

//   Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
//     await _authBox.put(model.email, model);
//     return model;
//   }

//   Future<AuthHiveModel?> loginUser(String email, String password) async {
//     final users = _authBox.values.where(
//       (user) =>
//           user.email.toLowerCase() == email.toLowerCase() &&
//           user.password == password,
//     );

//     if (users.isNotEmpty) {
//       return users.first;
//     }
//     return null;
//   }

//   Future<void> logoutUser() async {
//     await _authBox.clear();
//   }

//   AuthHiveModel? getCurrentUser(String userId) {
//     return _authBox.get(userId);
//   }

//   bool isEmailExists(String email) {
//     final users = _authBox.values.where(
//       (user) => user.email.toLowerCase() == email.toLowerCase(),
//     );
//     return users.isNotEmpty;
//   }
// }
