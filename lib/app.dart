import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/l10n/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/profile/presentation/providers/locale_provider.dart';
import 'features/profile/presentation/providers/theme_provider.dart';

class CryptoFolioApp extends ConsumerWidget {
  const CryptoFolioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    final themeMode =
        ref.watch(themeNotifierProvider).valueOrNull ?? ThemeMode.system;
    final locale = ref.watch(localeNotifierProvider).valueOrNull;

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      theme:     AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      routerConfig: router,

      locale:                 locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [
        Locale('en'),
        Locale('uk'),
        Locale('pl'),
      ],
    );
  }
}
