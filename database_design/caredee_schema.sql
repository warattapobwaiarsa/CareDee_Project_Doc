-- CareDee Platform - PostgreSQL Schema
-- Generated from database-schema-plan.md

-- Extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- Enums
CREATE TYPE "Role" AS ENUM ('CUSTOMER', 'CAREGIVER', 'OPERATOR', 'ADMIN', 'TRAINING_INSTITUTE');
CREATE TYPE "AuthProvider" AS ENUM ('LOCAL', 'GOOGLE', 'FACEBOOK', 'LINE', 'APPLE');
CREATE TYPE "BookingStatus" AS ENUM ('PENDING', 'CONFIRMED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED');
CREATE TYPE "TransactionStatus" AS ENUM ('PENDING', 'SUCCESS', 'FAILED', 'REFUNDED');
CREATE TYPE "CertificationStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'REVOKED', 'EXPIRED');
CREATE TYPE "DayOfWeek" AS ENUM ('MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY');
CREATE TYPE "ApprovalStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');
CREATE TYPE "ReviewAppealStatus" AS ENUM ('PENDING', 'IN_REVIEW', 'RESOLVED', 'REJECTED');
CREATE TYPE "TransactionType" AS ENUM ('DEPOSIT', 'FINAL_PAYMENT', 'REFUND', 'RETRY', 'ADJUSTMENT');
CREATE TYPE "NotificationStatus" AS ENUM ('PENDING', 'SENT', 'FAILED');

-- Tables

CREATE TABLE "User" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "email" TEXT,
    "phone" TEXT,
    "role" "Role" NOT NULL,
    "firstName" TEXT NOT NULL,
    "lastName" TEXT NOT NULL,
    "avatarUrl" TEXT,
    "notificationPreferences" JSONB,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "deletedAt" TIMESTAMP WITH TIME ZONE,
    "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE "UserCredential" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "userId" UUID NOT NULL REFERENCES "User"("id") ON DELETE CASCADE,
    "authProvider" "AuthProvider" NOT NULL,
    "providerId" TEXT NOT NULL,
    "passwordHash" TEXT,
    "failedLoginAttempts" INTEGER NOT NULL DEFAULT 0,
    "lockoutUntil" TIMESTAMP WITH TIME ZONE,
    "deletedAt" TIMESTAMP WITH TIME ZONE,
    "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    CONSTRAINT "chk_local_password" CHECK ("authProvider" != 'LOCAL' OR "passwordHash" IS NOT NULL)
);

CREATE TABLE "UserConsentHistory" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "userId" UUID NOT NULL REFERENCES "User"("id") ON DELETE CASCADE,
    "consentType" TEXT NOT NULL,
    "version" TEXT NOT NULL,
    "termsUrl" TEXT,
    "documentHash" TEXT,
    "acceptedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    "ipAddress" TEXT
);

CREATE TABLE "CareRecipient" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "customerId" UUID NOT NULL REFERENCES "User"("id") ON DELETE CASCADE,
    "firstName" TEXT NOT NULL,
    "lastName" TEXT NOT NULL,
    "dateOfBirth" TIMESTAMP WITH TIME ZONE,
    "gender" TEXT,
    "healthConditions" JSONB,
    "allergies" TEXT[],
    "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE "CaregiverProfile" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "userId" UUID NOT NULL UNIQUE REFERENCES "User"("id") ON DELETE CASCADE,
    "operatorId" UUID REFERENCES "User"("id") ON DELETE SET NULL,
    "nationalId" TEXT NOT NULL UNIQUE, -- Application-level encryption recommended (SA-003)
    "approvalStatus" "ApprovalStatus" NOT NULL DEFAULT 'PENDING',
    "skills" TEXT[],
    "serviceArea" TEXT NOT NULL,
    "hourlyRate" DOUBLE PRECISION NOT NULL,
    "ratingAvg" DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE "LocationHistory" (
    "id" UUID DEFAULT gen_random_uuid(),
    "userId" UUID NOT NULL REFERENCES "User"("id") ON DELETE CASCADE,
    "location" GEOGRAPHY(POINT, 4326) NOT NULL,
    "timestamp" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    PRIMARY KEY ("id", "timestamp")
) PARTITION BY RANGE ("timestamp");

-- Example partitions (Declarative Partitioning - Monthly)
CREATE TABLE "LocationHistory_2026_05" PARTITION OF "LocationHistory"
    FOR VALUES FROM ('2026-05-01') TO ('2026-06-01');

CREATE TABLE "LocationHistory_2026_06" PARTITION OF "LocationHistory"
    FOR VALUES FROM ('2026-06-01') TO ('2026-07-01');

CREATE TABLE "CaregiverAvailability" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "caregiverProfileId" UUID NOT NULL REFERENCES "CaregiverProfile"("id") ON DELETE CASCADE,
    "dayOfWeek" "DayOfWeek" NOT NULL,
    "startTime" TIME NOT NULL,
    "endTime" TIME NOT NULL
);

CREATE TABLE "Certification" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "caregiverProfileId" UUID REFERENCES "CaregiverProfile"("id") ON DELETE CASCADE,
    "nationalId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "issuingInstituteId" UUID NOT NULL REFERENCES "User"("id"),
    "status" "CertificationStatus" NOT NULL DEFAULT 'PENDING',
    "fileUrl" TEXT NOT NULL,
    "expiryDate" TIMESTAMP WITH TIME ZONE NOT NULL,
    "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE "Booking" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "customerId" UUID NOT NULL REFERENCES "User"("id"),
    "careRecipientId" UUID NOT NULL REFERENCES "CareRecipient"("id"),
    "caregiverId" UUID NOT NULL REFERENCES "CaregiverProfile"("id"),
    "serviceType" TEXT NOT NULL,
    "locationAddress" TEXT NOT NULL,
    "locationGeog" GEOGRAPHY(POINT, 4326),
    "scheduledStart" TIMESTAMP WITH TIME ZONE NOT NULL,
    "scheduledEnd" TIMESTAMP WITH TIME ZONE NOT NULL,
    "checkInTime" TIMESTAMP WITH TIME ZONE,
    "checkInLocation" GEOGRAPHY(POINT, 4326),
    "checkOutTime" TIMESTAMP WITH TIME ZONE,
    "checkOutLocation" GEOGRAPHY(POINT, 4326),
    "status" "BookingStatus" NOT NULL DEFAULT 'PENDING',
    "cancellationReason" TEXT,
    "cancelledBy" UUID REFERENCES "User"("id"),
    "cancellationFee" DOUBLE PRECISION,
    "originalCaregiverId" UUID REFERENCES "CaregiverProfile"("id"),
    "totalPrice" DOUBLE PRECISION NOT NULL,
    "deletedAt" TIMESTAMP WITH TIME ZONE,
    "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE "Transaction" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "bookingId" UUID NOT NULL REFERENCES "Booking"("id"),
    "externalRefId" TEXT UNIQUE,
    "transactionType" "TransactionType" NOT NULL,
    "amount" DOUBLE PRECISION NOT NULL,
    "commission" DOUBLE PRECISION NOT NULL,
    "netAmount" DOUBLE PRECISION NOT NULL,
    "status" "TransactionStatus" NOT NULL DEFAULT 'PENDING',
    "paymentMethod" TEXT NOT NULL,
    "deletedAt" TIMESTAMP WITH TIME ZONE,
    "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE "CareReport" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "bookingId" UUID NOT NULL UNIQUE REFERENCES "Booking"("id"),
    "activities" JSONB NOT NULL,
    "mediaUrls" TEXT[],
    "location" GEOGRAPHY(POINT, 4326),
    "submittedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    "deletedAt" TIMESTAMP WITH TIME ZONE
);

CREATE TABLE "Review" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "bookingId" UUID NOT NULL UNIQUE REFERENCES "Booking"("id"),
    "customerId" UUID NOT NULL REFERENCES "User"("id"),
    "rating" INTEGER NOT NULL,
    "comment" TEXT,
    "isPublished" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE "Notification" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "userId" UUID NOT NULL REFERENCES "User"("id") ON DELETE CASCADE,
    "type" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "status" "NotificationStatus" NOT NULL DEFAULT 'PENDING',
    "retryCount" INTEGER NOT NULL DEFAULT 0,
    "lastRetryAt" TIMESTAMP WITH TIME ZONE,
    "isRead" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE "AuditLog" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "userId" UUID NOT NULL REFERENCES "User"("id"),
    "action" TEXT NOT NULL,
    "entity" TEXT NOT NULL,
    "details" JSONB NOT NULL, -- Recommended to store {before: {...}, after: {...}}
    "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE "SystemConfiguration" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "key" TEXT UNIQUE NOT NULL,
    "value" JSONB NOT NULL,
    "updatedBy" UUID REFERENCES "User"("id"),
    "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE "MatchRecommendationLog" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "customerId" UUID NOT NULL REFERENCES "User"("id"),
    "caregiverProfileId" UUID NOT NULL REFERENCES "CaregiverProfile"("id"),
    "score" DOUBLE PRECISION NOT NULL,
    "reasoning" JSONB,
    "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE "ReviewAppeal" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "reviewId" UUID NOT NULL UNIQUE REFERENCES "Review"("id") ON DELETE CASCADE,
    "caregiverProfileId" UUID NOT NULL REFERENCES "CaregiverProfile"("id") ON DELETE CASCADE,
    "reason" TEXT NOT NULL,
    "status" "ReviewAppealStatus" NOT NULL DEFAULT 'PENDING',
    "resolvedBy" UUID REFERENCES "User"("id"),
    "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE "UserDevice" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "userId" UUID NOT NULL REFERENCES "User"("id") ON DELETE CASCADE,
    "deviceToken" TEXT UNIQUE NOT NULL,
    "platform" TEXT NOT NULL,
    "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Functions & Triggers

CREATE OR REPLACE FUNCTION update_caregiver_rating()
RETURNS TRIGGER AS $$
DECLARE
    v_caregiver_id UUID;
BEGIN
    -- Identify the caregiver affected by this review
    SELECT "caregiverId" INTO v_caregiver_id 
    FROM "Booking" 
    WHERE id = COALESCE(NEW."bookingId", OLD."bookingId");
    
    -- Explicitly lock the caregiver profile row to ensure serialized calculation for this caregiver
    PERFORM 1 FROM "CaregiverProfile" WHERE id = v_caregiver_id FOR UPDATE;

    UPDATE "CaregiverProfile"
    SET "ratingAvg" = (
        SELECT COALESCE(AVG(r.rating), 0.0)
        FROM "Review" r
        JOIN "Booking" b ON r."bookingId" = b.id
        WHERE b."caregiverId" = v_caregiver_id
        AND r."isPublished" = true
    ),
    "updatedAt" = NOW()
    WHERE id = v_caregiver_id;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_caregiver_rating
AFTER INSERT OR UPDATE OR DELETE ON "Review"
FOR EACH ROW EXECUTE FUNCTION update_caregiver_rating();

-- Trigger to handle certification expiry (Pseudo-logic, usually handled by a cron/worker but can be partially automated)
CREATE OR REPLACE FUNCTION check_certification_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW."expiryDate" < NOW() THEN
        NEW."status" := 'EXPIRED';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_certification_expiry
BEFORE INSERT OR UPDATE ON "Certification"
FOR EACH ROW EXECUTE FUNCTION check_certification_status();

-- Indexes for performance
CREATE UNIQUE INDEX "idx_user_email_active" ON "User"("email") WHERE "deletedAt" IS NULL;
CREATE UNIQUE INDEX "idx_user_phone_active" ON "User"("phone") WHERE "deletedAt" IS NULL;
CREATE INDEX "idx_user_role" ON "User"("role");

-- UserCredential Indexes
CREATE UNIQUE INDEX "idx_credential_provider_active" ON "UserCredential"("authProvider", "providerId") WHERE "deletedAt" IS NULL;
CREATE UNIQUE INDEX "idx_credential_user_provider_active" ON "UserCredential"("userId", "authProvider") WHERE "deletedAt" IS NULL;
CREATE INDEX "idx_credential_login" ON "UserCredential"("authProvider", "providerId");
CREATE INDEX "idx_credential_user" ON "UserCredential"("userId");
CREATE INDEX "idx_caregiver_operator" ON "CaregiverProfile"("operatorId");
CREATE INDEX "idx_caregiver_service_area" ON "CaregiverProfile"("serviceArea");

-- Spatial Index for LocationHistory
CREATE INDEX "idx_location_history_geom" ON "LocationHistory" USING GIST ("location");

-- Booking Indexes
CREATE INDEX "idx_booking_customer" ON "Booking"("customerId") WHERE "deletedAt" IS NULL;
CREATE INDEX "idx_booking_caregiver" ON "Booking"("caregiverId") WHERE "deletedAt" IS NULL;
CREATE INDEX "idx_booking_scheduled_start" ON "Booking"("scheduledStart") WHERE "deletedAt" IS NULL;
CREATE INDEX "idx_booking_status" ON "Booking"("status") WHERE "deletedAt" IS NULL;
CREATE INDEX "idx_booking_active" ON "Booking"("id") WHERE "deletedAt" IS NULL;
CREATE INDEX "idx_booking_location" ON "Booking" USING GIST ("locationGeog");

-- Transaction Indexes
CREATE INDEX "idx_transaction_booking" ON "Transaction"("bookingId") WHERE "deletedAt" IS NULL;
CREATE UNIQUE INDEX "idx_transaction_external_ref" ON "Transaction"("externalRefId") WHERE "deletedAt" IS NULL;

-- CareReport Indexes
CREATE INDEX "idx_care_report_booking" ON "CareReport"("bookingId") WHERE "deletedAt" IS NULL;
CREATE INDEX "idx_care_report_location" ON "CareReport" USING GIST ("location");

-- Other Indexes
CREATE INDEX "idx_notification_user_unread" ON "Notification"("userId") WHERE "isRead" = false AND "status" != 'FAILED';
CREATE INDEX "idx_audit_log_user" ON "AuditLog"("userId");
CREATE INDEX "idx_audit_log_created_at" ON "AuditLog"("createdAt");
CREATE INDEX "idx_system_config_key" ON "SystemConfiguration"("key");
CREATE INDEX "idx_match_log_customer" ON "MatchRecommendationLog"("customerId");
CREATE INDEX "idx_match_log_caregiver" ON "MatchRecommendationLog"("caregiverProfileId");
CREATE INDEX "idx_review_appeal_status" ON "ReviewAppeal"("status");
CREATE INDEX "idx_user_device_user" ON "UserDevice"("userId");
