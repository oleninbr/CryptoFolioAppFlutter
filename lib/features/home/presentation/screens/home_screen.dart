import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/theme_mode_provider.dart';
import '../../../../core/utils/app_exception.dart';
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
    final coinsAsync  = ref.watch(sortedFilteredCoinsProvider);
    final currency    = ref.watch(selectedCurrencyProvider);
    final sortOption  = ref.watch(sortOptionProvider);
    final themeMode   = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.currency_bitcoin_rounded, size: 22),
            SizedBox(width: 6),
            Text('CryptoFolio'),
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
            tooltip: 'Toggle theme',
            onPressed: () {
              ref.read(themeModeProvider.notifier).state =
                  themeMode == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search field ───────────────────────────────────
          _CoinSearchField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onClear: _clearSearch,
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
    // skipLoadingOnRefresh (default true): when the notifier sets
    // AsyncLoading.copyWithPrevious(), when() keeps calling data()
    // with the old list — so the RefreshIndicator spinner appears
    // instead of the shimmer, avoiding a layout flash.
    return coinsAsync.when(
      loading: () => const ShimmerCoinList(key: ValueKey('shimmer')),
      error: (err, _) => _ErrorView(
        key: const ValueKey('error'),
        message: err is AppException ? err.message : 'Something went wrong.',
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
            itemBuilder: (_, index) => CoinListTile(
              coin: coins[index],
              currency: currency,
            ),
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Private widgets
// ════════════════════════════════════════════════════════════════

// ── Search field ─────────────────────────────────────────────────

class _CoinSearchField extends StatelessWidget {
  const _CoinSearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

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
              hintText: 'Search coins…',
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

  static const _labels = {
    SortOption.marketCapDesc: 'Market Cap',
    SortOption.priceDesc:     'Price: High → Low',
    SortOption.priceAsc:      'Price: Low → High',
    SortOption.changeDesc:    '24h Change',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<SortOption>(
      icon: const Icon(Icons.sort_rounded),
      tooltip: 'Sort by',
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
              Text(_labels[opt] ?? opt.name),
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
              label: const Text('Retry'),
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
            'No coins found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different search term',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.30),
            ),
          ),
        ],
      ),
    );
  }
}
