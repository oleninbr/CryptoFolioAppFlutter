import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/models/coin_market_model.dart';

final coinLocalDataSourceProvider = Provider<CoinLocalDataSource>(
  (_) => const CoinLocalDataSource(),
);

/// Encapsulates all SharedPreferences read/write for the app.
/// Every method swallows storage errors so callers never crash on I/O.
class CoinLocalDataSource {
  const CoinLocalDataSource();

  // ── Coins cache ────────────────────────────────────────────────

  /// Persists [coins] as JSON and records the current timestamp.
  Future<void> saveCoinsToCache(List<CoinMarketModel> coins) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.coinsKey,
        jsonEncode(coins.map((c) => c.toJson()).toList()),
      );
      await prefs.setInt(
        AppConstants.cacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {}
  }

  /// Returns the cached coin list, or `null` if the cache is missing/corrupt.
  Future<List<CoinMarketModel>?> loadCoinsFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(AppConstants.coinsKey);
      if (raw == null) return null;
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => CoinMarketModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null; // Corrupt cache — discard silently.
    }
  }

  /// Returns `true` if no cache exists or it is older than [AppConstants.cacheExpiry].
  Future<bool> isCacheExpired() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ts = prefs.getInt(AppConstants.cacheTimestampKey);
      if (ts == null) return true;
      final savedAt = DateTime.fromMillisecondsSinceEpoch(ts);
      return DateTime.now().difference(savedAt) > AppConstants.cacheExpiry;
    } catch (_) {
      return true;
    }
  }

  // ── Last viewed coin ───────────────────────────────────────────

  Future<void> saveLastViewedCoin(String coinId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.lastViewedCoinKey, coinId);
    } catch (_) {}
  }

  Future<String?> getLastViewedCoin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConstants.lastViewedCoinKey);
    } catch (_) {
      return null;
    }
  }

  // ── Theme ──────────────────────────────────────────────────────

  Future<void> saveThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.themeKey, mode.name);
    } catch (_) {}
  }

  Future<ThemeMode> getThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(AppConstants.themeKey);
      if (name == null) return ThemeMode.system;
      return ThemeMode.values.firstWhere(
        (m) => m.name == name,
        orElse: () => ThemeMode.system,
      );
    } catch (_) {
      return ThemeMode.system;
    }
  }
}
