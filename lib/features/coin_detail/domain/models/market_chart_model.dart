
class PricePoint {
  const PricePoint({required this.timestamp, required this.price});

  final DateTime timestamp;
  final double   price;

  factory PricePoint.fromList(List<dynamic> list) {
    return PricePoint(
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (list[0] as num).toInt(),
      ),
      price: (list[1] as num).toDouble(),
    );
  }

  List<dynamic> toList() => [timestamp.millisecondsSinceEpoch, price];
}

class MarketChartModel {
  const MarketChartModel({required this.prices});

  final List<PricePoint> prices;

  factory MarketChartModel.fromJson(Map<String, dynamic> json) {
    final raw = json['prices'] as List<dynamic>;
    return MarketChartModel(
      prices: raw
          .map((e) => PricePoint.fromList(e as List<dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'prices': prices.map((p) => p.toList()).toList(),
      };
}
