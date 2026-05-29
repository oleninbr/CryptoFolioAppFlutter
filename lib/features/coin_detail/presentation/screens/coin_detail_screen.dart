import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/coin_detail_model.dart';
import '../../domain/models/market_chart_model.dart';
import '../providers/coin_detail_provider.dart';
import '../../../portfolio/presentation/widgets/add_to_portfolio_sheet.dart';

class CoinDetailScreen extends ConsumerWidget {
  const CoinDetailScreen({
    super.key,
    required this.coinId,
    this.initialImageUrl,
  });

  final String coinId;

  final String? initialImageUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(coinDetailProvider(coinId));

    final imageUrl = detailAsync.valueOrNull?.image ?? initialImageUrl ?? '';
    final coinName = detailAsync.valueOrNull?.name;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _CoinSliverAppBar(
            coinId: coinId,
            imageUrl: imageUrl,
            coinName: coinName,
          ),
          ...detailAsync.when<List<Widget>>(
            loading: () => [const _LoadingSliver()],
            error: (err, _) => [
              _ErrorSliver(
                onRetry: () => ref.invalidate(coinDetailProvider(coinId)),
              ),
            ],
            data: (detail) => [
              _PriceHeaderSliver(detail: detail),
              _PriceChartSliver(coinId: coinId),
              _MarketDataSliver(detail: detail),
              if (detail.description?.isNotEmpty == true)
                _DescriptionSliver(description: detail.description!),
              const _BottomPaddingSliver(),
            ],
          ),
        ],
      ),
      floatingActionButton: detailAsync.hasValue
          ? FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (_) => AddToPortfolioSheet(
                    detail: detailAsync.valueOrNull!,
                  ),
                );
              },
              icon: const Icon(Icons.add_rounded),
              label: Text(AppLocalizations.of(context)!.addToPortfolio),
            )
          : null,
    );
  }
}

class _CoinSliverAppBar extends StatelessWidget {
  const _CoinSliverAppBar({
    required this.coinId,
    required this.imageUrl,
    this.coinName,
  });

  final String coinId;
  final String imageUrl;
  final String? coinName;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SliverAppBar(
      expandedHeight: 168,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 14),
        title: coinName != null
            ? Text(
                coinName!,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              )
            : null,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                cs.primary.withValues(alpha: 0.12),
                cs.surface.withValues(alpha: 0.0),
              ],
            ),
          ),
          child: Align(
            alignment: const Alignment(0, -0.15),
            child: Hero(
              tag: 'coin_image_$coinId',
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 80,
                      height: 80,
                      imageBuilder: (_, imageProvider) => CircleAvatar(
                        radius: 40,
                        backgroundImage: imageProvider,
                        backgroundColor: Colors.transparent,
                      ),
                      placeholder: (_, __) => CircleAvatar(
                        radius: 40,
                        backgroundColor: cs.surfaceContainerHighest,
                      ),
                      errorWidget: (_, __, ___) => CircleAvatar(
                        radius: 40,
                        backgroundColor: cs.surfaceContainerHighest,
                        child: Icon(
                          Icons.currency_bitcoin_rounded,
                          size: 40,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    )
                  : CircleAvatar(
                      radius: 40,
                      backgroundColor: cs.surfaceContainerHighest,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingSliver extends StatelessWidget {
  const _LoadingSliver();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SliverToBoxAdapter(
      child: Shimmer.fromColors(
        baseColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
        highlightColor:
            isDark ? const Color(0xFF3D3D3D) : const Color(0xFFF5F5F5),
        child: const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _ShimmerBox(width: 180, height: 38, radius: 6),
              SizedBox(height: 10),
              _ShimmerBox(width: 90, height: 22, radius: 6),
              SizedBox(height: 28),

              _ShimmerBox(width: double.infinity, height: 220, radius: 10),
              SizedBox(height: 24),

              _ShimmerBox(width: double.infinity, height: 140, radius: 10),
              SizedBox(height: 12),

              _ShimmerBox(width: double.infinity, height: 100, radius: 10),
            ],
          ),
        ),
      ),
    );
  }
}

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

class _ErrorSliver extends StatelessWidget {
  const _ErrorSliver({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 56,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.failedToLoad,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(AppLocalizations.of(context)!.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceHeaderSliver extends StatelessWidget {
  const _PriceHeaderSliver({required this.detail});
  final CoinDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final change24h = detail.priceChangePercentage24h;
    final isPositive = (change24h ?? 0) >= 0;
    final changeColor =
        isPositive ? AppColors.positive : AppColors.negative;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    CurrencyFormatter.formatPrice(
                        detail.currentPrice, 'usd'),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: changeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          CurrencyFormatter.formatPercent(change24h),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: changeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '24h',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (detail.marketCapRank != null)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: cs.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '#${detail.marketCapRank}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PriceChartSliver extends ConsumerWidget {
  const _PriceChartSliver({required this.coinId});
  final String coinId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDays = ref.watch(selectedDaysProvider);
    final chartAsync = ref.watch(marketChartProvider(coinId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            SegmentedButton<int>(
              segments: [
                ButtonSegment(
                    value: 7,
                    label: Text(AppLocalizations.of(context)!.days7)),
                ButtonSegment(
                    value: 14,
                    label: Text(AppLocalizations.of(context)!.days14)),
                ButtonSegment(
                    value: 30,
                    label: Text(AppLocalizations.of(context)!.days30)),
              ],
              selected: {selectedDays},
              onSelectionChanged: (set) =>
                  ref.read(selectedDaysProvider.notifier).state = set.first,
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 180,
              child: chartAsync.when(
                loading: () => _ChartShimmer(isDark: isDark),
                error: (_, __) => Center(
                  child: Text(
                    AppLocalizations.of(context)!.chartUnavailable,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.4),
                    ),
                  ),
                ),
                data: (chart) => _LineChartWidget(chart: chart),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartShimmer extends StatelessWidget {
  const _ChartShimmer({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
      highlightColor:
          isDark ? const Color(0xFF3D3D3D) : const Color(0xFFF5F5F5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _LineChartWidget extends StatelessWidget {
  const _LineChartWidget({required this.chart});
  final MarketChartModel chart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (chart.prices.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noData,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      );
    }

    final prices = chart.prices;
    final isUp = prices.last.price >= prices.first.price;
    final lineColor = isUp ? AppColors.positive : AppColors.negative;

    final spots = [
      for (var i = 0; i < prices.length; i++)
        FlSpot(i.toDouble(), prices[i].price),
    ];

    final minY =
        prices.map((p) => p.price).reduce((a, b) => a < b ? a : b);
    final maxY =
        prices.map((p) => p.price).reduce((a, b) => a > b ? a : b);
    final range = maxY - minY;
    final yPadding = range > 0 ? range * 0.1 : maxY * 0.05;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (prices.length - 1).toDouble(),
        minY: minY - yPadding,
        maxY: maxY + yPadding,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => theme.colorScheme.inverseSurface,
            getTooltipItems: (spots) => spots
                .map(
                  (spot) => LineTooltipItem(
                    CurrencyFormatter.formatPrice(spot.y, 'usd'),
                    TextStyle(
                      color: theme.colorScheme.onInverseSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: lineColor,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  lineColor.withValues(alpha: 0.25),
                  lineColor.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketDataSliver extends StatelessWidget {
  const _MarketDataSliver({required this.detail});
  final CoinDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.marketData,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _MarketStat(
                        label: AppLocalizations.of(context)!.marketCap,
                        value: CurrencyFormatter.formatMarketCap(
                            detail.marketCap),
                      ),
                    ),
                    Expanded(
                      child: _MarketStat(
                        label: AppLocalizations.of(context)!.volume24h,
                        value: CurrencyFormatter.formatMarketCap(
                            detail.totalVolume),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _MarketStat(
                        label: AppLocalizations.of(context)!.allTimeHigh,
                        value: detail.ath != null
                            ? CurrencyFormatter.formatPrice(
                                detail.ath!, 'usd')
                            : '—',
                      ),
                    ),
                    Expanded(
                      child: _MarketStat(
                        label: AppLocalizations.of(context)!.allTimeLow,
                        value: detail.atl != null
                            ? CurrencyFormatter.formatPrice(
                                detail.atl!, 'usd')
                            : '—',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MarketStat extends StatelessWidget {
  const _MarketStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color:
                theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DescriptionSliver extends StatefulWidget {
  const _DescriptionSliver({required this.description});
  final String description;

  @override
  State<_DescriptionSliver> createState() => _DescriptionSliverState();
}

class _DescriptionSliverState extends State<_DescriptionSliver> {
  bool _expanded = false;

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cleaned = _stripHtml(widget.description);

    if (cleaned.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
      height: 1.5,
    );

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.about,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedCrossFade(
                  firstChild: Text(
                    cleaned,
                    style: bodyStyle,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  secondChild: Text(cleaned, style: bodyStyle),
                  crossFadeState: _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Text(
                    _expanded
                        ? AppLocalizations.of(context)!.showLess
                        : AppLocalizations.of(context)!.showMore,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomPaddingSliver extends StatelessWidget {
  const _BottomPaddingSliver();

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(child: SizedBox(height: 88));
  }
}
