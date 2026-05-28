import 'package:cloud_firestore/cloud_firestore.dart';

/// A single coin holding in the user's portfolio.
///
/// Stored in Firestore at `users/{uid}/portfolio/{coinId}`.
/// The Firestore document ID equals [coinId], so [id] == [coinId].
class PortfolioItemModel {
  const PortfolioItemModel({
    required this.id,
    required this.coinId,
    required this.coinName,
    required this.coinSymbol,
    required this.coinImage,
    required this.quantity,
    required this.buyPrice,
    required this.addedAt,
  });

  /// Firestore document ID (equals [coinId]).
  final String id;

  /// CoinGecko coin identifier (e.g. "bitcoin", "ethereum").
  final String coinId;

  final String coinName;
  final String coinSymbol;
  final String coinImage;

  /// Number of coins held.
  final double quantity;

  /// Purchase price per coin in USD.
  final double buyPrice;

  final DateTime addedAt;

  // ── Computed fields (not stored in Firestore) ────────────────────

  double get totalInvested => quantity * buyPrice;

  double currentValue(double currentPrice) => quantity * currentPrice;

  double profitLoss(double currentPrice) =>
      currentValue(currentPrice) - totalInvested;

  double profitLossPercent(double currentPrice) {
    if (totalInvested == 0) return 0;
    return (profitLoss(currentPrice) / totalInvested) * 100;
  }

  // ── Serialisation ────────────────────────────────────────────────

  factory PortfolioItemModel.fromJson(Map<String, dynamic> json) {
    final addedAtRaw = json['addedAt'];
    final DateTime addedAt;
    if (addedAtRaw is Timestamp) {
      addedAt = addedAtRaw.toDate();
    } else if (addedAtRaw is String) {
      addedAt = DateTime.tryParse(addedAtRaw) ?? DateTime.now();
    } else {
      addedAt = DateTime.now();
    }

    final cid = json['coinId'] as String? ?? '';
    return PortfolioItemModel(
      id: cid,
      coinId: cid,
      coinName: json['coinName'] as String? ?? '',
      coinSymbol: json['coinSymbol'] as String? ?? '',
      coinImage: json['coinImage'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      buyPrice: (json['buyPrice'] as num?)?.toDouble() ?? 0.0,
      addedAt: addedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'coinId': coinId,
        'coinName': coinName,
        'coinSymbol': coinSymbol,
        'coinImage': coinImage,
        'quantity': quantity,
        'buyPrice': buyPrice,
        'addedAt': Timestamp.fromDate(addedAt),
      };

  // ── copyWith ─────────────────────────────────────────────────────

  PortfolioItemModel copyWith({
    String? id,
    String? coinId,
    String? coinName,
    String? coinSymbol,
    String? coinImage,
    double? quantity,
    double? buyPrice,
    DateTime? addedAt,
  }) =>
      PortfolioItemModel(
        id: id ?? this.id,
        coinId: coinId ?? this.coinId,
        coinName: coinName ?? this.coinName,
        coinSymbol: coinSymbol ?? this.coinSymbol,
        coinImage: coinImage ?? this.coinImage,
        quantity: quantity ?? this.quantity,
        buyPrice: buyPrice ?? this.buyPrice,
        addedAt: addedAt ?? this.addedAt,
      );
}
