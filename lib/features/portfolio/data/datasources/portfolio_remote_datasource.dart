import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/portfolio_item_model.dart';

final portfolioRemoteDataSourceProvider = Provider<PortfolioRemoteDataSource>(
  (_) => const PortfolioRemoteDataSource(),
);

/// Handles all Firestore operations for the portfolio feature.
///
/// Collection path: `users/{uid}/portfolio/{coinId}`
class PortfolioRemoteDataSource {
  const PortfolioRemoteDataSource();

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('portfolio');

  // ── Streams ───────────────────────────────────────────────────────

  /// Real-time stream of all portfolio items for [uid].
  Stream<List<PortfolioItemModel>> watchPortfolio(String uid) =>
      _col(uid).snapshots().map(
            (snap) => snap.docs
                .map((doc) => PortfolioItemModel.fromJson(doc.data()))
                .toList(),
          );

  // ── Mutations ─────────────────────────────────────────────────────

  /// Adds a new item or overwrites an existing one (upsert by [coinId]).
  Future<void> addOrUpdateItem(String uid, PortfolioItemModel item) =>
      _col(uid).doc(item.coinId).set(item.toJson());

  /// Removes the portfolio document for [coinId].
  Future<void> deleteItem(String uid, String coinId) =>
      _col(uid).doc(coinId).delete();

  /// Updates only the quantity field of an existing document.
  Future<void> updateQuantity(
    String uid,
    String coinId,
    double newQuantity,
  ) =>
      _col(uid).doc(coinId).update({'quantity': newQuantity});
}
