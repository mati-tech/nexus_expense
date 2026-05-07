# Nexus Ledger — Frontend

Flutter app for Web + Mobile. State management via `provider`.

## Prerequisites

- Flutter 3.13+ (`flutter --version`)
- A running backend (see `../backend/README.md`)

## Setup

```bash
flutter pub get
```

If platform folders (`android/`, `ios/`, `web/`) are missing for a target you
care about, scaffold them:

```bash
flutter create . --platforms=web,android,ios
```

(The repo ships only `web/index.html` + `manifest.json` — Flutter generates the
rest on demand and they're git-ignored.)

## Run

```bash
# Web (Chrome)
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000

# Android emulator (uses 10.0.2.2 to reach host's localhost)
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8000

# iOS simulator
flutter run -d ios --dart-define=API_BASE_URL=http://localhost:8000
```

`API_BASE_URL` defaults to `http://localhost:8000` when not provided.

## Layout

```
lib/
├── main.dart                  # app entry + provider wiring + auth gate
├── theme/app_theme.dart       # deep-sea blue palette + Inter font
├── models/                    # Transaction, AppUser, WeeklySummary
├── services/api_service.dart  # HTTP client for the FastAPI backend
├── providers/
│   ├── auth_provider.dart     # login/signup/logout, persisted JWT
│   └── transaction_provider.dart
├── widgets/
│   ├── balance_card.dart      # gradient card on home
│   ├── weekly_summary_card.dart
│   ├── transaction_tile.dart  # color-coded amount row
│   ├── quick_log_bar.dart     # bottom input + In/Out toggle + note
│   └── empty_state.dart
└── screens/
    ├── login_screen.dart
    ├── signup_screen.dart
    ├── home_screen.dart       # grouped list + swipe-to-delete
    └── profile_screen.dart    # nickname/balance/logout
```

## UI conventions

- Income amounts → green (`AppColors.income`).
- Expense amounts → soft red/orange (`AppColors.expense`).
- All cards use `AppColors.surface` with a 1px `divider` border for a calm look.
- Swipe a transaction left to reveal the delete action.
- Empty home state shows an illustration with a friendly prompt.
