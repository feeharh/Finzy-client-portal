# System Architecture

## 1. Purpose

This document defines the high-level architecture for the Finzy Client Portal.

The architecture is designed to support the MVP for Finzy Alterations while keeping the system maintainable, secure, testable, and capable of evolving into a multi-business SaaS platform later.

The system will initially be implemented as a modular monolith rather than as microservices.

---

## 2. Architecture Goals

The architecture should:

- Support the full customer appointment and alteration workflow
- Keep customer measurements and garment records secure
- Allow independent evolution of major business domains
- Remain simple enough for one full-stack engineer to build and maintain
- Support low-cost deployment
- Avoid premature complexity
- Enable future SaaS and marketplace integrations
- Provide clear separation between frontend, backend, database, storage, and third-party services

---

## 3. Architecture Style

The MVP will use a three-tier architecture:

1. Presentation Layer
2. Application Layer
3. Data Layer

The backend will be implemented as a modular monolith.

### 3.1 Presentation Layer

Responsible for:

- Customer-facing pages
- Administrator dashboard
- Appointment forms
- Customer portal
- Measurement views
- Quote views
- Garment tracking
- Calendar links
- WhatsApp deep links

Technology:

- Next.js
- React
- TypeScript
- Tailwind CSS

### 3.2 Application Layer

Responsible for:

- Business logic
- Authentication
- Authorization
- Appointment workflows
- Customer management
- Garment management
- Measurement management
- Quote management
- Notification orchestration
- File metadata
- Audit logging
- Secure customer portal access

Technology:

- Java
- Spring Boot
- Spring Security
- Spring Data JPA

### 3.3 Data Layer

Responsible for:

- Persistent business data
- Historical records
- Status history
- Audit logs
- Secure access-token metadata
- Notification delivery records
- File metadata

Technology:

- PostgreSQL
- Flyway database migrations

---

## 4. High-Level System Diagram

```text
+------------------------+
| Customer Web Browser   |
+-----------+------------+
            |
            | HTTPS
            v
+------------------------+
| Next.js Frontend       |
|                        |
| Customer Portal        |
| Admin Dashboard        |
+-----------+------------+
            |
            | REST/JSON over HTTPS
            v
+-------------------------------+
| Spring Boot Backend           |
|                               |
| Authentication                |
| Customer Module               |
| Appointment Module            |
| Garment Module                |
| Measurement Module            |
| Quote Module                  |
| Communication Module          |
| Notification Module           |
| File Module                   |
| Audit Module                  |
+-----------+-------------------+
            |
            +-----------------------------+
            |                             |
            v                             v
+------------------------+     +--------------------------+
| PostgreSQL Database    |     | External Media Storage   |
|                        |     |                          |
| Customers              |     | Photos                   |
| Appointments           |     | Videos                   |
| Garments               |     | PDFs                     |
| Measurements           |     | Attachments              |
| Quotes                 |     |                          |
| Status History         |     | Cloudinary or S3         |
| Audit Logs             |     +--------------------------+
+------------------------+
            |
            +-----------------------------+
            |                             |
            v                             v
+------------------------+     +--------------------------+
| Email Provider         |     | WhatsApp                 |
|                        |     |                          |
| Appointment updates    |     | Deep links for MVP       |
| Quote notifications    |     | Business API later       |
| Reminders              |     +--------------------------+
+------------------------+



5. Technology Stack
5.1 Frontend
Next.js
React
TypeScript
Tailwind CSS
React Hook Form
Zod
Fetch API or Axios
5.2 Backend
Java 21
Spring Boot
Spring Web
Spring Security
Spring Data JPA
Bean Validation
Flyway
Jackson
Lombok, if used carefully
MapStruct, if mapping complexity justifies it
5.3 Database
PostgreSQL
5.4 File Storage

MVP:

Cloudinary or an S3-compatible storage provider

Future:

AWS S3 with signed URLs and lifecycle policies
5.5 Notifications

MVP:

Email provider
WhatsApp deep links

Future:

WhatsApp Business Platform
SMS provider
Background notification worker
5.6 Local Development
Docker
Docker Compose
PostgreSQL container
Optional MailHog container for email testing
5.7 Deployment

Potential MVP deployment:

Frontend: Vercel
Backend: Render, Railway, Fly.io, or another container host
Database: Neon, Supabase PostgreSQL, Railway PostgreSQL, or managed PostgreSQL
Media: Cloudinary or S3-compatible storage

The final hosting choice will be documented in the infrastructure phase.

6. Modular Monolith Design

The backend will be one deployable Spring Boot application, organized into business modules.


backend/
└── src/main/java/com/finzyportal/
    ├── auth/
    ├── customer/
    ├── appointment/
    ├── garment/
    ├── measurement/
    ├── quote/
    ├── communication/
    ├── notification/
    ├── file/
    ├── calendar/
    ├── audit/
    ├── shared/
    └── config/


Each module may contain:
controller/
service/
repository/
entity/
dto/
mapper/
event/
exception/



The application should avoid one global package for all controllers, another for all services, and another for all repositories.

Packaging by business feature will make the system easier to maintain and easier to separate later if necessary.

7. Core Business Modules
7.1 Authentication Module

Responsibilities:

Administrator login
Password validation
Token or session creation
Authorization checks
Login-attempt protection
Role management

MVP users:

Administrator

Future users:

Customer
Employee
Business owner
Platform administrator
7.2 Customer Module

Responsibilities:

Customer profile creation
Customer profile updates
Contact information
Preferred communication method
Customer history
Secure portal access association

Primary data:

Customer
CustomerAccessToken
7.3 Appointment Module

Responsibilities:

Appointment requests
Appointment approval
Rescheduling
Cancellation
Appointment status
Appointment history
Calendar eligibility

Primary data:

Appointment
AppointmentStatusHistory
PolicyAgreement
7.4 Garment Module

Responsibilities:

Multiple garments per appointment
Garment details
Alteration requests
Garment-specific status
Garment history
Marketplace source metadata

Primary data:

Garment
Alteration
GarmentStatusHistory
MarketplacePurchase
7.5 Measurement Module

Responsibilities:

Measurement profile creation
Measurement versioning
Current or preferred profile selection
Customer portal access
Measurement sharing
Future PDF generation

Primary data:

MeasurementProfile
MeasurementValue
7.6 Quote Module

Responsibilities:

Quote creation
Quote line items
Quote revision
Quote approval
Quote rejection
Price totals

Primary data:

Quote
QuoteLineItem
7.7 Communication Module

Responsibilities:

WhatsApp deep-link generation
Prefilled messages
Manual communication logs
Internal notes
Communication history

Primary data:

CommunicationLog
7.8 Notification Module

Responsibilities:

Notification creation
Email delivery
Notification retries
Delivery-status tracking
Failed-delivery recording

Primary data:

Notification
NotificationAttempt
7.9 File Module

Responsibilities:

Upload validation
File metadata
Storage-provider integration
File association with customers, appointments, and garments
Secure retrieval

Primary data:

FileAsset
7.10 Calendar Module

Responsibilities:

Google Calendar links
.ics file generation
Appointment event formatting
Rescheduled-event updates

This module may not require its own database table for the MVP unless calendar delivery history must be recorded.

7.11 Audit Module

Responsibilities:

Important administrator-action logging
Before-and-after values
Entity references
Immutable audit history

Primary data:

AuditLog
8. Frontend Architecture

The frontend will contain two primary experiences:

8.1 Customer Experience

Routes may include:


/
 /book
 /booking/confirmation
 /portal/{accessToken}
 /portal/{accessToken}/appointments
 /portal/{accessToken}/measurements
 /portal/{accessToken}/quotes


Responsibilities:

Appointment request form
Garment information
Media uploads
Secure portal access
Status tracking
Quote approval
Measurement viewing
Calendar links
8.2 Administrator Experience

Routes may include:
/admin/login
/admin/dashboard
/admin/customers
/admin/customers/{customerId}
/admin/appointments
/admin/appointments/{appointmentId}
/admin/garments/{garmentId}
/admin/measurements
/admin/quotes

Responsibilities:

Dashboard
Customer management
Appointment workflow
Garment workflow
Measurement entry
Quote creation
Communication tools
Audit-history viewing
9. Authentication and Authorization
9.1 Administrator Authentication

The administrator will authenticate using email and password.

Passwords will be stored only as secure password hashes.

Possible MVP authentication approaches:

Secure HTTP-only session cookie
JWT stored in an HTTP-only secure cookie

The final choice will be made before backend implementation.

Tokens should not be stored in browser local storage when a secure cookie approach is available.

9.2 Customer Portal Authentication

Customers will not create accounts in the MVP.

They will receive a secure private link containing a random access token.

Example:

https://app.example.com/portal/{token}

The backend will:

Receive the token
Hash or validate the token
Check that it is active
Check that it has not expired
Resolve it to one customer
Return only that customer's permitted data
9.3 Authorization Rules
Customers may access only their own portal data.
Administrators may access operational business data.
Internal notes must never be returned through customer-facing endpoints.
Secure token access must be revocable.
Sensitive actions must require administrator authorization.
10. API Architecture

The frontend will communicate with the backend through REST APIs using JSON.

Example API groups:

/api/v1/public/appointments
/api/v1/portal
/api/v1/admin/auth
/api/v1/admin/customers
/api/v1/admin/appointments
/api/v1/admin/garments
/api/v1/admin/measurements
/api/v1/admin/quotes

The API will use:

Versioned endpoints
DTOs rather than exposing JPA entities
Bean Validation
Consistent error responses
Pagination for list endpoints
Authorization at endpoint and service levels
Idempotency protection where useful

Detailed endpoints will be documented in api-spec.md.

11. Database Architecture

PostgreSQL will store normalized relational data.

Key relationships:

Customer
    |
    +--- Appointments
    |
    +--- Measurement Profiles
    |
    +--- Customer Access Tokens

Appointment
    |
    +--- Garments
    |
    +--- Quotes
    |
    +--- Communication Logs
    |
    +--- Appointment Status History

Garment
    |
    +--- Alterations
    |
    +--- File Assets
    |
    +--- Garment Status History

Database migrations will be managed by Flyway.

The application will not use Hibernate automatic schema creation in production.

Recommended production setting:

spring.jpa.hibernate.ddl-auto=validate
12. File Storage Architecture

Raw photos and videos will not be stored in PostgreSQL.

Upload flow:

Customer or Admin
        |
        v
Frontend selects file
        |
        v
Backend validates request
        |
        v
Media storage receives file
        |
        v
Backend stores file metadata and secure URL

The database will store:

Storage provider
Storage key
File name
MIME type
File size
Resource type
Related entity
Uploaded by
Upload timestamp

Future improvements may include:

Signed upload URLs
Signed download URLs
Malware scanning
Thumbnail generation
Automatic media optimization
Retention policies
13. Notification Architecture

Notification delivery should not block the main business operation.

Example:

Administrator updates garment status
        |
        v
Status is saved successfully
        |
        v
Notification record is created
        |
        v
Notification service attempts delivery
        |
        +--- Success
        |
        +--- Failure recorded for retry

For the initial MVP, notification processing may occur in the same application through an internal event listener and scheduled retry process.

Future versions may use:

Redis-backed queues
RabbitMQ
Kafka
Cloud queues
Separate notification workers

A message broker is not required for the first release.

14. WhatsApp Architecture
14.1 MVP

The application will generate WhatsApp deep links.

Example:

https://wa.me/{phoneNumber}?text={encodedMessage}

The administrator clicks the link and continues the conversation in WhatsApp.

The system may manually record:

Communication type
Message summary
Appointment reference
Communication timestamp
Administrator note
14.2 Future Integration

Future versions may use the WhatsApp Business Platform for:

Automated templates
Two-way messaging
Delivery status
Incoming-message webhooks
Appointment-specific conversation threads

This future integration will require business verification, provider approval, approved templates, and additional privacy controls.

15. Calendar Architecture

Approved appointments may be added to calendars through:

Google Calendar URL
Downloadable .ics file

Calendar events will include:

Appointment title
Start time
End time
Business name
Business location
Appointment reference
Preparation instructions

The application will generate calendar content dynamically from the approved appointment.

Direct calendar-account synchronization is outside MVP scope.

16. Marketplace Architecture

Marketplace purchases will use the same core appointment and garment workflow.

MVP flow:

Customer chooses marketplace alteration
        |
        v
Customer selects marketplace source
        |
        v
Customer pastes listing URL or uploads screenshots
        |
        v
Customer chooses saved measurement profile
        |
        v
System creates appointment and garment records

The core domain should not depend directly on Depop, Vinted, or another specific marketplace.

Marketplace-specific data should be represented through a generic marketplace source and optional external listing URL.

Direct marketplace API integrations are future adapters, not core-domain dependencies.

17. Security Architecture

Security controls will include:

HTTPS
Password hashing
Secure cookies or secure token handling
Role-based access control
Input validation
Output filtering
Rate limiting
File-type validation
File-size validation
Secure portal tokens
Audit logging
Restricted CORS configuration
Secrets stored outside source control
Generic authentication error messages
Sensitive-data redaction in logs

The system should follow OWASP recommendations where practical.

18. Error Handling

The backend will return consistent API error responses.

Example:

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

Error categories may include:

Validation errors
Authentication errors
Authorization errors
Resource not found
Conflict
Invalid status transition
File upload error
External service error
Internal server error

Internal exception details must not be exposed to customers.

19. Observability

The application will use structured logging.

Logs should include:

Request correlation ID
Endpoint
HTTP status
Execution time
Relevant entity identifiers
External-service failures

Logs must not include:

Passwords
Raw access tokens
Full sensitive measurement profiles
Unnecessary customer personal information

Future observability may include:

Sentry
OpenTelemetry
Prometheus
Grafana
Centralized log storage
20. Testing Architecture

The testing strategy will include:

Unit Tests

For:

Business rules
Status transitions
Quote calculations
Token validation
Calendar generation
WhatsApp link generation
Integration Tests

For:

Repositories
Database migrations
Authentication
Appointment creation
Measurement persistence
Quote approval
Customer portal access
API Tests

For:

Validation
Authorization
Error responses
Pagination
Status codes
Frontend Tests

For:

Forms
Customer tracking
Quote approval
Measurement display
Admin workflows
End-to-End Tests

For critical user journeys:

Customer submits appointment
Administrator approves appointment
Customer views approved appointment
Administrator adds measurements
Customer views measurements
Administrator creates quote
Customer approves quote
Administrator marks garment ready for pickup
21. Deployment Architecture

Potential MVP deployment:

GitHub Repository
        |
        v
GitHub Actions
        |
        +----------------------+
        |                      |
        v                      v
Frontend Deployment      Backend Deployment
Vercel                   Container Host
        |                      |
        +----------+-----------+
                   |
                   v
          Managed PostgreSQL

Additional services:

- External media storage
- Email provider
- Error monitoring

Production and development environments will use separate configuration and credentials.

22. Scalability Strategy

The system will begin as a single-business modular monolith.

Future scalability may include:

Phase 1
One business
One administrator
One application instance
Phase 2
Multiple administrators
Background workers
Redis caching
Improved media delivery
Read replicas if needed
Phase 3
Multiple businesses
Tenant-aware data model
Business-level authorization
Subscription billing
Multiple locations
Phase 4
Selective service extraction
Dedicated notification service
Dedicated file-processing service
Marketplace integration services

Microservices will be introduced only when operational or scaling needs justify them.

23. Key Architecture Decisions
ADR-001: Use a Modular Monolith

Decision:

Use one Spring Boot deployment organized by business modules.

Reason:

Easier for one engineer to build
Simpler deployment
Lower infrastructure cost
Easier transaction management
Supports future extraction if needed
ADR-002: Measurements Belong to Customers

Decision:

Measurement profiles belong to customers rather than appointments.

Reason:

Measurements may be reused
Customers can have measurement history
Avoids unnecessary duplication
ADR-003: Appointments Support Multiple Garments

Decision:

One appointment may contain multiple garments.

Reason:

Customers commonly bring several garments during one visit.

ADR-004: Garments Have Independent Status

Decision:

Each garment has its own workflow status.

Reason:

Garments under the same appointment may progress at different speeds.

ADR-005: Use Secure Customer Links for MVP

Decision:

Customers will access the portal using secure private links rather than accounts.

Reason:

Lower customer friction
Faster MVP delivery
No password-reset flow
Suitable for one-time customers
ADR-006: Use WhatsApp Deep Links for MVP

Decision:

Use prefilled WhatsApp deep links instead of direct API integration.

Reason:

Lower complexity
Lower cost
No business-platform approval required
Matches the business's current workflow
ADR-007: Use External Media Storage

Decision:

Store raw media outside PostgreSQL.

Reason:

Better performance
Lower database size
Easier delivery and optimization
Better scalability
ADR-008: Marketplace Support Uses a Generic Model

Decision:

Represent marketplace purchases generically instead of building the domain around Depop or Vinted.

Reason:

Avoid vendor lock-in
Support multiple marketplaces
Preserve a clean core domain
24. Architecture Constraints
MVP must remain affordable.
The system must be manageable by one full-stack engineer.
Free-tier limitations may affect provider selection.
Measurement data requires strong access controls.
Marketplace integrations depend on third-party API availability.
WhatsApp Business integration requires additional approval and setup.
Premature microservice architecture must be avoided.
25. Open Architecture Questions

The following decisions will be finalized before implementation:

Should administrator authentication use server sessions or JWT in secure HTTP-only cookies?
Which media-storage provider should be used for MVP?
Which email provider should be used?
Should measurement values use fixed database columns or a flexible measurement-value model?
Should quote ownership be appointment-level, garment-level, or support both?
Should notifications use synchronous internal events or a database-backed outbox pattern for MVP?
Which deployment providers provide the best balance of cost, reliability, and developer experience?
