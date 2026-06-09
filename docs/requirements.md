# Requirements

## User Personas

### Customer

A customer who needs alteration services.

Goals:
- Book appointments
- Upload garment photos/videos
- View appointment status
- Access measurements anytime
- Add approved appointments to calendar
- Receive updates by email, SMS, or WhatsApp

Pain Points:
- Repeating information multiple times
- Not knowing garment status
- Losing measurement records
- Forgetting appointment dates/times

---

### Administrator

The business owner or alteration specialist.

Goals:
- Manage appointments
- Track garments
- Store measurements
- Communicate with customers
- Maintain customer history
- Request more information through WhatsApp

Pain Points:
- Managing customers through WhatsApp/text manually
- Paper measurement records
- Repeated customer inquiries
- Tracking garment progress manually

---

## Functional Requirements

### Customer Features

The system shall allow customers to:
- Submit appointment requests
- Upload photos/videos
- View appointment status
- View measurements
- Download measurements
- Receive notifications
- View appointment history
- Add approved appointments to calendar
- Communicate through WhatsApp when more information is needed

---

### Administrator Features

The system shall allow administrators to:
- Login securely
- Manage appointments
- Manage customers
- Save measurements
- Upload garment photos
- Update garment status
- Send notifications
- View customer history
- Request additional information through WhatsApp
- Send pre-filled WhatsApp messages linked to an appointment
- Log WhatsApp communication notes under the appointment

---

### Appointment Statuses

The system shall support:
- REQUEST_SUBMITTED
- APPROVED
- GARMENT_RECEIVED
- IN_PROGRESS
- READY_FOR_FITTING
- READY_FOR_PICKUP
- COMPLETED
- CANCELLED

---

### Calendar Integration

The system shall allow customers to add approved appointments to their personal calendars.

Supported options may include:
- Google Calendar link
- Apple Calendar file
- Outlook Calendar link
- Downloadable `.ics` calendar file

Calendar event details should include:
- Appointment date
- Appointment time
- Business name
- Business address
- Appointment type
- Notes or preparation instructions

---

### WhatsApp Communication

The system shall allow administrators to communicate with customers through WhatsApp.

MVP support:
- Store customer WhatsApp number
- Open WhatsApp chat from appointment details
- Generate pre-filled WhatsApp message
- Log communication notes manually

Future support:
- WhatsApp Business API integration
- Two-way messaging inside dashboard
- Automated WhatsApp notifications

---

## Non-Functional Requirements

### Security
- Secure authentication
- Role-based authorization
- Encrypted communication
- Private customer access links

### Performance
- API response time under 500ms
- Support file uploads
- Mobile-friendly experience

### Reliability
- Data persistence
- Audit logging
- Status history tracking
- Notification failure tracking

### Usability
- Simple booking experience
- Mobile responsive design
- Minimal steps for customers

---

## Assumptions

- Customers may not create accounts initially.
- Customers can access appointment details through secure private links.
- Communication may begin through WhatsApp deep links.
- The first version supports a single business.

---

## Constraints

- Initial version must be low cost.
- Initial version will be used by Finzy Alterations.
- Cloud infrastructure should remain within free-tier limits.
