import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/providers/selected_currency_provider.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../providers/locale_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _uploading = false;

  Future<void> _pickAndUpload(ImageSource source) async {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    XFile? picked;
    try {
      picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 512,
        maxHeight: 512,
      );
    } catch (_) {

      if (mounted) _showPermissionDialog(l10n);
      return;
    }

    if (picked == null) return;

    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;

    setState(() => _uploading = true);
    try {
      final ds = ref.read(profileRemoteDataSourceProvider);
      final url = await ds.uploadProfilePhoto(uid, File(picked.path));
      await ds.updateUserProfile(uid, photoUrl: url);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            content: Text(l10n.uploadingPhoto),
            behavior: SnackBarBehavior.floating,
            backgroundColor: cs.error,
          ));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _showPermissionDialog(AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.permissionDenied),
        content: Text(l10n.permissionDeniedMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  void _showPhotoSourceSheet(AppLocalizations l10n) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: Text(l10n.takePhoto),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndUpload(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: Text(l10n.chooseFromGallery),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndUpload(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authUser = ref.watch(authStateProvider).valueOrNull;
    final uid = authUser?.uid;

    final profileData = uid != null
        ? ref.watch(profileProvider(uid)).valueOrNull
        : null;

    final photoUrl =
        (profileData?['photoUrl'] as String?) ?? authUser?.photoUrl;

    final themeMode =
        ref.watch(themeNotifierProvider).valueOrNull ?? ThemeMode.system;
    final locale =
        ref.watch(localeNotifierProvider).valueOrNull?.languageCode ?? 'en';
    final currency = ref.watch(selectedCurrencyProvider);

    final displayName = authUser?.displayName;
    final emailStr = authUser?.email ?? '';
    final initial = (displayName?.isNotEmpty == true
            ? displayName![0]
            : (emailStr.isNotEmpty ? emailStr[0] : '?'))
        .toUpperCase();

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [

                  Stack(
                    alignment: Alignment.center,
                    children: [
                      _uploading
                          ? CircleAvatar(
                              radius: 48,
                              backgroundColor: cs.surfaceContainerHighest,
                              child: const CircularProgressIndicator(),
                            )
                          : _buildAvatar(photoUrl, initial, cs),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _uploading
                              ? null
                              : () => _showPhotoSourceSheet(l10n),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: cs.primary,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: cs.surface, width: 2),
                            ),
                            child: Icon(Icons.edit_rounded,
                                size: 16, color: cs.onPrimary),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (displayName != null && displayName.isNotEmpty)
                    Text(
                      displayName,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  if (emailStr.isNotEmpty)
                    Text(
                      emailStr,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.6)),
                    ),
                  const SizedBox(height: 8),

                  TextButton.icon(
                    onPressed: _uploading
                        ? null
                        : () => _showPhotoSourceSheet(l10n),
                    icon: const Icon(Icons.add_a_photo_rounded, size: 18),
                    label: Text(l10n.changePhoto),
                  ),
                ],
              ),
            ),
          ),

          if (_uploading) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.uploadingPhoto,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  const LinearProgressIndicator(),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.theme,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      segments: [
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text(l10n.themeLight),
                          icon: const Icon(Icons.light_mode_rounded),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text(l10n.themeSystem),
                          icon: const Icon(Icons.brightness_auto_rounded),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text(l10n.themeDark),
                          icon: const Icon(Icons.dark_mode_rounded),
                        ),
                      ],
                      selected: {themeMode},
                      onSelectionChanged: (modes) => ref
                          .read(themeNotifierProvider.notifier)
                          .setTheme(modes.first),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.language,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'uk', label: Text('🇺🇦 UA')),
                        ButtonSegment(value: 'en', label: Text('🇬🇧 EN')),
                        ButtonSegment(value: 'pl', label: Text('🇵🇱 PL')),
                      ],
                      selected: {locale},
                      onSelectionChanged: (codes) => ref
                          .read(localeNotifierProvider.notifier)
                          .setLocale(codes.first),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.currency,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DropdownButton<String>(
                    value: currency,
                    underline: const SizedBox.shrink(),
                    borderRadius: BorderRadius.circular(12),
                    items: supportedCurrencies
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.toUpperCase(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        ref
                            .read(selectedCurrencyProvider.notifier)
                            .select(val);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed: () =>
                ref.read(authNotifierProvider.notifier).signOut(),
            icon: const Icon(Icons.logout_rounded),
            label: Text(l10n.logout),
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAvatar(
      String? photoUrl, String initial, ColorScheme cs) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 48,
        backgroundColor: cs.surfaceContainerHighest,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: photoUrl,
            width: 96,
            height: 96,
            fit: BoxFit.cover,
            placeholder: (_, __) => _initialsAvatar(initial, cs),
            errorWidget: (_, __, ___) => _initialsAvatar(initial, cs),
          ),
        ),
      );
    }
    return _initialsAvatar(initial, cs);
  }

  Widget _initialsAvatar(String initial, ColorScheme cs) {
    return CircleAvatar(
      radius: 48,
      backgroundColor: cs.primaryContainer,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: cs.onPrimaryContainer,
        ),
      ),
    );
  }
}
