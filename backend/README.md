# Nexus Ledger — Backend

FastAPI + SQLAlchemy + PostgreSQL. JWT auth.

## Prerequisites

- Python 3.9+
- A running PostgreSQL instance (local or hosted)

## Setup

```bash
python -m venv .venv
source .venv/bin/activate      # Windows: .venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env
```

Edit `.env`:

```
DATABASE_URL=postgresql://user:pass@localhost:5432/nexus_ledger
SECRET_KEY=<generate a long random string>
```

Create the database (tables are auto-created on first launch):

```bash
createdb nexus_ledger        # or use pgAdmin / your tool of choice
```

## Run

```bash
uvicorn app.main:app --reload
```

- API: http://localhost:8000
- Interactive docs: http://localhost:8000/docs
- Health check: http://localhost:8000/health

## Layout

```
app/
├── config.py             # settings via pydantic-settings
├── database.py           # engine, session, Base
├── models.py             # User, Transaction, TransactionType
├── schemas.py            # pydantic DTOs
├── auth.py               # password hashing, JWT, get_current_user
├── parser.py             # smart input parsing + auto-categorization
├── main.py               # app factory, CORS, route registration
└── routers/
    ├── auth.py           # /auth/signup, /auth/login
    ├── users.py          # /user/profile, /user/balance, /user/nickname
    └── transactions.py   # CRUD + weekly summary
```

## Smart parser

`app/parser.py` exposes `parse_input("Pizza 15") -> ("Pizza", Decimal("15"))` and
`categorize_for_type(name, type) -> "Food & Drink"`. Categories are keyword-driven;
extend `CATEGORY_KEYWORDS` to taste.

## Notes

- Tables are auto-created via `Base.metadata.create_all` on startup. For real
  migrations, swap to Alembic.
- CORS origins are configurable via the `CORS_ORIGINS` env var (comma-separated).
- Default JWT lifetime is 7 days.
