# System Architecture

## Architecture Style

The application will use a modern three-tier architecture.

Layers:

1. Presentation Layer (Frontend)
2. Application Layer (Backend APIs)
3. Data Layer (Database and Storage)

---

## High-Level Architecture

Customer
        |
        |
        V
Frontend (Next.js)
        |
        |
        V
Backend API (Spring Boot)
        |
        |
        +----------------------+
        |                      |
        V                      V
 PostgreSQL              File Storage
 Database               (Cloudinary/S3)

        |
        |
        V

 Notification Services

 - Email
 - SMS
 - WhatsApp

---

## Frontend

Technology:

- Next.js
- React
- Tailwind CSS
- TypeScript

Responsibilities:

- Appointment booking
- Customer portal
- Admin dashboard
- Measurement views
- Status tracking
- Calendar integration

---

## Backend

Technology:

- Java 21
- Spring Boot
- Spring Security
- Spring Data JPA

Responsibilities:

- Authentication
- Appointment management
- Customer management
- Measurement management
- File upload handling
- Notification orchestration
- Status tracking

---

## Database

Technology:

- PostgreSQL

Responsibilities:

- Customer data
- Appointment data
- Measurement records
- Status history
- Communication logs

---

## File Storage

Technology:

- Cloudinary (MVP)

Future:

- AWS S3

Responsibilities:

- Garment photos
- Garment videos
- Measurement PDFs
- Customer attachments

---

## Authentication

MVP

Admin:
- Username/password login
- JWT authentication

Customer:
- Secure appointment links

Future:

- Customer accounts
- OAuth login

---

## Notification Architecture

Notifications should not be sent directly from the request thread.

Recommended flow:

Status Updated
      |
      V
Notification Event Created
      |
      V
Notification Service
      |
      +---- Email
      |
      +---- SMS
      |
      +---- WhatsApp

Benefits:

- Faster API response
- Better scalability
- Easier retries

---

## Calendar Integration

Supported providers:

- Google Calendar
- Apple Calendar
- Outlook

Methods:

- Calendar links
- ICS file generation

---

## WhatsApp Integration

Phase 1

- WhatsApp deep links
- Prefilled messages

Phase 2

- WhatsApp Business API

Phase 3

- Two-way messaging
- Automated notifications

---

## Scalability Considerations

Future SaaS Version

Support:

- Multiple businesses
- Multiple administrators
- Multiple locations

Multi-tenancy strategy:

- tenant_id column
- Shared database
- Logical tenant isolation

---

## Security Considerations

- HTTPS only
- JWT authentication
- Password hashing
- Secure file access
- Audit logging
- Input validation
- Rate limiting

---

## Monitoring

Future:

- API performance metrics
- Error tracking
- Notification failures
- File upload failures
- Appointment analytics
