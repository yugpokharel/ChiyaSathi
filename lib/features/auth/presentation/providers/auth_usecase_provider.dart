import 'package:chiya_sathi/features/auth/domain/usecases/login_usecase.dart';
import 'package:chiya_sathi/features/auth/domain/usecases/register_usecase.dart';
import 'package:chiya_sathi/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loginUseCaseProvider = Provider<LoginUsecase>(
  (ref) => LoginUsecase(ref.watch(authRepositoryProvider)),
);

final registerUseCaseProvider = Provider<RegisterUsecase>(
  (ref) => RegisterUsecase(ref.watch(authRepositoryProvider)),
);
