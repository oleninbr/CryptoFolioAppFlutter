// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CryptoFolio';

  @override
  String get homeTitle => 'Market';

  @override
  String get portfolioTitle => 'Portfolio';

  @override
  String get profileTitle => 'Profile';

  @override
  String get loginTitle => 'Sign In';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get logout => 'Logout';

  @override
  String get search => 'Search coins...';

  @override
  String get price => 'Price';

  @override
  String get change24h => '24h Change';

  @override
  String get marketCap => 'Market Cap';

  @override
  String get volume => 'Volume';

  @override
  String get addToPortfolio => 'Add to Portfolio';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get loading => 'Loading...';
}
