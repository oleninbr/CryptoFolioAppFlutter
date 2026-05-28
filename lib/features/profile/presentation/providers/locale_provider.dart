import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';

/// Persisted locale provider.
/// Loads the saved language code from SharedPreferences on first access.
/// Change with: ref.read(localeNotifierProvider.notifier).setLocale('uk');
final localeNotifierProvider =
    AsyncNotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

class LocaleNotifier extends AsyncNotifier<Locale> {
  @override
  Future<Locale> build() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(AppConstants.languageKey) ?? 'en';
    return Locale(code);
  }

  /// Persists [languageCode] and updates the app locale immediately.
  Future<void> setLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.languageKey, languageCode);
    state = AsyncData(Locale(languageCode));
  }
}
