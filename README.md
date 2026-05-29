# CryptoFolio 📈

![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.5+-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

A cryptocurrency portfolio tracker built with Flutter. Browse live coin prices from CoinGecko, manage your portfolio with real-time P&L, authenticate with Firebase, and switch between Ukrainian, English, and Polish.

---

## Screenshots

| Home | Coin Detail | Portfolio | Profile |
|------|-------------|-----------|---------|
| ![Home](screenshots/home.png) | ![Detail](screenshots/detail.png) | ![Portfolio](screenshots/portfolio.png) | ![Profile](screenshots/profile.png) |

---

## Features

- ✅ Browse top-50 cryptocurrencies from CoinGecko API
- ✅ Price chart for 7 / 14 / 30 days
- ✅ Portfolio tracker with real-time P&L calculation
- ✅ Firebase Auth — register, login, password reset
- ✅ Cloud Firestore — portfolio storage with live sync
- ✅ Profile photo — camera / gallery → Firebase Storage
- ✅ Search and sort coins (market cap, price, 24 h change)
- ✅ Offline mode (SharedPreferences cache, 5-minute TTL)
- ✅ Localization: 🇺🇦 Ukrainian · 🇬🇧 English · 🇵🇱 Polish
- ✅ Light / Dark / System theme
- ✅ Animations — Hero, Fade, Shimmer, AnimatedContainer

---

## Tech Stack

| Technology | Purpose |
|---|---|
| Flutter 3.24+ | UI Framework |
| Dart 3.5+ | Programming Language |
| Riverpod 2.x | State Management |
| GoRouter 14 | Navigation |
| Firebase Auth | Authentication |
| Cloud Firestore | Database |
| Firebase Storage | File Storage |
| CoinGecko API | Crypto Market Data |
| fl_chart | Price Charts |
| SharedPreferences | Local Cache |

---

## Getting Started

### Requirements

- Flutter 3.24+
- Dart 3.5+
- Android Studio or VS Code
- A Firebase project (see below)

### Steps

**1. Clone the repository**
```bash
git clone https://github.com/<your-username>/CryptoFolioAppFlutter.git
cd CryptoFolioAppFlutter
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Configure Firebase**

1. Go to [console.firebase.google.com](https://console.firebase.google.com) and create a project.
2. Enable **Authentication → Email/Password**.
3. Enable **Firestore Database** (start in test mode, then add security rules).
4. Enable **Storage**.
5. Register your Android and iOS apps in the Firebase console.
6. Download `google-services.json` → place in `android/app/`.
7. Download `GoogleService-Info.plist` → place in `ios/Runner/`.
8. Run `flutterfire configure` to generate `lib/firebase_options.dart`, **or** fill in the `REPLACE_WITH_*` placeholders in the existing file manually.

**4. Run the app**
```bash
flutter run
```

**5. Run tests**
```bash
flutter test
```

---

## Project Structure

```
lib/
├── app.dart                        # Root widget, theme, and locale setup
├── main.dart                       # Entry point — Firebase initialisation
├── firebase_options.dart           # Firebase config (excluded from git)
│
├── core/
│   ├── constants/                  # API base URL, cache TTL
│   ├── l10n/                       # Generated ARB localizations (EN/UK/PL)
│   ├── network/                    # Dio provider with interceptors
│   ├── providers/                  # Theme mode provider
│   ├── router/                     # GoRouter + auth redirect guard
│   ├── theme/                      # AppColors, AppTheme
│   └── utils/                      # CurrencyFormatter, AppException
│
└── features/
    ├── auth/                       # Login, Register, Forgot Password
    ├── coin_detail/                # Detail screen, price chart, market data
    ├── home/                       # Coin list, search, sort, shimmer
    ├── portfolio/                  # Firestore CRUD, P&L, add / delete
    └── profile/                    # Photo upload, theme, language, currency

test/
├── unit/                           # Pure Dart unit tests (7 tests)
└── widget/                         # Widget tests with provider overrides (4 tests)
```

---

## CoinGecko API

The app uses the public CoinGecko v3 API — no API key required for basic usage.

| Endpoint | Description |
|---|---|
| `GET /coins/markets` | Top coins list with prices and market caps |
| `GET /coins/{id}` | Full coin detail and market data |
| `GET /coins/{id}/market_chart` | Historical price data for charts |
| `GET /search` | Coin search by name or symbol |

---

## License

MIT © Bohdan Olenin
