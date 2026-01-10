import 'package:chiya_sathi/core/constants/hive_table_constants.dart';
import 'package:chiya_sathi/features/auth/domain/entities/auth_entity.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstants.authtypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String? userId;

  @HiveField(1)
  final String? userName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? password;

  @HiveField(4)
  final String? profileImage;

  AuthHiveModel({
    String? userId,
    required this.email,
    this.profileImage,
    this.userName,
    this.password,
  }) : userId = userId ?? Uuid().v4();

  //from entity to hive model
  factory AuthHiveModel.fromEntity(AuthEntity authEntity) {
    return AuthHiveModel(
      userId: authEntity.userId,
      email: authEntity.email,
      profileImage: authEntity.profileImage,
      userName: authEntity.userName,
      password: authEntity.password,
    );
  }

  //to entity
  AuthEntity toEntity() {
    return AuthEntity(
      userId: userId,
      email: email,
      profileImage: profileImage,
      userName: userName,
      password: password,
    );
  }

  //To entity list
  static List<AuthEntity> toEntityList(List<AuthHiveModel> hiveModels) {
    return hiveModels.map((model) => model.toEntity()).toList();
  }
}
