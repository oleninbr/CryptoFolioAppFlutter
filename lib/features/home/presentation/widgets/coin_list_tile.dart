import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/coin_market_model.dart';
import 'animated_price_widget.dart';

/// One row in the coin market list.
///
/// Layout:
///   [40×40 img]  Name                   $65,432.10
///                BTC · $1.2T mktcap     +2.34%
class CoinListTile extends StatelessWidget {
  const CoinListTile({
    super.key,
    required this.coin,
    required this.currency,
  });

  final CoinMarketModel coin;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final change = coin.priceChangePercentage24h;
    final isPositive = (change ?? 0) >= 0;
    final changeColor = isPositive ? AppColors.positive : AppColors.negative;

    return InkWell(
      onTap: () => context.push('/home/coin/${coin.id}', extra: coin.image),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // ── Leading: coin icon (Hero source for detail transition)
            Hero(
              tag: 'coin_image_${coin.id}',
              child: _CoinImage(url: coin.image),
            ),
            const SizedBox(width: 12),

            // ── Middle: name + symbol / market cap ─────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    coin.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        coin.symbol.toUpperCase(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.55),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          '·',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.30),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          CurrencyFormatter.formatMarketCap(coin.marketCap),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.45),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // ── Trailing: price + 24 h change ──────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Explicit animation: rolls number + color flash on change.
                AnimatedPriceWidget(
                  price: coin.currentPrice,
                  currency: currency,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                // Colored pill badge for the change %
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: changeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    CurrencyFormatter.formatPercent(change),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: changeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Coin image with graceful placeholder / error fallback ────────

class _CoinImage extends StatelessWidget {
  const _CoinImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CachedNetworkImage(
      imageUrl: url,
      width: 40,
      height: 40,
      imageBuilder: (_, imageProvider) => CircleAvatar(
        radius: 20,
        backgroundImage: imageProvider,
        backgroundColor: Colors.transparent,
      ),
      placeholder: (_, __) => CircleAvatar(
        radius: 20,
        backgroundColor: cs.surfaceContainerHighest,
      ),
      errorWidget: (_, __, ___) => CircleAvatar(
        radius: 20,
        backgroundColor: cs.surfaceContainerHighest,
        child: Icon(
          Icons.currency_bitcoin_rounded,
          size: 20,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}
