import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_exception.dart';
import '../../domain/models/app_user_model.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (_) => const AuthRemoteDataSource(),
);

class AuthRemoteDataSource {
  const AuthRemoteDataSource();

  FirebaseAuth get _auth => FirebaseAuth.instance;

  AppUserModel _mapUser(User user) => AppUserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );

  AppException _mapError(FirebaseAuthException e) {
    final message = switch (e.code) {
      'user-not-found'          => 'No account found for this email.',
      'wrong-password'          => 'Incorrect password.',
      'invalid-credential'      => 'Invalid email or password.',
      'invalid-email'           => 'The email address is invalid.',
      'email-already-in-use'    => 'An account already exists for this email.',
      'weak-password'           => 'Password must be at least 6 characters.',
      'user-disabled'           => 'This account has been disabled.',
      'too-many-requests'       => 'Too many attempts. Please try again later.',
      'network-request-failed'  => 'No internet connection.',
      'operation-not-allowed'   => 'This sign-in method is not enabled.',
      _                         => 'Authentication failed. Please try again.',
    };
    return AppException(message: message, type: AppExceptionType.auth);
  }

  Future<AppUserModel> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _mapUser(cred.user!);
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  Future<AppUserModel> signUp(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _mapUser(cred.user!);
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  Stream<AppUserModel?> get authStateChanges =>
      _auth.authStateChanges().map(
            (user) => user == null ? null : _mapUser(user),
          );

  AppUserModel? get currentUser {
    final user = _auth.currentUser;
    return user == null ? null : _mapUser(user);
  }
}
