-- ============================================================
-- MediMate - Initial Database Schema
-- ============================================================
--
-- Core model:
--
-- profiles
--    ├── caregiver_relationships
--    ├── medications
--    │      ├── medication_schedules
--    │      └── dose_events
--    └── alerts
--
-- medicine_knowledge is global reference data and is intentionally
-- separate from patient-specific medications.
--
-- ============================================================


-- ============================================================
-- 1. PROFILES
-- ============================================================
-- Stores people using MediMate.
-- role:
--   elder
--   caregiver
--
-- For the MVP, profiles are independent from Supabase Auth.
-- Authentication can be connected later without changing the
-- medication data model.
-- ============================================================

CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    name TEXT NOT NULL,

    role TEXT NOT NULL
        CHECK (role IN ('elder', 'caregiver')),

    age INTEGER
        CHECK (age IS NULL OR age >= 0),

    language TEXT NOT NULL DEFAULT 'en',

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ============================================================
-- 2. CAREGIVER RELATIONSHIPS
-- ============================================================
-- Defines which caregiver is responsible for which elder.
--
-- One caregiver can manage multiple elders.
-- One elder can have multiple caregivers.
-- ============================================================

CREATE TABLE caregiver_relationships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    elder_id UUID NOT NULL
        REFERENCES profiles(id)
        ON DELETE CASCADE,

    caregiver_id UUID NOT NULL
        REFERENCES profiles(id)
        ON DELETE CASCADE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE (elder_id, caregiver_id),

    -- Prevent accidentally linking an elder to themselves.
    CHECK (elder_id <> caregiver_id)
);


-- ============================================================
-- 3. MEDICINE KNOWLEDGE
-- ============================================================
-- Global, verified reference information about medicines.
--
-- This is NOT patient-specific prescription data.
--
-- Example:
--   Metformin -> purpose, description, warnings, etc.
--
-- AI may use this table as verified context before generating
-- a simplified response.
-- ============================================================

CREATE TABLE medicine_knowledge (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    name TEXT NOT NULL UNIQUE,

    generic_name TEXT,

    purpose TEXT,

    simple_description TEXT,

    common_effects TEXT,

    warnings TEXT,

    food_instructions TEXT
);


-- ============================================================
-- 4. MEDICATIONS
-- ============================================================
-- Patient-specific medication records.
--
-- This answers:
-- "What medicine does this elder take?"
--
-- quantity = number of units taken per dose.
-- Example:
--   quantity = 1
--   form = 'tablet'
--   => take 1 tablet per scheduled dose.
-- ============================================================

CREATE TABLE medications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    elder_id UUID NOT NULL
        REFERENCES profiles(id)
        ON DELETE CASCADE,

    name TEXT NOT NULL,

    strength TEXT NOT NULL,

    form TEXT NOT NULL,

    quantity INTEGER NOT NULL
        CHECK (quantity > 0),

    purpose TEXT,

    instructions TEXT,

    image_url TEXT,

    start_date DATE NOT NULL,

    end_date DATE,

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- An end date cannot be before the start date.
    CHECK (
        end_date IS NULL
        OR end_date >= start_date
    )
);


-- ============================================================
-- 5. MEDICATION SCHEDULES
-- ============================================================
-- Defines WHEN a medication should be taken.
--
-- A medication may have multiple schedules.
--
-- Example:
--
-- Metformin
--   schedule 1 -> 08:00 -> every day
--   schedule 2 -> 20:00 -> every day
--
-- days is a PostgreSQL TEXT array:
--
-- {'mon','tue','wed','thu','fri'}
--
-- We deliberately do NOT store frequency.
-- The combination of time + days defines the schedule.
-- ============================================================

CREATE TABLE medication_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    medication_id UUID NOT NULL
        REFERENCES medications(id)
        ON DELETE CASCADE,

    time TIME NOT NULL,

    days TEXT[] NOT NULL,

    active BOOLEAN NOT NULL DEFAULT TRUE,

    -- Prevent invalid day names.
    CHECK (
        days <@ ARRAY[
            'mon',
            'tue',
            'wed',
            'thu',
            'fri',
            'sat',
            'sun'
        ]::TEXT[]
    ),

    -- A schedule must contain at least one day.
    CHECK (cardinality(days) > 0)
);


-- ============================================================
-- 6. DOSE EVENTS
-- ============================================================
-- Represents an individual occurrence of a scheduled dose.
--
-- Example:
--
-- medication:
--   Metformin
--
-- scheduled_time:
--   2026-09-26 20:00:00+05:30
--
-- status:
--   pending
--
-- Later:
--   status = taken
--   taken_at = 2026-09-26 20:07:00+05:30
--
-- IMPORTANT:
-- Backend lazily generates these rows when today's schedule
-- is requested.
--
-- UNIQUE(medication_id, scheduled_time) makes that operation
-- safe to repeat using INSERT ... ON CONFLICT DO NOTHING.
-- ============================================================

CREATE TABLE dose_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    medication_id UUID NOT NULL
        REFERENCES medications(id)
        ON DELETE CASCADE,

    scheduled_time TIMESTAMPTZ NOT NULL,

    status TEXT NOT NULL DEFAULT 'pending'
        CHECK (
            status IN (
                'pending',
                'taken',
                'missed',
                'skipped'
            )
        ),

    taken_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE (medication_id, scheduled_time),

    -- Only taken doses should have taken_at.
    CHECK (
        (status = 'taken' AND taken_at IS NOT NULL)
        OR
        (status <> 'taken' AND taken_at IS NULL)
    )
);


-- ============================================================
-- 7. ALERTS
-- ============================================================
-- Notifications that require caregiver attention.
--
-- Examples:
--
-- missed_dose:
--   related to a specific dose_event
--
-- health_concern:
--   may not be related to a dose event
-- ============================================================

CREATE TABLE alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    elder_id UUID NOT NULL
        REFERENCES profiles(id)
        ON DELETE CASCADE,

    dose_event_id UUID
        REFERENCES dose_events(id)
        ON DELETE SET NULL,

    type TEXT NOT NULL
        CHECK (
            type IN (
                'missed_dose',
                'health_concern'
            )
        ),

    title TEXT NOT NULL,

    message TEXT NOT NULL,

    severity TEXT NOT NULL
        CHECK (
            severity IN (
                'low',
                'medium',
                'high'
            )
        ),

    resolved BOOLEAN NOT NULL DEFAULT FALSE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ============================================================
-- INDEXES
-- ============================================================
-- These are the queries we know the application will perform
-- frequently.
-- ============================================================


-- Find medications belonging to an elder.
CREATE INDEX idx_medications_elder_id
    ON medications(elder_id);


-- Find schedules belonging to a medication.
CREATE INDEX idx_medication_schedules_medication_id
    ON medication_schedules(medication_id);


-- Find dose events for a medication.
CREATE INDEX idx_dose_events_medication_id
    ON dose_events(medication_id);


-- Find dose events by date/time.
CREATE INDEX idx_dose_events_scheduled_time
    ON dose_events(scheduled_time);


-- Find alerts for an elder.
CREATE INDEX idx_alerts_elder_id
    ON alerts(elder_id);


-- Find unresolved alerts efficiently.
CREATE INDEX idx_alerts_unresolved
    ON alerts(elder_id, resolved);


-- Find caregiver relationships.
CREATE INDEX idx_caregiver_relationships_elder_id
    ON caregiver_relationships(elder_id);

CREATE INDEX idx_caregiver_relationships_caregiver_id
    ON caregiver_relationships(caregiver_id);