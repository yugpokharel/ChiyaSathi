import 'package:chiya_sathi/core/constants/hive_table_constants.dart';
import 'package:chiya_sathi/features/auth/domain/entities/auth_entity.dart';
import 'package:hive/hive.dart';


@HiveType(typeId: HiveTableConstants.authtypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String username;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String phoneNumber;

  @HiveField(5)
  final String? profileImage;

  @HiveField(6)
  final String? batchId;

  @HiveField(7)
  final String? password; // added to store locally if needed

  AuthHiveModel({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    this.profileImage,
    this.batchId,
    this.password,
  });

  // From Entity → Hive
  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      id: entity.id ?? '',
      fullName: entity.fullName,
      username: entity.username,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      password: entity.password,
    );
  }

  // Hive → Entity
  AuthEntity toEntity() {
    return AuthEntity(
      id: id,
      fullName: fullName,
      username: username,
      email: email,
      phoneNumber: phoneNumber,
      token: null,
      password: password,
    );
  }

  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((e) => e.toEntity()).toList();
  }
}
