import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mutable theme-mode state.
/// Toggle with: ref.read(themeModeProvider.notifier).state = ThemeMode.dark;
final themeModeProvider = StateProvider<ThemeMode>(
  (ref) => ThemeMode.system,
);
