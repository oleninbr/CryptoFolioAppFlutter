import 'package:flutter/material.dart';

/// Central color palette — never use raw Color literals in widgets;
/// reference these constants or Theme.of(context).colorScheme instead.
class AppColors {
  AppColors._();

  /// Seed for ColorScheme.fromSeed (both light and dark themes)
  static const Color seed = Color(0xFF1565C0);

  // ── Dark theme surfaces ──────────────────────────────────────
  static const Color darkBackground     = Color(0xFF0D1117);
  static const Color darkSurface        = Color(0xFF161B22);
  static const Color darkSurfaceVariant = Color(0xFF21262D);

  // ── Light theme surfaces ─────────────────────────────────────
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightSurface    = Color(0xFFFFFFFF);

  // ── Semantic: portfolio values ───────────────────────────────
  static const Color positive = Color(0xFF00C853); // gains / price up
  static const Color negative = Color(0xFFFF3D00); // losses / price down

  // ── Neutral grey scale ───────────────────────────────────────
  static const Color grey50  = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey900 = Color(0xFF212121);
}
