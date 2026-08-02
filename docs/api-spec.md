# API Specification

## 1. Overview

This document defines the REST API for the Finzy Client Portal.

- **Base URL:** `/api/v1`
- **Content-Type:** `application/json` (except file uploads and `.ics` downloads)
- **Authentication:** See [auth-decision.md](./auth-decision.md)

### API Groups

| Group | Prefix | Auth |
|-------|--------|------|
| Public | `/public/*` | None |
| Portal | `/portal/*` | `X-Portal-Token` header |
| Admin | `/admin/*` | Session cookie (`FINZY_ADMIN_SESSION`) |

---

## 2. Common Conventions

### 2.1 Pagination

List endpoints accept query parameters:

```
?page=0&size=20&sort=createdAt,desc
```

**Response shape:**

```json
{
  "content": [],
  "page": 0,
  "size": 20,
  "totalElements": 142,
  "totalPages": 8
}
```

### 2.2 Error Response

```json
{
  "timestamp": "2026-07-21T20:30:00Z",
  "status": 400,
  "code": "VALIDATION_ERROR",
  "message": "The request contains invalid fields.",
  "fieldErrors": {
    "email": "A valid email address is required."
  },
  "path": "/api/v1/public/appointments"
}
```

**Error codes:**

| Code | HTTP Status |
|------|-------------|
| `VALIDATION_ERROR` | 400 |
| `UNAUTHORIZED` | 401 |
| `FORBIDDEN` | 403 |
| `NOT_FOUND` | 404 |
| `CONFLICT` | 409 |
| `INVALID_STATUS_TRANSITION` | 422 |
| `FILE_UPLOAD_ERROR` | 422 |
| `EXTERNAL_SERVICE_ERROR` | 502 |
| `INTERNAL_ERROR` | 500 |

### 2.3 Customer-Friendly Status Labels

Garment and appointment statuses are returned to customers as display labels:

| Internal | Customer Label |
|----------|----------------|
| `REQUEST_SUBMITTED` | Request Submitted |
| `APPROVED` | Approved |
| `READY_FOR_PICKUP` | Ready for Pickup |
| `IN_PROGRESS` | In Progress |

Administrators receive internal enum values.

---

## 3. Public API

No authentication required. Rate-limited by IP.

### 3.1 Submit Appointment Request

**Option B:** Accepts a full appointment shape. Shopify and the native `/book` form submit the same endpoint. Shopify sends one garment with minimal fields; the portal may send multiple garments with richer data.

```
POST /api/v1/public/appointments
```

**Request body:**

```json
{
  "customer": {
    "firstName": "Sarah",
    "lastName": "Johnson",
    "email": "sarah@example.com",
    "phoneNumber": "+1234567890",
    "whatsappNumber": null,
    "preferredCommunicationMethod": null
  },
  "appointment": {
    "appointmentType": "ALTERATION_CONSULTATION",
    "preferredStartAt": null,
    "preferredCompletionDate": "2026-09-15",
    "serviceDescription": null,
    "rushServiceRequested": false,
    "customerNotes": null
  },
  "garments": [
    {
      "garmentType": "DRESS",
      "description": null,
      "color": null,
      "brand": null,
      "sizeLabel": null,
      "customerNotes": "Need 1 inch hem, bringing shoes for length reference",
      "alterations": [
        {
          "alterationType": "HEMMING",
          "description": null
        }
      ],
      "fileAssetIds": []
    }
  ],
  "policyAgreements": [
    {
      "policyName": "Finzy Alterations Policies & Terms",
      "policyVersion": "1.0",
      "agreed": true
    },
    {
      "policyName": "Garment Inspection Acknowledgement",
      "policyVersion": "1.0",
      "agreed": true
    }
  ]
}
```

**Field notes:**

| Field | Required | Notes |
|-------|----------|-------|
| `customer.firstName` | Yes | Shopify splits full name into first/last |
| `customer.lastName` | Yes | |
| `customer.email` | Conditional | At least one contact method required |
| `customer.phoneNumber` | Conditional | E.164 format recommended |
| `customer.whatsappNumber` | No | |
| `customer.preferredCommunicationMethod` | No | `WHATSAPP`, `SMS`, `EMAIL`, `PHONE` |
| `appointment.appointmentType` | Yes | Defaults to `ALTERATION_CONSULTATION` if omitted |
| `appointment.preferredStartAt` | No | Visit date/time (portal); null from Shopify |
| `appointment.preferredCompletionDate` | No | Target completion date (Shopify form) |
| `appointment.rushServiceRequested` | Yes | Boolean |
| `garments` | Yes | Minimum 1 garment |
| `garments[].alterations` | Yes | Minimum 1 alteration per garment |
| `garments[].fileAssetIds` | No | UUIDs from presign/confirm upload flow |
| `policyAgreements` | Yes | All required policies must have `agreed: true` |

**Shopify form mapping:**

| Shopify Field | API Field |
|---------------|-----------|
| Full Name | `customer.firstName` + `customer.lastName` |
| Email | `customer.email` |
| Phone | `customer.phoneNumber` |
| Garment type | `garments[0].garmentType` |
| Alteration type | `garments[0].alterations[0].alterationType` |
| Alteration details | `garments[0].customerNotes` |
| File upload | `garments[0].fileAssetIds` |
| Preferred completion date | `appointment.preferredCompletionDate` |
| Rush service | `appointment.rushServiceRequested` |
| Policy checkboxes | `policyAgreements[]` |

**Response `201 Created`:**

```json
{
  "appointmentNumber": "FA-2026-0001",
  "appointmentId": "550e8400-e29b-41d4-a716-446655440000",
  "status": "REQUEST_SUBMITTED",
  "portalUrl": "https://app.finzy.com/portal/{rawToken}",
  "message": "Your request has been submitted."
}
```

The raw portal token is returned once in `portalUrl`. It is never stored in plain text.

**Server-side behavior:**

1. Create or match customer by email/phone
2. Create appointment with status `REQUEST_SUBMITTED`
3. Create garments and proposed alterations
4. Record policy agreements
5. Generate customer access token
6. Create appointment status history record
7. Queue notification (appointment request received)

---

### 3.2 List Appointment Types

```
GET /api/v1/public/appointment-types
```

**Response `200`:**

```json
[
  { "value": "ALTERATION_CONSULTATION", "label": "Alteration Consultation" },
  { "value": "GARMENT_DROP_OFF", "label": "Garment Drop-off" },
  { "value": "MEASUREMENT_SESSION", "label": "Measurement Session" },
  { "value": "FITTING", "label": "Fitting" },
  { "value": "FINAL_FITTING", "label": "Final Fitting" },
  { "value": "PICKUP", "label": "Pickup" },
  { "value": "BRIDAL_CONSULTATION", "label": "Bridal Consultation" },
  { "value": "MARKETPLACE_ALTERATION", "label": "Marketplace Alteration" },
  { "value": "OTHER", "label": "Other" }
]
```

---

### 3.3 List Policies

```
GET /api/v1/public/policies
```

**Response `200`:**

```json
[
  {
    "policyName": "Finzy Alterations Policies & Terms",
    "policyVersion": "1.0",
    "url": "https://finzy.com/policies/alterations"
  },
  {
    "policyName": "Garment Inspection Acknowledgement",
    "policyVersion": "1.0",
    "url": null
  }
]
```

---

### 3.4 Presign File Upload (Phase 4)

```
POST /api/v1/public/files/presign
```

**Request:**

```json
{
  "fileName": "dress-front.jpg",
  "mimeType": "image/jpeg",
  "fileSizeBytes": 2048000,
  "resourceType": "GARMENT_PHOTO"
}
```

**Response `200`:**

```json
{
  "uploadUrl": "https://...",
  "fileAssetId": "550e8400-e29b-41d4-a716-446655440000",
  "expiresAt": "2026-07-21T21:00:00Z"
}
```

---

## 4. Portal API

All portal endpoints require the header:

```http
X-Portal-Token: {rawToken}
```

Invalid, expired, or revoked tokens return **404 Not Found**.

### 4.1 Customer Profile

```
GET /api/v1/portal/profile
```

**Response `200`:**

```json
{
  "firstName": "Sarah",
  "lastName": "Johnson",
  "email": "sarah@example.com",
  "phoneNumber": "+1234567890",
  "preferredCommunicationMethod": "WHATSAPP"
}
```

---

### 4.2 List Appointments

```
GET /api/v1/portal/appointments
```

**Response `200`:**

```json
{
  "content": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "appointmentNumber": "FA-2026-0001",
      "appointmentType": "Alteration Consultation",
      "status": "Approved",
      "preferredCompletionDate": "2026-09-15",
      "scheduledStartAt": "2026-08-15T14:00:00Z",
      "scheduledEndAt": "2026-08-15T15:00:00Z",
      "garmentCount": 1,
      "createdAt": "2026-07-21T10:00:00Z"
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 1,
  "totalPages": 1
}
```

---

### 4.3 Get Appointment Detail

```
GET /api/v1/portal/appointments/{appointmentId}
```

**Response `200`:**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "appointmentNumber": "FA-2026-0001",
  "appointmentType": "Alteration Consultation",
  "status": "Approved",
  "preferredCompletionDate": "2026-09-15",
  "scheduledStartAt": "2026-08-15T14:00:00Z",
  "scheduledEndAt": "2026-08-15T15:00:00Z",
  "serviceDescription": null,
  "customerNotes": null,
  "rushServiceRequested": false,
  "garments": [
    {
      "id": "660e8400-e29b-41d4-a716-446655440001",
      "garmentNumber": "FG-2026-0001",
      "garmentType": "Dress",
      "description": null,
      "color": null,
      "status": "In Progress",
      "customerNotes": "Need 1 inch hem",
      "alterations": [
        {
          "alterationType": "Hemming",
          "description": null,
          "status": "In Progress"
        }
      ],
      "files": [
        {
          "id": "770e8400-e29b-41d4-a716-446655440002",
          "fileName": "dress-front.jpg",
          "mimeType": "image/jpeg",
          "url": "https://..."
        }
      ]
    }
  ],
  "createdAt": "2026-07-21T10:00:00Z"
}
```

---

### 4.4 Appointment Status History

```
GET /api/v1/portal/appointments/{appointmentId}/status-history
```

**Response `200`:**

```json
[
  {
    "previousStatus": null,
    "newStatus": "Request Submitted",
    "occurredAt": "2026-07-21T10:00:00Z"
  },
  {
    "previousStatus": "Request Submitted",
    "newStatus": "Approved",
    "occurredAt": "2026-07-22T09:00:00Z"
  }
]
```

---

### 4.5 Measurement Profiles

```
GET /api/v1/portal/measurements
GET /api/v1/portal/measurements/{profileId}
```

**Profile detail response `200`:**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "profileName": "Bridal Fit",
  "measurementDate": "2026-07-20",
  "unit": "INCHES",
  "isCurrent": true,
  "values": [
    { "measurementType": "Bust", "value": 36.0, "note": null },
    { "measurementType": "Waist", "value": 28.0, "note": null }
  ]
}
```

---

### 4.6 Quotes

```
GET /api/v1/portal/quotes
GET /api/v1/portal/quotes/{quoteId}
```

**Quote detail response `200`:**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "quoteNumber": "FQ-2026-0001",
  "status": "Sent",
  "currency": "USD",
  "subtotal": 45.00,
  "materialFee": 0.00,
  "rushFee": 15.00,
  "discountAmount": 0.00,
  "taxAmount": 0.00,
  "totalAmount": 60.00,
  "customerMessage": "Includes rush service fee.",
  "lineItems": [
    {
      "description": "Dress hem — 1 inch",
      "quantity": 1,
      "unitPrice": 45.00,
      "lineTotal": 45.00
    }
  ],
  "expiresAt": "2026-08-01T00:00:00Z",
  "sentAt": "2026-07-23T10:00:00Z"
}
```

---

### 4.7 Approve / Reject Quote

```
POST /api/v1/portal/quotes/{quoteId}/approve
POST /api/v1/portal/quotes/{quoteId}/reject
```

**Request (optional note):**

```json
{
  "note": "Approved, please proceed."
}
```

**Response `200`:**

```json
{
  "quoteId": "550e8400-e29b-41d4-a716-446655440000",
  "status": "Approved",
  "decidedAt": "2026-07-24T14:00:00Z"
}
```

---

### 4.8 Calendar Integration

Available only when appointment status is `APPROVED`.

```
GET /api/v1/portal/appointments/{appointmentId}/calendar/google
```

**Response `200`:**

```json
{
  "url": "https://calendar.google.com/calendar/render?action=TEMPLATE&..."
}
```

```
GET /api/v1/portal/appointments/{appointmentId}/calendar.ics
```

**Response `200`:** `text/calendar` file download.

---

## 5. Admin Auth API

Session cookie authentication. Frontend must send `credentials: 'include'`.

### 5.1 Login

```
POST /api/v1/admin/auth/login
```

**Request:**

```json
{
  "email": "owner@finzy.com",
  "password": "secure-password"
}
```

**Response `200`:**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "firstName": "Finzy",
  "lastName": "Owner",
  "email": "owner@finzy.com",
  "role": "OWNER"
}
```

Sets `FINZY_ADMIN_SESSION` cookie.

---

### 5.2 Logout

```
POST /api/v1/admin/auth/logout
```

**Response `204`:** No content. Clears session cookie.

---

### 5.3 Current User

```
GET /api/v1/admin/auth/me
```

**Response `200`:** Same shape as login response.

**Response `401`:** Not authenticated.

---

### 5.4 CSRF Token

```
GET /api/v1/admin/auth/csrf
```

**Response `200`:**

```json
{
  "token": "csrf-token-value",
  "headerName": "X-XSRF-TOKEN"
}
```

---

## 6. Admin Dashboard

```
GET /api/v1/admin/dashboard/summary
```

**Response `200`:**

```json
{
  "newRequests": 3,
  "todaysAppointments": 5,
  "garmentsInProgress": 12,
  "readyForFitting": 2,
  "readyForPickup": 4,
  "outstandingQuotes": 6
}
```

---

## 7. Admin Customers

```
GET    /api/v1/admin/customers
POST   /api/v1/admin/customers
GET    /api/v1/admin/customers/{id}
PUT    /api/v1/admin/customers/{id}
GET    /api/v1/admin/customers/{id}/history
POST   /api/v1/admin/customers/{id}/access-tokens
POST   /api/v1/admin/customers/{id}/access-tokens/{tokenId}/revoke
```

### Create Customer

**Request:**

```json
{
  "firstName": "Sarah",
  "lastName": "Johnson",
  "email": "sarah@example.com",
  "phoneNumber": "+1234567890",
  "whatsappNumber": "+1234567890",
  "preferredCommunicationMethod": "WHATSAPP",
  "notes": null
}
```

### Generate Portal Token

```
POST /api/v1/admin/customers/{id}/access-tokens
```

**Response `201`:**

```json
{
  "portalUrl": "https://app.finzy.com/portal/{rawToken}",
  "expiresAt": "2026-10-21T10:00:00Z"
}
```

---

## 8. Admin Appointments

```
GET    /api/v1/admin/appointments
GET    /api/v1/admin/appointments/{id}
POST   /api/v1/admin/appointments/{id}/approve
POST   /api/v1/admin/appointments/{id}/decline
POST   /api/v1/admin/appointments/{id}/reschedule
POST   /api/v1/admin/appointments/{id}/cancel
POST   /api/v1/admin/appointments/{id}/request-information
POST   /api/v1/admin/appointments/{id}/complete
GET    /api/v1/admin/appointments/{id}/status-history
```

### Approve Appointment

**Request:**

```json
{
  "scheduledStartAt": "2026-08-15T14:00:00Z",
  "scheduledEndAt": "2026-08-15T15:00:00Z",
  "internalNotes": "Confirmed via WhatsApp"
}
```

### Decline Appointment

**Request:**

```json
{
  "note": "Schedule fully booked for requested date."
}
```

### Reschedule Appointment

**Request:**

```json
{
  "scheduledStartAt": "2026-08-20T14:00:00Z",
  "scheduledEndAt": "2026-08-20T15:00:00Z",
  "note": "Customer requested new date."
}
```

### Request Information

**Request:**

```json
{
  "note": "Please send a photo of the shoes you plan to wear."
}
```

---

## 9. Admin Garments

```
GET    /api/v1/admin/appointments/{appointmentId}/garments
POST   /api/v1/admin/appointments/{appointmentId}/garments
GET    /api/v1/admin/garments/{id}
PUT    /api/v1/admin/garments/{id}
POST   /api/v1/admin/garments/{id}/status
GET    /api/v1/admin/garments/{id}/status-history
POST   /api/v1/admin/garments/{id}/alterations
PUT    /api/v1/admin/alterations/{id}
```

### Update Garment Status

**Request:**

```json
{
  "newStatus": "READY_FOR_PICKUP",
  "note": "Pressed and bagged"
}
```

**Response `422`** if transition is invalid (`INVALID_STATUS_TRANSITION`).

---

## 10. Admin Measurements

```
GET    /api/v1/admin/customers/{customerId}/measurements
POST   /api/v1/admin/customers/{customerId}/measurements
GET    /api/v1/admin/measurements/{profileId}
PUT    /api/v1/admin/measurements/{profileId}
POST   /api/v1/admin/measurements/{profileId}/set-current
```

### Create Measurement Profile

**Request:**

```json
{
  "profileName": "Bridal Fit",
  "measurementDate": "2026-07-20",
  "unit": "INCHES",
  "notes": "Wearing 2 inch heels",
  "isCurrent": true,
  "values": [
    { "measurementType": "BUST", "value": 36.0 },
    { "measurementType": "WAIST", "value": 28.0 }
  ]
}
```

Creating a new profile never overwrites existing profiles.

---

## 11. Admin Quotes

Quotes belong to an appointment. An optional `garmentId` scopes a quote to one garment.

```
GET    /api/v1/admin/appointments/{appointmentId}/quotes
POST   /api/v1/admin/appointments/{appointmentId}/quotes
GET    /api/v1/admin/quotes/{id}
PUT    /api/v1/admin/quotes/{id}
POST   /api/v1/admin/quotes/{id}/send
POST   /api/v1/admin/quotes/{id}/revise
```

### Create Quote

**Request:**

```json
{
  "garmentId": "660e8400-e29b-41d4-a716-446655440001",
  "currency": "USD",
  "materialFee": 0.00,
  "rushFee": 15.00,
  "discountAmount": 0.00,
  "taxAmount": 0.00,
  "customerMessage": "Includes rush service fee.",
  "lineItems": [
    {
      "alterationId": null,
      "description": "Dress hem — 1 inch",
      "quantity": 1,
      "unitPrice": 45.00
    }
  ]
}
```

Server calculates `subtotal`, `lineTotal`, and `totalAmount`.

---

## 12. Admin Communication

```
GET    /api/v1/admin/customers/{customerId}/communications
POST   /api/v1/admin/communications
GET    /api/v1/admin/communications/whatsapp-link
```

### Log Communication

**Request:**

```json
{
  "customerId": "550e8400-e29b-41d4-a716-446655440000",
  "appointmentId": "660e8400-e29b-41d4-a716-446655440001",
  "garmentId": null,
  "communicationType": "WHATSAPP",
  "direction": "OUTBOUND",
  "subject": null,
  "messageSummary": "Requested photo of shoes for hem length.",
  "customerVisible": false,
  "occurredAt": "2026-07-22T11:00:00Z"
}
```

### WhatsApp Deep Link

```
GET /api/v1/admin/communications/whatsapp-link?customerId={id}&appointmentId={id}&template=REQUEST_PHOTO
```

**Response `200`:**

```json
{
  "url": "https://wa.me/1234567890?text=Hi%20Sarah%2C%20this%20is%20Finzy%20Alterations...",
  "prefilledMessage": "Hi Sarah, this is Finzy Alterations regarding appointment FA-2026-0001. Could you please send a photo of the shoes you plan to wear with the dress?"
}
```

---

## 13. Admin Files (Phase 4)

```
POST   /api/v1/admin/files/presign
POST   /api/v1/admin/files/confirm
GET    /api/v1/admin/files/{id}
DELETE /api/v1/admin/files/{id}
```

---

## 14. Admin Audit Logs

```
GET /api/v1/admin/audit-logs?entityType=APPOINTMENT&entityId={id}&page=0&size=20
```

**Response `200`:**

```json
{
  "content": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "actionType": "APPOINTMENT_APPROVED",
      "entityType": "APPOINTMENT",
      "entityId": "660e8400-e29b-41d4-a716-446655440001",
      "actorAdminId": "770e8400-e29b-41d4-a716-446655440002",
      "createdAt": "2026-07-22T09:00:00Z"
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 1,
  "totalPages": 1
}
```

---

## 15. Reference Number Formats

| Entity | Format | Example |
|--------|--------|---------|
| Customer | `FC-{sequence}` | `FC-000001` |
| Appointment | `FA-{year}-{sequence}` | `FA-2026-0001` |
| Garment | `FG-{year}-{sequence}` | `FG-2026-0001` |
| Quote | `FQ-{year}-{sequence}` | `FQ-2026-0001` |

Generated in the application layer, not by the database.

---

## 16. Implementation Phases

| Phase | Endpoints |
|-------|-----------|
| **Phase 2** | Admin auth, error handling |
| **Phase 3** | Public appointments, admin appointment workflow, portal read, garments, measurements, quotes |
| **Phase 4** | File uploads, email notifications, WhatsApp links, calendar |
| **Phase 5** | Dashboard summary, audit logs |

---

## 17. Related Documents

- [auth-decision.md](./auth-decision.md) — Authentication architecture
- [erd.md](./erd.md) — Database schema
- [architecture.md](./architecture.md) — System architecture
- [requirements.md](./requirements.md) — Functional requirements
