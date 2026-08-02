# Postman Collection

Import these files into Postman to test the Finzy Client Portal API.

## Files

| File | Purpose |
|------|---------|
| `Finzy-Client-Portal.postman_collection.json` | All API endpoints |
| `Finzy-Client-Portal.postman_environment.json` | Local dev variables |

## Import Steps

1. Open Postman
2. **Import** → drag both JSON files (or File → Import)
3. Select environment **Finzy Client Portal — Local** (top-right dropdown)
4. Start backend: `cd backend && mvn spring-boot:run`
5. Run **System → Health Check** — should return `200` with `{ "status": "UP" }`

## Environment Variables

| Variable | Default | Set by |
|----------|---------|--------|
| `baseUrl` | `http://localhost:8080/api/v1` | Manual |
| `adminEmail` | `owner@finzy.com` | Manual |
| `adminPassword` | `change-me` | Manual |
| `portalToken` | empty | Submit Appointment / Generate Portal Token |
| `customerId` | empty | Create Customer |
| `appointmentId` | empty | Submit Appointment |
| `garmentId` | empty | Add Garment |
| `quoteId` | empty | Create Quote |
| `profileId` | empty | Create Measurement Profile |

## Default Admin Credentials (local seed)

| Field | Value |
|-------|-------|
| Email | `owner@finzy.com` |
| Password | `change-me` |

Change this password before production deployment.

## Testing Admin Endpoints

1. Run **Admin Auth → Login** first
2. Postman stores the `FINZY_ADMIN_SESSION` cookie automatically
3. Run other admin requests in the same collection

> **Note:** Enable cookies in Postman: Settings → General → **Automatically follow redirects** and ensure cookies are enabled.

## Testing Portal Endpoints

1. Set `portalToken` manually, or
2. Run **Public → Submit Appointment** (once implemented) — auto-sets token from response, or
3. Run **Admin Customers → Generate Portal Token** (once implemented)

Portal folder applies `X-Portal-Token: {{portalToken}}` to all requests.

## Suggested Test Flow (once Phase 3 is built)

```text
1.  Public → Submit Appointment (Shopify shape)
2.  Admin Auth → Login
3.  Admin Appointments → Get Appointment
4.  Admin Appointments → Approve Appointment
5.  Portal → Get Appointment Detail
6.  Admin Garments → Update Garment Status
7.  Portal → Get Appointment Detail (see updated status)
8.  Admin Measurements → Create Measurement Profile
9.  Portal → List Measurements
10. Admin Quotes → Create Quote → Send Quote
11. Portal → Approve Quote
```

## Current Status

Only **Health Check** returns a live response in Phase 1. Other requests will return `404` until their implementation phase is complete.

See [api-spec.md](../api-spec.md) for full API documentation.
