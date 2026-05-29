import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../domain/models/app_user_model.dart';

final authStateProvider = StreamProvider<AppUserModel?>((ref) {
  return ref.watch(authRemoteDataSourceProvider).authStateChanges;
});

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, AppUserModel?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<AppUserModel?> {
  AuthRemoteDataSource get _ds => ref.read(authRemoteDataSourceProvider);

  @override
  Future<AppUserModel?> build() async {

    return _ds.currentUser;
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _ds.signIn(email, password));
  }

  Future<void> signUp(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _ds.signUp(email, password));
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    await _ds.signOut();
    state = const AsyncData(null);
  }

  Future<void> sendPasswordReset(String email) async {
    await _ds.sendPasswordResetEmail(email);
  }
}
