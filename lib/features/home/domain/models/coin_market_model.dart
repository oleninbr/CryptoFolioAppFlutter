
class CoinMarketModel {
  const CoinMarketModel({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    required this.currentPrice,
    required this.marketCap,
    required this.marketCapRank,
    this.priceChangePercentage24h,
    this.totalVolume,
    this.ath,
  });

  final String id;
  final String symbol;
  final String name;
  final String image;
  final double currentPrice;
  final double marketCap;
  final int    marketCapRank;
  final double? priceChangePercentage24h;
  final double? totalVolume;
  final double? ath;

  factory CoinMarketModel.fromJson(Map<String, dynamic> json) {
    return CoinMarketModel(
      id:           json['id']     as String,
      symbol:       json['symbol'] as String? ?? '',
      name:         json['name']   as String? ?? '',
      image:        json['image']  as String? ?? '',
      currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      marketCap:    (json['market_cap']    as num?)?.toDouble() ?? 0.0,
      marketCapRank: json['market_cap_rank'] as int? ?? 0,
      priceChangePercentage24h:
          (json['price_change_percentage_24h'] as num?)?.toDouble(),
      totalVolume: (json['total_volume'] as num?)?.toDouble(),
      ath:         (json['ath']          as num?)?.toDouble(),
    );
  }

  factory CoinMarketModel.fromSearchJson(Map<String, dynamic> json) {
    return CoinMarketModel(
      id:           json['id']     as String,
      symbol:       (json['symbol'] as String? ?? '').toLowerCase(),
      name:         json['name']   as String? ?? '',

      image:        json['large']  as String? ??
                    json['thumb']  as String? ?? '',
      currentPrice: 0.0,
      marketCap:    0.0,
      marketCapRank: json['market_cap_rank'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id':            id,
        'symbol':        symbol,
        'name':          name,
        'image':         image,
        'current_price': currentPrice,
        'market_cap':    marketCap,
        'market_cap_rank': marketCapRank,
        'price_change_percentage_24h': priceChangePercentage24h,
        'total_volume':  totalVolume,
        'ath':           ath,
      };

  CoinMarketModel copyWith({
    String? id,
    String? symbol,
    String? name,
    String? image,
    double? currentPrice,
    double? marketCap,
    int?    marketCapRank,
    double? priceChangePercentage24h,
    double? totalVolume,
    double? ath,
  }) {
    return CoinMarketModel(
      id:           id           ?? this.id,
      symbol:       symbol       ?? this.symbol,
      name:         name         ?? this.name,
      image:        image        ?? this.image,
      currentPrice: currentPrice ?? this.currentPrice,
      marketCap:    marketCap    ?? this.marketCap,
      marketCapRank: marketCapRank ?? this.marketCapRank,
      priceChangePercentage24h:
          priceChangePercentage24h ?? this.priceChangePercentage24h,
      totalVolume:  totalVolume  ?? this.totalVolume,
      ath:          ath          ?? this.ath,
    );
  }
}
