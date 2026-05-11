# CareDee Database Schema Documentation

This document provides a thorough explanation of the PostgreSQL schema for the CareDee platform. It details every table, column, data type, and the rationale behind architectural choices, ensuring 100% alignment with the `caredee_schema.sql` implementation.

---

### Schema Overview

The CareDee database is designed to handle complex workflows across 10 main modules, prioritizing security (PDPA), financial traceability, and high-volume scalability.

- **Total Tables:** 18 Logical Tables (including 1 Partitioned Table)
- **Total Columns:** 158 Columns
- **Primary Key Strategy:** UUID (v4) for all entities.
- **Audit Strategy:** Soft deletes (`deletedAt`) and immutable Audit Logs.

### Entity Relationship Summary

#### One-to-One (1:1)
- `User` ↔ `CaregiverProfile` (Base identity to professional profile)
- `Booking` ↔ `CareReport` (One daily report per session)
- `Booking` ↔ `Review` (One review allowed per completed session)
- `Review` ↔ `ReviewAppeal` (One appeal per disputed review)

#### One-to-Many (1:N)
- `User` → `UserConsentHistory` (History of legal agreements)
- `User` → `CareRecipient` (Customer managing multiple recipients)
- `User` → `CaregiverProfile` (Operator managing multiple caregivers)
- `User` → `LocationHistory` (Time-series GPS data)
- `User` → `Booking` (Customer/Cancel relation)
- `CaregiverProfile` → `CaregiverAvailability` (Multiple work shifts)
- `CaregiverProfile` → `Certification` (Professional credentials)
- `Booking` → `Transaction` (Supports multi-stage payments/refunds)
- `CareRecipient` → `Booking` (Session history per recipient)

---

## 1. Core User Management

### Table: `"User"`
Stores the primary identity data for all actors in the system (Customers, Caregivers, Operators, Admins, Training Institutes). Authentication data is stored separately in `"UserCredential"`.

| Column | Data Type | Description | Rationale |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | Primary Key | Uses `UUID` (v4) to prevent ID enumeration and ensure global uniqueness. |
| `email` | `TEXT` | User email | Primary contact identifier. Uniqueness enforced via partial index for soft deletes. |
| `phone` | `TEXT` | User phone | Secondary contact identifier. Uniqueness enforced via partial index for soft deletes. |
| `role` | `Role` | User's system role | Enum-based RBAC (Role-Based Access Control). |
| `firstName` | `TEXT` | Legal first name | Essential for verification and service delivery. |
| `lastName` | `TEXT` | Legal last name | Essential for verification and service delivery. |
| `avatarUrl` | `TEXT` | Profile image URL | Link to S3/Cloud Storage. |
| `notificationPreferences` | `JSONB` | User alert settings | `JSONB` allows flexible toggles without schema changes. |
| `isActive` | `BOOLEAN` | Account status | Primary flag for account availability. |
| `deletedAt` | `TIMESTAMPTZ`| Soft delete time | Support for logical deletion while preserving history. |
| `createdAt` | `TIMESTAMPTZ`| Record creation time | Standard audit tracking. |
| `updatedAt` | `TIMESTAMPTZ`| Last update time | Standard audit tracking. |

### Table: `"UserCredential"`
Stores authentication-related information and supports multiple authentication methods per user.

| Column | Data Type | Description | Rationale |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | Primary Key | Unique credential identifier. |
| `userId` | `UUID` | Link to User table | Foreign Key to the parent identity record. |
| `authProvider` | `AuthProvider` | Login method | Enum to strictly control supported login methods (LOCAL, GOOGLE, etc.). |
| `providerId` | `TEXT` | Provider unique ID | Unique ID from social provider, or User ID for LOCAL auth. |
| `passwordHash` | `TEXT` | Hashed password | Security compliance (Bcrypt/Argon2). Used for LOCAL auth. |
| `failedLoginAttempts`| `INTEGER` | Lockout counter | Tracks wrong passwords to trigger security lockout. |
| `lockoutUntil` | `TIMESTAMPTZ`| Lockout duration | Point in time when a locked account becomes usable again. |
| `deletedAt` | `TIMESTAMPTZ`| Soft delete time | Support for logical deletion. |
| `createdAt` | `TIMESTAMPTZ`| Record creation time | Standard audit tracking. |
| `updatedAt` | `TIMESTAMPTZ`| Last update time | Standard audit tracking. |

### Table: `"UserConsentHistory"`
Stores versioned PDPA and legal agreement history for compliance.

| Column | Data Type | Description | Rationale |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | Primary Key | Unique consent record identifier. |
| `userId` | `UUID` | Link to User | Records which user gave consent. |
| `consentType`| `TEXT` | Category | E.g., 'PDPA', 'TERMS_OF_SERVICE'. |
| `version` | `TEXT` | Version string | Tracks exactly which version was agreed to. |
| `termsUrl` | `TEXT` | Document link | URL to the immutable policy document at that time. |
| `documentHash`| `TEXT` | Integrity check | SHA-256 hash of the policy text for legal defensibility. |
| `acceptedAt` | `TIMESTAMPTZ`| Consent timestamp | Exact time when the user accepted the terms. |
| `ipAddress` | `TEXT` | Network origin | Forensic data for consent verification. |

---

## 2. Caregiver & Recipient Profiles

### Table: `"CaregiverProfile"`
Stores professional and geographical data for caregivers.

| Column | Data Type | Description | Rationale |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | Primary Key | Unique profile identifier. |
| `userId` | `UUID` | Link to User table | 1-to-1 relationship with the base User entity. |
| `operatorId` | `UUID` | Managed by | Link to the Service Operator (User) overseeing this caregiver. |
| `nationalId` | `TEXT` | Thai ID Number (Unique) | Encrypted at app-level; used for background checks. |
| `approvalStatus` | `ApprovalStatus` | Verification state | Enum: PENDING, APPROVED, REJECTED. |
| `skills` | `TEXT[]` | List of expertise | Array type allows storing multiple skills efficiently. |
| `serviceArea` | `TEXT` | Coverage area | Geographic scope of work (e.g., District name or Polygon JSON). |
| `hourlyRate` | `DOUBLE PRECISION`| Service cost | Stores floating-point currency values. |
| `ratingAvg` | `DOUBLE PRECISION`| Cached rating | Performance optimization for search/sorting; updated via automated triggers. |
| `createdAt` | `TIMESTAMPTZ`| Record creation time | Standard audit tracking. |
| `updatedAt` | `TIMESTAMPTZ`| Last update time | Standard audit tracking. |

### Table: `"LocationHistory"` (Partitioned)
Time-series location data for tracking and auditing. This table uses **Declarative Range Partitioning** by `timestamp`.

| Column | Data Type | Description | Rationale |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | ID Part | Component of the Composite Primary Key. |
| `userId` | `UUID` | Link to User | Identifies which user was at the location. |
| `latitude` | `DOUBLE PRECISION`| GPS Latitude | High-precision coordinate. |
| `longitude` | `DOUBLE PRECISION`| GPS Longitude | High-precision coordinate. |
| `timestamp` | `TIMESTAMPTZ`| Event time (PK) | Partition key; used for range partitioning and retention policies. |

**Partitioning Strategy:**
- **Type:** Range Partitioning (Monthly).
- **Benefits:** 
  - Improves query performance on large datasets.
  - Simplifies data retention (dropping an entire month's partition is more efficient than `DELETE`).
  - Scales effectively to millions of records.

### Table: `"CareRecipient"`
Stores details of the person receiving care.

| Column | Data Type | Description | Rationale |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | Primary Key | Unique recipient identifier. |
| `customerId` | `UUID` | Primary Contact | The User who manages/pays for this recipient. |
| `firstName` | `TEXT` | Recipient First Name | Essential for service delivery and identification. |
| `lastName` | `TEXT` | Recipient Last Name | Essential for service delivery and identification. |
| `dateOfBirth` | `TIMESTAMPTZ`| Date of Birth | Used for age calculation and age-appropriate care. |
| `gender` | `TEXT` | Recipient Gender | Necessary for matching and caregiver assignment. |
| `healthConditions` | `JSONB` | Medical history | Semi-structured data for varying complexity of medical notes. |
| `allergies` | `TEXT[]` | List of allergies | Array for quick listing of medicines/foods. |
| `createdAt` | `TIMESTAMPTZ`| Record creation time | Standard audit tracking. |
| `updatedAt` | `TIMESTAMPTZ`| Last update time | Standard audit tracking. |

### Table: `"CaregiverAvailability"`
Defines when a caregiver is available for bookings.

| Column | Data Type | Description | Rationale |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | Primary Key | Unique availability record identifier. |
| `caregiverProfileId` | `UUID` | Link to Profile | Foreign Key to the caregiver's professional profile. |
| `dayOfWeek` | `DayOfWeek` | Day of the week | Enum: MONDAY to SUNDAY. |
| `startTime` | `TIME` | Shift start time | Defines the beginning of the daily shift window. |
| `endTime` | `TIME` | Shift end time | Defines the end of the daily shift window. |

### Table: `"Certification"`
Verified professional credentials.

| Column | Data Type | Description | Rationale |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | Primary Key | Unique certificate identifier. |
| `caregiverProfileId` | `UUID` | Link to Profile | Nullable to allow Training Institutes to upload certificates before registration. |
| `nationalId` | `TEXT` | Linking Identity | The primary key used to "claim" certificates during registration. |
| `name` | `TEXT` | Certificate Name | Title of the professional qualification or course. |
| `issuingInstituteId` | `UUID` | Verified by | Link to a User with the `TRAINING_INSTITUTE` role. |
| `status` | `CertificationStatus`| Verification state | Tracks the lifecycle of a certificate. |
| `fileUrl` | `TEXT` | Certificate File | Link to the digital document in Cloud Storage. |
| `expiryDate` | `TIMESTAMPTZ`| Validity limit | Standard compliance tracking for certificate renewal. |
| `createdAt` | `TIMESTAMPTZ`| Record creation time | Standard audit tracking. |
| `updatedAt` | `TIMESTAMPTZ`| Last update time | Standard audit tracking. |

---

## 3. Booking & Scheduling

### Table: `"Booking"`
The central transactional table managing care sessions.

| Column | Data Type | Description | Rationale |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | Primary Key | Unique booking identifier. |
| `customerId` | `UUID` | Customer Link | Foreign Key to the User (Customer) who made the booking. |
| `careRecipientId` | `UUID` | Recipient Link | Foreign Key to the CareRecipient receiving the service. |
| `caregiverId` | `UUID` | Caregiver Link | Foreign Key to the CaregiverProfile assigned to this session. |
| `serviceType` | `TEXT` | Type of care | E.g., 'Daily Care', 'Specialist Care'. |
| `locationAddress` | `TEXT` | Service Location | The physical address where care is provided. |
| `scheduledStart` | `TIMESTAMPTZ`| Planned Start | The agreed-upon date and time for the session to begin. |
| `scheduledEnd` | `TIMESTAMPTZ`| Planned End | The agreed-upon date and time for the session to conclude. |
| `checkInTime` | `TIMESTAMPTZ`| Actual Start | Verified time when the caregiver started the session. |
| `checkInLat` | `DOUBLE PRECISION`| Check-in Latitude | GPS coordinate for physical presence verification at start. |
| `checkInLng` | `DOUBLE PRECISION`| Check-in Longitude | GPS coordinate for physical presence verification at start. |
| `checkOutTime` | `TIMESTAMPTZ`| Actual End | Verified time when the caregiver ended the session. |
| `checkOutLat` | `DOUBLE PRECISION`| Check-out Latitude | GPS coordinate for physical presence verification at end. |
| `checkOutLng` | `DOUBLE PRECISION`| Check-out Longitude | GPS coordinate for physical presence verification at end. |
| `status` | `BookingStatus` | Workflow state | Enum ensures only valid transitions (PENDING, CONFIRMED, etc.). |
| `cancellationReason`| `TEXT` | Cancel Detail | Qualitative reason for cancelling the booking. |
| `cancelledBy` | `UUID` | Cancelled By | Link to the User who performed the cancellation. |
| `cancellationFee` | `DOUBLE PRECISION`| Penalty Amount | Fee charged for late cancellations or policy violations. |
| `originalCaregiverId`| `UUID` | Reassignment log | Tracks history if an Operator replaces the initial caregiver. |
| `totalPrice` | `DOUBLE PRECISION`| Agreed cost | Final amount the customer pays for this session. |
| `deletedAt` | `TIMESTAMPTZ`| Soft delete time | Support for logical deletion of bookings. |
| `createdAt` | `TIMESTAMPTZ`| Record creation time | Standard audit tracking. |
| `updatedAt` | `TIMESTAMPTZ`| Last update time | Standard audit tracking. |

---

## 4. Payment & Revenue

### Table: `"Transaction"`
Logs financial events tied to bookings.

| Column | Data Type | Description | Rationale |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | Primary Key | Unique transaction identifier. |
| `bookingId` | `UUID` | Link to Booking | 1-to-N relationship allowing multiple financial events (Deposit, Final, Refund) per booking. |
| `externalRefId` | `TEXT` | Payment Gateway ID | Link to Stripe/Omise/KBANK logs for auditing and reconciliation. |
| `transactionType` | `TransactionType`| Event category | Enum: DEPOSIT, FINAL_PAYMENT, REFUND, RETRY, ADJUSTMENT. |
| `amount` | `DOUBLE PRECISION`| Gross amount | Total payment from customer in THB. |
| `commission` | `DOUBLE PRECISION`| Platform's cut | CareDee service fee deducted from the gross amount. |
| `netAmount` | `DOUBLE PRECISION`| Caregiver's share | Payout to the caregiver after commission. |
| `status` | `TransactionStatus`| Payment state | Enum: PENDING, SUCCESS, FAILED, REFUNDED. |
| `paymentMethod` | `TEXT` | Payment Channel | E.g., 'QR_CODE', 'CREDIT_CARD', 'BANK_TRANSFER'. |
| `deletedAt` | `TIMESTAMPTZ`| Soft delete time | Support for logical deletion of transactions. |
| `createdAt` | `TIMESTAMPTZ`| Record creation time | Standard audit tracking. |
| `updatedAt` | `TIMESTAMPTZ`| Last update time | Standard audit tracking. |

---

## 5. Care Monitoring & Feedback

### Table: `"CareReport"`
Daily logs of caregiver activities during a booking.

| Column | Data Type | Description | Rationale |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | Primary Key | Unique report identifier. |
| `bookingId` | `UUID` | Link to Booking | 1-to-1 relationship linking the report to a specific session. |
| `activities` | `JSONB` | Task checklist | Stores what was done (e.g., 'Bathed: Yes') in a flexible JSON format. |
| `mediaUrls` | `TEXT[]` | Proof of care | Links to photos of food/environment for quality assurance and family visibility. |
| `latitude` | `DOUBLE PRECISION`| Report Latitude | GPS coordinate at the time of report submission. |
| `longitude` | `DOUBLE PRECISION`| Report Longitude | GPS coordinate at the time of report submission. |
| `submittedAt` | `TIMESTAMPTZ`| Submission Time | Exact timestamp when the caregiver finalized the report. |
| `deletedAt` | `TIMESTAMPTZ`| Soft delete time | Support for logical deletion of care reports. |

### Table: `"Review"`
Post-service feedback from Customers.

| Column | Data Type | Description | Rationale |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | Primary Key | Unique review identifier. |
| `bookingId` | `UUID` | Link to Booking | 1-to-1 relationship ensuring only one review per session. |
| `customerId` | `UUID` | Reviewer Link | Foreign Key to the User who wrote the review. |
| `rating` | `INTEGER` | Score (1-5) | Quantifiable feedback used to calculate caregiver's `ratingAvg`. |
| `comment` | `TEXT` | Review Text | Qualitative feedback from the customer. |
| `isPublished` | `BOOLEAN` | Moderation flag | Allows hiding reviews during investigation or if they violate terms. |
| `createdAt` | `TIMESTAMPTZ`| Record creation time | Standard audit tracking. |

### Table: `"ReviewAppeal"`
Handles caregiver disputes against unfair ratings.

| Column | Data Type | Description | Rationale |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | Primary Key | Unique appeal identifier. |
| `reviewId` | `UUID` | Link to Review | 1-to-1 relationship with the disputed review. |
| `caregiverProfileId`| `UUID` | Appellant Link | Foreign Key to the caregiver filing the dispute. |
| `reason` | `TEXT` | Appeal Justification| Detailed reason why the caregiver believes the review is unfair. |
| `status` | `ReviewAppealStatus`| Investigation state | Enum: PENDING, IN_REVIEW, RESOLVED, REJECTED. |
| `resolvedBy` | `UUID` | Resolved By | Link to the Admin or Operator who handled the appeal. |
| `createdAt` | `TIMESTAMPTZ`| Record creation time | Standard audit tracking. |
| `updatedAt` | `TIMESTAMPTZ`| Last update time | Standard audit tracking. |

---

## 6. Intelligence, Configuration & Auditing

### Table: `"MatchRecommendationLog"`
The "brain" of the matching engine, storing the history of profile recommendations.

| Column | Data Type | Description | Rationale |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | Primary Key | Unique log entry identifier. |
| `customerId` | `UUID` | Searching User | Foreign Key to the User (Customer) for whom the match was made. |
| `caregiverProfileId`| `UUID` | Recommended Profile| Foreign Key to the CaregiverProfile being suggested. |
| `score` | `DOUBLE PRECISION`| Match quality % | Stores calculated suitability score (0.0 to 1.0). |
| `reasoning` | `JSONB` | Score breakdown | Explains why the score was given (e.g., skill match, proximity) for transparency. |
| `createdAt` | `TIMESTAMPTZ`| Event timestamp | Time when the recommendation was generated. |

### Table: `"SystemConfiguration"`
Global platform settings used to manage dynamic system behavior.

| Column | Data Type | Description | Rationale |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | Primary Key | Unique configuration identifier. |
| `key` | `TEXT` | Setting name | Unique identifier for a configuration item (e.g., 'MIN_BOOKING_HOURS'). |
| `value` | `JSONB` | Setting payload | Allows storing complex settings (arrays, objects) without schema changes. |
| `updatedBy` | `UUID` | Last modified by | Link to the Admin User who last changed this setting. |
| `updatedAt` | `TIMESTAMPTZ`| Last modified time | Standard audit tracking for configuration changes. |

### Table: `"AuditLog"`
Immutable record of system actions for security and compliance (PDPA).

| Column | Data Type | Description | Rationale |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | Primary Key | Unique log identifier. |
| `userId` | `UUID` | Performer Link | Foreign Key to the User who performed the action. |
| `action` | `TEXT` | Action Type | The type of event that occurred (e.g., 'LOGIN', 'DELETE_USER'). |
| `entity` | `TEXT` | Target Entity | The name of the table or resource affected by the action. |
| `details` | `JSONB` | State change | Stores the 'before' and 'after' state or extra metadata for the event. |
| `createdAt` | `TIMESTAMPTZ`| Event timestamp | Exact time when the action was recorded. |

---

## 7. Notifications & Devices

### Table: `"Notification"`
User-facing alerts and messages delivered across multiple channels (Push, SMS, Email, LINE).

| Column | Data Type | Description | Rationale |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | Primary Key | Unique notification identifier. |
| `userId` | `UUID` | Target Recipient | Foreign Key to the User receiving the alert. |
| `type` | `TEXT` | Category | E.g., 'BOOKING_CONFIRMED', 'PAYMENT_FAILED' for filtering. |
| `message` | `TEXT` | Alert Content | The actual text shown to the user. |
| `isRead` | `BOOLEAN` | Read Status | Tracks if the user has interacted with or seen the alert. |
| `createdAt` | `TIMESTAMPTZ`| Audit timestamp | Record creation time; used for chronological display. |

### Table: `"UserDevice"`
Maps users to their mobile hardware for push notifications (FCM/APNs).

| Column | Data Type | Description | Rationale |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | Primary Key | Unique device record identifier. |
| `userId` | `UUID` | Device Owner | Foreign Key to the User who owns the device. |
| `deviceToken` | `TEXT` | Push Token | Unique identifier for the device (FCM/APNs) to receive Push Notifications. |
| `platform` | `TEXT` | OS Type | Logic to handle payload differences between Android and iOS. |
| `createdAt` | `TIMESTAMPTZ`| Record creation time | Time when the device was first registered. |
| `updatedAt` | `TIMESTAMPTZ`| Last heartbeat | Tracks when the token was last refreshed or the user logged in. |

---

## Key Technical Decisions Summary

1.  **UUID vs BIGINT:** We use `UUID` for all IDs to support future scaling (merging data from different regions) and to prevent "ID scraping".
2.  **TIMESTAMP WITH TIME ZONE (TIMESTAMPTZ):** Absolute requirement for a platform operating across time zones (Postgres shorthand `TIMESTAMP WITH TIME ZONE`).
3.  **JSONB vs Normalized Columns:** Used for data that varies significantly (e.g., medical conditions, matching logic, config) to avoid frequent `ALTER TABLE` commands.
4.  **Enums:** Used for status and roles to enforce data integrity at the database level.
5.  **Audit Logs:** Every major action is recorded in the `AuditLog` table for PDPA and operational accountability.
6.  **Soft Deletes & Partial Indexes:** Critical tables use a `deletedAt` column for logical deletion. Partial unique indexes (e.g., on `User.email`) allow re-registration with the same identifier once an old account is soft-deleted.
7.  **Automated Rating Triggers:** Caregiver `ratingAvg` is managed by database-level triggers that aggregate published reviews. To prevent race conditions during high-volume concurrent updates, explicit row-level locking (`FOR UPDATE`) is implemented on the `CaregiverProfile` row being recalculated.
8.  **PDPA Versioning:** Consent is stored in a dedicated `UserConsentHistory` table with versioning and document hashes, ensuring high legal traceability and compliance with PDPA requirements.
9. Scalability for High-Volume Data: Tables like `LocationHistory` are expected to grow rapidly. The design explicitly recommends table partitioning by `timestamp` (e.g., monthly) to maintain query performance as the dataset reaches millions of rows.

---

## 8. Module to Database Mapping (ความสัมพันธ์ระหว่าง Module และ Database)

จากโครงสร้าง **10 Main Modules** ของระบบ CareDee ตารางต่างๆ ในฐานข้อมูลถูกออกแบบมาเพื่อรองรับการทำงานในแต่ละส่วน ดังนี้:

### 1. User Management & Access Control
*   **`"User"`**: ตารางหลักที่เก็บข้อมูลพื้นฐานของทุก Role (Customer, Caregiver, Operator, Admin, Training Institute) โดยใช้ `UUID` เพื่อความปลอดภัยและ `deletedAt` สำหรับ PDPA
*   **`"UserCredential"`**: แยกข้อมูลการพิสูจน์ตัวตน (Password/Social Login) ออกจากข้อมูลส่วนบุคคล เพื่อความปลอดภัยและการจัดการหลาย Auth Provider
*   **`"UserConsentHistory"`**: เก็บประวัติการยอมรับข้อตกลง (PDPA) พร้อม `version` และ `documentHash` เพื่อใช้เป็นหลักฐานทางกฎหมาย

### 2. Marketplace & Search
*   **`"CaregiverProfile"`**: เก็บข้อมูลวิชาชีพ ทักษะ (`skills` เป็น Array) และ `ratingAvg` เพื่อความรวดเร็วในการค้นหา
*   **`"CaregiverAvailability"`**: จัดการตารางกะเวลาทำงาน เพื่อตรวจสอบความว่างและป้องกันการจองทับซ้อน

### 3. Matching Engine
*   **`"MatchRecommendationLog"`**: บันทึกประวัติการจับคู่และเหตุผล (`reasoning` เป็น JSONB) เพื่อใช้ในการปรับปรุง Algorithm ในอนาคต

### 4. Booking & Scheduling
*   **`"Booking"`**: ตารางธุรกรรมหลัก จัดการสถานะการจอง พิกัด Check-in/out และราคา
*   **`"CareRecipient"`**: แยกข้อมูลผู้รับการดูแลออกมา เนื่องจากลูกค้า 1 รายอาจจองให้ผู้ป่วยหลายคน โดยเก็บประวัติสุขภาพเป็น `JSONB` เพื่อความยืดหยุ่น

### 5. Payment & Revenue Management
*   **`"Transaction"`**: บันทึกเส้นทางการเงิน แยกระหว่างยอดรวม ยอดสุทธิ และค่าคอมมิชชั่น เพื่อความโปร่งใสในการตรวจสอบ

### 6. Care Report System
*   **`"CareReport"`**: ให้ Caregiver บันทึกกิจกรรมประจำวัน (`activities` เป็น JSONB) พร้อมหลักฐานภาพถ่าย (`mediaUrls`)

### 7. Rating & Review System
*   **`"Review"`**: เก็บผลตอบรับจากลูกค้าเพื่อประเมิน Caregiver
*   **`"ReviewAppeal"`**: ระบบอุทธรณ์สำหรับ Caregiver ในกรณีที่ได้รับรีวิวที่ไม่เป็นธรรม

### 8. Notification System
*   **`"Notification"`**: จัดเก็บประวัติการแจ้งเตือนส่วนบุคคล
*   **`"UserDevice"`**: จัดเก็บ Device Token เพื่อส่ง Push Notification แยกตาม Platform (iOS/Android)

### 9. Operator & Admin Portal
*   **`"SystemConfiguration"`**: เก็บค่าปรับตั้งค่าระบบที่ Admin สามารถแก้ไขได้ผ่านหน้าเว็บ (`JSONB`)
*   **`"AuditLog"`**: บันทึกทุกความเคลื่อนไหวในระบบ (Immutable) เพื่อความปลอดภัยและ Audit
*   **`"LocationHistory"`**: เก็บเส้นทาง GPS แบบ Time-series (Partitioned Table) เพื่อตรวจสอบการทำงานและความปลอดภัย

### 10. Training Institute Interface
*   **`"Certification"`**: จัดเก็บและตรวจสอบใบประกาศนียบัตรวิชาชีพ เชื่อมโยงด้วย `nationalId`

