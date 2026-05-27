import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';

/// Supported display currencies.
const List<String> supportedCurrencies = ['usd', 'eur', 'uah'];

final selectedCurrencyProvider =
    NotifierProvider<SelectedCurrencyNotifier, String>(
  SelectedCurrencyNotifier.new,
);

/// Holds the user's chosen vs-currency (e.g. "usd").
///
/// [build] returns the default "usd" synchronously, then immediately
/// fires an async load from SharedPreferences so the persisted value
/// replaces the default before the first frame is painted.
class SelectedCurrencyNotifier extends Notifier<String> {
  @override
  String build() {
    _loadPersisted();
    return 'usd';
  }

  /// Change the active currency and persist the selection.
  Future<void> select(String currency) async {
    assert(
      supportedCurrencies.contains(currency),
      'Currency "$currency" is not in supportedCurrencies',
    );
    state = currency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.currencyKey, currency);
  }

  // ── Private helpers ──────────────────────────────────────────

  void _loadPersisted() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppConstants.currencyKey);
    if (saved != null && supportedCurrencies.contains(saved)) {
      state = saved;
    }
  }
}
