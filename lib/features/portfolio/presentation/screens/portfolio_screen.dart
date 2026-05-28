import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/portfolio_provider.dart';

// ════════════════════════════════════════════════════════════════
// Root screen
// ════════════════════════════════════════════════════════════════

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final portfolioAsync = ref.watch(portfolioWithPricesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.portfolio),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: l10n.addCoin,
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      body: portfolioAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _ErrorState(l10n: l10n),
        data: (items) =>
            items.isEmpty ? _EmptyState(l10n: l10n) : _PortfolioList(items: items),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Portfolio list — totals card + per-coin tiles
// ════════════════════════════════════════════════════════════════

class _PortfolioList extends ConsumerWidget {
  const _PortfolioList({required this.items});

  final List<PortfolioItemWithPrice> items;

  Future<bool?> _confirmDelete(BuildContext context, AppLocalizations l10n) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: items.length + 1, // +1 for totals card
      itemBuilder: (context, index) {
        if (index == 0) return _TotalsCard(l10n: l10n);

        final itemWithPrice = items[index - 1];

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Dismissible(
            key: ValueKey(itemWithPrice.item.coinId),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: cs.error,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.delete_rounded, color: cs.onError),
            ),
            confirmDismiss: (_) => _confirmDelete(context, l10n),
            onDismissed: (_) => ref
                .read(portfolioNotifierProvider.notifier)
                .deleteItem(itemWithPrice.item.coinId),
            child: _PortfolioItemTile(itemWithPrice: itemWithPrice),
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Totals card with AnimatedContainer P&L highlight
// ════════════════════════════════════════════════════════════════

class _TotalsCard extends ConsumerWidget {
  const _TotalsCard({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totals = ref.watch(portfolioTotalsProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isPositive = totals.totalProfitLoss >= 0;
    final plColor = isPositive ? AppColors.positive : AppColors.negative;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cs.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row: current value ───────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.currentValue,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.formatPrice(
                            totals.totalCurrentValue,
                            'usd',
                          ),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Invested amount (right)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.totalInvested,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.formatPrice(
                          totals.totalInvested,
                          'usd',
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── P&L row with AnimatedContainer ───────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: plColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.profitLoss,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: plColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          CurrencyFormatter.formatPrice(
                            totals.totalProfitLoss.abs(),
                            'usd',
                          ),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: plColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: plColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            CurrencyFormatter.formatPercent(
                              totals.totalProfitLossPercent,
                            ),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: plColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Per-coin tile
// ════════════════════════════════════════════════════════════════

class _PortfolioItemTile extends StatelessWidget {
  const _PortfolioItemTile({required this.itemWithPrice});

  final PortfolioItemWithPrice itemWithPrice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final item = itemWithPrice.item;
    final price = itemWithPrice.currentPrice;
    final pl = item.profitLoss(price);
    final plPct = item.profitLossPercent(price);
    final isPositive = pl >= 0;
    final plColor = isPositive ? AppColors.positive : AppColors.negative;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // ── Coin icon ────────────────────────────────────────
            CachedNetworkImage(
              imageUrl: item.coinImage,
              width: 44,
              height: 44,
              imageBuilder: (_, img) => CircleAvatar(
                radius: 22,
                backgroundImage: img,
                backgroundColor: Colors.transparent,
              ),
              placeholder: (_, __) => CircleAvatar(
                radius: 22,
                backgroundColor: cs.surfaceContainerHighest,
              ),
              errorWidget: (_, __, ___) => CircleAvatar(
                radius: 22,
                backgroundColor: cs.surfaceContainerHighest,
                child: const Icon(Icons.currency_bitcoin_rounded, size: 20),
              ),
            ),
            const SizedBox(width: 12),

            // ── Name + quantity ───────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.coinName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.quantity} ${item.coinSymbol.toUpperCase()}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),

            // ── Current value + P&L ────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.formatPrice(item.currentValue(price), 'usd'),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 12,
                      color: plColor,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      CurrencyFormatter.formatPercent(plPct),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: plColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Empty state
// ════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 72,
              color: cs.onSurface.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.portfolioEmpty,
              style: theme.textTheme.titleMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.addCoin),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Error state
// ════════════════════════════════════════════════════════════════

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 56, color: cs.error),
            const SizedBox(height: 12),
            Text(
              l10n.errorLoading,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
