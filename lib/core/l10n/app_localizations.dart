import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
    Locale('uk')
  ];

  String get appTitle;
  String get home;
  String get portfolio;
  String get profile;
  String get search;
  String get sortBy;
  String get sortMarketCap;
  String get sortPriceDesc;
  String get sortPriceAsc;
  String get sortChange;
  String get marketCap;
  String get volume24h;
  String get allTimeHigh;
  String get allTimeLow;
  String get addToPortfolio;
  String get portfolioEmpty;
  String get addCoin;
  String get quantity;
  String get buyPrice;
  String get totalValue;
  String get profitLoss;
  String get login;
  String get register;
  String get email;
  String get password;
  String get forgotPassword;
  String get logout;
  String get settings;
  String get theme;
  String get themeLight;
  String get themeDark;
  String get themeSystem;
  String get language;
  String get currency;
  String get about;
  String get showMore;
  String get showLess;
  String get retry;
  String get noCoinsFound;
  String get offlineMode;
  String get errorLoading;
  String get chartUnavailable;
  String get marketData;
  String get toggleTheme;
  String get comingSoon;
  String get failedToLoad;
  String get profilePhoto;
  String get changePhoto;
  String get camera;
  String get gallery;
  String get save;
  String get cancel;
  String get delete;
  String get confirmDelete;
  String get days7;
  String get days14;
  String get days30;
  String get tryDifferentSearch;
  String get noData;

  // ── Auth ────────────────────────────────────────────────────────
  String get confirmPassword;
  String get passwordsDoNotMatch;
  String get loginSubtitle;
  String get registerSubtitle;
  String get alreadyHaveAccount;
  String get dontHaveAccount;
  String get sendResetEmail;
  String resetEmailSent(String email);
  String get emailInvalid;
  String get passwordTooShort;
  String get forgotPasswordTitle;
  String get forgotPasswordSubtitle;
  String get showPassword;
  String get hidePassword;

  // ── Portfolio ────────────────────────────────────────────────────
  String get currentValue;
  String get totalInvested;
  String get mustBePositive;
  String get coinAdded;
  String get deleteConfirmMessage;

  // ── Profile / photo ─────────────────────────────────────────────
  String get takePhoto;
  String get chooseFromGallery;
  String get uploadingPhoto;
  String get permissionDenied;
  String get permissionDeniedMessage;
  String get openSettings;
  String get selectPhotoSource;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
