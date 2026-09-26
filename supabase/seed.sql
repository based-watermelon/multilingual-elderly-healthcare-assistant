-- ============================================================
-- MediMate Demo Seed Data
-- ============================================================

-- ============================================================
-- 1. PROFILES
-- ============================================================

INSERT INTO profiles (
    id,
    name,
    role,
    age,
    language
)
VALUES
(
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'Eleanor',
    'elder',
    72,
    'en'
),
(
    'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    'James',
    'caregiver',
    45,
    'en'
);


-- ============================================================
-- 2. CAREGIVER RELATIONSHIP
-- ============================================================

INSERT INTO caregiver_relationships (
    elder_id,
    caregiver_id
)
VALUES (
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22'
);


-- ============================================================
-- 3. MEDICINE KNOWLEDGE
-- ============================================================
-- Demo/reference information.
--
-- Keep this conservative because this data is eventually
-- provided as context to the AI.
-- ============================================================

INSERT INTO medicine_knowledge (
    name,
    generic_name,
    purpose,
    simple_description,
    common_effects,
    warnings,
    food_instructions
)
VALUES
(
    'Metformin',
    'Metformin',
    'Helps control blood sugar levels.',
    'Metformin is commonly used to help manage blood sugar in people with type 2 diabetes.',
    'Nausea, diarrhea, stomach discomfort.',
    'Seek medical advice for severe or unusual symptoms.',
    'Often taken with food to reduce stomach discomfort.'
),
(
    'Amlodipine',
    'Amlodipine',
    'Helps lower blood pressure.',
    'Amlodipine is commonly used to help control high blood pressure.',
    'Swelling, dizziness, headache.',
    'Seek medical advice for severe dizziness or unusual symptoms.',
    'Can generally be taken with or without food.'
),
(
    'Vitamin D',
    'Vitamin D',
    'Helps maintain healthy bones and supports normal body functions.',
    'Vitamin D is a nutrient that helps the body absorb calcium and supports bone health.',
    'Usually well tolerated at recommended doses.',
    'Do not take more than the recommended amount unless advised by a healthcare professional.',
    'Follow the instructions provided by the caregiver or healthcare professional.'
);


-- ============================================================
-- 4. MEDICATIONS
-- ============================================================

INSERT INTO medications (
    id,
    elder_id,
    name,
    strength,
    form,
    quantity,
    purpose,
    instructions,
    image_url,
    start_date,
    end_date,
    active
)
VALUES
(
    'c1000000-0000-4000-8000-000000000001',
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'Metformin',
    '500 mg',
    'tablet',
    1,
    'Blood sugar control',
    'Take after food.',
    NULL,
    CURRENT_DATE,
    NULL,
    TRUE
),
(
    'c1000000-0000-4000-8000-000000000002',
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'Amlodipine',
    '5 mg',
    'tablet',
    1,
    'Blood pressure control',
    'Take once daily.',
    NULL,
    CURRENT_DATE,
    NULL,
    TRUE
),
(
    'c1000000-0000-4000-8000-000000000003',
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'Vitamin D',
    '1000 IU',
    'tablet',
    1,
    'Vitamin D supplementation',
    'Take once daily.',
    NULL,
    CURRENT_DATE,
    NULL,
    TRUE
);


-- ============================================================
-- 5. MEDICATION SCHEDULES
-- ============================================================

-- Metformin at 08:00 every day.
INSERT INTO medication_schedules (
    medication_id,
    time,
    days,
    active
)
VALUES (
    'c1000000-0000-4000-8000-000000000001',
    '08:00:00',
    ARRAY['mon','tue','wed','thu','fri','sat','sun'],
    TRUE
);


-- Metformin at 20:00 every day.
INSERT INTO medication_schedules (
    medication_id,
    time,
    days,
    active
)
VALUES (
    'c1000000-0000-4000-8000-000000000001',
    '20:00:00',
    ARRAY['mon','tue','wed','thu','fri','sat','sun'],
    TRUE
);


-- Amlodipine at 09:00 every day.
INSERT INTO medication_schedules (
    medication_id,
    time,
    days,
    active
)
VALUES (
    'c1000000-0000-4000-8000-000000000002',
    '09:00:00',
    ARRAY['mon','tue','wed','thu','fri','sat','sun'],
    TRUE
);


-- Vitamin D at 13:00 every day.
INSERT INTO medication_schedules (
    medication_id,
    time,
    days,
    active
)
VALUES (
    'c1000000-0000-4000-8000-000000000003',
    '13:00:00',
    ARRAY['mon','tue','wed','thu','fri','sat','sun'],
    TRUE
);