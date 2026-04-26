# Auth Design: simple custom auth + SQLAlchemy

This document describes a **deliberately small** custom authentication layer on top of a **SQLAlchemy-backed** database for the `inmybeli` iOS + backend project. It is **not** intended to be “enterprise” auth: no social login, no MFA, no account recovery webhooks, no token revocation service—just enough to sign up, sign in, and protect API routes with a verifiable token.

> **Code quality.** Prefer a few well-named functions and thin routes over abstractions, plugins, and configuration sprawl. If a piece of auth logic does not fit on one screen, it is probably too clever for this scope.

> **Assumed stack.** iOS client stores a bearer token in the Keychain; Python backend (FastAPI) issues and verifies that token, hashes passwords with a standard library (e.g. `bcrypt` or `argon2-cffi`), and uses SQLAlchemy 2.x for users and app data.

---

## 1. Guiding principles

1. **We own identity in our DB.** Email (or username) + password live here; the backend hashes passwords and never stores plaintext.
2. **The client never dictates identity.** After login, the client sends only a signed token; the backend decodes/verifies it and loads the user by id. No `user_id` in the body for auth.
3. **Stateless API auth.** Issue a **JWT** (or similar signed blob) at login/registration. The server verifies signature and expiry on each request. No server-side session store for v1 (keeps deployment simple).
4. **Explicit non-goals (v1).** No OAuth, no “Sign in with Apple” via a provider, no email verification, no password reset email flow, no refresh-token rotation, no distributed revocation list. Add those only when the product needs them.
5. **Simple code paths:** one module for “passwords + token mint/verify,” one dependency for `get_current_user`, and straightforward routes—no extra layers “for later.”

---

## 2. High-level flow

```
┌────────────┐     1. POST /auth/register or /auth/login
│            │         { email, password }                  ┌──────────────┐
│  iOS app   │ ───────────────────────────────────────────▶ │   Backend    │
│            │         2. 200 { access_token, ... }         │  (FastAPI)   │
└─────┬──────┘                                                └──────┬───────┘
      │                                                               │
      │ 3. HTTPS  Authorization: Bearer <JWT>                        │
      ▼                                                               ▼
      │                      verify JWT ──▶ load User by sub (user id) │
      │                      optional: check user.is_active            │
      └────────────────────────────────────────────────────────────────┘
```

### Step-by-step

1. **Register** creates a `users` row with a **password hash**; **login** checks the password and returns a **JWT** whose `sub` is the internal user id (or a stable public id if you prefer).
2. **Authenticated requests** send `Authorization: Bearer <token>`. Middleware or a FastAPI dependency verifies the JWT, loads the user, and injects `current_user`.
3. **Logout (client-only for v1).** User deletes the token from the Keychain. Without a blocklist, old JWTs remain valid until they expire—acceptable for a simple, non-robust design if TTL is short (e.g. 1h–24h; pick one and document it).

---

## 3. Database model

Keep the `users` table small. Hash passwords with a dedicated field; do not log or return it.

```python
# Example shape — names/types follow your project conventions
class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(primary_key=True)
    email: Mapped[str] = mapped_column(String(320), unique=True, index=True, nullable=False)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    created_at: Mapped[datetime] = ...
    updated_at: Mapped[...] = ...
```

**Do not** store: plaintext passwords, pre-hash “secrets” in logs, or full JWTs in the database for v1.

**Optional:** a single `public_id` (UUID) for external references instead of integer ids in APIs.

---

## 4. Backend: password hashing + JWT

### 4.1 Single module, clear responsibilities

Keep token and password helpers in one place, e.g. `app/auth/tokens.py` and `app/auth/passwords.py`, _or_ one file `app/auth/core.py` if the project is small—**whichever reads simpler**.

- **Hash password:** e.g. `bcrypt` with a sensible cost parameter; verify with constant-time compare (library helpers do this).
- **Mint JWT:** include `sub` (user id), `exp` (expiry), and optionally `iat`. Sign with `HS256` and a **long random secret** from the environment.
- **Verify JWT:** check signature and `exp`; return claims or fail closed.

```python
# Illustrative only — use your real settings and error types
def create_access_token(user_id: int) -> str: ...
def decode_access_token(token: str) -> dict:  # or raise
    ...
```

Use **one** `JWT_SECRET` (and optional `JWT_ALGORITHM`) in `config`; never commit secrets.

### 4.2 Routes: register and login (thin)

- `POST /auth/register` — validate email/password (minimal validation), hash password, insert user, return token (or 409 if email taken).
- `POST /auth/login` — look up by email, verify hash, return token; use generic error message for “bad credentials” to avoid user enumeration, or keep messages honest if you prefer simplicity over that nuance.
- **No** extra endpoints unless needed—one clear success shape: `{ "access_token": "...", "token_type": "bearer" }`.

### 4.3 FastAPI dependency: `get_current_user`

- Read `Authorization: Bearer ...`, decode JWT, get `user_id` from `sub`, load `User` from the DB, ensure `is_active`, return the model.
- On failure: `401` with a single short message. Avoid different error bodies for “expired” vs “invalid” if you want less surface area (optional).

```python
def get_current_user(
    authorization: str | None = Header(default=None),
    db: Session = Depends(get_db),
) -> User:
    ...
```

### 4.4 Using it in a route

```python
@app.get("/me")
def me(user: User = Depends(get_current_user)):
    return {"id": user.id, "email": user.email}
```

---

## 5. Clean and simple code (project rules)

- **One obvious path:** register and login should mirror each other in structure (parse → validate → db → token).
- **No premature factories:** a plain function that returns `User` is enough; skip generic “repositories” until you have more than one caller.
- **Config in one place:** all auth-related env vars in `config.py` (or equivalent) with types and defaults documented in comments, not spread across the codebase.
- **Errors:** map auth failures to HTTP status codes in the dependency or small helpers—avoid duplicating `if not token: raise` in every route.
- **Tests:** unit-test password verify + JWT encode/decode; integration-test one happy path and one 401. Do not over-mock; keep fixtures minimal.

---

## 6. Client responsibilities (iOS)

- On login/register response, store `access_token` in **Keychain**.
- Set `Authorization: Bearer <access_token>` on API calls.
- On **401**, clear the token and send the user to the login screen (no silent refresh for v1 if you do not implement refresh tokens).
- **Do not** put tokens in `UserDefaults`.

---

## 7. Security notes (realistic for “simple”)

- **HTTPS** everywhere in production. JWTs are bearer tokens.
- **Short-ish JWT TTL** to limit damage from a stolen token; accept that there is no server-side logout without a blocklist/refresh flow.
- **Secret hygiene:** `JWT_SECRET` is long, random, and stored as a real secret in deployment.
- **Hashing:** use a recognized password hashing library, not `hashlib` + salt by hand.
- This design is **not** a substitute for a hosted IdP or Firebase when you need recovery flows, social login, or compliance-heavy scenarios.

---

## 8. Testing strategy

- **Unit tests:** password hash round-trip; JWT exp and bad signature.
- **Integration tests:** register → `GET /me` with token → 200; bad token → 401.

---

## 9. Open questions / decisions

- [ ] Backend framework and DB engine (Postgres recommended; SQLite is fine for early dev with simpler migrations).
- [ ] JWT lifetime and clock skew policy.
- [ ] Whether public APIs expose integer `id` or a `public_id` (UUID) only.
- [ ] When (if ever) to add refresh tokens, email verification, or password reset—treat as a **new** design increment, not a tangle in v1.

---

## 10. Minimal reference layout

```
backend/
├── app/
│   ├── main.py                 # FastAPI app, include auth routes
│   ├── config.py               # JWT secret, db url, etc.
│   ├── db.py
│   ├── auth/
│   │   ├── __init__.py
│   │   ├── password.py         # or merged into security.py
│   │   ├── tokens.py
│   │   └── deps.py             # get_current_user
│   ├── models/
│   │   └── user.py
│   └── routes/
│       └── auth.py             # register, login
│       └── users.py            # /me, ...
└── pyproject.toml
```

**Summary:** the backend stores a password hash, issues a signed JWT, and protects routes with a **small** amount of well-factored code—no third-party auth provider, no extra moving parts in v1.
