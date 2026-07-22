# SportHeroes — Auth Flow (Email / Phone + Password)

Auth is handled entirely by the SportHeroes API. No Firebase / Supabase Auth.

## Login screen flow

1. User enters **email or phone** only → Continue  
2. App checks the account (`POST /auth/check`, or login probe fallback):
   - **Exists + has password** → ask for password → `POST /auth/login`
   - **Exists + no password** → Set password screen → `POST /auth/set-password`
   - **Not found** → Register screen (prefilled) → `POST /auth/register`
3. Store **`data.tokens.accessToken`** (app JWT) for all other APIs

## Endpoints

| Action | Endpoint |
|--------|----------|
| Check account | `POST /v1/auth/check` (optional; FE falls back if missing) |
| Register | `POST /v1/auth/register` |
| Login | `POST /v1/auth/login` |
| Set password (placeholder users) | `POST /v1/auth/set-password` |
| Change password (logged in) | `POST /v1/auth/change-password` |
| Reset password (knows current) | `POST /v1/auth/reset-password` |

### Check response (preferred)

```json
{ "success": true, "data": { "exists": true, "hasPassword": true } }
```

## Images

Still uploaded via our multipart APIs (backend stores in Supabase Storage):

- `POST /v1/auth/avatar`
- `PUT /v1/teams/:id/logo`
- `POST /v1/support/upload-image`
