# Authentication Decisions

## ADR-AUTH-001: Administrator Authentication

### Decision

Use **server-side sessions** with an **HTTP-only, Secure, SameSite=Lax cookie** named `FINZY_ADMIN_SESSION`.

Do not use JWT in `localStorage` or `sessionStorage`.

### Rationale

- Native Spring Security session support
- Simple logout and revocation (invalidate session server-side)
- One admin user for MVP — JWT adds complexity without benefit
- CSRF protection via Spring Security + SameSite cookies

### Flow

```text
POST /api/v1/admin/auth/login  { email, password }
        │
        ▼
Spring Security validates → creates server session
        │
        ▼
Set-Cookie: FINZY_ADMIN_SESSION=...; HttpOnly; Secure; SameSite=Lax
        │
        ▼
Subsequent admin requests send cookie automatically
```

### Session Storage (MVP)

JDBC-backed sessions in PostgreSQL so sessions survive application restarts.

### Brute-Force Protection

Lock account after repeated failed login attempts using `failed_login_attempts` and `locked_until` on `admin_users`.

### Roles (MVP)

Only `OWNER` is required initially. The schema supports `ADMIN` and `STAFF` for future use.

### CORS and Cookies

| Setting | Development | Production |
|---------|-------------|------------|
| Frontend origin | `http://localhost:3000` | `https://app.finzy.com` |
| Backend origin | `http://localhost:8080` | `https://api.finzy.com` |
| CORS | Allow frontend origin with `credentials: true` | Same |
| Frontend fetch | `credentials: 'include'` on admin API calls | Same |
| CSRF | Spring CSRF enabled; token from login or `/admin/auth/csrf` | Same |

---

## ADR-AUTH-002: Customer Portal Authentication

### Decision

Use **opaque access tokens** in the URL path. Customers do not create accounts in the MVP.

```text
https://app.finzy.com/portal/{rawToken}
```

### Token Rules

| Rule | Detail |
|------|--------|
| Format | Cryptographically random, ≥ 32 bytes, URL-safe (Base64URL) |
| Storage | SHA-256 hash only in `customer_access_tokens.token_hash` |
| Delivery | Raw token shown or sent once when generated; never logged |
| Validation | Not revoked, not expired, customer `is_active = true` |
| API header | `X-Portal-Token: {rawToken}` |

### Portal Security

- Rate-limit portal endpoints by IP and token
- Return **404** (not 403) for invalid or expired tokens
- Never expose `internal_notes`, audit data, admin-only files, or token hashes in portal responses

### Token Lifecycle (MVP)

| Setting | Value |
|---------|-------|
| Expiration | 90 days from creation |
| Revocation | Administrator can revoke from customer profile |
| Multiple tokens | Allowed historically; one active token preferred per customer |

---

## Auth Summary

| Actor | Mechanism | MVP Accounts |
|-------|-----------|--------------|
| Administrator | Session cookie | Yes (email + password) |
| Customer | Opaque portal token | No |
| Public visitor | None | N/A (booking form only) |
