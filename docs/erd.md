# Entity Relationship Diagram

## Customer

A customer represents a client of the business.

Fields:

- id
- first_name
- last_name
- email
- phone_number
- whatsapp_number
- created_at
- updated_at

Relationships:

Customer
|
+---- Appointments
|
+---- Measurement Profiles

---

## Appointment

Fields:

- id
- customer_id
- appointment_number
- appointment_type
- preferred_date
- preferred_time
- status
- notes
- rush_service
- created_at
- updated_at

Relationships:

Appointment
|
+---- Garments
|
+---- Files
|
+---- Communication Logs
|
+---- Status History

---

## Measurement Profile

Fields:

- id
- customer_id
- profile_name
- bust
- waist
- hip
- shoulder
- sleeve_length
- inseam
- dress_length
- notes
- measured_at
- created_at

Examples:

"Standard Fit"

"Bridal Fit"

"Corset Fit"

---

## Garment

Fields:

- id
- appointment_id
- garment_type
- garment_description
- status
- created_at

Examples:

Dress

Skirt

Pants

Wedding Dress

Kaftan

---

## File Upload

Fields:

- id
- appointment_id
- file_url
- file_type
- uploaded_by
- created_at

---

## Appointment Status History

Fields:

- id
- appointment_id
- previous_status
- new_status
- changed_by
- notes
- created_at

---

## Communication Log

Fields:

- id
- appointment_id
- customer_id
- communication_type
- message
- created_at

communication_type:

- EMAIL
- SMS
- WHATSAPP
- NOTE

---

## Admin User

Fields:

- id
- first_name
- last_name
- email
- password_hash
- role
- created_at


## Customer Access Token

Used for secure customer portal access.

Fields:

- id
- customer_id
- token
- expires_at
- is_active
- created_at

Purpose:

Allows customers to access measurements,
appointments and garment tracking without
creating an account.
