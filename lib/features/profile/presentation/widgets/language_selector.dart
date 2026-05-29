import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/l10n/app_localizations.dart';
import '../providers/locale_provider.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  static const _options = [
    (code: 'uk', flag: '🇺🇦', label: 'Українська'),
    (code: 'en', flag: '🇬🇧', label: 'English'),
    (code: 'pl', flag: '🇵🇱', label: 'Polski'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final current =
        ref.watch(localeNotifierProvider).valueOrNull?.languageCode ?? 'en';
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                l10n.language,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            RadioGroup<String>(
              groupValue: current,
              onChanged: (code) {
                if (code != null) {
                  ref
                      .read(localeNotifierProvider.notifier)
                      .setLocale(code);
                }
              },
              child: Column(
                children: [
                  for (final option in _options)
                    RadioListTile<String>(
                      value: option.code,
                      title: Text('${option.flag}  ${option.label}'),
                      dense: true,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
