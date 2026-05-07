# Nexus Ledger

A cross-platform (Web + Mobile) expense tracker built with **Flutter** and a **FastAPI + PostgreSQL** backend. Log transactions in natural language ("Pizza 15", "Salary 2000"), see them grouped by date, and track your running balance.

## Highlights

- **Smart input parsing** — `Coffee 5` is split into name + amount automatically.
- **Auto-categorization** — keyword-driven (Food, Transport, Entertainment, …).
- **Temporal grouping** — Today / Yesterday / specific dates.
- **Weekly summary card** — at-a-glance "spent vs earned this week."
- **Swipe-to-delete** — auto-reverts the balance change.
- **JWT auth** with persistent session via `shared_preferences`.
- **Deep-sea blue / white** UI using Inter via `google_fonts`.

## Repo layout

```
.
├── backend/        FastAPI + SQLAlchemy + PostgreSQL
│   └── app/        models, schemas, auth, parser, routers
└── frontend/       Flutter (Web + Mobile) using Provider
    └── lib/        theme, models, providers, services, widgets, screens
```

See [`backend/README.md`](backend/README.md) and [`frontend/README.md`](frontend/README.md) for setup.

## Quick start

```bash
# 1. Backend
cd backend
python -m venv .venv && source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env                                # then edit DATABASE_URL + SECRET_KEY
uvicorn app.main:app --reload                       # http://localhost:8000

# 2. Frontend (in another terminal)
cd frontend
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
```

## API surface

| Method | Path                            | Notes                                  |
| ------ | ------------------------------- | -------------------------------------- |
| POST   | `/auth/signup`                  | username, nickname, password, balance  |
| POST   | `/auth/login`                   | OAuth2 password form                   |
| GET    | `/user/profile`                 | current user                           |
| PUT    | `/user/balance`                 | manually set current balance           |
| PUT    | `/user/nickname`                | rename                                 |
| GET    | `/transactions`                 | grouped by date (Today/Yesterday/…)    |
| POST   | `/transactions`                 | `{ raw_input, type: IN/OUT, note? }`   |
| DELETE | `/transactions/{id}`            | reverts the balance change             |
| GET    | `/transactions/summary/weekly`  | spent / earned / net for current week  |

Interactive docs at `http://localhost:8000/docs` once the backend is running.
