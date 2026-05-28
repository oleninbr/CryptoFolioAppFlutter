import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../widgets/language_selector.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode =
        ref.watch(themeNotifierProvider).valueOrNull ?? ThemeMode.system;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Theme section ──────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      l10n.theme,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.light,
                    groupValue: themeMode,
                    title: Text(l10n.themeLight),
                    dense: true,
                    onChanged: (m) =>
                        ref.read(themeNotifierProvider.notifier).setTheme(m!),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.dark,
                    groupValue: themeMode,
                    title: Text(l10n.themeDark),
                    dense: true,
                    onChanged: (m) =>
                        ref.read(themeNotifierProvider.notifier).setTheme(m!),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.system,
                    groupValue: themeMode,
                    title: Text(l10n.themeSystem),
                    dense: true,
                    onChanged: (m) =>
                        ref.read(themeNotifierProvider.notifier).setTheme(m!),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Language section ───────────────────────────────
          const LanguageSelector(),
        ],
      ),
    );
  }
}
