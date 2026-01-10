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
    if (!Hive.isAdapterRegistered(HiveTableConstants.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  Future<void> openBoxed() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstants.authTable);
  }

  // Delete all batches
  // Future<void> deleteAllBatches() async {
  //   await _batchBox.clear();
  // }

  // Close all boxes
  Future<void> close() async {
    await Hive.close();
  }

  // ==================== Batch CRUD Operations ====================

  // Get batch box
  // Box<BatchHiveModel> get _batchBox =>
  //     Hive.box<BatchHiveModel>(HiveTableConstant.batchTable);

  // // Create a new batch
  // Future<BatchHiveModel> createBatch(BatchHiveModel batch) async {
  //   await _batchBox.put(batch.batchId, batch);
  //   return batch;
  // }

  // // Get all batches
  // List<BatchHiveModel> getAllBatches() {
  //   return _batchBox.values.toList();
  // }

  // // Get batch by ID
  // BatchHiveModel? getBatchById(String batchId) {
  //   return _batchBox.get(batchId);
  // }

  // // Update a batch
  // Future<void> updateBatch(BatchHiveModel batch) async {
  //   await _batchBox.put(batch.batchId, batch);
  // }

  // // Delete a batch
  // Future<void> deleteBatch(String batchId) async {
  //   await _batchBox.delete(batchId);
  // }

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
