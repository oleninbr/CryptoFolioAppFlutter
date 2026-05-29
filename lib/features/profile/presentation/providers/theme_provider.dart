import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../home/data/datasources/coin_local_datasource.dart';

final themeNotifierProvider =
    AsyncNotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);

class ThemeNotifier extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    return ref.read(coinLocalDataSourceProvider).getThemeMode();
  }

  Future<void> toggleTheme() async {
    final current = state.valueOrNull ?? ThemeMode.system;
    final next =
        current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await ref.read(coinLocalDataSourceProvider).saveThemeMode(next);
    state = AsyncData(next);
  }

  Future<void> setTheme(ThemeMode mode) async {
    await ref.read(coinLocalDataSourceProvider).saveThemeMode(mode);
    state = AsyncData(mode);
  }
}
