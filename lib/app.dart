import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/l10n/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Holds the active [ThemeMode]. Swap to a [StateProvider] later
/// to let users toggle light/dark from the profile screen.
final themeModeProvider = Provider<ThemeMode>((ref) => ThemeMode.system);

class CryptoFolioApp extends ConsumerWidget {
  const CryptoFolioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router    = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // ── Themes ──────────────────────────────────────────────
      theme:      AppTheme.lightTheme,
      darkTheme:  AppTheme.darkTheme,
      themeMode:  themeMode,

      // ── Navigation ──────────────────────────────────────────
      routerConfig: router,

      // ── Localizations ───────────────────────────────────────
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales:       AppLocalizations.supportedLocales,
    );
  }
}
