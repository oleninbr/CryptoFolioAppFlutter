
class CoinDetailModel {
  const CoinDetailModel({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    required this.currentPrice,
    required this.marketCap,
    required this.totalVolume,
    this.description,
    this.ath,
    this.atl,
    this.priceChangePercentage24h,
    this.priceChangePercentage7d,
    this.marketCapRank,
  });

  final String  id;
  final String  symbol;
  final String  name;
  final String  image;
  final double  currentPrice;
  final double  marketCap;
  final double  totalVolume;
  final String? description;
  final double? ath;
  final double? atl;
  final double? priceChangePercentage24h;
  final double? priceChangePercentage7d;
  final int?    marketCapRank;

  factory CoinDetailModel.fromJson(Map<String, dynamic> json) {
    final market      = (json['market_data']   as Map<String, dynamic>?) ?? {};
    final priceMap    = (market['current_price'] as Map<String, dynamic>?) ?? {};
    final capMap      = (market['market_cap']    as Map<String, dynamic>?) ?? {};
    final volMap      = (market['total_volume']  as Map<String, dynamic>?) ?? {};
    final athMap      = (market['ath']           as Map<String, dynamic>?) ?? {};
    final atlMap      = (market['atl']           as Map<String, dynamic>?) ?? {};
    final imageMap    = (json['image']           as Map<String, dynamic>?) ?? {};
    final descMap     = (json['description']     as Map<String, dynamic>?) ?? {};

    return CoinDetailModel(
      id:           json['id']     as String,
      symbol:       json['symbol'] as String? ?? '',
      name:         json['name']   as String? ?? '',
      image:        imageMap['large'] as String? ?? '',
      currentPrice: (priceMap['usd'] as num?)?.toDouble() ?? 0.0,
      marketCap:    (capMap['usd']   as num?)?.toDouble() ?? 0.0,
      totalVolume:  (volMap['usd']   as num?)?.toDouble() ?? 0.0,
      ath:          (athMap['usd']   as num?)?.toDouble(),
      atl:          (atlMap['usd']   as num?)?.toDouble(),
      priceChangePercentage24h:
          (market['price_change_percentage_24h'] as num?)?.toDouble(),
      priceChangePercentage7d:
          (market['price_change_percentage_7d'] as num?)?.toDouble(),
      marketCapRank: json['market_cap_rank'] as int?,
      description:   descMap['en'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id':             id,
        'symbol':         symbol,
        'name':           name,
        'image':          {'large': image},
        'description':    {'en': description},
        'market_cap_rank': marketCapRank,
        'market_data': {
          'current_price': {'usd': currentPrice},
          'market_cap':    {'usd': marketCap},
          'total_volume':  {'usd': totalVolume},
          'ath':           {'usd': ath},
          'atl':           {'usd': atl},
          'price_change_percentage_24h': priceChangePercentage24h,
          'price_change_percentage_7d':  priceChangePercentage7d,
        },
      };

  CoinDetailModel copyWith({
    String? id,
    String? symbol,
    String? name,
    String? image,
    double? currentPrice,
    double? marketCap,
    double? totalVolume,
    String? description,
    double? ath,
    double? atl,
    double? priceChangePercentage24h,
    double? priceChangePercentage7d,
    int?    marketCapRank,
  }) {
    return CoinDetailModel(
      id:           id           ?? this.id,
      symbol:       symbol       ?? this.symbol,
      name:         name         ?? this.name,
      image:        image        ?? this.image,
      currentPrice: currentPrice ?? this.currentPrice,
      marketCap:    marketCap    ?? this.marketCap,
      totalVolume:  totalVolume  ?? this.totalVolume,
      description:  description  ?? this.description,
      ath:          ath          ?? this.ath,
      atl:          atl          ?? this.atl,
      priceChangePercentage24h:
          priceChangePercentage24h ?? this.priceChangePercentage24h,
      priceChangePercentage7d:
          priceChangePercentage7d  ?? this.priceChangePercentage7d,
      marketCapRank: marketCapRank ?? this.marketCapRank,
    );
  }
}
