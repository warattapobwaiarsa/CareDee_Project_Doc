# CareDee Platform - Database Schema Plan

## 1. Background & Motivation
The CareDee Platform requires a robust, scalable, and secure relational database to manage its 10 core modules. Based on the technical requirements, we use **Prisma ORM** with **PostgreSQL** to define the declarative schema. Prisma provides excellent type safety and native support for `JSONB` fields, which is essential for storing semi-structured data like Care Reports, Audit Logs, and User Preferences.

## 2. Scope & Impact
This plan covers the comprehensive logical database design, ensuring 100% alignment with the `caredee_schema.sql` implementation. The schema includes models for:
- **User Management & Access Control** (RBAC, MFA, Lockout security)
- **Marketplace & Search** (Caregiver Profiles, Availability)
- **Booking & Scheduling** (Check-in/out, Reassignment logs)
- **Payment & Revenue Management** (Transaction tracking)
- **Care Report System** (Daily activity logging)
- **Rating & Review System** (Moderation and Appeals)
- **Intelligence & Analytics** (Match recommendations)
- **Notification System** (Multi-channel & Device mapping)
- **Operator & Admin Portal** (Audit Trail & System Config)
- **Training Institute Interface** (Certifications & Trainee pre-approval)

## 3. Proposed Solution (Prisma Schema)

```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
}

enum Role {
  CUSTOMER
  CAREGIVER
  OPERATOR
  ADMIN
  TRAINING_INSTITUTE
}

enum AuthProvider {
  LOCAL
  GOOGLE
  FACEBOOK
  LINE
  APPLE
}

enum BookingStatus {
  PENDING
  CONFIRMED
  IN_PROGRESS
  COMPLETED
  CANCELLED
}

enum TransactionStatus {
  PENDING
  SUCCESS
  FAILED
  REFUNDED
}

enum CertificationStatus {
  PENDING
  APPROVED
  REJECTED
  REVOKED
}

enum DayOfWeek {
  MONDAY
  TUESDAY
  WEDNESDAY
  THURSDAY
  FRIDAY
  SATURDAY
  SUNDAY
}

enum ApprovalStatus {
  PENDING
  APPROVED
  REJECTED
}

enum ReviewAppealStatus {
  PENDING
  IN_REVIEW
  RESOLVED
  REJECTED
}

enum TransactionType {
  DEPOSIT
  FINAL_PAYMENT
  REFUND
  RETRY
  ADJUSTMENT
}

model User {
  id                      String       @id @default(uuid())
  email                   String?      
  phone                   String?      
  passwordHash            String?
  authProvider            AuthProvider @default(LOCAL)
  socialId                String?      @unique
  role                    Role
  firstName               String
  lastName                String
  avatarUrl               String?
  notificationPreferences Json?        // JSONB for flexible toggle settings
  failedLoginAttempts     Int          @default(0)
  lockoutUntil            DateTime?
  isActive                Boolean      @default(true)
  deletedAt               DateTime?
  createdAt               DateTime     @default(now())
  updatedAt               DateTime     @updatedAt
  
  // Relations
  caregiverProfile        CaregiverProfile?
  locationHistory         LocationHistory[]
  consentHistory          UserConsentHistory[]
  operatorCaregivers      CaregiverProfile[] @relation("OperatorCaregivers")
  careRecipients          CareRecipient[]
  bookings                Booking[]           @relation("CustomerBookings")
  cancelledBookings       Booking[]           @relation("CancelledByUser")
  reviews                 Review[]            @relation("CustomerReviews")
  notifications           Notification[]
  auditLogs               AuditLog[]
  updatedConfigs          SystemConfiguration[]
  matchRecommendations    MatchRecommendationLog[]
  appealsResolved         ReviewAppeal[]      @relation("AppealResolver")
  devices                 UserDevice[]
}

model UserConsentHistory {
  id           String   @id @default(uuid())
  userId       String
  user         User     @relation(fields: [userId], references: [id])
  consentType  String
  version      String
  termsUrl     String?
  documentHash String?
  acceptedAt   DateTime @default(now())
  ipAddress    String?
}

model CareRecipient {
  id               String   @id @default(uuid())
  customerId       String
  customer         User     @relation(fields: [customerId], references: [id])
  firstName        String
  lastName         String
  dateOfBirth      DateTime?
  gender           String?
  healthConditions Json?    // JSONB for medical history
  allergies        String[]
  createdAt        DateTime @default(now())
  updatedAt        DateTime @updatedAt
  
  bookings         Booking[]
}

model CaregiverProfile {
  id             String   @id @default(uuid())
  userId         String   @unique
  user           User     @relation(fields: [userId], references: [id])
  operatorId     String?  
  operator       User?    @relation("OperatorCaregivers", fields: [operatorId], references: [id])
  nationalId     String   @unique
  approvalStatus ApprovalStatus @default(PENDING)
  skills         String[] 
  serviceArea    String
  hourlyRate     Float
  ratingAvg      Float    @default(0.0)
  createdAt      DateTime @default(now())
  updatedAt      DateTime @updatedAt
  
  availabilities CaregiverAvailability[]
  certifications Certification[]
  bookings       Booking[]       @relation("CaregiverBookings")
  originalBookings Booking[]     @relation("OriginalCaregiver")
  matchLogs      MatchRecommendationLog[]
  appeals        ReviewAppeal[]
}

model LocationHistory {
  id        String   @default(uuid())
  userId    String
  user      User     @relation(fields: [userId], references: [id])
  latitude  Float
  longitude Float
  timestamp DateTime @default(now())

  @@id([id, timestamp])
}
// Note: LocationHistory is partitioned by RANGE (timestamp) in PostgreSQL. 
// Prisma currently has limited declarative support for native partitioning;
// implementation requires manual SQL for partition creation and retention policy.

model CaregiverAvailability {
  id                 String           @id @default(uuid())
  caregiverProfileId String
  caregiverProfile   CaregiverProfile @relation(fields: [caregiverProfileId], references: [id])
  dayOfWeek          DayOfWeek
  startTime          DateTime         @db.Time
  endTime            DateTime         @db.Time
}

model Certification {
  id                 String   @id @default(uuid())
  caregiverProfileId String?
  caregiverProfile   CaregiverProfile? @relation(fields: [caregiverProfileId], references: [id])
  nationalId         String
  name               String
  issuingInstituteId String   
  status             CertificationStatus @default(PENDING)
  fileUrl            String
  expiryDate         DateTime
  createdAt          DateTime @default(now())
  updatedAt          DateTime @updatedAt
}

model Booking {
  id                  String   @id @default(uuid())
  customerId          String
  customer            User     @relation("CustomerBookings", fields: [customerId], references: [id])
  careRecipientId     String
  careRecipient       CareRecipient @relation(fields: [careRecipientId], references: [id])
  caregiverId         String
  caregiver           CaregiverProfile @relation("CaregiverBookings", fields: [caregiverId], references: [id])
  serviceType         String
  locationAddress     String
  scheduledStart      DateTime
  scheduledEnd        DateTime
  checkInTime         DateTime?
  checkInLat          Float?
  checkInLng          Float?
  checkOutTime        DateTime?
  checkOutLat         Float?
  checkOutLng         Float?
  status              BookingStatus @default(PENDING)
  cancellationReason  String?
  cancelledBy         String?
  cancelledByUser     User?    @relation("CancelledByUser", fields: [cancelledBy], references: [id])
  cancellationFee     Float?
  originalCaregiverId String?
  originalCaregiver   CaregiverProfile? @relation("OriginalCaregiver", fields: [originalCaregiverId], references: [id])
  totalPrice          Float
  deletedAt           DateTime?
  createdAt           DateTime @default(now())
  updatedAt           DateTime @updatedAt
  
  transactions        Transaction[]
  careReport          CareReport?
  review              Review?
}

model Transaction {
  id              String   @id @default(uuid())
  bookingId       String   
  booking         Booking  @relation(fields: [bookingId], references: [id])
  externalRefId   String?  @unique
  transactionType TransactionType
  amount          Float
  commission      Float
  netAmount       Float
  status          TransactionStatus @default(PENDING)
  paymentMethod   String
  deletedAt       DateTime?
  createdAt       DateTime @default(now())
  updatedAt       DateTime @updatedAt
}

model CareReport {
  id            String   @id @default(uuid())
  bookingId     String   @unique
  booking       Booking  @relation(fields: [bookingId], references: [id])
  activities    Json     // JSONB task checklist
  mediaUrls     String[] 
  latitude      Float?   // Submit location
  longitude     Float?
  submittedAt   DateTime @default(now())
  deletedAt     DateTime?
}

model Review {
  id            String   @id @default(uuid())
  bookingId     String   @unique
  booking       Booking  @relation(fields: [bookingId], references: [id])
  customerId    String
  customer      User     @relation("CustomerReviews", fields: [customerId], references: [id])
  rating        Int      
  comment       String?
  isPublished   Boolean  @default(true) 
  createdAt     DateTime @default(now())
  
  appeal        ReviewAppeal?
}

model ReviewAppeal {
  id                 String   @id @default(uuid())
  reviewId           String   @unique
  review             Review   @relation(fields: [reviewId], references: [id])
  caregiverProfileId String
  caregiverProfile   CaregiverProfile @relation(fields: [caregiverProfileId], references: [id])
  reason             String
  status             ReviewAppealStatus @default(PENDING)
  resolvedBy         String?
  resolver           User?    @relation("AppealResolver", fields: [resolvedBy], references: [id])
  createdAt          DateTime @default(now())
  updatedAt          DateTime @updatedAt
}

model Notification {
  id            String   @id @default(uuid())
  userId        String
  user          User     @relation(fields: [userId], references: [id])
  type          String   
  message       String
  isRead        Boolean  @default(false)
  createdAt     DateTime @default(now())
}

model AuditLog {
  id            String   @id @default(uuid())
  userId        String
  user          User     @relation(fields: [userId], references: [id])
  action        String
  entity        String
  details       Json     
  createdAt     DateTime @default(now())
}

model SystemConfiguration {
  id            String   @id @default(uuid())
  key           String   @unique
  value         Json     
  updatedBy     String?
  updater       User?    @relation(fields: [updatedBy], references: [id])
  updatedAt     DateTime @updatedAt
}

model MatchRecommendationLog {
  id                 String   @id @default(uuid())
  customerId         String
  customer           User     @relation(fields: [customerId], references: [id])
  caregiverProfileId String
  caregiverProfile   CaregiverProfile @relation(fields: [caregiverProfileId], references: [id])
  score              Float
  reasoning          Json?    
  createdAt          DateTime @default(now())
}

model UserDevice {
  id            String   @id @default(uuid())
  userId        String
  user          User     @relation(fields: [userId], references: [id])
  deviceToken   String   @unique
  platform      String   
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt
}
```

## 4. Alternatives Considered
- **TypeORM**: Offers a similar feature set, but Prisma's declarative schema and auto-generated client are preferred for faster development and better type safety in the CareDee context.
- **Direct SQL**: While flexible, it lacks the developer productivity gains and structured migration management provided by Prisma.

## 5. Implementation Plan
1.  **Initialize Prisma**: Execute `npx prisma init` in the backend service directory.
2.  **Apply Schema**: Use the consolidated schema above to ensure all 16 tables and relationships are correctly defined.
3.  **Migrations**: Run `npx prisma migrate dev` to generate and apply the PostgreSQL schema.
4.  **Client Generation**: Generate the Prisma Client for use in the API controllers.

## 6. Verification
- **Relationship Integrity**: Verify that all foreign keys and relations (e.g., `originalCaregiverId` in Booking) correctly track data.
- **Security Validation**: Confirm `failedLoginAttempts` and `lockoutUntil` are present for UM-001 compliance.
- **JSONB Indexing**: Ensure complex types like `notificationPreferences` and `CareReport` activities are accessible and performant.

## 7. Migration & Rollback
Initial deployments will focus on a clean state. For future updates, Prisma Migrations will be used to track changes, with mandatory manual review of any `DROP` or `ALTER` commands to protect user data.
