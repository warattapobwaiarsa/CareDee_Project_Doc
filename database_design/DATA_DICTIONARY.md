# CareDee Data Dictionary

This document serves as the technical reference for the CareDee PostgreSQL database schema. It lists all entities, attributes, data types, and constraints.

---

## Enums (Custom Types)

| Enum Name | Values |
| :--- | :--- |
| **Role** | CUSTOMER, CAREGIVER, OPERATOR, ADMIN, TRAINING_INSTITUTE |
| **AuthProvider** | LOCAL, GOOGLE, FACEBOOK, LINE, APPLE |
| **BookingStatus** | PENDING, CONFIRMED, IN_PROGRESS, COMPLETED, CANCELLED |
| **TransactionStatus** | PENDING, SUCCESS, FAILED, REFUNDED |
| **CertificationStatus** | PENDING, APPROVED, REJECTED, REVOKED, EXPIRED |
| **DayOfWeek** | MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY |
| **ApprovalStatus** | PENDING, APPROVED, REJECTED |
| **ReviewAppealStatus** | PENDING, IN_REVIEW, RESOLVED, REJECTED |
| **TransactionType** | DEPOSIT, FINAL_PAYMENT, REFUND, RETRY, ADJUSTMENT |
| **NotificationStatus** | PENDING, SENT, FAILED |

---

## Tables

### 1. User
Core identity table.

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | UUID | PK | `gen_random_uuid()` | Unique identifier for the user. |
| `email` | TEXT | Partial Unique (Active) | - | User email address. |
| `phone` | TEXT | Partial Unique (Active) | - | User phone number. |
| `role` | Role | NOT NULL | - | System role for RBAC. |
| `firstName` | TEXT | NOT NULL | - | Legal first name. |
| `lastName` | TEXT | NOT NULL | - | Legal last name. |
| `avatarUrl` | TEXT | - | - | Profile picture URL. |
| `notificationPreferences` | JSONB | - | - | User-specific alert settings. |
| `isActive` | BOOLEAN | NOT NULL | true | Operational status. |
| `deletedAt` | TIMESTAMPTZ | - | - | Soft delete timestamp. |
| `createdAt` | TIMESTAMPTZ | NOT NULL | `NOW()` | Audit creation time. |
| `updatedAt` | TIMESTAMPTZ | NOT NULL | `NOW()` | Audit update time. |

### 2. UserCredential
Authentication data and login methods. Supports 1:N relationship (one user, multiple login methods).

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | UUID | PK | `gen_random_uuid()` | Unique identifier for the credential. |
| `userId` | UUID | FK (User.id), NOT NULL | - | Reference to the owner. |
| `authProvider` | AuthProvider | NOT NULL | - | Identity provider type. |
| `providerId` | TEXT | NOT NULL | - | Provider-specific identifier (e.g., social ID or User ID for LOCAL). |
| `passwordHash` | TEXT | - | - | Bcrypt hashed password (for LOCAL auth). |
| `failedLoginAttempts` | INTEGER | NOT NULL | 0 | Security counter. |
| `lockoutUntil` | TIMESTAMPTZ | - | - | Security lockout timestamp. |
| `deletedAt` | TIMESTAMPTZ | - | - | Soft delete timestamp. |
| `createdAt` | TIMESTAMPTZ | NOT NULL | `NOW()` | Audit creation time. |
| `updatedAt` | TIMESTAMPTZ | NOT NULL | `NOW()` | Audit update time. |

### 3. UserConsentHistory
Versioned legal and PDPA consent records.

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | UUID | PK | `gen_random_uuid()` | Unique identifier. |
| `userId` | UUID | FK (User.id), NOT NULL | - | Reference to the user. |
| `consentType` | TEXT | NOT NULL | - | E.g., 'PDPA', 'TOS'. |
| `version` | TEXT | NOT NULL | - | Policy version string. |
| `termsUrl` | TEXT | - | - | Link to policy document. |
| `documentHash` | TEXT | - | - | SHA-256 hash of document. |
| `acceptedAt` | TIMESTAMPTZ | NOT NULL | `NOW()` | Timestamp of agreement. |
| `ipAddress` | TEXT | - | - | Origin network address. |

### 4. CareRecipient
Details of individuals receiving care services.

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | UUID | PK | `gen_random_uuid()` | Unique identifier. |
| `customerId` | UUID | FK (User.id), NOT NULL | - | The user managing this recipient. |
| `firstName` | TEXT | NOT NULL | - | Recipient's first name. |
| `lastName` | TEXT | NOT NULL | - | Recipient's last name. |
| `dateOfBirth` | TIMESTAMPTZ | - | - | For age calculations. |
| `gender` | TEXT | - | - | Recipient gender. |
| `healthConditions` | JSONB | - | - | Semi-structured medical history. |
| `allergies` | TEXT[] | - | - | List of known allergies. |
| `createdAt` | TIMESTAMPTZ | NOT NULL | `NOW()` | Audit creation time. |
| `updatedAt` | TIMESTAMPTZ | NOT NULL | `NOW()` | Audit update time. |

### 5. CaregiverProfile
Professional details for users with the CAREGIVER role.

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | UUID | PK | `gen_random_uuid()` | Unique identifier. |
| `userId` | UUID | FK (User.id), UNIQUE, NOT NULL | - | Base user reference. |
| `operatorId` | UUID | FK (User.id) | - | Managing Service Operator. |
| `nationalId` | TEXT | UNIQUE, NOT NULL | - | Thai ID card number (**Encrypted at app-level SA-003**). |
| `approvalStatus` | ApprovalStatus | NOT NULL | 'PENDING' | Workflow verification state. |
| `skills" | TEXT[] | - | - | Array of professional skills. |
| `serviceArea` | TEXT | NOT NULL | - | Coverage zone metadata. |
| `hourlyRate` | FLOAT8 | NOT NULL | - | Price per hour in THB. |
| `ratingAvg` | FLOAT8 | NOT NULL | 0.0 | Cached score from reviews. |
| `createdAt` | TIMESTAMPTZ | NOT NULL | `NOW()` | Audit creation time. |
| `updatedAt` | TIMESTAMPTZ | NOT NULL | `NOW()` | Audit update time. |

### 6. LocationHistory (Partitioned)
High-frequency GPS tracking data. **Partitions are managed automatically via Stored Procedure.**

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | UUID | PK (Composite) | `gen_random_uuid()` | Unique identifier. |
| `userId" | UUID | FK (User.id), NOT NULL | - | User being tracked. |
| `location` | GEOGRAPHY | NOT NULL | - | PostGIS GPS Point (4326). |
| `timestamp` | TIMESTAMPTZ | PK (Composite), NOT NULL | `NOW()` | Event time / Partition Key. |

**Partitioning Notes:**
- **Strategy:** Range Partitioning by `timestamp` (Monthly).
- **Automation:** The `create_next_month_location_history_partition()` stored procedure handles the creation of future tables.
- **Naming Convention:** `LocationHistory_YYYY_MM`.

### 7. CaregiverAvailability
Recuring work shift definitions for caregivers.

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | UUID | PK | `gen_random_uuid()` | Unique identifier. |
| `caregiverProfileId` | UUID | FK (CaregiverProfile.id), NOT NULL | - | Reference to profile. |
| `dayOfWeek` | DayOfWeek | NOT NULL | - | Enum: MONDAY to SUNDAY. |
| `startTime` | TIME | NOT NULL | - | Shift start time. |
| `endTime` | TIME | NOT NULL | - | Shift end time. |

### 8. Certification
Verified credentials for caregivers.

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | UUID | PK | `gen_random_uuid()` | Unique identifier. |
| `caregiverProfileId` | UUID | FK (CaregiverProfile.id) | - | Linked profile (Nullable for pre-claim). |
| `nationalId` | TEXT | NOT NULL | - | Used for certificate claiming. |
| `name` | TEXT | NOT NULL | - | Certificate/Course name. |
| `issuingInstituteId`| UUID | FK (User.id), NOT NULL | - | The Training Institute. |
| `status` | CertificationStatus | NOT NULL | 'PENDING' | Verification workflow (e.g. APPROVED, EXPIRED). |
| `fileUrl` | TEXT | NOT NULL | - | Link to S3/Storage file. |
| `expiryDate` | TIMESTAMPTZ | NOT NULL | - | Validity limit. **Status auto-updated via trigger.** |
| `createdAt` | TIMESTAMPTZ | NOT NULL | `NOW()` | Audit creation time. |
| `updatedAt` | TIMESTAMPTZ | NOT NULL | `NOW()` | Audit update time. |

### 9. Booking
Central transaction table for care sessions.

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | UUID | PK | `gen_random_uuid()` | Unique identifier. |
| `customerId` | UUID | FK (User.id), NOT NULL | - | The user booking the service. |
| `careRecipientId` | UUID | FK (CareRecipient.id), NOT NULL | - | The person receiving care. |
| `caregiverId` | UUID | FK (CaregiverProfile.id), NOT NULL | - | The assigned caregiver. |
| `serviceType` | TEXT | NOT NULL | - | Category of service. |
| `locationAddress` | TEXT | NOT NULL | - | Physical service location. |
| `locationGeog` | GEOGRAPHY | - | - | PostGIS point for distance logic. |
| `scheduledStart` | TIMESTAMPTZ | NOT NULL | - | Planned start. |
| `scheduledEnd` | TIMESTAMPTZ | NOT NULL | - | Planned end. |
| `checkInTime` | TIMESTAMPTZ | - | - | Actual start. |
| `checkInLocation` | GEOGRAPHY | - | - | GPS verification at start. |
| `checkOutTime` | TIMESTAMPTZ | - | - | Actual end. |
| `checkOutLocation` | GEOGRAPHY | - | - | GPS verification at end. |
| `status` | BookingStatus | NOT NULL | 'PENDING' | Workflow state. |
| `cancellationReason` | TEXT | - | - | Provided by user/operator. |
| `cancelledBy` | UUID | FK (User.id) | - | User who triggered cancel. |
| `totalPrice` | FLOAT8 | NOT NULL | - | Agreement amount in THB. |
| `deletedAt` | TIMESTAMPTZ | - | - | Soft delete timestamp. |
| `createdAt` | TIMESTAMPTZ | NOT NULL | `NOW()` | Audit creation time. |
| `updatedAt` | TIMESTAMPTZ | NOT NULL | `NOW()` | Audit update time. |

### 10. Transaction
Financial ledger for booking-related payments.

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | UUID | PK | `gen_random_uuid()` | Unique identifier. |
| `bookingId` | UUID | FK (Booking.id), NOT NULL | - | Reference to the booking. |
| `externalRefId` | TEXT | UNIQUE | - | Payment gateway reference. |
| `transactionType` | TransactionType | NOT NULL | - | E.g., DEPOSIT, REFUND. |
| `amount` | FLOAT8 | NOT NULL | - | Gross amount in THB. |
| `commission` | FLOAT8 | NOT NULL | - | Platform fee in THB. |
| `netAmount` | FLOAT8 | NOT NULL | - | Caregiver payout in THB. |
| `status` | TransactionStatus | NOT NULL | 'PENDING' | Payment state. |
| `paymentMethod` | TEXT | NOT NULL | - | E.g., 'QR_CODE', 'CREDIT_CARD'. |
| `deletedAt` | TIMESTAMPTZ | - | - | Soft delete timestamp. |
| `createdAt` | TIMESTAMPTZ | NOT NULL | `NOW()` | Audit creation time. |
| `updatedAt` | TIMESTAMPTZ | NOT NULL | `NOW()` | Audit update time. |

### 11. CareReport
Daily clinical/activity logs submitted by caregivers.

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | UUID | PK | `gen_random_uuid()` | Unique identifier. |
| `bookingId` | UUID | FK (Booking.id), UNIQUE, NOT NULL | - | Reference to session. |
| `activities` | JSONB | NOT NULL | - | Structured checklist of tasks. |
| `mediaUrls` | TEXT[] | - | - | List of evidence image URLs. |
| `location` | GEOGRAPHY | - | - | Submission PostGIS GPS location. |
| `submittedAt` | TIMESTAMPTZ | NOT NULL | `NOW()` | Record time. |
| `deletedAt` | TIMESTAMPTZ | - | - | Soft delete timestamp. |

### 12. Review
Customer feedback and ratings.

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | UUID | PK | `gen_random_uuid()` | Unique identifier. |
| `bookingId` | UUID | FK (Booking.id), UNIQUE, NOT NULL | - | Associated session. |
| `customerId` | UUID | FK (User.id), NOT NULL | - | The reviewer. |
| `rating` | INTEGER | NOT NULL | - | Score between 1 and 5. |
| `comment` | TEXT | - | - | Qualitative feedback. |
| `isPublished` | BOOLEAN | NOT NULL | true | Moderation status. |
| `createdAt` | TIMESTAMPTZ | NOT NULL | `NOW()` | Record time. |

### 13. ReviewAppeal
Caregiver disputes against specific reviews.

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | UUID | PK | `gen_random_uuid()` | Unique identifier. |
| `reviewId` | UUID | FK (Review.id), UNIQUE, NOT NULL | - | Disputed review reference. |
| `caregiverProfileId`| UUID | FK (CaregiverProfile.id), NOT NULL | - | The appellant. |
| `reason` | TEXT | NOT NULL | - | Justification for appeal. |
| `status` | ReviewAppealStatus | NOT NULL | 'PENDING' | Investigation state. |
| `resolvedBy` | UUID | FK (User.id) | - | Admin/Operator resolver. |
| `createdAt` | TIMESTAMPTZ | NOT NULL | `NOW()` | Record time. |
| `updatedAt` | TIMESTAMPTZ | NOT NULL | `NOW()` | Audit update time. |

### 14. AuditLog
Immutable log of system-wide actions.

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | UUID | PK | `gen_random_uuid()` | Unique identifier. |
| `userId` | UUID | FK (User.id), NOT NULL | - | Performer of the action. |
| `action` | TEXT | NOT NULL | - | E.g., 'LOGIN', 'UPDATE_RATE'. |
| `entity` | TEXT | NOT NULL | - | Affected table name. |
| `details` | JSONB | NOT NULL | - | State change (**{before: {...}, after: {...}}**). |
| `createdAt` | TIMESTAMPTZ | NOT NULL | `NOW()` | Event timestamp. |

### 15. SystemConfiguration
Dynamic platform settings.

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | UUID | PK | `gen_random_uuid()` | Unique identifier. |
| `key` | TEXT | UNIQUE, NOT NULL | - | Configuration identifier. |
| `value` | JSONB | NOT NULL | - | Configuration payload. |
| `updatedBy` | UUID | FK (User.id) | - | Last modified by. |
| `updatedAt` | TIMESTAMPTZ | NOT NULL | `NOW()` | Last modified timestamp. |

### 16. MatchRecommendationLog
Analytics data from the matching engine.

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | UUID | PK | `gen_random_uuid()` | Unique identifier. |
| `customerId` | UUID | FK (User.id), NOT NULL | - | The searcher. |
| `caregiverProfileId`| UUID | FK (CaregiverProfile.id), NOT NULL | - | The recommended profile. |
| `score` | FLOAT8 | NOT NULL | - | Suitably percentage (0-1). |
| `reasoning` | JSONB | - | - | Breakdown of score calculation. |
| `createdAt` | TIMESTAMPTZ | NOT NULL | `NOW()` | Event timestamp. |

### 17. Notification
Multi-channel alerts for users.

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | UUID | PK | `gen_random_uuid()` | Unique identifier. |
| `userId` | UUID | FK (User.id), NOT NULL | - | Target recipient. |
| `type` | TEXT | NOT NULL | - | Category (e.g., 'PAYMENT'). |
| `message` | TEXT | NOT NULL | - | Alert content. |
| `status` | NotificationStatus | NOT NULL | 'PENDING' | Queue state. |
| `retryCount` | INTEGER | NOT NULL | 0 | Number of failed attempts. |
| `lastRetryAt` | TIMESTAMPTZ | - | - | Last delivery attempt time. |
| `isRead` | BOOLEAN | NOT NULL | false | Read/Unread status. |
| `createdAt` | TIMESTAMPTZ | NOT NULL | `NOW()` | Audit creation time. |

### 18. UserDevice
Mapping of users to hardware for Push Notifications.

| Column | Type | Constraints | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | UUID | PK | `gen_random_uuid()` | Unique identifier. |
| `userId` | UUID | FK (User.id), NOT NULL | - | Owner of the device. |
| `deviceToken` | TEXT | UNIQUE, NOT NULL | - | FCM/APNs token. |
| `platform` | TEXT | NOT NULL | - | E.g., 'ANDROID', 'IOS'. |
| `createdAt` | TIMESTAMPTZ | NOT NULL | `NOW()` | Record time. |
| `updatedAt` | TIMESTAMPTZ | NOT NULL | `NOW()` | Last heartbeat/update. |
