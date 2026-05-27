import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// 10-row placeholder list shown while coins are loading.
/// Each row mimics the exact proportions of [CoinListTile] so there
/// is no layout shift when the real data arrives.
class ShimmerCoinList extends StatelessWidget {
  const ShimmerCoinList({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark
          ? const Color(0xFF2A2A2A)
          : const Color(0xFFE0E0E0),
      highlightColor: isDark
          ? const Color(0xFF3D3D3D)
          : const Color(0xFFF5F5F5),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 10,
        itemBuilder: (_, __) => const _ShimmerTile(),
      ),
    );
  }
}

class _ShimmerTile extends StatelessWidget {
  const _ShimmerTile();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        children: [
          // Leading circle — matches the 40 × 40 coin image
          const _ShimmerBox(width: 40, height: 40, radius: 20),
          const SizedBox(width: 12),

          // Name + symbol / market-cap columns
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _ShimmerBox(
                  width: MediaQuery.sizeOf(context).width * 0.35,
                  height: 14,
                  radius: 4,
                ),
                const SizedBox(height: 6),
                _ShimmerBox(
                  width: MediaQuery.sizeOf(context).width * 0.22,
                  height: 11,
                  radius: 4,
                ),
              ],
            ),
          ),

          // Trailing price + change columns
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              _ShimmerBox(width: 72, height: 14, radius: 4),
              SizedBox(height: 6),
              _ShimmerBox(width: 52, height: 11, radius: 4),
            ],
          ),
        ],
      ),
    );
  }
}

/// Solid white rectangle — the shimmer package animates white areas.
class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    this.radius = 4,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
