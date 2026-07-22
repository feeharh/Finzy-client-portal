# Software Requirements Specification

## 1. Introduction

### 1.1 Purpose

This document defines the functional and non-functional requirements for the Finzy Client Portal, a web-based client and workflow management platform for alteration businesses.

The platform will initially be developed for Finzy Alterations and will support the complete customer journey from appointment request through garment pickup.

The document serves as the primary requirements reference for:

- Product planning
- System architecture
- Database design
- API design
- Frontend development
- Backend development
- Testing
- Deployment

---

### 1.2 Product Scope

The Finzy Client Portal will centralize the processes currently managed through WhatsApp, text messages, paper records, phone calls, photo galleries, spreadsheets, and memory.

The platform will allow customers to:

- Request appointments
- Submit garment information
- Upload garment photos and videos
- Track appointment and garment progress
- Access saved measurements
- Add approved appointments to their calendars
- Receive updates
- Communicate with the business

The platform will allow administrators to:

- Manage customers
- Review appointment requests
- Approve, decline, or reschedule appointments
- Track multiple garments under one appointment
- Record customer measurements
- Create quotes
- Update garment statuses
- Communicate through WhatsApp
- Maintain customer and garment history

The first release will support one business: Finzy Alterations.

---

### 1.3 Definitions

| Term | Definition |
|---|---|
| Customer | A person requesting alteration or measurement services |
| Administrator | An authorized business user managing customers, appointments, garments, and measurements |
| Appointment | A request or scheduled visit for alteration, fitting, consultation, pickup, or measurement services |
| Garment | An individual clothing item associated with an appointment |
| Alteration | A specific modification requested for a garment |
| Measurement Profile | A versioned collection of a customer's body measurements |
| Customer Portal | A secure customer-facing area used to view appointments, garments, statuses, and measurements |
| Secure Access Link | A private token-based URL that allows a customer to access the portal without creating an account |
| Marketplace Purchase | A garment purchased from a resale or online marketplace |
| Communication Log | A record of communication related to a customer or appointment |
| MVP | The minimum viable product required for Finzy Alterations to use the system in production |

---

## 2. Stakeholders

### 2.1 Business Owner

The business owner requires a centralized platform that reduces administrative work and improves visibility across appointments, garments, measurements, and customer communication.

### 2.2 Administrator

The administrator manages daily operations, including appointment requests, customer records, measurements, garments, quotes, statuses, and communication.

For the MVP, the business owner and administrator may be the same person.

### 2.3 Customer

The customer requests services, provides garment details, attends appointments, receives updates, accesses measurements, and tracks garment progress.

### 2.4 Future Alteration Business

A future alteration business may subscribe to the platform and manage its own customers, employees, appointments, and locations.

This stakeholder is outside the MVP scope but should be considered in long-term architectural planning.

---

## 3. User Personas

### 3.1 Customer Persona

A customer who needs alteration, fitting, consultation, or measurement services.

#### Goals

- Request an appointment easily
- Share garment information before visiting
- Receive confirmation and reminders
- Know when a garment is ready
- Access saved measurements at any time
- Avoid repeatedly contacting the business for updates
- Reuse measurements for future services
- Request alterations for online or preowned purchases

#### Pain Points

- Losing measurement records
- Repeating the same information
- Forgetting appointment dates
- Not knowing garment progress
- Searching through old WhatsApp conversations
- Uncertainty about whether a purchased garment can be altered

---

### 3.2 Administrator Persona

The business owner or alteration specialist responsible for managing the service workflow.

#### Goals

- Review and control appointment scheduling
- Keep customer information organized
- Track every garment
- Record accurate measurements
- Retrieve previous alteration history
- Request additional information quickly
- Reduce repeated customer inquiries
- Maintain a record of important business actions

#### Pain Points

- Paper measurement books
- Scattered customer information
- Forgotten appointment details
- Garment photos stored across multiple devices
- Repeated status questions
- Difficulty tracking multiple garments under one appointment
- No centralized communication history

---

## 4. User Roles and Permissions

### 4.1 Customer

A customer may:

- Submit an appointment request
- Upload garment media
- Access their private customer portal
- View approved appointments
- View appointment and garment statuses
- View measurement profiles
- Download or share measurements
- Add approved appointments to a calendar
- View quotes
- Approve or reject quotes
- View previous completed services

A customer may not:

- View another customer's information
- Modify business-managed measurements
- Change garment statuses
- Access administrator tools
- View internal notes

---

### 4.2 Administrator

An administrator may:

- Log in securely
- Create and update customers
- Review appointment requests
- Approve, decline, cancel, or reschedule appointments
- Add multiple garments to appointments
- Add alterations to garments
- Upload files
- Create measurement profiles
- Create and update quotes
- Update appointment and garment statuses
- Send or initiate customer communication
- Add internal notes
- View audit and status histories

---

## 5. User Stories

### 5.1 Appointment Booking

As a customer, I want to submit an appointment request so that I can receive alteration services.

As a customer, I want to select my preferred date and time so that the business knows my availability.

As a customer, I want to explain what I need altered so that the business can prepare before my visit.

As an administrator, I want to review appointment requests so that I can control my schedule.

As an administrator, I want to suggest another date or time so that I can resolve scheduling conflicts.

---

### 5.2 Garment Submission

As a customer, I want to add multiple garments to one appointment so that I do not need to create separate requests for every item.

As a customer, I want to upload photos or videos so that the administrator can assess the garments.

As an administrator, I want each garment tracked separately so that its alterations, price, and status remain clear.

---

### 5.3 Measurement Management

As an administrator, I want to record customer measurements so that they are available for present and future services.

As a customer, I want to access my saved measurements so that I can use them when ordering clothes or working with another designer.

As a customer, I want to view previous measurement profiles so that I can see which measurements were recorded at different times.

As an administrator, I want to create a new measurement profile instead of overwriting an old one so that measurement history is preserved.

---

### 5.4 Appointment and Garment Tracking

As a customer, I want to view the progress of my appointment so that I do not need to ask for updates repeatedly.

As a customer, I want to see the status of each garment because garments under the same appointment may be completed at different times.

As an administrator, I want to update garment statuses so that customers remain informed.

As an administrator, I want every status change recorded so that I can review the complete workflow history.

---

### 5.5 Communication

As an administrator, I want to open a WhatsApp conversation from an appointment so that I can quickly request additional information.

As an administrator, I want the system to generate a prefilled WhatsApp message so that the appointment context is included.

As an administrator, I want to record communication notes so that I remember what was discussed.

As a customer, I want to receive notifications so that I know when action is required.

---

### 5.6 Calendar Integration

As a customer, I want to add an approved appointment to my calendar so that I do not forget it.

As an administrator, I want appointment information included in the calendar event so that the customer arrives prepared.

---

### 5.7 Quotes

As an administrator, I want to create a quote for each garment or alteration so that pricing is transparent.

As a customer, I want to review and approve a quote before work begins.

As an administrator, I want quote decisions recorded so that there is a clear approval history.

---

### 5.8 Marketplace Alteration Request

As a customer, I want to submit a garment purchased from an online marketplace so that I can request alterations.

As a customer, I want to use my saved measurements for a marketplace purchase so that I do not need to enter them again.

As a customer, I want to upload listing screenshots or paste a listing URL so that the business understands what I purchased.

As an administrator, I want marketplace purchases handled through the same garment workflow as other alteration requests.

---

## 6. Functional Requirements

## 6.1 Customer Management

### FR-CUS-001

The system shall allow an administrator to create a customer record.

### FR-CUS-002

The system shall store the customer's:

- First name
- Last name
- Email address
- Phone number
- WhatsApp number
- Preferred communication method

### FR-CUS-003

The system shall require at least one valid customer contact method.

### FR-CUS-004

The system shall allow an administrator to update customer contact information.

### FR-CUS-005

The system shall maintain a customer history containing appointments, garments, measurements, quotes, files, and communication logs.

### FR-CUS-006

The system shall prevent customers from accessing another customer's records.

---

## 6.2 Appointment Requests

### FR-APT-001

The system shall allow a customer to submit an appointment request without creating an account.

### FR-APT-002

The appointment request shall capture:

- Customer information
- Appointment type
- Preferred date
- Preferred time
- Service description
- Rush-service request
- Garment information
- Uploaded files
- Policy agreement

### FR-APT-003

The system shall generate a unique appointment number.

Example:

```text
FA-2026-0001



FR-APT-004

New appointment requests shall begin with the status:

REQUEST_SUBMITTED
FR-APT-005

The administrator shall be able to:

Approve
Decline
Reschedule
Cancel
Request more information
FR-APT-006

The system shall prevent unapproved appointments from being treated as confirmed appointments.

FR-APT-007

The system shall display upcoming appointments in daily and weekly views.

FR-APT-008

The system shall retain completed and cancelled appointments as historical records.

6.3 Appointment Types

The system shall support the following appointment types:

Alteration consultation
Garment drop-off
Measurement session
Fitting
Final fitting
Pickup
Bridal consultation
Marketplace alteration
Other

The administrator may add additional appointment types in a future release.

6.4 Garment Management
FR-GAR-001

An appointment shall support one or more garments.

FR-GAR-002

Each garment shall contain:

Garment type
Description
Color
Brand, when known
Size label, when known
Customer notes
Administrator notes
Quoted price
Final price
Current status
FR-GAR-003

Each garment may contain one or more alterations.

FR-GAR-004

Each alteration shall contain:

Alteration type
Description
Price
Status
Internal notes
FR-GAR-005

Each garment may have its own photos, videos, alterations, price, and status.

FR-GAR-006

The system shall allow multiple garments under the same appointment to have different statuses.

FR-GAR-007

The system shall preserve completed garment records in the customer's garment history.

6.5 File Uploads
FR-FIL-001

The system shall allow customers and administrators to upload garment photos.

FR-FIL-002

The system may allow short garment videos within configured size limits.

FR-FIL-003

Each uploaded file shall store:

File URL
File name
File type
File size
Uploading user type
Upload timestamp
Related customer, appointment, or garment
FR-FIL-004

The system shall store files in external object or media storage rather than storing raw file content in PostgreSQL.

FR-FIL-005

The system shall validate supported file types and file sizes.

FR-FIL-006

Private customer files shall not be publicly discoverable.

6.6 Measurement Profiles
FR-MEA-001

Measurements shall belong to the customer rather than to a single appointment.

FR-MEA-002

A customer may have multiple measurement profiles.

FR-MEA-003

The system shall not overwrite historical measurement profiles when new measurements are recorded.

FR-MEA-004

Each measurement profile shall include:

Profile name
Measurement date
Unit of measurement
Measurement values
Notes
Measured by
Creation timestamp
FR-MEA-005

Supported measurement fields may include:

Bust
Underbust
Waist
High hip
Hip
Shoulder
Shoulder to waist
Shoulder to floor
Dress length
Skirt length
Sleeve length
Armhole
Bicep
Elbow
Wrist
Neck
Thigh
Knee
Inseam
Trouser length
Rise
FR-MEA-006

The administrator shall be able to mark one measurement profile as the customer's current or preferred profile.

FR-MEA-007

The customer shall be able to view measurement profiles through the secure customer portal.

FR-MEA-008

The customer shall be able to download or share a measurement summary.

FR-MEA-009

The measurement summary may be generated as a PDF in a later MVP iteration.

6.7 Secure Customer Portal
FR-POR-001

Customers shall access the MVP portal using a secure private link.

FR-POR-002

The secure link shall contain a random, non-predictable token.

FR-POR-003

The raw access token shall not be stored in plain text when avoidable.

FR-POR-004

The administrator shall be able to revoke a customer access token.

FR-POR-005

The system shall support token expiration.

FR-POR-006

The customer portal shall display only data belonging to the authorized customer.

FR-POR-007

The portal shall allow customers to view:

Upcoming appointments
Appointment statuses
Garment statuses
Measurement profiles
Quotes
Completed service history
FR-POR-008

Future versions shall support customer accounts and login while retaining secure-link access for one-time customers.

6.8 Status Tracking
FR-STA-001

The system shall support appointment statuses including:

REQUEST_SUBMITTED
INFORMATION_REQUIRED
APPROVED
RESCHEDULED
DECLINED
CANCELLED
COMPLETED
FR-STA-002

The system shall support garment statuses including:

AWAITING_GARMENT
GARMENT_RECEIVED
ASSESSMENT_PENDING
QUOTE_PENDING
QUOTE_APPROVED
IN_PROGRESS
READY_FOR_FITTING
FITTING_REQUIRED
ADJUSTMENT_IN_PROGRESS
READY_FOR_PICKUP
PICKED_UP
COMPLETED
CANCELLED
FR-STA-003

Every status change shall create a status-history record.

FR-STA-004

A status-history record shall contain:

Previous status
New status
Changed by
Change timestamp
Optional note
FR-STA-005

The system shall validate status transitions.

For example, a garment should not normally move directly from GARMENT_RECEIVED to PICKED_UP.

FR-STA-006

The customer shall see customer-friendly status labels rather than internal enum names.

Example:

READY_FOR_PICKUP

Displayed as:

Ready for Pickup
6.9 Quotes
FR-QUO-001

The administrator shall be able to create a quote associated with an appointment or garment.

FR-QUO-002

A quote may contain multiple line items.

FR-QUO-003

Each quote line item shall contain:

Description
Quantity
Unit price
Line total
FR-QUO-004

The quote shall calculate:

Subtotal
Material fees
Rush fees
Discounts
Taxes, when applicable
Total
FR-QUO-005

Quote statuses shall include:

DRAFT
SENT
APPROVED
REJECTED
EXPIRED
REVISED
FR-QUO-006

The customer shall be able to approve or reject a quote.

FR-QUO-007

The system shall record the date and time of the customer's quote decision.

FR-QUO-008

Payment processing is outside the initial MVP scope.

6.10 Communication and WhatsApp
FR-COM-001

The system shall store the customer's WhatsApp number when provided.

FR-COM-002

The administrator shall be able to open a WhatsApp conversation from:

Customer profile
Appointment details
Garment details
FR-COM-003

The system shall generate prefilled WhatsApp messages containing relevant context.

Example:

Hi Sarah, this is Finzy Alterations regarding appointment FA-2026-0001. Could you please send a photo of the shoes you plan to wear with the dress?
FR-COM-004

The MVP shall use WhatsApp deep links rather than direct two-way WhatsApp API messaging.

FR-COM-005

The administrator shall be able to manually record a communication log.

FR-COM-006

Communication types shall include:

WHATSAPP
SMS
EMAIL
PHONE
IN_PERSON
INTERNAL_NOTE
FR-COM-007

Internal notes shall not be visible to the customer.

FR-COM-008

Future versions may integrate with the WhatsApp Business Platform for automated and two-way messaging.

6.11 Notifications
FR-NOT-001

The system shall support notifications for:

Appointment request received
Appointment approved
Appointment declined
Appointment rescheduled
More information required
Appointment reminder
Quote available
Quote approved
Ready for fitting
Ready for pickup
Measurement profile updated
FR-NOT-002

The MVP shall support email notifications where configured.

FR-NOT-003

WhatsApp messages may initially be sent manually using generated deep links.

FR-NOT-004

The system shall store notification delivery attempts.

FR-NOT-005

A notification record shall contain:

Recipient
Channel
Template or message type
Delivery status
Attempt count
Failure reason
Created timestamp
Sent timestamp
FR-NOT-006

Notification failures shall not cause the primary appointment or status-update request to fail.

6.12 Calendar Integration
FR-CAL-001

Customers shall be able to add approved appointments to a personal calendar.

FR-CAL-002

Supported calendar options shall include:

Google Calendar link
Downloadable .ics file
FR-CAL-003

The .ics file should support:

Apple Calendar
Outlook
Other compatible calendar applications
FR-CAL-004

Calendar event details shall include:

Appointment title
Date
Start time
End time
Business name
Business location
Appointment type
Preparation instructions
Appointment reference number
FR-CAL-005

The calendar option shall only become available after an appointment is approved.

FR-CAL-006

If an appointment is rescheduled, the customer shall be given updated calendar information.

6.13 Marketplace Purchase Alterations
FR-MKT-001

The system shall allow a customer to identify a garment as a marketplace purchase.

FR-MKT-002

The customer shall be able to select the marketplace source.

Examples:

Depop
Vinted
Poshmark
eBay
Facebook Marketplace
Etsy
Other
FR-MKT-003

The customer shall be able to:

Paste a listing URL
Upload listing screenshots
Enter garment information manually
FR-MKT-004

The customer shall be able to select a saved measurement profile for the request.

FR-MKT-005

The marketplace request shall create a standard appointment and garment record.

FR-MKT-006

Direct API integrations with marketplaces are outside the MVP scope.

FR-MKT-007

Future versions may support marketplace APIs, referral partnerships, or embedded alteration services.

6.14 Administrator Dashboard
FR-ADM-001

The administrator dashboard shall display:

New appointment requests
Today's appointments
Upcoming appointments
Garments in progress
Garments ready for fitting
Garments ready for pickup
Outstanding quotes
FR-ADM-002

The administrator shall be able to search customers by:

Name
Email
Phone number
Appointment number
FR-ADM-003

The administrator shall be able to filter appointments and garments by status.

FR-ADM-004

The administrator shall be able to access a customer's complete profile from the dashboard.

FR-ADM-005

Revenue reporting and advanced analytics are outside the first MVP release.

6.15 Audit Logging
FR-AUD-001

The system shall record important administrator actions.

FR-AUD-002

Audited actions shall include:

Appointment approval
Appointment cancellation
Status changes
Measurement creation
Measurement update
Quote creation
Quote revision
Token revocation
Customer record modification
FR-AUD-003

Audit records shall contain:

Action type
Entity type
Entity identifier
Acting user
Timestamp
Relevant before-and-after values where appropriate
FR-AUD-004

Audit history shall not be editable by regular administrators.

7. Business Rules
BR-001

A customer may have multiple appointments.

BR-002

An appointment must belong to one customer.

BR-003

An appointment may contain multiple garments.

BR-004

A garment must belong to one appointment.

BR-005

A garment may contain multiple alterations.

BR-006

Measurement profiles belong to the customer and may be reused across multiple appointments.

BR-007

Creating a new measurement profile shall not delete or overwrite historical profiles.

BR-008

Only approved appointments may be added to a calendar as confirmed appointments.

BR-009

Every appointment and garment status change must be recorded.

BR-010

Every customer must provide at least one contact method.

BR-011

Only authorized administrators may modify measurements, quotes, and statuses.

BR-012

Customers may view only their own data.

BR-013

Internal notes must never be displayed in the customer portal.

BR-014

A customer access token may be revoked or allowed to expire.

BR-015

A quote should be approved before alteration work begins, unless the administrator records an approved exception.

BR-016

A completed or picked-up garment must remain available in historical records.

BR-017

Deleting customer data must follow applicable retention and privacy requirements.

BR-018

Marketplace garments use the same core garment and alteration workflow as non-marketplace garments.

8. Non-Functional Requirements
8.1 Security
NFR-SEC-001

All production traffic shall use HTTPS.

NFR-SEC-002

Administrator passwords shall be securely hashed using an industry-standard password hashing algorithm.

NFR-SEC-003

The system shall enforce role-based authorization.

NFR-SEC-004

The backend shall validate all client input.

NFR-SEC-005

The system shall protect against common web vulnerabilities, including:

SQL injection
Cross-site scripting
Cross-site request forgery where applicable
Broken access control
Insecure file uploads
Brute-force login attempts
NFR-SEC-006

Sensitive configuration values shall be stored in environment variables or a secrets-management solution.

NFR-SEC-007

Customer access tokens shall be sufficiently random and difficult to guess.

NFR-SEC-008

The system shall apply rate limiting to sensitive public endpoints.

8.2 Performance
NFR-PER-001

Standard API requests should respond within 500 milliseconds under normal MVP usage, excluding external service latency and large file uploads.

NFR-PER-002

Customer and appointment lists shall use pagination.

NFR-PER-003

The application shall avoid loading full-resolution media when thumbnails are sufficient.

NFR-PER-004

Database indexes shall support common search and filtering operations.

8.3 Availability and Reliability
NFR-REL-001

The production system should target 99% monthly availability during the MVP stage.

NFR-REL-002

Database records shall persist across application restarts and deployments.

NFR-REL-003

External notification failures shall be retried or recorded for manual action.

NFR-REL-004

The database shall be backed up according to the selected hosting provider's capabilities.

NFR-REL-005

The system shall prevent duplicate appointment submissions where reasonably possible.

8.4 Scalability
NFR-SCA-001

The MVP shall use a modular monolith architecture.

NFR-SCA-002

The application shall separate major business domains through clear modules or packages.

NFR-SCA-003

The architecture should allow future support for:

Multiple businesses
Multiple administrators
Multiple business locations
Subscription billing
Marketplace integrations
NFR-SCA-004

The MVP shall not implement microservices.

8.5 Usability
NFR-USA-001

The customer experience shall be mobile-first.

NFR-USA-002

Customers shall not be required to create an account for MVP access.

NFR-USA-003

The booking process should require the minimum practical number of steps.

NFR-USA-004

Status labels shall be clear and customer-friendly.

NFR-USA-005

Forms shall display understandable validation messages.

NFR-USA-006

The admin dashboard shall support desktop and tablet usage.

8.6 Accessibility
NFR-ACC-001

The frontend should follow WCAG 2.1 AA principles where practical.

NFR-ACC-002

Interactive controls shall be keyboard accessible.

NFR-ACC-003

Forms shall use clear labels and error messages.

NFR-ACC-004

Important status information shall not rely only on color.

8.7 Maintainability
NFR-MAI-001

The backend shall use clear separation between:

Controllers
Services
Repositories
Domain entities
DTOs
Mappers
Security
Integrations
NFR-MAI-002

Business logic shall not be placed directly inside controllers.

NFR-MAI-003

The codebase shall include automated tests for critical workflows.

NFR-MAI-004

The project shall maintain documentation for architecture, database design, APIs, and setup instructions.

NFR-MAI-005

Database schema changes shall use a migration tool.

8.8 Observability
NFR-OBS-001

The backend shall use structured application logging.

NFR-OBS-002

Production logs shall not expose passwords, access tokens, or unnecessary customer measurements.

NFR-OBS-003

The system shall log failed notifications, failed file uploads, and unexpected server errors.

NFR-OBS-004

Future releases may include centralized monitoring and error tracking.

9. MVP Scope

The first production release for Finzy Alterations shall include:

Customer Experience
Public appointment request form
Customer contact information
Multiple garments per appointment
Garment photo uploads
Secure customer portal link
Appointment tracking
Garment tracking
Measurement profile access
Approved appointment calendar link
Quote viewing and approval
Administrator Experience
Secure administrator login
Customer management
Appointment management
Appointment approval and rescheduling
Multiple garment management
Alteration records
Measurement profile creation
Quote creation
Appointment and garment status updates
WhatsApp deep links
Communication logs
Basic dashboard
Audit and status history
Technical Foundation
Java Spring Boot backend
PostgreSQL database
React or Next.js frontend
External media storage
Database migrations
Docker-based local environment
Automated backend tests
Basic deployment pipeline
10. Future Enhancements

Future releases may include:

Customer account registration and login
Password reset
Social login
Full WhatsApp Business Platform integration
Two-way messaging inside the dashboard
SMS notifications
Automated reminder scheduling
Online deposits and payments
Invoices and receipts
Digital pickup signatures
Team member accounts
Employee scheduling
Multiple business locations
Multi-tenant SaaS support
Subscription billing
Advanced analytics
Revenue reporting
Marketplace API integrations
AI-based fit analysis
Pre-purchase alteration recommendations
Automatic listing-data extraction
Customer digital closet
Portable digital fit identity
Mobile applications
White-label customer portals
11. Out of Scope for MVP

The following features will not be included in the first release:

Microservices
Native iOS application
Native Android application
Multi-tenant SaaS
Direct Depop integration
Direct Vinted integration
Direct marketplace checkout integration
AI fit scoring
AI alteration recommendations
Full two-way WhatsApp messaging
Automated SMS messaging
Online payment processing
Subscription billing
Inventory management
Payroll
Employee scheduling
Accounting integrations
Customer social login
Advanced reporting
Internationalization
Offline mode
12. Assumptions
The MVP will serve Finzy Alterations only.
One primary administrator will use the first version.
Most customers will use a mobile device.
Customers may prefer WhatsApp communication.
Customer accounts are not required for the MVP.
Customers will receive secure links through a trusted communication channel.
The business will manually verify garment details during drop-off.
File-storage and notification providers may impose free-tier limits.
Direct marketplace integrations require separate API access or business partnerships.
13. Constraints
The initial budget should remain low.
Hosting should use free or affordable tiers where practical.
The system will be developed while the founder is managing other professional and business responsibilities.
MVP scope must remain achievable by one full-stack engineer.
Customer measurement data requires careful privacy and access controls.
Third-party features depend on provider availability, pricing, and policies.
The initial release should favor simplicity over premature scalability.
14. Acceptance Criteria for MVP Launch

The MVP will be considered ready for initial Finzy Alterations use when:

A customer can submit an appointment request.
One appointment can contain multiple garments.
The administrator can approve, decline, or reschedule the request.
An approved customer can add the appointment to a calendar.
The administrator can create and retrieve customer measurement profiles.
The customer can securely view their measurements.
The administrator can update appointment and garment statuses.
The customer can securely track those statuses.
The administrator can create and send a quote.
The customer can approve or reject the quote.
The administrator can open a prefilled WhatsApp conversation.
Appointment, garment, quote, and status histories persist correctly.
Unauthorized customers cannot access another customer's records.
Critical backend workflows have automated tests.
The system can be deployed to a production environment.
