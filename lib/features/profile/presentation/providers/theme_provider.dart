import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../home/data/datasources/coin_local_datasource.dart';

/// Persisted theme-mode provider.
/// Loads the saved value from SharedPreferences on first access.
/// Toggle with: ref.read(themeNotifierProvider.notifier).toggleTheme();
final themeNotifierProvider =
    AsyncNotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);

class ThemeNotifier extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    return ref.read(coinLocalDataSourceProvider).getThemeMode();
  }

  /// Flips between light and dark, persisting the choice.
  Future<void> toggleTheme() async {
    final current = state.valueOrNull ?? ThemeMode.system;
    final next =
        current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await ref.read(coinLocalDataSourceProvider).saveThemeMode(next);
    state = AsyncData(next);
  }

  /// Sets an explicit theme mode and persists it.
  Future<void> setTheme(ThemeMode mode) async {
    await ref.read(coinLocalDataSourceProvider).saveThemeMode(mode);
    state = AsyncData(mode);
  }
}
