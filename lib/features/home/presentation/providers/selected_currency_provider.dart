import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';

const List<String> supportedCurrencies = ['usd', 'eur', 'uah'];

final selectedCurrencyProvider =
    NotifierProvider<SelectedCurrencyNotifier, String>(
  SelectedCurrencyNotifier.new,
);

class SelectedCurrencyNotifier extends Notifier<String> {
  @override
  String build() {
    _loadPersisted();
    return 'usd';
  }

  Future<void> select(String currency) async {
    assert(
      supportedCurrencies.contains(currency),
      'Currency "$currency" is not in supportedCurrencies',
    );
    state = currency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.currencyKey, currency);
  }

  void _loadPersisted() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppConstants.currencyKey);
    if (saved != null && supportedCurrencies.contains(saved)) {
      state = saved;
    }
  }
}
