// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'CryptoFolio';

  @override
  String get homeTitle => 'Ринок';

  @override
  String get portfolioTitle => 'Портфель';

  @override
  String get profileTitle => 'Профіль';

  @override
  String get loginTitle => 'Вхід';

  @override
  String get registerTitle => 'Реєстрація';

  @override
  String get email => 'Електронна пошта';

  @override
  String get password => 'Пароль';

  @override
  String get signIn => 'Увійти';

  @override
  String get signUp => 'Зареєструватись';

  @override
  String get logout => 'Вийти';

  @override
  String get search => 'Пошук монет...';

  @override
  String get price => 'Ціна';

  @override
  String get change24h => 'Зміна за 24г';

  @override
  String get marketCap => 'Ринкова капіталізація';

  @override
  String get volume => 'Обсяг';

  @override
  String get addToPortfolio => 'Додати до портфеля';

  @override
  String get errorGeneric => 'Щось пішло не так. Спробуйте ще раз.';

  @override
  String get loading => 'Завантаження...';
}
