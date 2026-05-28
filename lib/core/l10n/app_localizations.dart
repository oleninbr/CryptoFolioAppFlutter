import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
    Locale('uk')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'CryptoFolio'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @portfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get portfolio;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search coins...'**
  String get search;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @sortMarketCap.
  ///
  /// In en, this message translates to:
  /// **'Market Cap'**
  String get sortMarketCap;

  /// No description provided for @sortPriceDesc.
  ///
  /// In en, this message translates to:
  /// **'Price (high to low)'**
  String get sortPriceDesc;

  /// No description provided for @sortPriceAsc.
  ///
  /// In en, this message translates to:
  /// **'Price (low to high)'**
  String get sortPriceAsc;

  /// No description provided for @sortChange.
  ///
  /// In en, this message translates to:
  /// **'24h Change'**
  String get sortChange;

  /// No description provided for @marketCap.
  ///
  /// In en, this message translates to:
  /// **'Market Cap'**
  String get marketCap;

  /// No description provided for @volume24h.
  ///
  /// In en, this message translates to:
  /// **'Volume 24h'**
  String get volume24h;

  /// No description provided for @allTimeHigh.
  ///
  /// In en, this message translates to:
  /// **'All-Time High'**
  String get allTimeHigh;

  /// No description provided for @allTimeLow.
  ///
  /// In en, this message translates to:
  /// **'All-Time Low'**
  String get allTimeLow;

  /// No description provided for @addToPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Add to Portfolio'**
  String get addToPortfolio;

  /// No description provided for @portfolioEmpty.
  ///
  /// In en, this message translates to:
  /// **'Portfolio is empty'**
  String get portfolioEmpty;

  /// No description provided for @addCoin.
  ///
  /// In en, this message translates to:
  /// **'Add Coin'**
  String get addCoin;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @buyPrice.
  ///
  /// In en, this message translates to:
  /// **'Buy Price'**
  String get buyPrice;

  /// No description provided for @totalValue.
  ///
  /// In en, this message translates to:
  /// **'Total Value'**
  String get totalValue;

  /// No description provided for @profitLoss.
  ///
  /// In en, this message translates to:
  /// **'Profit / Loss'**
  String get profitLoss;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get showMore;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noCoinsFound.
  ///
  /// In en, this message translates to:
  /// **'No coins found'**
  String get noCoinsFound;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline mode — showing cached data'**
  String get offlineMode;

  /// No description provided for @errorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoading;

  /// No description provided for @chartUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Chart unavailable'**
  String get chartUnavailable;

  /// No description provided for @marketData.
  ///
  /// In en, this message translates to:
  /// **'Market Data'**
  String get marketData;

  /// No description provided for @toggleTheme.
  ///
  /// In en, this message translates to:
  /// **'Toggle theme'**
  String get toggleTheme;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Portfolio feature coming soon!'**
  String get comingSoon;

  /// No description provided for @failedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load coin details'**
  String get failedToLoad;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhoto;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get confirmDelete;

  /// No description provided for @days7.
  ///
  /// In en, this message translates to:
  /// **'7D'**
  String get days7;

  /// No description provided for @days14.
  ///
  /// In en, this message translates to:
  /// **'14D'**
  String get days14;

  /// No description provided for @days30.
  ///
  /// In en, this message translates to:
  /// **'30D'**
  String get days30;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearch;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;
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
  // Lookup logic when only language code is specified.
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
