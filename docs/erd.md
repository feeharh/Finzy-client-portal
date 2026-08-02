# Entity Relationship Design

## 1. Purpose

This document defines the relational data model for the Finzy Client Portal.

The database design supports:

- Customer management
- Appointment requests and scheduling
- Multiple garments per appointment
- Multiple alterations per garment
- Versioned customer measurements
- Quotes and quote line items
- Secure customer portal access
- Appointment and garment status history
- File uploads
- Communication logs
- Notifications
- Calendar integration
- Marketplace purchase information
- Administrator authentication
- Audit logging

The MVP will use PostgreSQL.

---

## 2. Design Principles

The data model follows these principles:

- Customer measurements belong to the customer, not to one appointment.
- Measurement history must be preserved.
- One appointment may contain multiple garments.
- Each garment may contain multiple alterations.
- Each garment may have an independent workflow status.
- Historical records should not be overwritten.
- Sensitive access tokens should not be stored in plain text.
- Uploaded media should be stored outside PostgreSQL.
- Core marketplace functionality should remain provider-neutral.
- Business entities should use stable internal identifiers.
- Customer-facing reference numbers should be separate from database identifiers.

---

## 3. High-Level Relationships

```text
AdminUser
    |
    +--- creates and manages operational records
    |
    +--- AuditLogs

Customer
    |
    +--- Appointments
    |
    +--- MeasurementProfiles
    |
    +--- CustomerAccessTokens
    |
    +--- CommunicationLogs
    |
    +--- Notifications

Appointment
    |
    +--- Garments
    |
    +--- AppointmentStatusHistory
    |
    +--- Quotes
    |
    +--- CommunicationLogs
    |
    +--- FileAssets
    |
    +--- PolicyAgreements

Garment
    |
    +--- Alterations
    |
    +--- GarmentStatusHistory
    |
    +--- FileAssets
    |
    +--- MarketplacePurchase

MeasurementProfile
    |
    +--- MeasurementValues

Quote
    |
    +--- QuoteLineItems

Notification
    |
    +--- NotificationAttempts

4. Cardinality Summary
Parent Entity	Relationship	Child Entity
Customer	One-to-many	Appointment
Customer	One-to-many	MeasurementProfile
Customer	One-to-many	CustomerAccessToken
Customer	One-to-many	CommunicationLog
Customer	One-to-many	Notification
Appointment	One-to-many	Garment
Appointment	One-to-many	AppointmentStatusHistory
Appointment	One-to-many	Quote
Appointment	One-to-many	CommunicationLog
Appointment	One-to-many	FileAsset
Appointment	One-to-many	PolicyAgreement
Garment	One-to-many	Alteration
Garment	One-to-many	GarmentStatusHistory
Garment	One-to-many	FileAsset
Garment	Zero-or-one	MarketplacePurchase
MeasurementProfile	One-to-many	MeasurementValue
Quote	One-to-many	QuoteLineItem
Notification	One-to-many	NotificationAttempt
AdminUser	One-to-many	AuditLog
5. Entity Definitions
5.1 Admin User

Represents an authenticated administrator who manages the business.

Table Name
admin_users
Fields
Column	Type	Constraints	Description
id	UUID	Primary key	Internal administrator identifier
first_name	VARCHAR(100)	Not null	Administrator first name
last_name	VARCHAR(100)	Not null	Administrator last name
email	VARCHAR(255)	Not null, unique	Login email
password_hash	VARCHAR(255)	Not null	Secure password hash
role	VARCHAR(50)	Not null	Administrator role
account_status	VARCHAR(50)	Not null	Account status
last_login_at	TIMESTAMPTZ	Nullable	Most recent successful login
failed_login_attempts	INTEGER	Not null, default 0	Failed login counter
locked_until	TIMESTAMPTZ	Nullable	Temporary account lock expiry
created_at	TIMESTAMPTZ	Not null	Creation timestamp
updated_at	TIMESTAMPTZ	Not null	Last update timestamp
Supported Roles
OWNER
ADMIN
STAFF

The MVP may initially use only:

OWNER
Supported Account Statuses
ACTIVE
LOCKED
DISABLED
5.2 Customer

Represents a person requesting alteration, fitting, pickup, consultation, or measurement services.

Table Name
customers
Fields
Column	Type	Constraints	Description
id	UUID	Primary key	Internal customer identifier
customer_number	VARCHAR(30)	Not null, unique	Customer-facing reference number
first_name	VARCHAR(100)	Not null	Customer first name
last_name	VARCHAR(100)	Not null	Customer last name
email	VARCHAR(255)	Nullable	Customer email
phone_number	VARCHAR(30)	Nullable	Customer phone number
whatsapp_number	VARCHAR(30)	Nullable	WhatsApp-compatible phone number
preferred_communication_method	VARCHAR(30)	Nullable	Preferred contact channel
notes	TEXT	Nullable	Administrator-visible general notes
is_active	BOOLEAN	Not null, default true	Whether the customer record is active
created_at	TIMESTAMPTZ	Not null	Creation timestamp
updated_at	TIMESTAMPTZ	Not null	Last update timestamp
Business Rules
At least one of email, phone_number, or whatsapp_number must be provided.
customer_number is separate from the UUID.
Customers should normally be deactivated rather than permanently deleted.
Internal notes must not be returned through customer-facing APIs.
Preferred Communication Methods
WHATSAPP
SMS
EMAIL
PHONE
5.3 Customer Access Token

Allows a customer to access the portal without creating an account.

Table Name
customer_access_tokens
Fields
Column	Type	Constraints	Description
id	UUID	Primary key	Internal token record identifier
customer_id	UUID	Foreign key, not null	Customer associated with the token
token_hash	VARCHAR(255)	Not null, unique	Hashed secure token
expires_at	TIMESTAMPTZ	Nullable	Expiration date
revoked_at	TIMESTAMPTZ	Nullable	Revocation timestamp
last_used_at	TIMESTAMPTZ	Nullable	Most recent usage
created_by_admin_id	UUID	Foreign key, nullable	Administrator who created it
created_at	TIMESTAMPTZ	Not null	Creation timestamp
Relationship
Customer 1 ----- * CustomerAccessToken
Business Rules
The raw token should be displayed or sent only when generated.
The database should store the token hash, not the raw token.
A token is valid only when:
It has not been revoked.
It has not expired.
Its customer is active.
A customer may have multiple tokens over time.
Only one active token may be preferred for the MVP.
5.4 Appointment

Represents an appointment request or scheduled business visit.

Table Name
appointments
Fields
Column	Type	Constraints	Description
id	UUID	Primary key	Internal appointment identifier
appointment_number	VARCHAR(30)	Not null, unique	Customer-facing reference
customer_id	UUID	Foreign key, not null	Customer who owns the appointment
appointment_type	VARCHAR(50)	Not null	Appointment category
status	VARCHAR(50)	Not null	Current appointment status
preferred_start_at	TIMESTAMPTZ	Nullable	Customer's preferred visit date and time
preferred_completion_date	DATE	Nullable	Customer's preferred completion or pickup date
scheduled_start_at	TIMESTAMPTZ	Nullable	Confirmed appointment start
scheduled_end_at	TIMESTAMPTZ	Nullable	Confirmed appointment end
service_description	TEXT	Nullable	Customer-provided service description
customer_notes	TEXT	Nullable	Notes visible to customer where applicable
internal_notes	TEXT	Nullable	Administrator-only notes
rush_service_requested	BOOLEAN	Not null, default false	Customer requested rush service
information_requested_at	TIMESTAMPTZ	Nullable	Time more information was requested
approved_at	TIMESTAMPTZ	Nullable	Approval timestamp
declined_at	TIMESTAMPTZ	Nullable	Decline timestamp
cancelled_at	TIMESTAMPTZ	Nullable	Cancellation timestamp
completed_at	TIMESTAMPTZ	Nullable	Completion timestamp
created_at	TIMESTAMPTZ	Not null	Creation timestamp
updated_at	TIMESTAMPTZ	Not null	Last update timestamp
Relationship
Customer 1 ----- * Appointment
Appointment Types
ALTERATION_CONSULTATION
GARMENT_DROP_OFF
MEASUREMENT_SESSION
FITTING
FINAL_FITTING
PICKUP
BRIDAL_CONSULTATION
MARKETPLACE_ALTERATION
OTHER
Appointment Statuses
REQUEST_SUBMITTED
INFORMATION_REQUIRED
APPROVED
RESCHEDULED
DECLINED
CANCELLED
COMPLETED
Business Rules
An appointment must belong to exactly one customer.
One appointment may contain multiple garments.
An appointment is not confirmed until its status is APPROVED.
preferred_start_at represents when the customer wants to visit; preferred_completion_date represents when they want the work completed or picked up. These are independent fields.
Calendar links are available only for approved appointments with confirmed scheduling information (scheduled_start_at / scheduled_end_at).
Status changes must create an appointment-status-history record.
Completed and cancelled appointments remain in historical records.
5.5 Appointment Status History

Stores every appointment status change.

Table Name
appointment_status_history
Fields
Column	Type	Constraints	Description
id	UUID	Primary key	History record identifier
appointment_id	UUID	Foreign key, not null	Related appointment
previous_status	VARCHAR(50)	Nullable	Previous status
new_status	VARCHAR(50)	Not null	New status
changed_by_admin_id	UUID	Foreign key, nullable	Administrator responsible
change_source	VARCHAR(30)	Not null	Source of change
note	TEXT	Nullable	Reason or context
created_at	TIMESTAMPTZ	Not null	Change timestamp
Relationship
Appointment 1 ----- * AppointmentStatusHistory
Change Sources
ADMIN
SYSTEM
CUSTOMER
Business Rules
History records should be immutable.
The first record may have a null previous_status.
The current status remains stored on the appointment for efficient retrieval.
History stores the complete transition trail.
5.6 Garment

Represents one clothing item associated with an appointment.

Table Name
garments
Fields
Column	Type	Constraints	Description
id	UUID	Primary key	Internal garment identifier
garment_number	VARCHAR(30)	Not null, unique	Customer-facing garment reference
appointment_id	UUID	Foreign key, not null	Parent appointment
garment_type	VARCHAR(50)	Not null	Garment category
description	TEXT	Nullable	Garment description
color	VARCHAR(100)	Nullable	Garment color
brand	VARCHAR(150)	Nullable	Garment brand
size_label	VARCHAR(50)	Nullable	Manufacturer size label
status	VARCHAR(50)	Not null	Current garment status
customer_notes	TEXT	Nullable	Customer-provided notes
internal_notes	TEXT	Nullable	Administrator-only notes
quoted_price	NUMERIC(12,2)	Nullable	Garment-level quoted amount
final_price	NUMERIC(12,2)	Nullable	Final garment charge
received_at	TIMESTAMPTZ	Nullable	Garment receipt timestamp
ready_for_pickup_at	TIMESTAMPTZ	Nullable	Ready-for-pickup timestamp
picked_up_at	TIMESTAMPTZ	Nullable	Pickup timestamp
completed_at	TIMESTAMPTZ	Nullable	Completion timestamp
created_at	TIMESTAMPTZ	Not null	Creation timestamp
updated_at	TIMESTAMPTZ	Not null	Last update timestamp
Relationship
Appointment 1 ----- * Garment
Garment Types

Initial examples:

DRESS
WEDDING_DRESS
BRIDESMAID_DRESS
SKIRT
TROUSERS
JUMPSUIT
BLOUSE
SHIRT
JACKET
SUIT
KAFTAN
ASO_OKE
TWO_PIECE_SET
OTHER
Garment Statuses
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
Business Rules
Every garment belongs to one appointment.
An appointment may contain multiple garments.
Each garment has an independent status.
Each garment may contain multiple alterations.
Completed and picked-up garments remain in customer history.
Internal notes must not be exposed in the customer portal.
5.7 Garment Status History

Stores each garment status transition.

Table Name
garment_status_history
Fields
Column	Type	Constraints	Description
id	UUID	Primary key	History record identifier
garment_id	UUID	Foreign key, not null	Related garment
previous_status	VARCHAR(50)	Nullable	Previous garment status
new_status	VARCHAR(50)	Not null	New garment status
changed_by_admin_id	UUID	Foreign key, nullable	Administrator responsible
change_source	VARCHAR(30)	Not null	Source of change
note	TEXT	Nullable	Reason or details
created_at	TIMESTAMPTZ	Not null	Transition timestamp
Relationship
Garment 1 ----- * GarmentStatusHistory
Business Rules
History records must be immutable.
The application must validate garment-status transitions.
The current status is also stored on the garment.
5.8 Alteration

Represents one specific modification requested or performed on a garment.

Table Name
alterations
Fields
Column	Type	Constraints	Description
id	UUID	Primary key	Internal alteration identifier
garment_id	UUID	Foreign key, not null	Garment being altered
alteration_type	VARCHAR(100)	Not null	Alteration category
description	TEXT	Nullable	Detailed alteration description
status	VARCHAR(50)	Not null	Current alteration status
quantity	INTEGER	Not null, default 1	Number of units
unit_price	NUMERIC(12,2)	Nullable	Price per unit
total_price	NUMERIC(12,2)	Nullable	Total alteration price
internal_notes	TEXT	Nullable	Administrator-only details
created_at	TIMESTAMPTZ	Not null	Creation timestamp
updated_at	TIMESTAMPTZ	Not null	Last update timestamp
Relationship
Garment 1 ----- * Alteration
Alteration Statuses
PROPOSED
QUOTED
APPROVED
IN_PROGRESS
COMPLETED
CANCELLED
Example Alteration Types
HEMMING
TAKE_IN
LET_OUT
ZIPPER_REPLACEMENT
BUST_ADJUSTMENT
WAIST_ADJUSTMENT
HIP_ADJUSTMENT
SLEEVE_SHORTENING
SLEEVE_TIGHTENING
ADD_BUSTLE
CORSET_ADJUSTMENT
RESTRUCTURE
CUSTOM
Business Rules
One garment may have multiple alterations.
Alterations should be individually priced when possible.
An alteration may be included in one quote line item.
Internal notes are not visible to customers.
5.9 Measurement Profile

Represents one version of a customer's body measurements.

Table Name
measurement_profiles
Fields
Column	Type	Constraints	Description
id	UUID	Primary key	Measurement profile identifier
customer_id	UUID	Foreign key, not null	Customer who owns the profile
profile_name	VARCHAR(150)	Not null	Human-readable profile name
measurement_date	DATE	Not null	Date measurements were taken
unit	VARCHAR(20)	Not null	Measurement unit
is_current	BOOLEAN	Not null, default false	Whether this is the preferred profile
notes	TEXT	Nullable	Measurement context
measured_by_admin_id	UUID	Foreign key, nullable	Administrator who measured customer
created_at	TIMESTAMPTZ	Not null	Creation timestamp
updated_at	TIMESTAMPTZ	Not null	Last update timestamp
Relationship
Customer 1 ----- * MeasurementProfile
Units
INCHES
CENTIMETERS
Example Profile Names
Standard Fit
Bridal Fit
Corset Fit
Updated Measurements
Postpartum Measurements
Business Rules
Measurement profiles belong to customers.
A customer may have multiple profiles.
New profiles should not overwrite old profiles.
Only one profile should normally be marked is_current for a customer.
A measurement profile may be referenced by appointments or marketplace requests without transferring ownership.
5.10 Measurement Value

Stores individual values within a measurement profile.

Table Name
measurement_values
Fields
Column	Type	Constraints	Description
id	UUID	Primary key	Internal value identifier
measurement_profile_id	UUID	Foreign key, not null	Parent profile
measurement_type	VARCHAR(100)	Not null	Type of body measurement
value	NUMERIC(8,2)	Not null	Numeric measurement value
note	VARCHAR(255)	Nullable	Field-specific note
display_order	INTEGER	Nullable	Customer-facing ordering
created_at	TIMESTAMPTZ	Not null	Creation timestamp
updated_at	TIMESTAMPTZ	Not null	Last update timestamp
Relationship
MeasurementProfile 1 ----- * MeasurementValue
Supported Measurement Types
BUST
UNDERBUST
WAIST
HIGH_HIP
HIP
SHOULDER
SHOULDER_TO_WAIST
SHOULDER_TO_FLOOR
DRESS_LENGTH
SKIRT_LENGTH
SLEEVE_LENGTH
ARMHOLE
BICEP
ELBOW
WRIST
NECK
THIGH
KNEE
INSEAM
TROUSER_LENGTH
FRONT_RISE
BACK_RISE
OTHER
Why Use a Measurement Value Table?

A flexible child table allows:

New measurement types without adding database columns
Different measurement sets for different profiles
Easier support for designers and garment categories
Custom measurements in future releases
Tradeoff

This model requires additional validation because measurement types are not enforced as fixed columns.

The application must prevent duplicate measurement types within one profile.

Recommended unique constraint:

UNIQUE (measurement_profile_id, measurement_type)
5.11 Quote

Represents a price proposal sent to a customer.

Table Name
quotes
Fields
Column	Type	Constraints	Description
id	UUID	Primary key	Internal quote identifier
quote_number	VARCHAR(30)	Not null, unique	Customer-facing quote reference
appointment_id	UUID	Foreign key, not null	Appointment associated with quote
garment_id	UUID	Foreign key, nullable	Optional garment-specific quote
status	VARCHAR(50)	Not null	Quote workflow status
version_number	INTEGER	Not null, default 1	Quote revision version
currency	CHAR(3)	Not null, default USD	ISO currency code
subtotal	NUMERIC(12,2)	Not null	Line-item subtotal
material_fee	NUMERIC(12,2)	Not null, default 0	Material charges
rush_fee	NUMERIC(12,2)	Not null, default 0	Rush-service fee
discount_amount	NUMERIC(12,2)	Not null, default 0	Discount
tax_amount	NUMERIC(12,2)	Not null, default 0	Applicable tax
total_amount	NUMERIC(12,2)	Not null	Final quote total
customer_message	TEXT	Nullable	Message visible to customer
internal_notes	TEXT	Nullable	Administrator-only notes
sent_at	TIMESTAMPTZ	Nullable	Time sent
expires_at	TIMESTAMPTZ	Nullable	Expiration time
approved_at	TIMESTAMPTZ	Nullable	Approval timestamp
rejected_at	TIMESTAMPTZ	Nullable	Rejection timestamp
created_by_admin_id	UUID	Foreign key, not null	Quote creator
created_at	TIMESTAMPTZ	Not null	Creation timestamp
updated_at	TIMESTAMPTZ	Not null	Last update timestamp
Relationships
Appointment 1 ----- * Quote

Garment 1 ----- * Quote

The garment relationship is optional.

Quote Statuses
DRAFT
SENT
APPROVED
REJECTED
EXPIRED
REVISED
Business Rules
Every quote belongs to an appointment.
A quote may optionally apply to one specific garment.
A quote may contain multiple line items.
Approved quotes should not be edited directly.
Revisions should create a new version or quote record.
Quote totals should be calculated server-side.
Customer approval timestamps must be retained.
5.12 Quote Line Item

Represents one charge within a quote.

Table Name
quote_line_items
Fields
Column	Type	Constraints	Description
id	UUID	Primary key	Line-item identifier
quote_id	UUID	Foreign key, not null	Parent quote
alteration_id	UUID	Foreign key, nullable	Optional related alteration
description	VARCHAR(255)	Not null	Customer-facing description
quantity	NUMERIC(10,2)	Not null, default 1	Quantity
unit_price	NUMERIC(12,2)	Not null	Price per unit
line_total	NUMERIC(12,2)	Not null	Calculated total
display_order	INTEGER	Nullable	Quote display order
created_at	TIMESTAMPTZ	Not null	Creation timestamp
updated_at	TIMESTAMPTZ	Not null	Last update timestamp
Relationship
Quote 1 ----- * QuoteLineItem
Business Rules
line_total should equal quantity × unit_price.
The server must calculate financial totals.
One line item may optionally reference an alteration.
5.13 Marketplace Purchase

Stores marketplace-specific information for a garment.

Table Name
marketplace_purchases
Fields
Column	Type	Constraints	Description
id	UUID	Primary key	Marketplace purchase identifier
garment_id	UUID	Foreign key, not null, unique	Related garment
marketplace_source	VARCHAR(50)	Not null	Marketplace name
listing_url	TEXT	Nullable	External listing URL
external_listing_id	VARCHAR(255)	Nullable	Provider listing identifier
seller_name	VARCHAR(255)	Nullable	Marketplace seller
listing_title	VARCHAR(255)	Nullable	Listing title
listed_size	VARCHAR(50)	Nullable	Size shown in listing
purchase_price	NUMERIC(12,2)	Nullable	Customer purchase price
selected_measurement_profile_id	UUID	Foreign key, nullable	Measurement profile selected
customer_fit_concern	TEXT	Nullable	Customer's fit concern
created_at	TIMESTAMPTZ	Not null	Creation timestamp
updated_at	TIMESTAMPTZ	Not null	Last update timestamp
Relationship
Garment 1 ----- 0..1 MarketplacePurchase
Marketplace Sources
DEPOP
VINTED
POSHMARK
EBAY
FACEBOOK_MARKETPLACE
ETSY
VESTIAIRE_COLLECTIVE
THE_REALREAL
MERCARI
OTHER
Business Rules
Marketplace data extends the garment entity.
Marketplace data should not replace the core garment workflow.
A garment may have no marketplace record.
Direct marketplace APIs are not required for MVP.
The selected measurement profile remains owned by the customer.
5.14 File Asset

Stores metadata for externally stored media and documents.

Table Name
file_assets
Fields
Column	Type	Constraints	Description
id	UUID	Primary key	File metadata identifier
customer_id	UUID	Foreign key, nullable	Related customer
appointment_id	UUID	Foreign key, nullable	Related appointment
garment_id	UUID	Foreign key, nullable	Related garment
marketplace_purchase_id	UUID	Foreign key, nullable	Related marketplace record
storage_provider	VARCHAR(50)	Not null	Media-storage provider
storage_key	VARCHAR(500)	Not null, unique	Provider resource identifier
original_file_name	VARCHAR(255)	Not null	Original upload name
mime_type	VARCHAR(150)	Not null	MIME type
file_size_bytes	BIGINT	Not null	File size
resource_type	VARCHAR(50)	Not null	Business file category
access_level	VARCHAR(30)	Not null	Visibility level
uploaded_by_type	VARCHAR(30)	Not null	Customer, admin, or system
uploaded_by_id	UUID	Nullable	User or administrator identifier
created_at	TIMESTAMPTZ	Not null	Upload timestamp
deleted_at	TIMESTAMPTZ	Nullable	Soft deletion timestamp
Relationships
Customer 1 ----- * FileAsset
Appointment 1 ----- * FileAsset
Garment 1 ----- * FileAsset
MarketplacePurchase 1 ----- * FileAsset

All relationships are optional individually, but at least one parent association must exist.

Resource Types
GARMENT_PHOTO
GARMENT_VIDEO
LISTING_SCREENSHOT
BEFORE_PHOTO
AFTER_PHOTO
MEASUREMENT_PDF
QUOTE_DOCUMENT
OTHER
Access Levels
CUSTOMER_VISIBLE
ADMIN_ONLY
PRIVATE
Business Rules
Raw file content is stored outside PostgreSQL.
The database stores only metadata and storage identifiers.
Admin-only files must not appear in customer responses.
Soft deletion is preferred to preserve auditability.
File type and size must be validated before storage.
5.15 Communication Log

Stores communication history and internal communication notes.

Table Name
communication_logs
Fields
Column	Type	Constraints	Description
id	UUID	Primary key	Communication record identifier
customer_id	UUID	Foreign key, not null	Related customer
appointment_id	UUID	Foreign key, nullable	Related appointment
garment_id	UUID	Foreign key, nullable	Related garment
communication_type	VARCHAR(30)	Not null	Channel or note type
direction	VARCHAR(20)	Nullable	Incoming, outgoing, or internal
subject	VARCHAR(255)	Nullable	Communication subject
message_summary	TEXT	Not null	Summary or message content
customer_visible	BOOLEAN	Not null, default false	Whether customer can view it
external_message_id	VARCHAR(255)	Nullable	Future provider message identifier
recorded_by_admin_id	UUID	Foreign key, nullable	Administrator who logged it
occurred_at	TIMESTAMPTZ	Not null	Time communication occurred
created_at	TIMESTAMPTZ	Not null	Record creation timestamp
Relationships
Customer 1 ----- * CommunicationLog
Appointment 1 ----- * CommunicationLog
Garment 1 ----- * CommunicationLog
Communication Types
WHATSAPP
SMS
EMAIL
PHONE
IN_PERSON
INTERNAL_NOTE
Directions
INBOUND
OUTBOUND
INTERNAL
Business Rules
Every communication log belongs to one customer.
Appointment and garment relationships are optional.
Internal notes must always have customer_visible = false.
For MVP, WhatsApp communication may be logged manually.
Future API integrations may populate external_message_id.
5.16 Notification

Represents a customer notification that should be delivered.

Table Name
notifications
Fields
Column	Type	Constraints	Description
id	UUID	Primary key	Notification identifier
customer_id	UUID	Foreign key, not null	Recipient customer
appointment_id	UUID	Foreign key, nullable	Related appointment
garment_id	UUID	Foreign key, nullable	Related garment
quote_id	UUID	Foreign key, nullable	Related quote
notification_type	VARCHAR(50)	Not null	Notification event
channel	VARCHAR(30)	Not null	Delivery channel
recipient_address	VARCHAR(255)	Not null	Email or phone destination
subject	VARCHAR(255)	Nullable	Message subject
message_body	TEXT	Not null	Rendered notification content
status	VARCHAR(30)	Not null	Delivery status
scheduled_at	TIMESTAMPTZ	Nullable	Scheduled send time
sent_at	TIMESTAMPTZ	Nullable	Successful send time
failure_reason	TEXT	Nullable	Final failure information
created_at	TIMESTAMPTZ	Not null	Creation timestamp
updated_at	TIMESTAMPTZ	Not null	Last update timestamp
Relationship
Customer 1 ----- * Notification
Notification Types
APPOINTMENT_REQUEST_RECEIVED
APPOINTMENT_APPROVED
APPOINTMENT_DECLINED
APPOINTMENT_RESCHEDULED
INFORMATION_REQUIRED
APPOINTMENT_REMINDER
QUOTE_AVAILABLE
QUOTE_APPROVED
READY_FOR_FITTING
READY_FOR_PICKUP
MEASUREMENT_PROFILE_UPDATED
Channels
EMAIL
SMS
WHATSAPP
IN_APP

The MVP may initially use only:

EMAIL

WhatsApp deep links do not necessarily create automatic notification records unless the administrator logs them.

Statuses
PENDING
PROCESSING
SENT
FAILED
CANCELLED
5.17 Notification Attempt

Stores individual delivery attempts for a notification.

Table Name
notification_attempts
Fields
Column	Type	Constraints	Description
id	UUID	Primary key	Attempt identifier
notification_id	UUID	Foreign key, not null	Parent notification
attempt_number	INTEGER	Not null	Sequential attempt number
provider	VARCHAR(50)	Nullable	Delivery provider
provider_message_id	VARCHAR(255)	Nullable	Provider identifier
status	VARCHAR(30)	Not null	Attempt result
response_code	VARCHAR(100)	Nullable	Provider response
failure_reason	TEXT	Nullable	Failure details
attempted_at	TIMESTAMPTZ	Not null	Attempt timestamp
Relationship
Notification 1 ----- * NotificationAttempt
Attempt Statuses
SUCCESS
FAILED
RETRYABLE
5.18 Policy Agreement

Records customer acceptance of business policies.

Table Name
policy_agreements
Fields
Column	Type	Constraints	Description
id	UUID	Primary key	Agreement identifier
appointment_id	UUID	Foreign key, not null	Related appointment
customer_id	UUID	Foreign key, not null	Customer who agreed
policy_name	VARCHAR(150)	Not null	Policy title
policy_version	VARCHAR(50)	Not null	Version accepted
agreed	BOOLEAN	Not null	Acceptance decision
agreed_at	TIMESTAMPTZ	Not null	Agreement timestamp
ip_address	VARCHAR(64)	Nullable	Request IP address
user_agent	TEXT	Nullable	Browser or device information
created_at	TIMESTAMPTZ	Not null	Record creation timestamp
Relationships
Appointment 1 ----- * PolicyAgreement
Customer 1 ----- * PolicyAgreement
Business Rules
Appointment submission may require one or more policy agreements.
The policy version must be preserved.
Historical agreements should be immutable.
5.19 Audit Log

Stores significant system and administrator actions.

Table Name
audit_logs
Fields
Column	Type	Constraints	Description
id	UUID	Primary key	Audit record identifier
actor_admin_id	UUID	Foreign key, nullable	Acting administrator
actor_type	VARCHAR(30)	Not null	Admin, customer, or system
action_type	VARCHAR(100)	Not null	Action performed
entity_type	VARCHAR(100)	Not null	Affected entity type
entity_id	UUID	Nullable	Affected entity identifier
before_values	JSONB	Nullable	Selected previous values
after_values	JSONB	Nullable	Selected updated values
ip_address	VARCHAR(64)	Nullable	Request IP address
correlation_id	VARCHAR(100)	Nullable	Request correlation identifier
created_at	TIMESTAMPTZ	Not null	Event timestamp
Relationship
AdminUser 1 ----- * AuditLog

The administrator relationship is optional because some actions are performed by the system or customer.

Actor Types
ADMIN
CUSTOMER
SYSTEM
Example Action Types
CUSTOMER_CREATED
CUSTOMER_UPDATED
APPOINTMENT_APPROVED
APPOINTMENT_RESCHEDULED
APPOINTMENT_CANCELLED
GARMENT_STATUS_CHANGED
MEASUREMENT_PROFILE_CREATED
MEASUREMENT_PROFILE_UPDATED
QUOTE_CREATED
QUOTE_REVISED
QUOTE_APPROVED
ACCESS_TOKEN_REVOKED
Business Rules
Audit records are immutable.
Sensitive values should not be stored unnecessarily.
Passwords and raw tokens must never appear in audit data.
JSONB fields should include only useful changed values.
6. Optional Calendar Event Entity

For the MVP, Google Calendar links and .ics files can be generated dynamically without storing a calendar event.

A future table may be introduced if the system needs to record calendar exports or provider synchronization.

Possible Table Name
calendar_events
Possible Fields
id
appointment_id
provider
external_event_id
event_version
generated_at
last_synced_at
status

This entity is not required for the first database migration.

7. Database Relationship Diagram
8. Recommended Primary Key Strategy

Use UUID primary keys for internal identifiers.

Example:

550e8400-e29b-41d4-a716-446655440000

Benefits:

Difficult to guess
Suitable for distributed systems later
Safer in public URLs than sequential identifiers
Avoids identifier collision across future tenants

Customer-facing reference numbers should remain easier to read.

Examples:

Customer: FC-000001
Appointment: FA-2026-0001
Garment: FG-2026-0001
Quote: FQ-2026-0001

Reference numbers should not replace primary keys.

9. Timestamp Strategy

Use PostgreSQL:

TIMESTAMPTZ

for timestamps.

The backend should store timestamps in UTC.

The frontend should display dates and times in the business or customer timezone.

Common timestamp fields:

created_at
updated_at
approved_at
completed_at
sent_at
expires_at
revoked_at
10. Soft Deletion Strategy

The following entities may use soft deletion or deactivation:

Customer
File asset
Admin user
Customer access token

Operational records such as appointments, quotes, measurements, status history, and audit logs should generally remain available for historical and legal purposes.

Potential fields:

is_active
deleted_at
revoked_at
account_status

Hard deletion should be limited and governed by future data-retention rules.

11. Financial Data Strategy

All monetary values should use:

NUMERIC(12,2)

Do not use floating-point types for financial calculations.

Quote calculations should be performed on the backend.

Example:

subtotal
+ material_fee
+ rush_fee
+ tax_amount
- discount_amount
= total_amount

Currency should use an ISO 4217 code.

MVP default:

USD
12. Recommended Indexes
Customers
UNIQUE INDEX ON customers(email) WHERE email IS NOT NULL
INDEX ON customers(phone_number)
INDEX ON customers(whatsapp_number)
INDEX ON customers(last_name, first_name)
Appointments
UNIQUE INDEX ON appointments(appointment_number)
INDEX ON appointments(customer_id)
INDEX ON appointments(status)
INDEX ON appointments(scheduled_start_at)
INDEX ON appointments(created_at)
Garments
UNIQUE INDEX ON garments(garment_number)
INDEX ON garments(appointment_id)
INDEX ON garments(status)
Measurement Profiles
INDEX ON measurement_profiles(customer_id)
INDEX ON measurement_profiles(customer_id, measurement_date DESC)
Measurement Values
UNIQUE INDEX ON measurement_values(
    measurement_profile_id,
    measurement_type
)
Quotes
UNIQUE INDEX ON quotes(quote_number)
INDEX ON quotes(appointment_id)
INDEX ON quotes(garment_id)
INDEX ON quotes(status)
Customer Access Tokens
UNIQUE INDEX ON customer_access_tokens(token_hash)
INDEX ON customer_access_tokens(customer_id)
INDEX ON customer_access_tokens(expires_at)
Notifications
INDEX ON notifications(status, scheduled_at)
INDEX ON notifications(customer_id)
INDEX ON notifications(appointment_id)
Communication Logs
INDEX ON communication_logs(customer_id, occurred_at DESC)
INDEX ON communication_logs(appointment_id)
INDEX ON communication_logs(garment_id)
Audit Logs
INDEX ON audit_logs(entity_type, entity_id)
INDEX ON audit_logs(actor_admin_id)
INDEX ON audit_logs(created_at DESC)
INDEX ON audit_logs(correlation_id)
13. Recommended Unique Constraints
admin_users.email

customers.customer_number

appointments.appointment_number

garments.garment_number

quotes.quote_number

customer_access_tokens.token_hash

measurement_values(
    measurement_profile_id,
    measurement_type
)

marketplace_purchases.garment_id

file_assets.storage_key
14. Recommended Check Constraints

Examples:

quoted_price >= 0

final_price >= 0

unit_price >= 0

total_price >= 0

file_size_bytes > 0

quantity > 0

discount_amount >= 0

tax_amount >= 0

rush_fee >= 0

material_fee >= 0

Customer contact validation may be enforced in the application layer and optionally through a database check constraint:

email IS NOT NULL
OR phone_number IS NOT NULL
OR whatsapp_number IS NOT NULL
15. Deletion and Cascade Rules

Recommended behavior:

Customer

Do not automatically cascade-delete the customer's operational history.

Prefer deactivation or controlled deletion.

Appointment

Do not normally delete appointments.

If deletion is permitted in development, related garments and dependent draft data may cascade.

Garment

Deleting a draft garment may cascade to:

Alterations
Garment status history
Marketplace purchase

Completed garments should not be deleted.

Measurement Profile

Do not cascade-delete measurement history without explicit confirmation.

Quote

Deleting a draft quote may cascade to quote line items.

Approved or sent quotes should remain historical records.

Status History and Audit Logs

Do not allow normal application-level deletion.

16. Data Visibility Rules
Customer-Visible Data

Customers may view:

Their own profile information
Upcoming appointments
Historical appointments
Customer-friendly appointment statuses
Their garments
Customer-friendly garment statuses
Measurement profiles
Quotes
Customer-visible files
Customer-visible notes
Administrator-Only Data

Customers must not receive:

Password hashes
Token hashes
Internal notes
Audit metadata
Provider credentials
Notification failure details
Administrator-only files
Private communication notes
Sensitive security information

Visibility must be enforced through backend DTOs and authorization rules.

17. Multi-Tenant Future Considerations

The MVP supports one business and should not yet implement full multi-tenancy.

A future SaaS model may introduce:

businesses
business_users
business_locations
subscriptions

Future operational tables may receive:

business_id

Possible future relationship:

Business
    |
    +--- AdminUsers
    +--- Customers
    +--- Appointments
    +--- Locations
    +--- Subscription

This should not be implemented until multi-business requirements are validated.

18. Open Data-Model Decisions

The following decisions should be finalized before database migrations are created:

Should administrator authentication use UUID-based session records?
Should one quote support multiple garments, or should garment-level quotes remain separate?
Should measurement values use an enum-backed string or a configurable measurement-definition table?
Should customer access tokens expire automatically or remain valid until revoked?
Should file assets use explicit foreign-key columns or a polymorphic entity reference?
Should appointment rescheduling be stored only in status history or in a separate schedule-history table?
Should customer quote approval require a signed token or the existing customer access token?
Should soft deletion be implemented in the MVP or deferred?
Should customer numbers and appointment numbers be generated in the database or application layer?
Which records require formal retention periods?
19. MVP Tables

The recommended initial MVP migration should include:

admin_users
customers
customer_access_tokens
appointments
appointment_status_history
garments
garment_status_history
alterations
measurement_profiles
measurement_values
quotes
quote_line_items
marketplace_purchases
file_assets
communication_logs
notifications
notification_attempts
policy_agreements
audit_logs

A calendar_events table is not required for the MVP.

20. Entity Ownership Summary
Customer owns:
- Appointments
- Measurement profiles
- Access tokens
- Communication history
- Notifications

Appointment owns:
- Garments
- Appointment status history
- Quotes
- Policy agreements
- Appointment-related files and communication

Garment owns:
- Alterations
- Garment status history
- Marketplace metadata
- Garment-related files

Measurement profile owns:
- Measurement values

Quote owns:
- Quote line items

Notification owns:
- Notification attempts
21. Key Data-Model Decisions
ERD-001: Measurements Belong to Customers

Measurement profiles are associated with customers because measurements can be reused across appointments.

ERD-002: Measurements Are Versioned

New measurement profiles are created rather than overwriting previous profiles.

ERD-003: Appointments Support Multiple Garments

A customer may bring several garments during one appointment.

ERD-004: Garments Have Independent Status

Each garment can move through the alteration workflow separately.

ERD-005: Alterations Are Separate Records

A garment may require multiple independently described and priced alterations.

ERD-006: Marketplace Data Extends Garments

Marketplace purchases use the standard garment workflow with optional marketplace-specific metadata.

ERD-007: Files Are Stored Externally

PostgreSQL stores file metadata but not raw photos or videos.

ERD-008: Current Status and Status History Are Both Stored

The main entity stores the current status for efficient reads, while history tables preserve all transitions.

ERD-009: Secure Tokens Are Hashed

The database stores customer portal token hashes rather than raw access tokens.

ERD-010: Quotes Use Line Items

Quote line items provide transparent, structured, and calculable pricing.
