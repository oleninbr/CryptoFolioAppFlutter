import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_exception.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>(
  (_) => const ProfileRemoteDataSource(),
);

class ProfileRemoteDataSource {
  const ProfileRemoteDataSource();

  FirebaseFirestore get _db => FirebaseFirestore.instance;
  FirebaseStorage get _storage => FirebaseStorage.instance;

  Future<String> uploadProfilePhoto(String uid, File photo) async {
    try {
      final ref = _storage.ref('users/$uid/profile_photo.jpg');
      await ref.putFile(
        photo,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw AppException(
        message: e.message ?? 'Photo upload failed.',
        type: AppExceptionType.server,
      );
    }
  }

  Future<void> updateUserProfile(
    String uid, {
    String? photoUrl,
    String? displayName,
  }) async {
    final data = <String, dynamic>{
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (displayName != null) 'displayName': displayName,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  Stream<Map<String, dynamic>?> watchUserProfile(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snap) => snap.exists ? snap.data() : null);
  }
}
