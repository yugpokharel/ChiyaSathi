import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_view_model.dart';
import '../state/auth_state.dart';


final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  () => AuthViewModel(),
);
