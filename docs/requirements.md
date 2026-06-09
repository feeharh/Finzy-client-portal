# Requirements

## User Personas

### Customer

A customer who needs alteration services.

Goals:

- Book appointments
- Upload garment photos
- View appointment status
- Access measurements
- Receive updates

Pain Points:

- Repeating information multiple times
- Not knowing garment status
- Losing measurement records

---

### Administrator

The business owner or alteration specialist.

Goals:

- Manage appointments
- Track garments
- Store measurements
- Communicate with customers
- Maintain customer history

Pain Points:

- Managing customers through WhatsApp
- Paper measurement records
- Repeated customer inquiries
- Tracking garment progress manually

---

## User Stories

### Appointment Booking

As a customer,

I want to submit an appointment request

So that I can receive alteration services.

---

As an administrator,

I want to approve or decline appointment requests

So that I can control scheduling.

---

### Measurements

As a customer,

I want to access my measurements online

So that I can use them whenever needed.

---

As an administrator,

I want to save customer measurements

So that measurements remain available for future appointments.

---

### Garment Tracking

As a customer,

I want to see the status of my garment

So that I do not need to constantly ask for updates.

---

As an administrator,

I want to update garment status

So that customers stay informed.

---

### Communication

As an administrator,

I want to send customers messages

So that I can request additional information.

---

As a customer,

I want to receive notifications

So that I stay informed about my appointment.

---

## Functional Requirements

### Customer Features

The system shall allow customers to:

- Submit appointment requests
- Upload photos
- Upload videos
- View appointment status
- View measurements
- Download measurements
- Receive notifications
- View appointment history

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

## Non-Functional Requirements

### Security

- Secure authentication
- Role-based authorization
- Encrypted communication

### Performance

- API response time under 500ms
- Support file uploads

### Reliability

- Data persistence
- Audit logging
- Status history tracking

### Usability

- Mobile responsive design
- Simple customer experience

---

## Assumptions

- Customers may not create accounts initially.
- Communication may begin through WhatsApp.
- The first version supports a single business.

---

## Constraints

- Initial version must be low cost.
- Initial version will be used by Finzy Alterations.
- Cloud infrastructure should remain within free-tier limits.
