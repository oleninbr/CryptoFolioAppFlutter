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
  String get home => 'Головна';

  @override
  String get portfolio => 'Портфель';

  @override
  String get profile => 'Профіль';

  @override
  String get search => 'Пошук монет...';

  @override
  String get sortBy => 'Сортувати за';

  @override
  String get sortMarketCap => 'Ринкова капіталізація';

  @override
  String get sortPriceDesc => 'Ціна (від вищої)';

  @override
  String get sortPriceAsc => 'Ціна (від нижчої)';

  @override
  String get sortChange => 'Зміна за 24г';

  @override
  String get marketCap => 'Ринкова капіталізація';

  @override
  String get volume24h => 'Обсяг за 24г';

  @override
  String get allTimeHigh => 'Максимум за весь час';

  @override
  String get allTimeLow => 'Мінімум за весь час';

  @override
  String get addToPortfolio => 'Додати до портфеля';

  @override
  String get portfolioEmpty => 'Портфель порожній';

  @override
  String get addCoin => 'Додати монету';

  @override
  String get quantity => 'Кількість';

  @override
  String get buyPrice => 'Ціна купівлі';

  @override
  String get totalValue => 'Загальна вартість';

  @override
  String get profitLoss => 'Прибуток / Збиток';

  @override
  String get login => 'Вхід';

  @override
  String get register => 'Реєстрація';

  @override
  String get email => 'Електронна пошта';

  @override
  String get password => 'Пароль';

  @override
  String get forgotPassword => 'Забули пароль?';

  @override
  String get logout => 'Вийти';

  @override
  String get settings => 'Налаштування';

  @override
  String get theme => 'Тема';

  @override
  String get themeLight => 'Світла';

  @override
  String get themeDark => 'Темна';

  @override
  String get themeSystem => 'Системна';

  @override
  String get language => 'Мова';

  @override
  String get currency => 'Валюта';

  @override
  String get about => 'Про монету';

  @override
  String get showMore => 'Показати більше';

  @override
  String get showLess => 'Показати менше';

  @override
  String get retry => 'Повторити';

  @override
  String get noCoinsFound => 'Монети не знайдено';

  @override
  String get offlineMode => 'Офлайн-режим — показуються кешовані дані';

  @override
  String get errorLoading => 'Помилка завантаження даних';

  @override
  String get chartUnavailable => 'Графік недоступний';

  @override
  String get marketData => 'Ринкові дані';

  @override
  String get toggleTheme => 'Змінити тему';

  @override
  String get comingSoon => "Функція портфеля скоро з'явиться!";

  @override
  String get failedToLoad => 'Не вдалося завантажити деталі монети';

  @override
  String get profilePhoto => 'Фото профілю';

  @override
  String get changePhoto => 'Змінити фото';

  @override
  String get camera => 'Камера';

  @override
  String get gallery => 'Галерея';

  @override
  String get save => 'Зберегти';

  @override
  String get cancel => 'Скасувати';

  @override
  String get delete => 'Видалити';

  @override
  String get confirmDelete => 'Підтвердити видалення';

  @override
  String get days7 => '7Д';

  @override
  String get days14 => '14Д';

  @override
  String get days30 => '30Д';

  @override
  String get tryDifferentSearch => 'Спробуйте інший пошуковий запит';

  @override
  String get noData => 'Немає даних';

  @override
  String get confirmPassword => 'Підтвердити пароль';

  @override
  String get passwordsDoNotMatch => 'Паролі не збігаються';

  @override
  String get loginSubtitle => 'Увійдіть до свого облікового запису';

  @override
  String get registerSubtitle => 'Створіть новий обліковий запис';

  @override
  String get alreadyHaveAccount => 'Вже є обліковий запис? Увійти';

  @override
  String get dontHaveAccount => 'Немає облікового запису? Зареєструватися';

  @override
  String get sendResetEmail => 'Надіслати лист для скидання';

  @override
  String resetEmailSent(String email) =>
      'Лист для скидання надіслано на $email';

  @override
  String get emailInvalid => 'Введіть дійсну електронну адресу';

  @override
  String get passwordTooShort =>
      'Пароль має містити щонайменше 6 символів';

  @override
  String get forgotPasswordTitle => 'Забули пароль';

  @override
  String get forgotPasswordSubtitle =>
      'Введіть вашу пошту для отримання посилання';

  @override
  String get showPassword => 'Показати пароль';

  @override
  String get hidePassword => 'Приховати пароль';

  @override
  String get takePhoto => 'Зробити фото';

  @override
  String get chooseFromGallery => 'Вибрати з галереї';

  @override
  String get uploadingPhoto => 'Завантаження фото...';

  @override
  String get permissionDenied => 'Доступ заборонено';

  @override
  String get permissionDeniedMessage =>
      'Будь ласка, надайте доступ у налаштуваннях пристрою';

  @override
  String get openSettings => 'Відкрити налаштування';

  @override
  String get selectPhotoSource => 'Виберіть джерело фото';
}
