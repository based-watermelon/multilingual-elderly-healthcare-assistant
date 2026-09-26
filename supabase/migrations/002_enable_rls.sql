-- ============================================================
-- MediMate - Enable Row Level Security
-- ============================================================
--
-- The mobile application does NOT access the database directly.
-- Application data access goes through FastAPI.
--
-- FastAPI will use Supabase's server-side secret/service key,
-- which bypasses RLS.
--
-- Enabling RLS here prevents accidental public/anon access
-- through the Supabase Data API.
-- ============================================================


ALTER TABLE public.profiles
ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.caregiver_relationships
ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.medicine_knowledge
ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.medications
ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.medication_schedules
ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.dose_events
ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.alerts
ENABLE ROW LEVEL SECURITY;