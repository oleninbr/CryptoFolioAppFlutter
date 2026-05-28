import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../coin_detail/domain/models/coin_detail_model.dart';
import '../../domain/models/portfolio_item_model.dart';
import '../providers/portfolio_provider.dart';

/// Modal bottom sheet for adding a coin to the portfolio.
/// Opened from [CoinDetailScreen]; receives the fully loaded [CoinDetailModel].
class AddToPortfolioSheet extends ConsumerStatefulWidget {
  const AddToPortfolioSheet({super.key, required this.detail});

  final CoinDetailModel detail;

  @override
  ConsumerState<AddToPortfolioSheet> createState() =>
      _AddToPortfolioSheetState();
}

class _AddToPortfolioSheetState extends ConsumerState<AddToPortfolioSheet> {
  final _formKey = GlobalKey<FormState>();
  final _quantityCtrl = TextEditingController();
  final _buyPriceCtrl = TextEditingController();
  bool _loading = false;

  double get _quantity => double.tryParse(_quantityCtrl.text) ?? 0;
  double get _buyPrice => double.tryParse(_buyPriceCtrl.text) ?? 0;
  double get _totalInvestment => _quantity * _buyPrice;

  @override
  void initState() {
    super.initState();
    // Pre-fill buy price with the current market price.
    _buyPriceCtrl.text = widget.detail.currentPrice.toStringAsFixed(2);
    // Rebuild on every keystroke to update the real-time total.
    _quantityCtrl.addListener(_onFieldChanged);
    _buyPriceCtrl.addListener(_onFieldChanged);
  }

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _buyPriceCtrl.dispose();
    super.dispose();
  }

  // ── Submit ────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    try {
      final item = PortfolioItemModel(
        id: widget.detail.id,
        coinId: widget.detail.id,
        coinName: widget.detail.name,
        coinSymbol: widget.detail.symbol,
        coinImage: widget.detail.image,
        quantity: _quantity,
        buyPrice: _buyPrice,
        addedAt: DateTime.now(),
      );
      await ref.read(portfolioNotifierProvider.notifier).addItem(item);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.coinAdded),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
          backgroundColor: cs.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final d = widget.detail;

    return Padding(
      // Shift the sheet above the keyboard.
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Drag handle ──────────────────────────────────
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // ── Coin header (read-only) ───────────────────────
                Row(
                  children: [
                    CachedNetworkImage(
                      imageUrl: d.image,
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
                        child: const Icon(Icons.currency_bitcoin_rounded),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          d.symbol.toUpperCase(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      CurrencyFormatter.formatPrice(d.currentPrice, 'usd'),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Quantity ─────────────────────────────────────
                TextFormField(
                  controller: _quantityCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    labelText: l10n.quantity,
                    hintText: '0.00',
                    prefixIcon: const Icon(Icons.numbers_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    if (n == null || n <= 0) return l10n.mustBePositive;
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // ── Buy price ────────────────────────────────────
                TextFormField(
                  controller: _buyPriceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    labelText: '${l10n.buyPrice} (USD)',
                    hintText: '0.00',
                    prefixIcon: const Icon(Icons.attach_money_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    if (n == null || n <= 0) return l10n.mustBePositive;
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Real-time total ───────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.totalValue,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatPrice(_totalInvestment, 'usd'),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Add button ────────────────────────────────────
                FilledButton(
                  onPressed: _loading ? null : _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.addToPortfolio,
                          style: const TextStyle(fontSize: 16),
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
