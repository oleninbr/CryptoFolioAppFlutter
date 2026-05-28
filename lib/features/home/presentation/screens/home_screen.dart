import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../profile/presentation/providers/theme_provider.dart';
import '../../domain/models/coin_market_model.dart';
import '../providers/coins_provider.dart';
import '../providers/selected_currency_provider.dart';
import '../widgets/coin_list_tile.dart';
import '../widgets/shimmer_coin_list.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  // ── Lifecycle ────────────────────────────────────────────────

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ── Handlers ─────────────────────────────────────────────────

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(searchQueryProvider.notifier).state = query;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _debounce?.cancel();
    ref.read(searchQueryProvider.notifier).state = '';
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final coinsAsync = ref.watch(sortedFilteredCoinsProvider);
    final currency   = ref.watch(selectedCurrencyProvider);
    final sortOption = ref.watch(sortOptionProvider);
    final isOffline  = ref.watch(isOfflineModeProvider);

    // valueOrNull == null only during the first frame while prefs load.
    final themeMode  =
        ref.watch(themeNotifierProvider).valueOrNull ?? ThemeMode.system;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.currency_bitcoin_rounded, size: 22),
            const SizedBox(width: 6),
            Text(AppLocalizations.of(context)!.appTitle),
          ],
        ),
        actions: [
          _SortButton(currentSort: sortOption),
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            tooltip: AppLocalizations.of(context)!.toggleTheme,
            onPressed: () =>
                ref.read(themeNotifierProvider.notifier).toggleTheme(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Offline banner ─────────────────────────────────
          if (isOffline) const _OfflineBanner(),

          // ── Search field ───────────────────────────────────
          _CoinSearchField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onClear: _clearSearch,
            hint: AppLocalizations.of(context)!.search,
          ),

          // ── Content (with fade transition between states) ──
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: _buildBody(coinsAsync, currency),
            ),
          ),
        ],
      ),
    );
  }

  // ── Body dispatcher ──────────────────────────────────────────

  Widget _buildBody(
    AsyncValue<List<CoinMarketModel>> coinsAsync,
    String currency,
  ) {
    return coinsAsync.when(
      loading: () => const ShimmerCoinList(key: ValueKey('shimmer')),
      error: (err, _) => _ErrorView(
        key: const ValueKey('error'),
        message: err is AppException
            ? err.message
            : AppLocalizations.of(context)!.errorLoading,
        onRetry: () => ref.read(coinsProvider.notifier).refresh(),
      ),
      data: (coins) {
        if (coins.isEmpty) {
          return const _EmptyView(key: ValueKey('empty'));
        }
        return RefreshIndicator(
          key: const ValueKey('list'),
          onRefresh: () => ref.read(coinsProvider.notifier).refresh(),
          child: ListView.builder(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: coins.length,
            itemBuilder: (_, index) => _FadeInItem(
              // Stable key keeps the animation state alive while the user
              // scrolls; the widget re-animates only when data is replaced.
              key: ValueKey(coins[index].id),
              index: index,
              child: CoinListTile(
                coin: coins[index],
                currency: currency,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Fade-in wrapper  (implicit-style: AnimationController + FadeTransition)
// ════════════════════════════════════════════════════════════════

/// Fades each list item in with a staggered delay based on its [index].
/// Animation type: implicit — opacity transition driven by an
/// [AnimationController] that fires once on item appearance.
class _FadeInItem extends StatefulWidget {
  const _FadeInItem({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  State<_FadeInItem> createState() => _FadeInItemState();
}

class _FadeInItemState extends State<_FadeInItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  @override
  void initState() {
    super.initState();
    // Cap delay at 300 ms so items below the fold don't wait too long.
    final delayMs = (widget.index * 50).clamp(0, 300);
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _opacity, child: widget.child);
}

// ════════════════════════════════════════════════════════════════
// Private widgets
// ════════════════════════════════════════════════════════════════

// ── Offline banner ────────────────────────────────────────────────

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      color: cs.errorContainer,
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, size: 14, color: cs.onErrorContainer),
          const SizedBox(width: 8),
          Text(
            l10n.offlineMode,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: cs.onErrorContainer,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Search field ─────────────────────────────────────────────────

class _CoinSearchField extends StatelessWidget {
  const _CoinSearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.hint,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (_, value, __) {
          return TextField(
            controller: controller,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: value.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: onClear,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}

// ── Sort popup button ─────────────────────────────────────────────

class _SortButton extends ConsumerWidget {
  const _SortButton({required this.currentSort});

  final SortOption currentSort;

  Map<SortOption, String> _labels(AppLocalizations l10n) => {
    SortOption.marketCapDesc: l10n.sortMarketCap,
    SortOption.priceDesc:     l10n.sortPriceDesc,
    SortOption.priceAsc:      l10n.sortPriceAsc,
    SortOption.changeDesc:    l10n.sortChange,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final labels = _labels(l10n);
    return PopupMenuButton<SortOption>(
      icon: const Icon(Icons.sort_rounded),
      tooltip: l10n.sortBy,
      onSelected: (opt) =>
          ref.read(sortOptionProvider.notifier).state = opt,
      itemBuilder: (_) => SortOption.values.map((opt) {
        return PopupMenuItem<SortOption>(
          value: opt,
          child: Row(
            children: [
              Icon(
                opt == currentSort
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 18,
                color: opt == currentSort
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              const SizedBox(width: 10),
              Text(labels[opt] ?? opt.name),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty search results ──────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noCoinsFound,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.tryDifferentSearch,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.30),
            ),
          ),
        ],
      ),
    );
  }
}
