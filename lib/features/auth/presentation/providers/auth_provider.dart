import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../domain/models/app_user_model.dart';

// ── Source of truth ───────────────────────────────────────────────────────────

/// Live Firebase auth stream.  The router and any widget that needs to know
/// "is the user logged in?" should watch this provider.
final authStateProvider = StreamProvider<AppUserModel?>((ref) {
  return ref.watch(authRemoteDataSourceProvider).authStateChanges;
});

// ── Action notifier ───────────────────────────────────────────────────────────

/// Exposes sign-in / sign-up / sign-out actions and their loading / error
/// states.  Auth screens listen to this for error snackbars and loading
/// indicators; the router watches [authStateProvider] for navigation.
final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, AppUserModel?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<AppUserModel?> {
  AuthRemoteDataSource get _ds => ref.read(authRemoteDataSourceProvider);

  @override
  Future<AppUserModel?> build() async {
    // Initialise synchronously from the cached Firebase current-user value.
    return _ds.currentUser;
  }

  /// Signs in with email + password.
  /// On failure the state becomes [AsyncError] with an [AppException].
  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _ds.signIn(email, password));
  }

  /// Creates a new account with email + password.
  Future<void> signUp(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _ds.signUp(email, password));
  }

  /// Signs out the current user and clears the notifier state.
  Future<void> signOut() async {
    state = const AsyncLoading();
    await _ds.signOut();
    state = const AsyncData(null);
  }

  /// Sends a password-reset email.  Errors propagate as [AppException].
  Future<void> sendPasswordReset(String email) async {
    await _ds.sendPasswordResetEmail(email);
  }
}
