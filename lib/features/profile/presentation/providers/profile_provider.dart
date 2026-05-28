import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/profile_remote_datasource.dart';

/// Real-time stream of the Firestore user-profile document for [uid].
/// Emits `null` if the document does not exist yet.
///
/// Usage:
/// ```dart
/// final profileAsync = ref.watch(profileProvider(uid));
/// final photoUrl = profileAsync.valueOrNull?['photoUrl'] as String?;
/// ```
final profileProvider =
    StreamProvider.family<Map<String, dynamic>?, String>((ref, uid) {
  return ref.watch(profileRemoteDataSourceProvider).watchUserProfile(uid);
});
